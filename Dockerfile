FROM pritunl/archlinux

RUN pacman -S --noconfirm ansible unzip make openssh && \
    curl -SLo terraform.zip https://releases.hashicorp.com/terraform/0.7.2/terraform_0.7.2_linux_amd64.zip && \
    unzip terraform.zip -d /usr/local/bin/ && \
    curl -SLo packer.zip https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip && \
    unzip packer.zip -d /usr/local/bin/ && \
    mv /usr/local/bin/packer /usr/local/bin/packer-io && \
    pacman -Sc --noconfirm
COPY . /usr/local/src/clickcount-infra/
WORKDIR /usr/local/src/clickcount-infra/
ENTRYPOINT ["/bin/bash", "/usr/local/src/clickcount-infra/scripts/entrypoint.sh"]
VOLUME terraform/state
