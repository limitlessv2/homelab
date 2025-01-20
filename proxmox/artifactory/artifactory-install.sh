#!/usr/bin/env bash
# Copyright (c) 2021-2025 community-scripts ORG
# Author: kristocopani
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Setting up Environment variables and directories"
mkdir -p /opt/jfrog
export JFROG_HOME=/opt/jfrog

msg_info "Downloading Artifactory Community Edition"
sudo curl -g -L -o /opt/jfrog/jfrog-artifactory-oss-7.98.8-linux.tar.gz 'https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/7.98.8/jfrog-artifactory-oss-7.98.8-linux.tar.gz'

msg_info "Installing Artifactory"
tar -xvf jfrog-artifactory-oss-7.98.8-linux.tar.gz
mv artifactory-oss-7.98.8/ artifactory
/opt/jfrog/artifactory/app/bin/installService.sh

#edit db settings in /opt/jfrog/artifactory/var/etc/system.yaml
systemctl start artifactory.service 

msg_ok "Configured and Started Artifactory Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/jfrog/jfrog-artifactory-oss-7.98.8-linux.tar.gz
apt-get -y autoremove
apt-get -y autoclean
msg_ok "Cleaned"
