cp ./config/ssh.conf /etc/ssh/sshd_config.d/ssh.conf
systemctl restart sshd

echo "Configuration completed successfully!"