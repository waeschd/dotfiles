#!/usr/bin/env bash

# ----- Bash options ----- #
set -eu -o pipefail

# Define colors
COLOR_RED='\033[0;31m'
COLOR_LBLUE='\033[1;36m'
COLOR_RESET='\033[0m'

# Error handling function
on_error() {
    local line=$1
    local code=$2
    echo ""
    echo "----------------------------------------------------"
    echo -e "  ${COLOR_RED}FATAL ERROR:${COLOR_RESET} Command '$BASH_COMMAND' failed"
    echo "  Line: $line"
    echo "  Exit Code: $code"
    echo "----------------------------------------------------"
}

trap 'on_error $LINENO $?' ERR


# ----- Helper Functions ----- #

# Function to convert input (e.g., 8G or 512M) to MiB
to_mib() {
    local val=$1
    local num=${val%[MG]}
    local unit=${val: -1}
    if [[ "$unit" == "G" ]]; then
        echo $(( num * 1024 ))
    else
        echo "$num"
    fi
}

# Unmount everything under /mnt recursively and forcefully
cleanup_mounts() {
    if mountpoint -q /mnt; then
        umount -Rf /mnt || true
    fi

    # 2. Turn off swap if it's active on the VG
    swapoff -a || true

    # 3. Deactivate LVM Volume Groups to unlock the disk
    if vgdisplay vg_nixos >/dev/null 2>&1; then
        vgchange -an vg_nixos || true
    fi

    # 4. Close LUKS container if it's open
    if [ -b /dev/mapper/cryptmain ]; then
        cryptsetup close cryptmain || true
    fi
}


# ----- Main Logic ----- #

pre_flight_checks() {
    if [[ $EUID -ne 0 ]]; then
      echo "Error: This script must be run as root user."
       exit 1
    fi
}


gather_user_input() {
    # 1. Select Disk
    echo "Listing available disks:"
    lsblk -d -n -o NAME,SIZE,MODEL | grep -v "loop"
    echo ""

    # Prompt user for just the name
    read -p "Enter the disk name (e.g., sda or nvme0n1): " DISK_INPUT

    # Clean the input: Remove /dev/ if the user typed it anyway, then prepend /dev/
    # This makes the script "dummy-proof" for both styles of input
    DISK_NAME="/dev/${DISK_INPUT#/dev/}"

    if [[ ! -b "$DISK_NAME" ]]; then
        echo "Error: Device $DISK_NAME not found."
        exit 1
    fi

    # Calculate total available space in MiB for more precision
    TOTAL_BYTES=$(blockdev --getsize64 "$DISK_NAME")
    TOTAL_MIB=$(( TOTAL_BYTES / 1024 / 1024 ))
    TOTAL_GIB=$(( TOTAL_MIB / 1024 ))
    EFI_MIB=1024 # 1GiB
    AVAIL_LVM_MIB=$(( TOTAL_MIB - EFI_MIB ))

    echo ""
    echo "--- Disk Space Overview ---"
    echo "Total Disk Size: ${TOTAL_GIB}G"
    echo "Reserved: 1G for EFI Partition"
    echo "Available for LVM (Swap + Root + Home): $(( AVAIL_LVM_MIB / 1024 ))G"
    echo "---------------------------"

    # 2. Encryption Choice
    read -p "Enable LUKS encryption? (y/N): " USE_ENC
    USE_ENC=${USE_ENC:-n}

    # 3. Get Sizes
    echo ""
    echo "Partition Sizes: Enter a number followed by 'M' or 'G' (e.g., 8G, 512M)."
    while true; do
        read -p "Enter SWAP size: " SWAP_SIZE
        if [[ $SWAP_SIZE =~ ^[0-9]+[MG]$ ]]; then break; fi
        echo "Invalid format. Try again."
    done

    while true; do
        echo "Note: The remaining space will be automatically used for HOME."
        read -p "Enter ROOT size: " ROOT_SIZE
        if [[ $ROOT_SIZE =~ ^[0-9]+[MG]$ ]]; then break; fi
        echo "Invalid format. Try again."
    done

    SWAP_MIB=$(to_mib "$SWAP_SIZE")
    ROOT_MIB=$(to_mib "$ROOT_SIZE")
    HOME_MIB=$(( AVAIL_LVM_MIB - SWAP_MIB - ROOT_MIB ))
    HOME_GIB_DISPLAY=$(( HOME_MIB / 1024 ))

    # Check for negative space
    if [ "$HOME_MIB" -le 0 ]; then
        echo "FATAL ERROR: The sum of Swap and Root exceeds available disk space!"
        exit 1
    fi

    # 4. Label Customization
    echo ""
    echo "--- Label Configuration ---"
    echo "Enter label name or press Enter to use the default."

    read -p "Boot Partition Label [Default: NixOS-Boot]: " L_BOOT
    L_BOOT=${L_BOOT:-NixOS-Boot}

    read -p "Root Partition Label [Default: NixOS-Root]: " L_ROOT
    L_ROOT=${L_ROOT:-NixOS-Root}

    read -p "Home Partition Label [Default: NixOS-Home]: " L_HOME
    L_HOME=${L_HOME:-NixOS-Home}

    read -p "Swap Partition Label [Default: NixOS-Swap]: " L_SWAP
    L_SWAP=${L_SWAP:-NixOS-Swap}

    L_LUKS="NixOS-Encrypted"
    if [[ "$USE_ENC" =~ ^[Yy]$ ]]; then
        read -p "LUKS Container Label [Default: NixOS-Encrypted]: " L_LUKS
        L_LUKS=${L_LUKS:-NixOS-Encrypted}
    fi

    # Confirmation
    echo ""
    echo "----------------------------------------------------"
    echo "TARGET DISK: $DISK_NAME"
    echo "ENCRYPTION:  ${USE_ENC^^}"
    echo "BOOT SIZE:   1G"
    echo "SWAP SIZE:   $SWAP_SIZE"
    echo "ROOT SIZE:   $ROOT_SIZE"
    echo "HOME SIZE:   ~${HOME_GIB_DISPLAY}G (Remainder)"
    echo ""
    echo "BOOT LABEL:  $L_BOOT"
    echo "ROOT LABEL:  $L_ROOT"
    echo "HOME LABEL:  $L_HOME"
    echo "SWAP LABEL:  $L_SWAP"
    if [[ "$USE_ENC" =~ ^[Yy]$ ]]; then
        echo "LUKS LABEL:  $L_LUKS"
    fi
    echo "----------------------------------------------------"
    echo "WARNING: This will ERASE ALL DATA on $DISK_NAME."
    read -p "Are you sure you want to continue? (y/N): " CONFIRM
    if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi

    # Check for negative space
    if [ "$HOME_MIB" -le 0 ]; then
        echo "FATAL ERROR: The sum of Swap and Root exceeds available disk space!"
        exit 1
    fi
}


