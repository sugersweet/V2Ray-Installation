#!/bin/bash
read -p "输入阿里云RAM用户的ALICLOUD_ACCESS_KEY: " alicloudAccessKey
read -p "输入阿里云RAM用户的ALICLOUD_SECRET_KEY: " alicloudSecretKey
read -p "输入阿里云的ALICLOUD_REGION(cn-hongkong): " alicloudRegion
read -p "输入阿里云服务器的root密码(p@ssw0rd123456): " alicloudPassword


if [ -z "${alicloudRegion}" ];then
    alicloudRegion="cn-hongkong"
fi

if [ -z "${alicloudPassword}" ];then
    alicloudPassword="p@ssw0rd123456"
fi

echo "阿里云ALICLOUD_ACCESS_KEY: " $alicloudAccessKey
echo "阿里云ALICLOUD_SECRET_KEY: " $alicloudSecretKey
echo "阿里云服务器的ALICLOUD_REGION: " $alicloudRegion
echo "阿里云服务器的root密码: " $alicloudPassword

read -p "你想要1.安装 还是2.卸载：" install_destroy

export ALICLOUD_ACCESS_KEY=$alicloudAccessKey
export ALICLOUD_SECRET_KEY=$alicloudSecretKey
export ALICLOUD_REGION=$alicloudRegion
export SERVER_PASSWORD=$alicloudPassword

envsubst < terraform.template > terraform.tf
#terraform init
if [ $install_destroy == "1" ]
then
  terraform apply
  new_instance_ip=`terraform show | grep public_ip | awk '{print $3}'`
  echo "This is the Aliyun Instance generated based on your terraform.tf file: "${new_instance_ip}
  export Aliyun_ECS=${new_instance_ip}
  envsubst < inventory.template > inventory

  sshpass_install_or_not=`sshpass -V| head -1|awk '{print $1}'`

  if [ $sshpass_install_or_not == "sshpass" ]
  then
    ssh_version=`sshpass -V| head -1`
    echo "sshpass already installed and the version is: "${ssh_version}
  else 
    brew install hudochenkov/sshpass/sshpass
  fi
  echo "这个脚本为了省事，会休眠30s等待阿里云上的所有资源创建完成。现在开始休眠。。。"
  sleep 5s
  echo "休眠倒数25s..."
  sleep 5s
  echo "休眠倒数20s..."
  sleep 10s
  echo "休眠倒数10s..."
  sleep 5s
  echo "休眠倒数5s..."
  sleep 5s 
  export ANSIBLE_HOST_KEY_CHECKING=False
  ansible-playbook -i inventory v2ray.yaml

elif [ $install_destroy == "2" ]
then 
  terraform destroy

else
  echo "Hi you enter a invalid number"

fi
