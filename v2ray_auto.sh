echo "first thx v2ray白话文教程 address is  https://toutyrater.github.io/"
echo "this script do things below "
echo "will check your syetem had install wget, if not, install"
echo "will modify /etc/v2ray/config.json"
echo "will down script go.sh into current user home"
echo " the script from https://install.direct/go.sh"
echo "if current user home had other go.sh not from same source, your file will change name go.sh.bak.by.v2ray "
echo "\n\n\n"


echo "confirm install? y/n"
read answer
if [ $answer != 'y' ]
then
	echo "see you again"
	exit
fi

echo "type server using port, must less than 65535 and more than 1080"
read answer
server_port=$answer
if [ -z $server_port ]
then
	echo "input error, server port can't be null"
	exit
elif [ $server_port -gt 65535 ]
then 
	echo "input error, port can't more than 65535"
	exit
elif [ $server_port -lt 1080 ]
then
	echo "input error, port can't less than 1080"
	exit
fi


echo "server time is `date +%Y-%m-%d' '%H:%M:%S` timezone is `date +%z`"
echo "check the time is right"
echo "timezone can be inconsistent with client"

echo "is the time right? y/n"
read answer
if [ $answer != 'y' ]
then
	echo "you can change time by yourself"
	echo "you may need bellow command"
	echo "sudo date --set='2017-01-22 16:16:23'"
	echo "if you can't modify server time, you can contact you server provider"
	exit
fi

had_wget=1
if [ -x "/usr/bin/wget"  ]
then
	had_wget=1
elif [ -x "/usr/local/bin/wget" ]
then
	had_wget=1
else
	had_wget=0
fi

if [ $had_wget = 0 ]
then
	echo "will install wget"
	linux_distributions=`cat /etc/os-release | grep -w ID`
	linux_distributions_name=${linux_distributions#*=}
	echo "you linux server is $linux_distributions_name"
	if [ $linux_distributions_name = "ubuntu" ]
	then
		sudo apt-get install -y wget
	elif [ $linux_distributions_name = "debian" ]
	then
		sudo apt-get install -y wget
	elif [ $linux_distributions_name = "deepin" ]
	then
		sudo apt-get install -y wget
	elif [ $linux_distributions_name = '"centos"' ]
	then
		yum intall -y wget
	else
		echo "un support your system $linux_distributions, please send email to wheesys@sina.com, with your system"
		exit
	fi
fi

current_user=`whoami`
echo "current user is $current_user"

go_sh_md5="90e189a10d716fd0c3fc06029d00df86"
if [ -f "/home/$current_user/go.sh" ]
then
	echo "had go.sh"
	current_go_md5=md5sum /home/$current_user/go.sh | grep -v grep | awk '{print $1}' 
	if [ go_sh_md5 != current_go_md5 ]
	then
		echo "your go.sh is not v2ray about, will back"
		mv ~/go.sh ~/go.sh.bak.by.v2ray
		cd ~
		wget https://install.direct/go.sh
	fi
else
	cd ~
	wget https://install.direct/go.sh
fi

chmod u+x ~/go.sh
sudo bash ~/go.sh
new_uuid=`cat /proc/sys/kernel/random/uuid`
sudo cp /etc/v2ray/config.json /etc/v2ray/config.json.bak
echo "your server port is $server_port, id is $new_uuid"
sudo sed -i "s/\"port\":.*/\"port\": $server_port,/g" /etc/v2ray/config.json
sudo sed -i "s/\"id\":.*/\"id\": \"$new_uuid\",/g" /etc/v2ray/config.json
sudo systemctl restart v2ray
