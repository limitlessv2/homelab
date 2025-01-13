#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: kristocopani
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://jfrog.com/artifactory/

# App Default Values
APP="Artifactory"
var_tags="artifact-management"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="debian"
var_version="12"
var_unprivileged="1"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources
    if [[ ! -d /opt/artifactory ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    msg_info "Updating $APP LXC"
    apt-get update &>/dev/null
    apt-get -y upgrade &>/dev/null
    msg_ok "Updated $APP LXC"
    exit
}

function install_artifactory() {
    msg_info "Installing Dependencies"
    $STD apt-get install -y openjdk-11-jre curl sudo mc
    msg_ok "Installed Dependencies"

    msg_info "Downloading Artifactory Community Edition"
    ARTIFACTORY_VERSION="7.49.8" # Update to the latest version if needed
    wget -qO /tmp/artifactory.tar.gz https://releases.jfrog.io/artifactory/artifactory-pro/org/artifactory/pro/jfrog-artifactory-oss/${ARTIFACTORY_VERSION}/jfrog-artifactory-oss-${ARTIFACTORY_VERSION}-linux.tar.gz
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
}

start
build_container
description
install_artifactory

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8081${CL}"
