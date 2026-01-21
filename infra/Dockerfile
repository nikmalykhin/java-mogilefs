FROM ubuntu:14.04

# LEGACY: This Dockerfile is kept for historical reference (Phase 2)
# Phase 3.3 uses Dockerfile.gradle with Gradle 8.5 + Java 8

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

# NOTE: Ant has been decommissioned in Phase 3.3
# This image is retained for historical reference only

# Copy entrypoint script (from infra directory in project root context)
COPY infra/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
