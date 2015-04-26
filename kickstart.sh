### Generated by CMS system ###

install
key --skip
lang en_US.UTF-8
keyboard us

network --device eth0 --onboot yes --bootproto static  --ip 10.86.18.5 --netmask 255.255.255.224 --gateway 10.86.18.1 --hostname cn09proprof00 --nameserver 10.86.21.10
rootpw --iscrypted $1$JaBLu7mI$kOSv/qwgYSJszYoH74LcG1
firewall --disabled
##  authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc UTC
firstboot --disable
skipx
text
bootloader --location=mbr --md5pass=$1$0c3AY0$bijoy3wmgdy3NnATIa/VV1
zerombr



# It can be a mistake in RHEL docs!
# clearpart --drives=sda --all
   
part / --fstype=ext4 --size=10000 --asprimary --ondisk=sda
part /home --fstype=ext4 --size=10000 --asprimary --ondisk=sda
part /u01 --fstype=ext4 --size=200 --asprimary --ondisk=sda --grow
part /var --fstype=ext4 --size=10000 --asprimary --ondisk=sda
reboot

######install set of software

 %packages --nobase
 -anacron
 -hal
 -kudzu
 -pm-utils
 -prelink
 audit
 sysstat
 vim-enhanced
 mc
 man
 groff
 wget
 ntp
 mlocate
 dhclient
 openssh
 openssh-clients
 openssh-server
 postfix
 vim-minimal
 crontabs
 anacron
 vixie-cron
 telnet
 yum
 bzip2
 unzip
 sudo
 mailx
 pciutils
 dmidecode
 coreutils
 iproute
 gdb
 lsof
 net-tools
 procps
 psmisc
 pstack
 rpm
 strace
 sysstat
 tcpdump
 util-linux
 patch
 iptables
 -sysklogd
 yum-utils
 net-snmp
    
 %end #%packages

 %post
 (



#detect some virtual machines

  [ -d /proc/xen ] && { grep -q "control_d" /proc/xen/capabilities || VIRTUAL="XEN-DOMU"; }
  lspci -n | grep -q "5853:0001" && VIRTUAL="XEN-HVM"
  lspci -n | grep -q "15ad:0405" && VIRTUAL="VMWARE"
  lspci -n | grep -q "80ee:beef" && VIRTUAL="VIRTUALBOX"
  lspci -n | grep -q "80ee:cafe" && VIRTUAL="VIRTUALBOX"
  lspci -n | grep -q "1af4:1002" && VIRTUAL="KVM"

# bonds

  echo -e 'DEVICE=bond0\nIPADDR=10.86.18.5\nNETMASK=255.255.255.224\nGATEWAY=10.86.18.1\nONBOOT=yes\nBOOTPROTO=static\nBONDING_OPTS="mode=1 miimon=100"' > /etc/sysconfig/network-scripts/ifcfg-bond0
  echo -e "DEVICE=eth0\nMASTER=bond0\nSLAVE=yes\nONBOOT=yes\nBOOTPROTO=static" > /etc/sysconfig/network-scripts/ifcfg-eth0
  echo -e "DEVICE=eth1\nMASTER=bond0\nSLAVE=yes\nONBOOT=yes\nBOOTPROTO=static" > /etc/sysconfig/network-scripts/ifcfg-eth1
  echo "Restarting networking..." && service network restart 1>/dev/null


# routes (before configuring network!)


#DNS settings
 cat << EOF > /etc/resolv.conf
 options attempts:2 timeout:2 rotate
 nameserver 10.86.21.10
 domain cn09.phorm.com
 search cn09.phorm.com
 EOF

### creating new /etc/hosts
 cat << EOF > /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail
 127.0.0.1               localhost.localdomain localhost
 ::1             localhost6.localdomain6 localhost6
 EOF

### set time
 [ "$VIRTUAL" = "XEN-DOMU" ] && { echo 1 > /proc/sys/xen/independent_wallclock; }

 /usr/sbin/ntpdate -b ntp1
# ntp.conf
 mv /etc/ntp.conf /etc/ntp.conf.orig
 cat << EOF > /etc/ntp.conf
 restrict default kod nomodify notrap nopeer noquery
 restrict 127.0.0.1
 server ntp1
 server ntp2
 driftfile /var/lib/ntp/drift
 keys /etc/ntp/keys
 EOF

# core dumps

### SECURITY

## Security notice that will be printed after a successful login
 echo ' +---------------------------------------------------+
  | WARNING:                                          |
  |                                                   |
  | You have accessed a server operated by Phorm.     |
  |                                                   |
  | You must be personally authorised by the system   |
  | administrator before you use this computer and    |
  | you are strictly limited to the extent of that    |
  | authorisation. Unauthorised access or misuse of   |
  | this computer is prohibited and may constitute    |
  | an offence under the Computer Misuse Act 1990.    |
  |                                                   |
  | If you are not authorised to use this system,     |
  | terminate this session immediately. Please note   |
  | that all access is logged.                        |
   +---------------------------------------------------+ ' >> /etc/motd

## Editing sysctl
                cat << EOF >> /etc/sysctl.conf
# security settings
                net.ipv4.conf.all.rp_filter = 1
                net.ipv4.conf.all.accept_source_route = 0
                net.ipv4.icmp_echo_ignore_broadcasts = 1
                net.ipv4.conf.all.accept_redirects = 0
                net.ipv4.conf.default.accept_redirects = 0
                net.ipv4.conf.all.secure_redirects = 0
                net.ipv4.conf.default.secure_redirects = 0
                net.ipv4.conf.all.send_redirects = 0
                net.ipv4.conf.default.send_redirects = 0
                net.ipv4.tcp_max_syn_backlog = 4096
                EOF

                echo 'echo 262144 > /sys/module/nf_conntrack/parameters/hashsize' >> /etc/rc.local
                echo 'net.netfilter.nf_conntrack_generic_timeout = 120' >> /etc/sysctl.conf
                echo 'net.netfilter.nf_conntrack_tcp_timeout_established = 54000' >> /etc/sysctl.conf
                echo 'net.core.somaxconn = 511' >> /etc/sysctl.conf
                echo 'net.ipv4.neigh.default.gc_thresh1 = 512' >> /etc/sysctl.conf
                echo 'net.ipv4.neigh.default.gc_thresh2 = 1024' >> /etc/sysctl.conf
                echo 'net.ipv4.neigh.default.gc_thresh3 = 2048' >> /etc/sysctl.conf
                echo 'net.ipv4.tcp_keepalive_time = 30' >> /etc/sysctl.conf
                echo 'net.ipv4.tcp_keepalive_intvl = 30' >> /etc/sysctl.conf
                echo 'net.ipv4.tcp_keepalive_probes = 10' >> /etc/sysctl.conf


## Force password login for single user mode
                sed -i 's|^SINGLE=/sbin/sushell$|SINGLE=/sbin/sulogin|' -i /etc/sysconfig/init
## Disallow ctrl-alt-del from console
                sed -i 's|^exec /sbin/shutdown -r now "Control-Alt-Delete pressed"|#&|' -i /etc/init/control-alt-delete.conf


## Set the minimum password length to 8 chars
                sed -i 's|PASS_MIN_LEN 5|PASS_MIN_LEN 8|' /etc/login.defs

                cat << EOF >> /etc/profile
## Set bash to logout after 30 minutes
                TMOUT=1800

## The screen should be cleared on logout
                trap clear 0
                EOF

## SSH configuration settings
#sed 's|PasswordAuthentication yes|PasswordAuthentication no|g' -i /etc/ssh/sshd_config

                cat << EOF > /etc/ssh/sshd_config
                Protocol 2
                SyslogFacility AUTHPRIV
                LoginGraceTime 1m
                PermitRootLogin no
                RSAAuthentication yes
                PubkeyAuthentication yes
                AuthorizedKeysFile      /var/lib/ssh_pubkeys/%u.pub
                RhostsRSAAuthentication no
                IgnoreUserKnownHosts yes
                IgnoreRhosts yes
                PermitEmptyPasswords no
                PasswordAuthentication no
                ChallengeResponseAuthentication no
                GSSAPIAuthentication no
                GSSAPICleanupCredentials yes
                UsePAM yes
                AllowTcpForwarding yes
                X11Forwarding yes
                TCPKeepAlive yes
                Compression yes
                UseDNS no
                PidFile /var/run/sshd.pid
                Subsystem       sftp    /usr/libexec/openssh/sftp-server
                HostbasedAuthentication no
                MaxStartups 10:30:100
                EOF

                mkdir /var/lib/ssh_pubkeys/

## Enabling sysstat
                chkconfig sysstat on

## Disable interactive prompt menu
                sed -i 's|PROMPT=yes|PROMPT=no|' /etc/sysconfig/init

                sed -i 's|^timeout=.*|timeout=5|' /boot/grub/grub.conf

## Setting umask to 077
                for i in /etc/{profile,bashrc,csh.cshrc,login.defs,csh.login} `find /etc/profile.d/ | xargs echo` /root/{.bashrc,.bash_profile,.cshrc,.tcshrc}
                do
                [ -f "$i" ] && sed s'|^\(\s*umask\s\+\)[0-9]\{3\}\(.*\)$|\1077\2|i' -i $i
                done

## specifying coredumps dir and files
                [ -d '/u01/cores' ] || mkdir -p -m 1777 /u01/cores
                echo 'kernel.core_pattern = /u01/cores/%e-%p' >> /etc/sysctl.conf
############END OF SECURITY


## grub.conf
                sed -i 's|^splashimage|#&|; s|^hiddenmenu|#&|; s|\(.*/vmlinuz-.*\)|\1 vga=791|; s| rhgb | |; s| quiet | |;' /boot/grub/grub.conf


# console configuration
                [ "$VIRTUAL" = "XEN-DOMU" ] && { echo 'co:2345:respawn:/sbin/agetty xvc0 9600 vt100-nav' >> /etc/inittab; }
#[ "$VIRTUAL" = "KVM" ] && { echo 'S0:2345:respawn:/sbin/agetty ttyS0 115200 vt100-nav' >> /etc/inittab; echo "ttyS0" >> /etc/securetty; }
                [ "$VIRTUAL" = "KVM" ] && { echo "ttyS0" >> /etc/securetty; }

# disable 169.254.0.0/16 subnet
                echo 'NOZEROCONF=yes' >> /etc/sysconfig/network

# disable ipv6
                grep -q 'NETWORKING_IPV6' /etc/sysconfig/network || echo 'NETWORKING_IPV6=no' >> /etc/sysconfig/network
                sed 's|NETWORKING_IPV6=yes|NETWORKING_IPV6=no|' -i /etc/sysconfig/network
#echo -e '\n## Disable ipv6\nalias net-pf-10 off\nalias ipv6 off\ninstall ipv6 /bin/true' >> /etc/modprobe.d/disable-ipv6.conf

                echo -e "# Disable ipv6\noptions ipv6 disable=1" >> /etc/modprobe.d/disable-ipv6.conf

# tune postfix
                sed -e 's|inet_protocols.*|inet_protocols = ipv4|' -e \
                    '1,/^#myhostname =.*/s/^#myhostname =.*/myhostname = cn09proprof00.cn09.phorm.com\n&/' \
                    -i /etc/postfix/main.cf

                    echo -e '#Bug 564274 - fake EDAC errors\nblacklist i3200_edac' >> /etc/modprobe.d/blacklist-edac.conf

                    echo 'alias netdev-bond0 bonding' >> /etc/modprobe.d/bonding.conf


### /etc/sysctl.conf
                    cat << EOF >> /etc/sysctl.conf
# Prevent arp answer on wrong interface
                    net.ipv4.conf.all.arp_filter = 1
                    net.ipv4.conf.all.arp_ignore = 2
# disable ipv6
                    net.ipv6.conf.all.disable_ipv6 = 1
                    EOF

### disable some services
                    CHKCONFIG_OFF="firstboot cpuspeed lvm2-monitor kudzu isdn ip6tables auditd restorecond atd readahead_early mcstrans \
                                   setroubleshoot portmap nfslock mdmonitor rpcidmapd rpcgssd bluetooth pcscd apmd hidd autofs cups gpm xfs anacron rhnsd \
                                   yum-updatesd avahi-daemon netfs iscsid iscsi rawdevices netfs abrtd kdump"
                                   for s in $CHKCONFIG_OFF; do
                                   [ -f "/etc/init.d/$s" ] && chkconfig $s off
                                   done

                                   CHKCONFIG_ON="iptables ntpd"
                                   for s in $CHKCONFIG_ON; do
                                   [ -f "/etc/init.d/$s" ] && chkconfig $s on
                                   done

#disable ntpd on paravirtualized XEN-DOMU
                                   [ "$VIRTUAL" = "XEN-DOMU" ] && { echo -e '\n#unlink dom0 and domU clock to work ntpd\nxen.independent_wallclock = 1' \
                                       >> /etc/sysctl.conf; }

#disable smartd on virtual machines
                                       [ -n "$VIRTUAL"  ] && [ -f "/etc/init.d/smartd" ] && chkconfig smartd off

# tune bash
                                       echo 'HISTCONTROL=ignoreboth' >> /etc/profile
                                       sed -i 's|^HISTSIZE=.*|HISTSIZE=1000000|' /etc/profile

# enable sudo for wheel and requretty
                                       sed 's|^# %wheel\tALL=(ALL)\tNOPASSWD: ALL|%wheel\tALL=(ALL)\tNOPASSWD: ALL|; s|^Defaults    requiretty|#&|' -i /etc/sudoers

# tune iptables
                                       cat << EOF > /etc/sysconfig/iptables
                                       *mangle
                                       :PREROUTING ACCEPT [0:0]
                                       :INPUT ACCEPT [0:0]
                                       :FORWARD ACCEPT [0:0]
                                       :OUTPUT ACCEPT [0:0]
                                       :POSTROUTING ACCEPT [0:0]
                                       COMMIT

                                       *nat
                                       :PREROUTING ACCEPT [0:0]
                                       :POSTROUTING ACCEPT [0:0]
                                       :OUTPUT ACCEPT [0:0]
                                       COMMIT

                                       *filter
                                       :INPUT ACCEPT [0:0]
                                       :FORWARD ACCEPT [0:0]
                                       :OUTPUT ACCEPT [0:0]

                                       -A INPUT -p ICMP --icmp-type timestamp-request -j DROP
                                       -A OUTPUT -p ICMP --icmp-type timestamp-reply -j DROP

                                       COMMIT

                                       *raw
                                       :PREROUTING ACCEPT [0:0]
                                       :OUTPUT ACCEPT [0:0]
                                       -A PREROUTING -j NOTRACK
                                       -A OUTPUT -j NOTRACK
                                       COMMIT

                                       EOF

### ENVDEV-1348. Do not format!!!

                                       echo '77a78
                                       > Arch        : %{ARCH}\n\' | patch -o /etc/popt /usr/lib/rpm/rpmpopt-4.8.0 > /dev/null && chmod 644 /etc/popt
# noclear console
                                       sed -i 's|^exec /sbin/mingetty $TTY$|exec /sbin/mingetty --noclear $TTY|' /etc/init/tty.conf


                                       [ -f "/etc/sysconfig/prelink" ] && sed -i 's|^PRELINKING=yes$|PRELINKING=no|' /etc/sysconfig/prelink

### bug with disable selinux in install section
                                       [ -f "/etc/selinux/config" ] && sed 's|^SELINUX=.*|SELINUX=disabled|' -i /etc/selinux/config

### disable all external yum repos
                                       find /etc/yum.repos.d/ -mindepth 1 -name \*.repo -exec sed 's|^[^#].\+|#&|g' -i '{}' +
# temporary yum repo

                                       cat << EOF >> /etc/yum.repos.d/phorm-tmp.repo

                                       [phorm-os]
                                       name=phorm/production-cn-jiangsu//os
                                       baseurl=http://repo/repos/production-cn-jiangsu/RPMS.os
                                       enabled=1

                                       [phorm-updates]
                                       name=phorm/production-cn-jiangsu//updates
                                       baseurl=http://repo/repos/production-cn-jiangsu/RPMS.updates
                                       enabled=1

                                       [phorm-cms]
                                       name=phorm/production-cn-jiangsu//cms
                                       baseurl=http://repo/repos/production-cn-jiangsu/RPMS.cms
                                       enabled=1

                                       [phorm-common]
                                       name=phorm/production-cn-jiangsu//common
                                       baseurl=http://repo/repos/production-cn-jiangsu/RPMS.common
                                       enabled=1


                                       EOF

### install host configuration package
                                       yum --quiet --nogpgcheck install ks-host-production-cn-jiangsu   -y && rm -f /etc/yum.repos.d/phorm-tmp.repo
                                       yum --quiet --nogpgcheck install syslog-ng

                                       yum --quiet remove net-snmp-libs.i386 -y


### Install snmpd
                                       yum --quiet install net-snmp-subagent -y

                                       groupadd -f -g 506 adgroup 1>/dev/null ||:
# create snmp config
                                       mv -f /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.dist

                                       echo 'com2sec         notConfigUser  default       V9AaE_3G+2-0
                                       group           notConfigGroup v1            notConfigUser
                                       group           notConfigGroup v2c           notConfigUser
                                       access          notConfigGroup ""            any  noauth exact systemview none none

                                       view            systemview     included      .1
#for hight load system comment the line above and uncomment below
#this will exclude large tcp connection tables from default system view
#view    systemview    included   .1.3.6.1.2.1.1
#view    systemview    included   .1.3.6.1.2.1.2
#view    systemview    included   .1.3.6.1.2.1.4
#view    systemview    included   .1.3.6.1.2.1.25
#view    systemview    included   .1.3.6.1.2.1.31
#view    systemview    included   .1.3.6.1.4.1.777
#view    systemview    included   .1.3.6.1.4.1.2021
#view    systemview    included   .1.3.6.1.4.1.28675
#view    systemview    included   .1.3.6.1.4.1.57052



                                       master  agentx
                                       agentxperms 770 770 daemon adgroup

                                       dontLogTCPWrappersConnects 1
                                       interface lo 24 1000000000' > /etc/snmp/snmpd.conf

                                       sed 's|\(syslocation[^.]\+\)\..*$|\1|' -i /etc/snmp/snmpd.conf
                                       echo 'OPTIONS="-Lsd -Lf /dev/null -p /var/run/snmpd.pid"' >> /etc/sysconfig/snmpd.options

                                       service snmpd start &> /dev/null && chkconfig snmpd on && sleep 3
                                       mkdir -p /var/agentx
                                       chmod 750 /var/agentx
                                       chown daemon.adgroup /var/agentx



# install other packages

                                       yum --quiet install noc-usermgr-server screen -y
                                          

# upgrade all packages

                                       yum --quiet upgrade -y


#turn selected services ON


#turn selected services OFF


##parameters for KVM kernel
                                       [ "$VIRTUAL" = "KVM" ] && { sed -i 's|\(.*/vmlinuz-.*\)|\1 divider=10 clocksource=acpi_pm console=tty0 console=ttyS0,115200|' /boot/grub/grub.conf; }
                                       [ "$VIRTUAL" = "KVM" ] && { echo -e "serial --unit=0 --speed=115200\nterminal --timeout=5 serial console" >> /boot/grub/grub.conf; }

##prepare root .ssh dir
                                       mkdir --mode=700 ~root/.ssh && touch ~root/.ssh/authorized_keys && chmod 600 ~root/.ssh/authorized_keys


                                       groupadd -g 506 adgroup

                                       adduser olgierd.ziolko -u 531 -g users -G wheel -p '$1$hnPhDNrF$APd7gXG/1bTa2dgO5xy93.'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAprt0/lL+3zQP4OtO51cpyVGeLK00CxY8o8cxgv9XfXNux+liRysEiH5bqu8x/e9KiigHig+2+76kE2tSEvZZ/06lnvel2jWngWMjvt5Glv4co2LfXMT1+ZvRRc/IJ/iKi41oCrcB3MCKi9vUnzk/mjBV4Ysljwgy6rg+ZkoKWZs= olgierd@phorm-20121001' | tee -a /var/lib/ssh_pubkeys/olgierd.ziolko.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/olgierd.ziolko.pub
                                          

                                       adduser aduser -u 506 -g adgroup -G wheel -p '!!'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAorBiQ+pO0b6G6y3sDBOx5UkDcrh1r7pg+3wzAQdz5Akegz9O0cDgnazTiPslI+mKpZVMX4EvDyxdwlqP/dgzMszzkArb71ujZDzyXU+71+jhSCQXLlzdCxP hKHJVvCfGpp/YPMmFxsifD8uJsW69ClL74xT82kHZRKcOgGPJDW3ytIcxyZBhGYx+yzQ0CeVvT3jmgF54qHE9wADelDZnfeezgTtWgv8WlgncffCjkoJA0MtuFn/CdigU5FzbBGN70IlPukK0jpGBfkgrg3iSonyW+KCFqjyzQeulext+5uULIskW0KJ4v2ZPbLzjdTjvD P+Z717qOFJdC9P7cBROOw== aduser@cn10proadbe00' | tee -a /var/lib/ssh_pubkeys/aduser.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/aduser.pub
                                          

                                       adduser leo.li -u 533 -g users -G wheel -p '$1$X7nq5rgN$Ozivz9q8hPsaeEL/YnTrD0'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuLIL7bb3Ek7Ie6bDETPwVVkcf4bGtiyi5nNVB2o67i45+DqyW7WTMBufbQPEmg56QmEof63805QWXiZ04GnF0sgSKvwAgRO3ScBqoKWHlir9wqdsTZhgg5kbdg5bwZN+YsIJ9mkBSTUibmer63AvE89uPMLe+ddC9ws2iejRQkLD64bMvNVUQA6BNpA7mCUKqRcJP+AbqjZyHNEaXowySUXn64qrRIABJSHXeiWVSIR5dd0gyhXDVQkMzrtcRHaTMmLMKy0CGzYaUlSxJ7CJEu7DT+EJkrN6xL5MBqFGDkxwJaFq6PniQUMJtn9Xxg4wDDXHeqeYWqTfW8ArkYvPaQ==' | tee -a /var/lib/ssh_pubkeys/leo.li.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/leo.li.pub
                                          

                                       adduser billy.zheng -u 534 -g users -G wheel -p '$1$XeoAYl1y$Z/GehZ1CGtdj0zoLYtxHn.'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1qkDQs3pNKsXY9RAwtfdtHowInr2Cio7ajBq9lKhlNKiDZ4ya2Y0tXQx6NpfjuNpcrh5AkfVCp9kKhvl5oGLdh6G2Z/UH0OFzhOhQp5vqcOhR4NAlU /DF9sw9oj2Yw0qbCUzx/y5TtCEKKvou9+B5SLf9IJNyqHU7VPwE6qoh4VUdHMWa4uF/in3835JHhtKD0bPlhaKYR9Uym47x07bQfaKE/LfiL1Nd3XazuvTOTkDbyh43nVPUfWmin2EpDdHcG1KNHtPMUumxyKJhtF07UPR3+cpA1j+0XaIIDqAg4uPtCzykdnbwj+f338v T5FbYNx0Dj2ARuEVEbxzauo2tw==' | tee -a /var/lib/ssh_pubkeys/billy.zheng.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/billy.zheng.pub
                                          

                                       adduser ivan.vinitskyy -u 532 -g users -G wheel -p '$1$EiAarB8K$..J3fcVEU.MA6CBdHhvQK1'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0qKvNvSw8ftyF9CnoHQISesOVcJROhg9RUbLCmCdphC87sTY4eLDUcP/K1hioDFL17MRewhBcfTETtjz+uXyB+5LUHh1dzPp+jw13JC1iJQEGy+lIONUlr8JLY4Uud6fDe24uwgEfQKZPRKeoAxsehjc6zgvq+jiM6yRHZg9kNaY+w69okcgw1qWUFvNCtamdK2LJFdqelwkxtuTeb+w/wyTqOMhkVZvDXw33/tHwwkurk2phjH4r/sJJcUgmjzEJfl8XdkhMxqbLY0ZU4UXB23mpd4OOQffsQeOMrNJ5wMyWsbOXVZCEh2xFB5nfIXzQhvfoO0Zitx65gixclgvvQ== ivan.vinitskyy@phorm.com' | tee -a /var/lib/ssh_pubkeys/ivan.vinitskyy.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/ivan.vinitskyy.pub
                                          

                                       adduser tibor.racz -u 535 -g users -G wheel -p '$1$JNwFDHj8$YVIxYFvRxij90xy.7YBpn/'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQACbaQ4Kvbe7EqzS0vlSNViOdOPqgDLHVZ2r3ssrqe46aZW189yjw2nlQ5bQpnGm/zvurMx5EN3JYvIyG0rtAEnEzMYThoykiRDgzH8JIs6OSAznJ0eNhjbpPLf/U6F6G0dWTmSD8FGvIurbDknjBRMGcxlZH3MsXbTdRw6wmK4IBX5ElaXvJU8nGqdBJG4qHeqNOhi6gzqJrURoijTtmWTFzkE+NjJDmxFuayV9FuI8N5z6TuNDiD+IIJjq5kLfPl1AKIpijhenqT7MK+CGKVbd9nqmoyaEO3Gm2OPQGinKUPHfggKGII71UOeGzCouRYoKQfBHzo+zs0Zgs3fq3 Tibor' | tee -a /var/lib/ssh_pubkeys/tibor.racz.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/tibor.racz.pub
                                          

                                       adduser byron.sorgdrager -u 501 -g users -G wheel -p '$1$9RFPVew3$Wqifm2WeVvqEeGz/S.VbO0'
                                       echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2I9ud12FttTCh97WgnPmJx7Zkzv1vNycUtnEaGi4Hl+lcS2NSwwP0p/GdWRQezjCvSpf0+pr7vZc0cqsSjNCg8YAxMYgfkPqx4NFMUocs9a674avvRj+DPnggUh7sMkDHy+U395DFTlg3je+xTq+/dYcHzpndCGvh57rEVjZhO6KioGHVAjWUhlkABLWPdym9dZIvvW5LKTzhd5MtUfSzTmDt/5KqBmu7x4rnlDVrcxcFavY7fRpsgkOLt2mCsi/0CiWe6MYwOGnMu2Rc4gvqcrvrteR9ya6IRZ3gwr2ejbMpZlxCuG2rODsI4GYrvxbIYyXcn+78vuIXkMhukYzH benyg@valjean' | tee -a /var/lib/ssh_pubkeys/byron.sorgdrager.pub >/dev/null
                                       chmod 644 /var/lib/ssh_pubkeys/byron.sorgdrager.pub
                                          
#send all root mail to admins
                                       echo 'root:           noc@phorm.com' >> /etc/aliases


#additional postinstall
                                       wget http://repo/ssl.tbz -O /tmp/ssl.tbz
                                       tar -jxf /tmp/ssl.tbz -C /opt/noc/
                                       rm -f /tmp/ssl.tbz

# send email

                                       interface=`ip r | grep default | cut -f5 -d" "`
                                       gateway=`ip r | grep default | cut -f3 -d" "`
                                       ipaddress=`ifconfig $interface | grep 'inet addr' | sed 's|\:| |g' | awk '{print $3}'`
                                       netmask=`ifconfig $interface | grep 'inet addr' | sed 's|\:| |g' | awk '{print $7}'`
                                       macaddr=`ip a s $interface | grep 'link/ether' | awk '{print $2}'`
                                       os=`cat /etc/redhat-release`
                                       arch=`uname -m`
                                       host=`cat /etc/sysconfig/network | grep HOSTNAME | cut -f 2 -d=`
                                       dtae=`date +'%R %d/%m/%Y'`


### send mail of success
                                       service postfix start > /dev/null

                                       echo -e "date: ${dtae}\nipaddr: ${ipaddress}\nos: ${os}\narch: ${arch}\ninterface: ${interface}\nmac: ${macaddr}\nplatform: \
                                           `dmidecode -s baseboard-manufacturer` `dmidecode -s baseboard-product-name`\nvirtual: ${VIRTUAL:-No}\n\n#free\n`free`\n\n\
#fdisk -l`fdisk -l`\n\n#lspci\n`lspci`\n\n# \
                                           `awk -F': ' '/^model name/{mn=$2} /^physical id/{pi=$2} /^cpu cores/{cc=$2} /^flags/{f=$2} \
                                           END{ printf("CPU info:\nname: %s\nCPU: %s physical * %s cores\nflags: %s\n", mn,pi+1,cc,f)}' /proc/cpuinfo`\n\n\
#Accounts , present on server:\n\n `cat /etc/passwd | grep /bin/bash | cut -d ':' -f 1`" \
                                           | mail -s "INFO: new server ready.. [${host} ${ipaddress}/${macaddr}]" noc@phorm.com

                                           sleep 10

                                           exit
                                           ) 1>/root/post_install.log 2>&1
                                           %end
