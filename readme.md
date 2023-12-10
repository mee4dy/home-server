Attention! Docker and docker compose must be installed on your server in advance.
The external server must have openssh-server installed.


### Step 1
Run the command on your external server to create tunnels:
```
echo "GatewayPorts yes" > /etc/ssh/sshd_config.d/ssh.conf && systemctl restart sshd
```

### Step 2
Generate ssh key to connect to our external server. Run `bash ./scripts/ssh-keygen.sh`.
Copy the contents of the public key to an external server in an `~/.ssh/authorized_keys`.  

### Step 3  
Prepare the env file, copy the example file, and change the content to match your access settings.
```
cp .env.example .env
```

### Step 4  
Run the docker composite service to establish tunnel connections and port forwarding
```
docker-compose up -d
```