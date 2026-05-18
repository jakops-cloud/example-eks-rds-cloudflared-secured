#!/bin/bash
curl -fsSl https://pkg.cloudflare.com/cloudflared-ascii.repo | tee /etc/yum.repos.d/cloudflared.repo

yum update -y
yum install -y cloudflared jq

SECRET_JSON=$(aws secretsmanager get-secret-value --region ${region} --secret-id ${secret_name} | jq -r .SecretString)
CLOUDFLARE_TOKEN=$(echo $SECRET_JSON | jq -r .tunnel_token)

mkdir -p /etc/cloudflared
tee /etc/cloudflared/config.yml <<EOL
warp-routing:
  enabled: ${warp_routing_enabled}
EOL

cat > /etc/systemd/system/cloudflared.service <<EOL
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=cloudflared
ExecStart=/usr/bin/cloudflared tunnel --config /etc/cloudflared/config.yml --no-autoupdate run --token $CLOUDFLARE_TOKEN
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL

useradd -r -s /bin/false cloudflared
chown -R cloudflared:cloudflared /etc/cloudflared

systemctl daemon-reload
systemctl enable cloudflared
systemctl start cloudflared
