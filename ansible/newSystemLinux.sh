#!/bin/bash

BOOTSTRAP_LOCALADMIN="ec2-user"
IP=192.168.0.0
MAC=001122334455
HOSTNAME="NewSystem"
HELP=0

###
###  Command line arguments
###

if [[ $# -eq 0 ]] ; then
    HELP=1
fi

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -i|--ip)
    IP="$2"
    shift # past argument
    ;;
    -h|--fqdn)
    HOSTNAME="$2"
    shift # past argument
    ;;
    *)
        # unknown option
	#HELP=1
    ;;
esac
shift # past argument or value
done

if [ $HELP -eq 1 ] ; then
	echo "Options are --ip , --fqdn. Example:  --ip 127.0.0.1 --fqdn testsystem.dev2.local"
	exit 1
fi

###
###
###



# join to domain
TMPFILE="bootstrap-$IP"
cat << EOF > /etc/ansible/inventory.d/$TMPFILE
[lin-base]
$IP

[lin-base:vars]
ansible_user = $BOOTSTRAP_LOCALADMIN
ansible_port = 22
ansible_connection = ssh
EOF

echo -e "Asking ansible to add ${HOSTNAME%%.*} ($IP) to the domain's DNS."
ansible-playbook bootstrap/joindns.yml --extra-vars "ip=$IP hostname=${HOSTNAME%%.*}"  -v 

rm /etc/ansible/inventory.d/$TMPFILE
echo -e "\n\n!!!!! COMPLETE !!!!!\nPlease add $HOSTNAME to your ansible host file under /etc/ansible/inventory.d/ in the appropriate section"
