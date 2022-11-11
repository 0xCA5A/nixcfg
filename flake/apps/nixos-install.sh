# shellcheck disable=SC1091
source @bashLib@

# Source: https://qfpl.io/posts/installing-nixos/

### Gather system info

readonly HOSTNAME="${1}"
readonly DISK="${2}"

# Validate arguments

test "${HOSTNAME}" || {
    # shellcheck disable=SC2016
    echo '$HOSTNAME is not given!'
    exit 1
}

NUM_SUPPORTED_DISKS=$(echo "${DISK}" | grep -P "^/dev/(sd[a-z]|nvme[0-9]n[1-9])$" -c)
readonly NUM_SUPPORTED_DISKS

[[ ${NUM_SUPPORTED_DISKS} -gt 0 ]] || {
    # shellcheck disable=SC2016
    echo '$DISK is not of format "/dev/sda" or "/dev/nvme0n1"!'
    exit 1
}

NUM_NVME_DISKS=$(echo "${DISK}" | grep "^/dev/nvme" -c)
readonly NUM_NVME_DISKS

is_nvme_disk() {
    [[ ${NUM_NVME_DISKS} -gt 0 ]]
}

get_partition() {
    if is_nvme_disk; then
        echo "${DISK}p${1}"
    else
        echo "${DISK}${1}"
    fi
}

BOOT_PARTITION="$(get_partition 1)"
readonly BOOT_PARTITION
ROOT_PARTITION="$(get_partition 2)"
readonly ROOT_PARTITION


### Declare functions

readonly ROOT_CRYPT="root-crypt"
readonly BOOT_FS="boot"
readonly ROOT_FS="root"
readonly MOUNT_ROOT="/mnt"

partition() {
    _log "[partition] Deleting partitions..."
    dd if=/dev/zero of="${DISK}" bs=512 count=1 conv=notrunc status=progress

    _log "[partition] Creating partition table..."
    parted "${DISK}" mklabel gpt
    parted "${DISK}" mkpart "boot" fat32 0% 1GiB
    parted "${DISK}" set 1 esp on
    parted "${DISK}" mkpart "root" ext4 1GiB 100%

    _log "[partition] Result of partitioning:"
    fdisk "${DISK}" -l
}

crypt_setup() {
    _log "[crypt_setup] Encrypting LVM partition..."
    cryptsetup luksFormat "${ROOT_PARTITION}"
    cryptsetup luksOpen "${ROOT_PARTITION}" "${ROOT_CRYPT}"
}

create_filesystems() {
    _log "[create_filesystems] Creating filesystems..."
    mkfs.vfat -n "${BOOT_FS}" "${BOOT_PARTITION}"
    mkfs.btrfs -L "${ROOT_FS}" "/dev/mapper/${ROOT_CRYPT}"

    _log "[create_filesystems] Creating sub volumes"
    mount "/dev/disk/by-label/${ROOT_FS}" "${MOUNT_ROOT}"
    btrfs subvolume create "${MOUNT_ROOT}/@"
    btrfs subvolume create "${MOUNT_ROOT}/@home"
    btrfs subvolume create "${MOUNT_ROOT}/@nix"
    btrfs subvolume create "${MOUNT_ROOT}/@swap"
    umount "${MOUNT_ROOT}"

    _log "[create_filesystems] Result of filesystems creation:"
    lsblk -f "${DISK}"
}

decrypt_volumes() {
    _log "[decrypt_volumes] Decrypting volumes..."
    cryptsetup luksOpen "${ROOT_PARTITION}" "${ROOT_CRYPT}"

    _log "[decrypt_volumes] Volumes decrypted:"
    lsblk -f "${DISK}"
}

mount_filesystems() {
    _log "[mount_filesystems] Mounting file systems..."
    mount -o noatime,compress=lzo,subvol=@ "/dev/disk/by-label/${ROOT_FS}" "${MOUNT_ROOT}"
    mkdir -p "${MOUNT_ROOT}/{home,nix,swap}"
    mount -o noatime,compress=lzo,subvol=@home "/dev/disk/by-label/${ROOT_FS}" "${MOUNT_ROOT}/home"
    mount -o noatime,compress=zstd,subvol=@nix "/dev/disk/by-label/${ROOT_FS}" "${MOUNT_ROOT}/nix"
    mount -o subvol=@swap "/dev/disk/by-label/${ROOT_FS}" "${MOUNT_ROOT}/swap"

    local mount_boot="${MOUNT_ROOT}/boot"
    mkdir -p "${mount_boot}"
    mount "${BOOT_PARTITION}" "${mount_boot}"

    _log "[mount_filesystems] File systems mounted:"
    findmnt --real
}

enable_swap() {
    local swap_dir="${MOUNT_ROOT}/swap"
    local swap_file="${swap_dir}/swapfile"

    _log "[create_filesystems] Creating swap file..."
    touch "${swap_file}"
    chattr +C "${swap_file}"
    dd if=/dev/zero of="${swap_file}" bs=1M count=4096
    chmod 0600 "${swap_file}"
    mkswap "${swap_file}"

    _log "[enable_swap] Enabling swap..."
    swapon -v "${swap_file}"
}

install() {
    _log "[install] Installing NixOS..."
    nixos-install --root "${MOUNT_ROOT}" --flake "github:christianharke/nixcfg#${HOSTNAME}" --impure
    _log "[install] Installing NixOS... finished!"

    _log "[install] Installation finished, please reboot and remove installation media..."
}


### Pull the trigger

if _read_boolean "Do you want to DELETE ALL PARTITIONS?" N; then
    partition
    crypt_setup
    create_filesystems
fi

CRYPT_VOL_STATUS="$(cryptsetup -q status "${ROOT_CRYPT}")"
readonly CRYPT_VOL_STATUS
CRYPT_VOL_NUM_ACTIVE=$(echo "${CRYPT_VOL_STATUS}" | grep "^/dev/mapper/${ROOT_CRYPT} is active and is in use.$" -c)
readonly CRYPT_VOL_NUM_ACTIVE
if [[ ${CRYPT_VOL_NUM_ACTIVE} -lt 1 ]]; then
    decrypt_volumes
fi

if _read_boolean "Do you want to INSTALL NixOS now?" N; then
    mount_filesystems
    enable_swap
    install
fi

