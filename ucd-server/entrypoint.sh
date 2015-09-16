#!/usr/bin/env bash
# See Dockerfile
# ENTRYPOINT thisFile
# RUN server run
set -e
[[ ${DEBUG_STARTUP,,} = true ]] && set -x

if [[ $1 != server ]]; then
    exec "$@"
fi

#if ! grep -q server.jms.mutualAuth=true conf/server/installed.properties; then
    #echo "server.jms.mutualAuth must be set to true during install"
    #cat conf/server/installed.properties
    #exit 1
#fi

#if [ ! -f "$CERTS_DIR/server.crt" ]; then
	#echo "UrbanCode Deploy TLS Certificate" 
	#keystore=appdata/conf/server.keystore
  	#keytool -export -keystore $keystore -storepass changeit -alias server \
    #-file $CERTS_DIR/server.crt
  #echo "UrbanCode Deploy TLS Certificate copied to $CERTS_DIR/server.crt"
#fi 

if [ "$LICENSE" = "accept" ]; then
  exec ./bin/server run
elif [ "$LICENSE" = "view" ]; then
  less /opt/ibm-ucd/server/notices
  echo -e "Set environment variable LICENSE=accept to continue"
  exit 1
else
  echo -e "Set environment variable LICENSE=accept to indicate acceptance of license terms and conditions.\n\nLicense agreements and information can be viewed by running this image with the environment variable LICENSE=view."
  exit 1
fi
#exec ./bin/server "$@"

