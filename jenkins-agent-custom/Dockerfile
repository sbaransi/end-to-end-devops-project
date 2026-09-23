FROM jenkins/inbound-agent:3385.vf1123fb_515da_-1

USER root

COPY ZscalerRootCA.pem /usr/local/share/ca-certificates/ZscalerRootCA.crt

RUN update-ca-certificates \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-pip \
       python3-venv \
       docker-cli \
       curl \
    && rm -rf /var/lib/apt/lists/*

# Let the jenkins user use the host Docker socket (group id 1001 on this machine)
RUN groupadd --gid 1001 docker \
    && usermod -aG docker jenkins

USER jenkins
