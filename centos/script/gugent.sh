#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}
SSH_USER_HOME=${SSH_USER_HOME:-/home/${SSH_USER}}

VRAURL=${VRA_URL:-vra-01.ad.lab.lostroncos.net}
VRA_PREP_URL=${VRA_PREP_URL:-http://10.0.0.48/packer/prepare_vra_template_linux.tar.gz}
LABCA_URL=${LABCA_URL:-http://10.0.0.48/packer/lab-ca.pem}
VRACA_URL=${VRACA_URL:-http://10.0.0.48/packer/VRA-LCM.cer}
VRLCMCERT_URL=${VRLCMCERT_URL:-http://10.0.0.48/packer/vrlcm.cer}
VRA_MGR_HOST=${VRA_MGR_HOST:-vra-iaas-01.ad.lab.lostroncos.net}
VRA_MGR_PORT=443
VRA_APP_HOST=${VRA_APP_HOST:-vra-01.ad.lab.lostroncos.net}
VRA_APP_PORT=443
VRA_MGR_CERT_PRINT="78:86:45:19:F2:E6:52:06:BF:62:35:25:78:A1:C8:70:2F:52:C0:6F"
VRA_APP_CERT_PRINT="78:86:45:19:F2:E6:52:06:BF:62:35:25:78:A1:C8:70:2F:52:C0:6F"
VRA_JAVA_INST="true"
VRA_CLOUD="vsphere"

cd /tmp

echo "==> Downloading vRA prep package"
wget ${VRA_PREP_URL}
echo "==> unzipping vRA prep package"
gunzip prepare_vra_template_linux.tar.gz
echo "==> Untarring vRA prep pkg"
tar xvf  prepare_vra_template_linux.tar
cd prepare_vra_template_linux

ls

echo "prepare_vra_template.sh -m "${VRA_MGR_HOST}" -a" ${VRA_APP_HOST}" -f" ${VRA_MGR_CERT_PRINT} "-a" ${VRA_APP_CERT_PRINT} "-j" ${VRA_JAVA_INST} "-c" ${VRA_CLOUD} "-n"
sudo sh -x ./prepare_vra_template.sh -m ${VRA_MGR_HOST} -a ${VRA_APP_HOST} -f ${VRA_MGR_CERT_PRINT} -g ${VRA_APP_CERT_PRINT} -j ${VRA_JAVA_INST} -c ${VRA_CLOUD} -n

