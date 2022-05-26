# RStudio Connect sample Dockerfile
FROM ubuntu:bionic

# Install tools needed to obtain and install R and RStudio Connect.
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y curl gdebi-core && \
    rm -rf /var/lib/apt/lists/*

# Download and install R 3.6.1.
ARG R_VERSION="3.6.1"
ARG R_OS=ubuntu-1804
ARG R_PACKAGE=r-${R_VERSION}_1_amd64.deb
ARG R_PACKAGE_URL=https://cdn.rstudio.com/r/${R_OS}/pkgs/${R_PACKAGE}
RUN curl -fsSL -O ${R_PACKAGE_URL} && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -f -y ./${R_PACKAGE} && \
    rm ${R_PACKAGE} && \
    rm -rf /var/lib/apt/lists/*

# Download and install RStudio Connect.
ARG CONNECT_VERSION=1.8.8
ARG CONNECT_SHORT_VERSION=1.8.8
ARG CONNECT_PACKAGE=rstudio-connect_${CONNECT_VERSION}_amd64.deb
ARG CONNECT_URL=https://cdn.rstudio.com/connect/${CONNECT_SHORT_VERSION}/${CONNECT_PACKAGE}
RUN curl -sL -o rstudio-connect.deb ${CONNECT_URL} && \
    apt-get update && \
    gdebi -n rstudio-connect.deb && \
    rm rstudio-connect.deb && \
    rm -rf /var/lib/apt/lists/*

# # Copy our configuration over the default install configuration
# COPY rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg

# Use a remote license server issuing floating licenses
RUN /opt/rstudio-connect/bin/license-manager license-server licensing.company.com

# Expose the configured listen port.
EXPOSE 3939

# Launch Connect.
CMD ["--config", "/etc/rstudio-connect/rstudio-connect.gcfg"]
ENTRYPOINT ["/opt/rstudio-connect/bin/connect"]