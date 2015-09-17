FROM debian:wheezy

MAINTAINER Nick Caley <ncaley@us.ibm.com>

# Note:
# When using IBM UrbanCode Deploy, be sure to set the External Agent URL
# to be something that is accessible from within a Docker container.
# For example, localhost will not work, but your wlan0 IP should.


# This build expects the ibm-ucd-agent.zip to be in the current directory
# as well as an install.properties file.
ADD ibm-ucd-agent.zip /tmp/ibm-ucd-agent.zip
ADD install.properties /tmp/install.properties


# Install Java6, remove any apt stuff that is no longer needed,
# then install the UCD Agent and remove the install files.
RUN apt-get update && \
	apt-get install unzip openjdk-7-jre-headless -y && \
	apt-get clean && \
	apt-get autoremove

RUN export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/ && \
	cd /tmp && \
        unzip -q IBM_UCD_SERVER_6.1.1.8.zip &&\
	unzip -q ibm-ucd-install/overlay/opt/tomcat/webapps/ROOT/tools/ibm-ucd-agent.zip &&\
	cp -f /tmp/install.properties /tmp/ibm-ucd-agent-install/install.properties && \
	sh /tmp/ibm-ucd-agent-install/install-agent.sh && \
	rm -rf /tmp/ibm-ucd-agent-install && \
	rm -rf /tmp/ibm-ucd-install/overlay/opt/tomcat/webapps/ROOT/tools/ibm-ucd-agent.zip


# TODO - replace this with install.dir from install.properties - but how?
# For now, override this with --entrypoint=$INSTALL_DIR/bin/agent
# If you're using an older agent, you may need to use ibm-ucdagent.
ENTRYPOINT ["/opt/ibm-ucd/agent/bin/agent", "run"]
CMD ["run"]

