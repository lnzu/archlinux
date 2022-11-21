#!/bin/bash

# 时区设置
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 设置 Locale 进行本地化
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8'  > /etc/locale.conf


# 置主机名
read -p "iput the hostname: " hostname
echo ${host_name} > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}
EOF

echo "set the root passwd"
# 为 root 用户设置密码
passwd root

# 安装引导程序

pacman -S grub efibootmgr

read -p "set the grub install partion: " grub_dir

grub-install --recheck ${grub_dir}

# 生成 grubconfig 文件
grub-mkconfig -o /boot/grub/grub.cfg

# 添加用户
read -p "add a user: " user

useradd -m -G wheel -s /bin/bash ${user}
echo "please set the ${user} passwd"
passwd ${user}

# 设置自动启动程序
systemctl enable dhcpcd
systemctl enable NetworkManager
systemctl enable sshd

# 完成安装
echo "Archliux install done!"



