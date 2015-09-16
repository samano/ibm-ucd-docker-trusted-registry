#!/bin/bash
# usage install_ucd.sh URL
# install the ucd from a zip that can be found at an http url.  See the Dockerfile for this line:
# RUN /installtools/install_ucd.sh $UCD_SERVER_ZIP

set -e

URL=$1
pushd /

# get and unzip the ucd installer
FILE=$(basename $URL)

trap 'rm -rf $FILE /ibm-ucd-install' EXIT
if [ ! -f $FILE ]; then
    echo "curl -sS -O $URL"
    curl -sS -O $URL
fi
# This creates /ibm-ucd-install
unzip -q $FILE

# install ucd and remove the installer
cd ibm-ucd-install

dockerhost=$(ip route | awk '/default/ { print $3 }')
case ${IBM_UCD_SECURE,,} in
    true)
        always_secure=Y
        web_url=https://$dockerhost:8443
        mutualAuth=n
        ;;
    false)
        always_secure=n
        web_url=http://$dockerhost:8080
        mutualAuth=n
        ;;
    *)  echo "IBM_UCD_SECURE must be true or false, not '$IBM_UCD_SECURE'"
        exit 1
esac

cat >> install.properties <<EOF

nonInteractive=true
#install.java.home=/opt/java/ibm-java-x86_64-71/jre
install.server.web.always.secure=$always_secure
install.server.web.https.port=8443
install.server.web.host=localhost
install.server.web.ip=0.0.0.0
install.server.web.port=8080
java.io.tmpdir=/opt/ibm-ucd/server/var/temp
database.derby.port=11377
database.type=derby
hibernate.connection.url=jdbc\:derby\://localhost\:11377/data
hibernate.connection.username=ibm_ucd
hibernate.connection.password=password
server.initial.password=admin
server.external.web.url=$web_url
server.jms.mutualAuth=$mutualAuth
EOF

# copy in plugins
(
    shopt -s nullglob
    for dir in $(dirname $0)/plugins/*; do
        stage=overlay/var/plugins/$(basename $dir)/stage
        mkdir -p $stage
        for plugin in $dir/*; do
            echo Copy $plugin to $stage
            cp $plugin $stage
        done
    done
)

sleep 1s
./install-server.sh > install-server.log 2>&1

popd

# copy the data away into a backup copy so it can be used from a volume during execution
#cp /installtools/ucd_data_copy.sh .
#./ucd_data_copy.sh save