partition_disk() {
    echo "Partitioning disk ..."
    wipefs -a "$DISK_NAME" > /dev/null
    sgdisk -Z "$DISK_NAME" > /dev/null
    sgdisk -o "$DISK_NAME" > /dev/null
    sgdisk -n 1:0:+1G -t 1:ef00 "$DISK_NAME" > /dev/null
    sgdisk -n 2:0:0   -t 2:8e00 "$DISK_NAME" > /dev/null

    partprobe "$DISK_NAME" > /dev/null
    sleep 2

    # Handle NVMe/SATA naming
    PART_SUFFIX=""
    [[ $DISK_NAME == *"/dev/nvme"* ]] && PART_SUFFIX="p"
    BOOT_PART="${DISK_NAME}${PART_SUFFIX}1"
    LVM_PART="${DISK_NAME}${PART_SUFFIX}2"
}


setup_encryption_and_lvm() {
    LVM_SOURCE="$LVM_PART"

    if [[ "$USE_ENC" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Setting up LUKS Encryption..."
        cryptsetup luksFormat \
            --type luks2 \
            --iter-time 10000 --key-size 256 \
            --batch-mode --verify-passphrase \
            --label="$L_LUKS" "$LVM_PART"

        echo "Opening LUKS container..."
        cryptsetup luksOpen "$LVM_PART" cryptmain
        LVM_SOURCE="/dev/mapper/cryptmain"
    fi

    # ----- LVM Setup ----- #
    echo ""
    echo "Setting up LVM..."
    # 1. Cleanup
    wipefs -a "$LVM_SOURCE" > /dev/null

    # 2. Create
    pvcreate -f "$LVM_SOURCE" > /dev/null
    vgcreate vg_nixos "$LVM_SOURCE" > /dev/null

    lvcreate -y -L"$SWAP_SIZE" vg_nixos -n swap > /dev/null
    lvcreate -y -L"$ROOT_SIZE" vg_nixos -n root > /dev/null
    lvcreate -y -l 100%FREE    vg_nixos -n home > /dev/null
}


format_and_mount() {
    echo ""
    # 1. Format
    echo "Creating filesystems..."
    mkfs.fat  -n "$L_BOOT" -F32 "$BOOT_PART" &> /dev/null
    mkfs.ext4 -L "$L_ROOT" /dev/mapper/vg_nixos-root &> /dev/null
    mkfs.ext4 -L "$L_HOME" /dev/mapper/vg_nixos-home &> /dev/null
    mkswap    -L "$L_SWAP" /dev/mapper/vg_nixos-swap &> /dev/null

    # 2. Mount
    mount "/dev/disk/by-label/$L_ROOT" /mnt

    mkdir -p /mnt/boot
    mount -o umask=077 "/dev/disk/by-label/$L_BOOT" /mnt/boot

    mkdir -p /mnt/home
    mount "/dev/disk/by-label/$L_HOME" /mnt/home

    swapon "/dev/disk/by-label/$L_SWAP"
}



perform_installation() {
    echo ""
    nixos-generate-config --root /mnt

    echo ""
    echo -e "${COLOR_LBLUE}Starting interactive shell at '/mnt/etc/nixos/'."
    echo -e "Please modify configuration files if needed. Also if a local flake install is intended, provide 'flake.nix'.${COLOR_RESET}"
    echo ""
    ( cd /mnt/etc/nixos && bash )  # Using a subshell to keep the main script's path stable


    echo ""
    echo "--- NixOS Installation ---"

    # Loop until a valid selection is made
    while true; do
        echo "1) Standard"
        echo "2) Flake (Local)"
        echo "3) Flake (Remote)"
        read -p "Select installation method [1-3]: " INST_METHOD

        case $INST_METHOD in
            1)
                echo "Running standard installation..."
                nixos-install --no-root-passwd --max-jobs 8
                break
                ;;
            2)
                read -p "Enter Flake Configuration Name: " FLAKE_NAME
                echo "Installing from /mnt/etc/nixos#$FLAKE_NAME..."

                # Move into the config directory
                pushd /mnt/etc/nixos > /dev/null

                # Create lock file if it does not exist.
                if [[ ! -f "flake.lock" ]]; then
                    nix --extra-experimental-features 'nix-command flakes' flake update
                fi

                nixos-install --flake ".#$FLAKE_NAME" --no-root-passwd --max-jobs 8

                popd > /dev/null
                break
                ;;
            3)
                read -p "Enter Flake Configuration Name: " FLAKE_NAME
                read -p "Enter Remote Flake Path (e.g., github:user/repo): " REMOTE_PATH
                echo "Installing from $REMOTE_PATH#$FLAKE_NAME..."
                nixos-install --flake "${REMOTE_PATH}#${FLAKE_NAME}" --no-root-passwd --max-jobs 8
                break
                ;;
            *)
                echo "Invalid selection: '$INST_METHOD'. Please choose 1, 2, or 3."
                echo ""
                ;;
        esac
    done
}


set_user_passwords() {
    echo ""
    echo "--- User Account Setup ---"
    echo "Set passwords for your users (e.g., root, yourname)."
    echo "Press [ENTER] without typing a name to finish."

    while true; do
        echo ""
        read -p "Username to configure: " TARGET_USER

        # Break loop if input is empty
        if [[ -z "$TARGET_USER" ]]; then
            break
        fi

        # Check if the user exists within the target filesystem
        if sudo nixos-enter --silent --root /mnt -c "getent passwd $TARGET_USER" &> /dev/null; then
            sudo nixos-enter --silent --root /mnt -c "passwd $TARGET_USER"
        else
            echo -e "${COLOR_RED}Error:${COLOR_RESET} User '$TARGET_USER' not found in /etc/passwd."
        fi
    done
}


# ----- Main Execution ----- #

main() {
    pre_flight_checks
    cleanup_mounts
    gather_user_input
    partition_disk
    setup_encryption_and_lvm
    format_and_mount
    perform_installation
    set_user_passwords
    cleanup_mounts

    echo "----------------------------------------------------"
    echo "Installation complete. Reboot whenever you're ready!"
    echo "----------------------------------------------------"
}

main "$@"
