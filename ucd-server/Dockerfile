FROM java:7-jre

MAINTAINER Zachary Jaffee <zjaffee@us.ibm.com>

# curl unzip
RUN apt-get update -qq \
  && apt-get --no-install-recommends install -qq curl unzip > /dev/null \
  && apt-get install less \
  && rm -rf /var/lib/apt/lists/*

#ENV UCD_SERVER ibm-ucd-6.1.1.7
ENV UCD_SERVER IBM_UCD_SERVER_6.1.1.8
ENV UCD_SERVER_ZIP $UCD_SERVER.zip
ENV IBM_UCD_SECURE true
ENV CERTS_DIR /certs.d


WORKDIR /opt/ibm-ucd/server

# The server state is persisted in this volume
VOLUME /opt/ibm-ucd/serer/var
VOLUME $CERTS_DIR

# http: 8080 https: 8443 jms: 7918
EXPOSE 8080 8443 7918

ADD $UCD_SERVER_ZIP /$UCD_SERVER_ZIP

COPY plugins/ /installtools/plugins/
COPY installtools/ /installtools/


COPY Dockerfile /info/base-Dockerfile
COPY setup_certs.sh /

RUN /installtools/install_ucd.sh $UCD_SERVER_ZIP

RUN mkdir -p /

# by default run the ucd server command with the run option
COPY entrypoint.sh /entrypoint.sh
#run cat /opt/ibm-ucd/server/conf/server/installed.properties | sed 's/server.jms.mutualAuth=true/server.jms.mutualAuth=false/g' > /opt/ibm-ucd/server/conf/server/installed.properties.new && mv /opt/ibm-ucd/server/conf/server/installed.properties.new /opt/ibm-ucd/server/conf/server/installed.properties
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server", "run"]
