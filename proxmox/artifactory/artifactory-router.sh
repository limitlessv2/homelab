cat <<EOF > /etc/systemd/system/artifactory-router.service
[Unit]
Description=Artifactory Router Service
After=network.target

[Service]
Type=forking
User=artifactory
ExecStart=/opt/artifactory/app/router/bin/router.sh start
ExecStop=/opt/artifactory/app/router/bin/router.sh stop
PIDFile=/opt/artifactory/var/run/router.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start artifactory-router
systemctl enable artifactory-router

