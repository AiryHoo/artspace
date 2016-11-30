#!/bin/bash
echo "-----------`date`----------"
paas_passwd='cnp200@HW'
root_passwd='cnp200@HW'
while read line; do
    [ -z "$line" ] && continue
    set -- $line
    hostname=$1
    ip=$2
    echo "hostname=$hostname, ip=$ip"
    echo "Login Host: $ip"
    expect << END
        set timeout 2000
        spawn -noecho ssh paas@$ip

        #input the passwd of paas to login
        expect {
            "(yes/no)? " {send "yes\r"; exp_continue}
            "password: " {send "$paas_passwd\r"}
            timeout {send_user "Login_Fail\n"}
            eof     {send_user "Login_Fail\n"}
        }

        expect "$ " { send "sudo su\r" }

        expect "# " {send "\[ -d /home/paas/backup/ ] || mkdir /home/paas/backup/\r"}

        expect "# " { send "fdisk /dev/xvde\r" }
        expect "Command (m for help): " {send "n\r"}
        expect "Select (default p): " {send "p\r"}
        expect "Partition number*: " {send "\r"}
        expect "First sector*: " {send "\r"}
        expect "Last sector*: " {send "\r"}
        expect "Command (m for help): " {send "w\r"}
        
        expect "# " {send "mkfs -t ext4 /dev/xvde1\r"}
        expect "# " { send "mount /dev/xvde1 /var/paas\r" }
        expect "# " { send "cp /etc/fstab /home/paas/backup/ \r" }
        expect "# " { send "echo \"/dev/xvde1 /var/paas ext4 defaults 1 1\" >> /etc/fstab \r" }

        #We have just finished our job,
        #and it's time to say goodbye!
        expect "# " {send "exit\r"}
        expect "$ " {send "exit\r"}

        expect eof
END
done<<<"
"
