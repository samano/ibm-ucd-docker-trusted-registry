#!/bin/bash
# usage: /opt/ibm-ucd/server/ucd_data_relocate.sh [save]
#
# Put this file into the installed server/ directory during installation.  Invoke it with the "save"
# parameter to save away the reolcatable directories.  Invoke with no parameters to run the docker image.
#
# It is expecting the following VOLUME line in the Dockerfile:
#
# VOLUME /ucddata
#
# run this command in the initial entrypoint.sh (ENTRYPOINT or CMD) script in the image (no parameters)
#
# The image should be started with -v HOSTDIR:/ucddata  See the VOLUME in the Dockerfile

# see http://www-01.ibm.com/support/knowledgecenter/SS4GSP_6.1.0/com.ibm.udeploy.install.doc/topics/server_install_silent.html
relocatables="\
    var/db \
    var/email \
    var/plugins \
    var/repository \
    var/sa \
    logs \
    conf/encryption.keystore \
    conf/server.keystore \
    conf/collectors \
    patches \
    conf/server/log4j.properties \
    "

SERVER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SERVER

DESTINATION=/ucddata
SAVED=$SERVER/saved

# save the contents away to avoid deleting later
if [ "$1" == "save" ]; then
    mkdir $SAVED
    for relocatable in $relocatables; do
        if [ -e $relocatable ]; then
            mkdir -p $SAVED/$relocatable # make sure parent exists
            rmdir $SAVED/$relocatable    # move will create the dir
            mv $relocatable $SAVED/$relocatable
        fi
        ln -s $DESTINATION/$relocatable $relocatable
    done
    exit 0
fi

for relocatable in $relocatables; do
    if [ ! -e $DESTINATION/$relocatable ]; then # already exists do not change it
        # assume it is a directory that must be created
        mkdir -p $DESTINATION/$relocatable  # make sure parent exists
        if [ -e $SAVED/$relocatable ]; then
            # but if the source exists, even if it is a file, delete and copy will create it
            rmdir $DESTINATION/$relocatable     # the copy will create the dir
            cp -r $SAVED/$relocatable $DESTINATION/$relocatable
        fi
    fi
done
