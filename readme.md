### Step 1
Run a git clone of the current repository on your external server.

### Step 2
Execute file `external.sh`.
```
bash external.sh
```

### Step 3  
Run a git clone of the current repository on your home server.

### Step 4  
Edit the file `home-start.sh`, set the IP address of the external server to the `SERVER_HOST` variable.

### Step 5
Generate ssh key to connect to our external server. Run `home-keygen.sh`.
```
bash home-keygen.sh 
```  
Copy the contents of the public key to an external server in an `~/.ssh/authorized_keys`.  

### Step 6
Execute file `home-start.sh` on home server.
```
bash home-start.sh
```

