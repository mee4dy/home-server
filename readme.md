## General information
This method consists of setting up a TCP tunnel between two servers: 
**Server A** - External server with a public IP (for example, a cheap VPS).
**Server B** - Home server without public IP.
All requests coming to server A are forwarded through a tunnel to server B, which hosts the target services for processing requests (for example, websites).
Thus, you do not need to configure port forwarding on the router and buy an external IP from your Internet provider.  
This allows you to host your projects even on your laptop.

`Attention! Docker and docker compose must be installed on your server in advance.`

The repository contains two options for implementing traffic tunneling: 
**1. Method** - ssh reverse tunnel. 
This is the simplest and most affordable option for creating a TСP tunnel.
But it has the disadvantage of not being able to forward the client’s real IP address to server B. 
Because of this, difficulties arise with maintaining statistics on user IP addresses or IP blocking. 
All incoming requests in this case will have local IP 127.0.0.1.
If this is not a problem for you, then this option is for you.
**2. Method** - tunnel through Wireguard VPN and iptables.
The advantage is that the problem of option 1 is solved; in this option, the client’s real IP comes to server B and it is not difficult to forward it further (for example, through Nginx) to the target port of the service.
As a bonus, you get a full-fledged VPN service, which you can use on your phone or other devices if necessary.
There is also a convenient web interface for enabling/disabling the tunnel and creating VPN clients.

## Reverse SSH Tunneling (Method 1)
**The external server must have openssh-server installed.**

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
Run the docker compose service to establish tunnel connections and port forwarding
```
docker-compose -f docker-compose.ssh.yml up -d
```

## Wireguard tunneling (Method 2)
**iptables must be installed, you can install it with the following command: sudo apt-get install iptables**

### Step 1 (Server A and Server B)
Add the following parameters to the Linux kernel settings by running the commands:
```
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```

### Step 2 (Server A - External Server)
Perform a git clone of this repository on your external server in any directory convenient for you.
Go to the project directory and configure the `.env` file, you must specify the required parameter `SERVER_HOST`. It must contain the IP address of the external server.
Run: `cp .env.example .env` and edit `.env` file.
It is not necessary to fill out the remaining parameters. 
For a list of all valid parameters, see `docker-compose.wg-server.yml`.

After setting up the env file, start the server part of the service by running the command:
```
docker-compose -f docker-compose.wg-server.yml up -d
```
Open the following URL in your web browser: `http://EXTERNAL_IP:51821`, where `EXTERNAL_IP` is the IP address of your external server.
Enter password from .env (or default 123qwezxc)
Create new client with name: "home-server".
Click the button to download the client connection configuration.

The server part is finished!

### Step 3 (Server B - Home Server)
Perform a git clone of this repository on your external server in any directory convenient for you.
Create file `./wg-config/home-server.conf` in the home server repository directory.
```
mkdir ./wg-config && nano ./wg-config/home-server.conf
```
Paste the contents of the connection configuration file that you downloaded in the previous step.
Launch the client part:  
```
docker-compose -f docker-compose.wg-client.yml up -d
```

### Additional Information
You can configure the list of external ports for forwarding using the env parameter: SERVER_PORTS.
If you have problems with wireguard tunnel, use command: `service network-manager restart`;
If you have message in log client: "wg-quick: 'wg0' already exists", run that: `ip link delete wg0`;

# Ready!
After this, you can send requests to your external server (Server A) and they will be proxied to (Server B).