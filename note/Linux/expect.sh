#!/bin/bash
echo "-----------`date`----------"

paas_passwd=''
root_passwd=''

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
        # monit stop all
        expect "$ " { send "scp paas@192.168.2.107:/home/paas/huxj/hbase-site.xml /var/paas/jobs/hbase/conf/ \r" }
        expect {
            "(yes/no)? " {send "yes\r"; exp_continue}
            "password: " {send "$paas_passwd\r"}
            timeout {send_user "Login_Fail\n"}
            eof     {send_user "Login_Fail\n"}
        }
#       expect "$ " { send "monit restart all \r" }
        #We have just finished our job,
        #and it's time to say goodbye!
        expect "$ " {send "exit\r"}
        expect eof
END
done<<<"
"
