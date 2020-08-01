# 无人值守Linux安装镜像制作

## 一、实验环境:

Ubuntu 18.04.04 Server 64bit

## 二、实验过程：

1. ssh远程连接虚拟机作为实验机

   ![](https://raw.githubusercontent.com/wanghaoxu001/cloudimg/master/img/20200801231606.png)

2. 在当前用户目录下创建一个用于挂载iso镜像文件的目录

   `****@ubuntu:~/cd$ mkdir loopdir`

3. 把宿主机的iso镜像文件上传至实验机

   `sftp ****@实验机ip   `

   `sftp> put [本地路径] [远程路径]`

4. 挂载iso镜像文件到该目录

   `****@ubuntu:~/cd$ sudo mount -o loop ubuntu-18.04.4-server-amd64.iso loopdir`

5. 创建一个工作目录用于克隆光盘内容

   `****@ubuntu:~/cd$ mkdir cd`

6. 同步光盘内容到目标工作目录

   `****@ubuntu:~/cd$ sudo rsync -av loopdir/ cd`	

7. 卸载iso镜像

   `****@ubuntu:~/cd$ sudo umount loopdir`

8. 进入目标工作目录

   `****@ubuntu:~/cd$ cd cd/`

9. 编辑Ubuntu安装引导界面增加一个新菜单项入口

   `****@ubuntu:~/cd$ sudo vim isolinux/txt.cfg`

   添加以下内容到该文件后强制保存退出

   `label autoinstall  menu label ^Auto Install Ubuntu Server  kernel /install/vmlinuz  append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet`

   ![](https://raw.githubusercontent.com/wanghaoxu001/cloudimg/master/img/20200801231604.png)

10. 下载修改定制好的ubuntu-server-autoinstall.seed到工作目录:~/cd/preseed

   `****@ubuntu:~/cd/preseed$ sudo wget https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x01/cd-rom/preseed/ubuntu-server-autoinstall.seed`

11. 修改isolinux/isolinux.cfg，增加内容timeout 10

    `****@ubuntu:~/cd$ sudo vim isolinux/isolinux.cfg`

    ![](https://raw.githubusercontent.com/wanghaoxu001/cloudimg/master/img/20200801231603.png)

12. 切换到 root 用户身份

    `sudo su -`

13. 重新生成md5sum.txt

    `root@ubuntu:~# cd "/home/****/cd" && find . -type f -print0 | xargs -0 md5sum > md5sum.txt`

14. 封闭改动后的目录到.iso

    `root@ubuntu:/home/****/cd# IMAGE=custom.iso`
    `root@ubuntu:/home/****/cd# BUILD="$HOME/cd/"`

    `#安装软件前挂起代理`

    `export https_proxy=http://127.0.0.1:** http_proxy=http://127.0.0.1:** all_proxy=socks5://127.0.0.1:**`
    `root@ubuntu:/home/****/cd# apt update && apt install -y genisoimage`

    ``root@ubuntu:/home/****/cd# genisoimage -r -V "Custom Ubuntu Install CD" \
    \> -cache-inodes \
    \> -J -l -b isolinux/isolinux.bin \
    \> -c isolinux/boot.cat -no-emul-boot \
    \> -boot-load-size 4 -boot-info-table \
    \> -o $IMAGE $BUILD``

    ![](https://raw.githubusercontent.com/wanghaoxu001/cloudimg/master/img/20200801231605.png)

## 实验中遇到的问题及其解决

1. 切换到 root 用户身份后, 运行命令:

   `cd "$HOME/cd" && find . -type f -print0 | xargs -0 md5sum > md5sum.txt`

   失败, 提示:root@localhost's password:localhost:permission denied,please try again

   搜索后发现是因为禁止了root用户ssh登陆

   解决方法:

   1. 修改root密码

   2. 辑配置文件，允许以 root 用户通过 ssh 登录

      `sudo vi /etc/ssh/sshd_config`

      修改：PermitRootLogin yes

   3. 重启ssh服务

      `sudo service ssh restart`

2. 之后运行该命令依然失败,提示找不到名为cd的目录

   搜索后发现`$HOME`是指定当前用户的主目录的环境变量, 别名是`~`

   于是尝试直接把命令改为:

   `root@ubuntu:~# cd "/home/****/cd" && find . -type f -print0 | xargs -0 md5sum > md5sum.txt`

   运行成功

## 使用diff命令进行seed文件对比

1. 注释系统发行版本不同

   > \#### Contents of the preconfiguration file (for stretch)   |	#### Contents of the preconfiguration file (for xenial)

   [Debian发行版列表](https://zh.wikipedia.org/wiki/Debian#发行版本)  [Ubuntu发行版列表](https://zh.wikipedia.org/wiki/Ubuntu发行版列表)

2. 指定语言

   > #d-i localechooser/supported-locales multiselect en_US.UTF-8,	#d-i localechooser/supported-locales multiselect en_US.UTF-8,
   >
   > ​							   >	d-i localechooser/supported-locales multiselect en_US.UTF-8, 
   >
   > ​							   >
   >
   > ​							   >	# http://askubuntu.com/questions/129651/how-do-i-configure-a-
   >
   > ​							   >	d-i pkgsel/install-language-support boolean false

3. 修改网络配置等待时间

   > #d-i netcfg/link_wait_timeout string 10			   |	d-i netcfg/link_wait_timeout string 5

   > -i netcfg/dhcp_timeout string 60			   |	d-i netcfg/dhcp_timeout string 5

4. 配置网络

   > \#d-i netcfg/disable_autoconfig boolean true		   |	d-i netcfg/disable_autoconfig boolean true

   > \# IPv4 example							# IPv4 example
   >
   > \#d-i netcfg/get_ipaddress string 192.168.1.42		   |	d-i netcfg/get_ipaddress string 192.168.138.42
   >
   > \#d-i netcfg/get_netmask string 255.255.255.0		   |	d-i netcfg/get_netmask string 255.255.255.0
   >
   > \#d-i netcfg/get_gateway string 192.168.1.1		   |	d-i netcfg/get_gateway string 192.168.138.1
   >
   > \#d-i netcfg/get_nameservers string 192.168.1.1		   |	d-i netcfg/get_nameservers string 192.168.138.1
   >
   > \#d-i netcfg/confirm_static boolean true			   |	d-i netcfg/confirm_static boolean true

   > d-i netcfg/get_hostname string unassigned-hostname	   |	d-i netcfg/get_hostname string svr.**************
   >
   > d-i netcfg/get_domain string unassigned-domain		   |	d-i netcfg/get_domain string dns.**************

5. 设置主机名 用户名 密码

   > #d-i netcfg/hostname string somehost			   |	d-i netcfg/hostname string isc-vm-host

   > \# To create a normal user account.				# To create a normal user account.
   >
   > \#d-i passwd/user-fullname string Ubuntu User		   |	d-i passwd/user-fullname string cuc
   >
   > \#d-i passwd/username string ubuntu			   |	d-i passwd/username string cuc
   >
   > \# Normal user's password, either in clear text			# Normal user's password, either in clear text
   >
   > \#d-i passwd/user-password password insecure		   |	d-i passwd/user-password password **************
   >
   > \#d-i passwd/user-password-again password insecure	   |	d-i passwd/user-password-again password **************

6. 设置时区

   > \# You may set this to any valid setting for $TZ; see the cont	# You may set this to any valid setting for $TZ; see the cont
   >
   > \# /usr/share/zoneinfo/ for valid values.			# /usr/share/zoneinfo/ for valid values.
   >
   > d-i time/zone string US/Eastern				   |	d-i time/zone string Asia/Shanghai

7. 取消使用NTP设置时钟

   > d-i clock-setup/ntp boolean true			   |	d-i clock-setup/ntp boolean false

8. 分区设置

   > \#d-i partman-auto/init_automatically_partition select biggest |	d-i partman-auto/init_automatically_partition select biggest_

   > \#d-i partman-auto-lvm/guided_size string max		   |	d-i partman-auto-lvm/guided_size string max

   

   > d-i partman-auto/choose_recipe select atomic		   |	d-i partman-auto/choose_recipe select multi

9. 不使用apt安装镜像

   > \#d-i apt-setup/use_mirror boolean false			   |	d-i apt-setup/use_mirror boolean false

10. 指定server版包

    > tasksel tasksel/first multiselect ubuntu-desktop	   |	tasksel tasksel/first multiselect server

11. 安装openssh-server

    > \#d-i pkgsel/include string openssh-server build-essential   |	d-i pkgsel/include string openssh-server

    > \#d-i pkgsel/upgrade select none				   |	d-i pkgsel/upgrade select none

12. 设置自动升级策略

    > \#d-i pkgsel/update-policy select none			   |	d-i pkgsel/update-policy select unattended-upgrades

## 实验问题回答

- 如何配置无人值守安装iso并在Virtualbox中完成自动化安装。

  编辑修改txt.cfg和seed文件

- Virtualbox安装完Ubuntu之后新添加的网卡如何实现系统开机自动启用和自动获取IP？

  ubuntu18.04版本通过/etc/netplan目录下yaml配置文件配置网络

  应用命令:

  `sudo netplan apply`

- 如何使用sftp在虚拟机和宿主机之间传输文件？

  在默认情况下， SFTP 使用 SSH 协议进行身份验证并建立安全连接

  连接远程服务器：

  `sftp username@ip`

  将文件上传到服务器上：

  `put [本地路径] [远程路径]`

