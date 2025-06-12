#!/bin/bash -ex

#install wget
yum install wget -y
yum -y install rpm-build

#install aws cli v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --update
ln -s /usr/local/bin/aws /usr/bin/aws


yum install -y python3-dnf python3-pip

#Install ansible
echo "ENVIRONMENT_GROUP: ${ENVIRONMENT_GROUP}"

if [ "${ENVIRONMENT_GROUP}" == "nonprod" ]
then
  PY_NEXUS_URL="https://nexus.itt.aws.odev.com.au/repository/pypi-central-proxy/simple/"
else
  PY_NEXUS_URL="https://nexus.itt.aws.oprd.com.au/repository/pypi-central-proxy/simple/"
fi

echo "PY_NEXUS_URL: ${PY_NEXUS_URL}"

python3 -m pip install --user --index-url ${PY_NEXUS_URL} ansible

#Run playbook
environment_group=$(aws ssm get-parameter --name /common/account/type --query Parameter.Value --output text)
ansible-playbook -e "environment_group=${environment_group}" -e "py_nexus_url=${PY_NEXUS_URL}" /tmp/ftpserver_install/playbooks/ftpserver_bootstrap.yaml

returnVal=$?
echo "exit code: $returnVal"
if [ $returnVal -eq 0 ]; then
   echo OK

else
   echo FAIL
   exit 99
fi
