FROM registry.access.redhat.com/ubi8/ubi:8.9-1160 as parent
# this example installs gradle 8.7
RUN dnf -y install unzip
RUN curl --location --show-error -O --url https://services.gradle.org/distributions/gradle-8.7-bin.zip
RUN mkdir -p /opt/gradle
RUN unzip -d /opt/gradle gradle-8.7-bin.zip
# install snyk cli now
RUN curl --compressed "https://static.snyk.io/cli/latest/snyk-linux" -o snyk
RUN chmod +x ./snyk
RUN mv ./snyk /usr/local/bin/snyk

FROM registry.access.redhat.com/ubi8-minimal:8.7-1107
RUN microdnf -y install openssl ca-certificates git
# modify following to install java version from artifactory
RUN microdnf -y install java-17-openjdk
RUN mkdir -p /opt/gradle
COPY --from=parent /opt/gradle /opt/gradle
COPY --from=parent /usr/local/bin/snyk /usr/local/bin/snyk

ENV PATH="$PATH:/opt/gradle/gradle-8.7/bin:/usr/bin"
ENV JAVA_HOME=/etc/alternatives/jre_openjdk
ENV SNYK_TOKEN=${SNYK_TOKEN}
ENV COMMAND=${COMMAND}

WORKDIR /app
ENTRYPOINT ["snyk"]
CMD ["test", "--all-projects"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
