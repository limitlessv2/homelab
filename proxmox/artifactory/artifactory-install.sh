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

msg_info "Installing Dependencies"
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    mc \
    sudo \
    openjdk-17-jre
msg_ok "Installed Dependencies"

msg_info "Downloading Artifactory Community Edition"
ARTIFACTORY_VERSION="7.77.5" # Update this to the latest version if needed
wget -qO /tmp/artifactory.tar.gz https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/${ARTIFACTORY_VERSION}/jfrog-artifactory-oss-${ARTIFACTORY_VERSION}-linux.tar.gz
msg_ok "Downloaded Artifactory"

msg_info "Installing Artifactory"
tar -xzf /tmp/artifactory.tar.gz -C /opt/
mv /opt/artifactory-* /opt/artifactory
/opt/artifactory/app/bin/installService.sh
msg_ok "Installed Artifactory"

msg_info "Configuring Artifactory Service"
cat <<EOF >/etc/systemd/system/artifactory.service
[Unit]
Description=JFrog Artifactory Community Edition
After=network.target

[Service]
Type=forking
ExecStart=/opt/artifactory/app/bin/artifactoryManage.sh start
ExecStop=/opt/artifactory/app/bin/artifactoryManage.sh stop
User=root
Group=root
Restart=always
TimeoutSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable -q --now artifactory
msg_ok "Configured and Started Artifactory Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /tmp/artifactory.tar.gz
apt-get -y autoremove
apt-get -y autoclean
msg_ok "Cleaned"
