#!/bin/bash

part_root="/dev/sda2"
part_efi="/dev/sda1"
part_swap=""


# 再次确认efi分区
read -p "efi partion is \"${part_efi}\" [y/n]: " check_efi
if [ "$check_efi" == "n" ];
then
    exit
fi

# 再次确认/分区
read -p "root partion is \"${part_root}\" [y/n]: " check_root
if [ "$check_root" == "n" ];
then
    exit
fi

# 换源
cat > /etc/pacman.d/mirrorlist << EOF
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch
EOF

pacman -Syy

# 是否需要格式化efi载分区
read -p  "format the efi partion (y/n): " clear_efi
 
if [ "$clear_efi" == "y" ];
then
    mkfs.fat -F32 ${part_efi}
fi


# 格式化"/"分区
mkfs.ext4 ${part_root}

# 自动判断是否启用swap分区
if [ "${part_swap}" ] 
then
    # 判断是否处理swap分区
    read -p "swap partion is \"${part_swap}\" [y/n]: " check_swap
    if [ "$check_swap" == "n" ];
    then
        exit
    else
        mkswap ${part_swap} -L Swap
        swapon ${part_swap}
    fi

fi


# 挂载分区
mount ${part_root} /mnt
mkdir -p /mnt/boot/EFI
mount ${part_efi} /mnt/boot/EFI

# 安装系统
pacstrap /mnt base base-devel linux linux-headers linux-firmware
pacstrap /mnt dhcpcd iwd vim bash-completion wget curl unzip openssh networkmanager

# 生成 fstab 文件
genfstab -U /mnt >> /mnt/etc/fstab

cp ./arch-root.sh /mnt
chmod +x /mnt/arch-root.sh

# change root
arch-chroot /mnt /bin/bash -c "./arch-root.sh"

