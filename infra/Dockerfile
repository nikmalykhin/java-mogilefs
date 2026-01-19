FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget tar curl ca-certificates && \
    apt-get install -y libxext6 libxrender1 libxtst6 libxi6 && \
    rm -rf /var/lib/apt/lists/*

# Install Java 6 from local tarball
COPY jdk-6u45-linux-x64.tar.gz /tmp/
RUN tar -xzf /tmp/jdk-6u45-linux-x64.tar.gz -C /opt/ && \
    mv /opt/jdk1.6.0_45 /opt/java && \
    rm /tmp/jdk-6u45-linux-x64.tar.gz
ENV JAVA_HOME=/opt/java
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Ant
ENV ANT_VERSION=1.9.7
ENV ANT_HOME=/opt/ant
ENV PATH=$PATH:$ANT_HOME/bin

RUN cd /tmp && \
    wget https://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar zxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-ant-${ANT_VERSION} ${ANT_HOME} && \
    rm -f *.gz

# Copy entrypoint script (from infra directory in project root context)
COPY infra/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
