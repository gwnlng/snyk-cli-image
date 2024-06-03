FROM registry.access.redhat.com/ubi8/ubi:8.9-1160 as parent
# this example installs gradle 8.7
RUN dnf -y install unzip
RUN curl --location --show-error -O --url https://services.gradle.org/distributions/gradle-8.7-bin.zip
RUN curl --location --show-error -O --url https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz
RUN mkdir -p /opt/gradle
RUN mkdir -p /opt/maven
RUN unzip -d /opt/gradle gradle-8.7-bin.zip
RUN tar -xvzf apache-maven-3.8.8-bin.tar.gz -C /opt/maven
# install snyk cli now
RUN curl --compressed "https://static.snyk.io/cli/latest/snyk-linux" -o snyk
RUN chmod +x ./snyk
RUN mv ./snyk /usr/local/bin/snyk

FROM registry.access.redhat.com/ubi8-minimal:8.7-1107
RUN microdnf -y install openssl ca-certificates git python311 python3.11-pip
# modify following to install java version from artifactory
RUN microdnf -y install java-17-openjdk
RUN mkdir -p /opt/gradle
RUN mkdir -p /opt/maven
COPY --from=parent /opt/gradle /opt/gradle
COPY --from=parent /opt/maven /opt/maven
COPY --from=parent /usr/local/bin/snyk /usr/local/bin/snyk
COPY docker-entrypoint.sh /usr/local/bin/

ENV PATH="$PATH:/opt/gradle/gradle-8.7/bin:/opt/maven/apache-maven-3.8.8/bin"
ENV JAVA_HOME=/etc/alternatives/jre_openjdk
ENV SNYK_TOKEN=${SNYK_TOKEN}
ENV COMMAND=${COMMAND}

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["snyk", "test"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
