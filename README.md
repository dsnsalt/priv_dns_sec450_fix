# SEC450 DNS Fix

Use if there are DNS restrictions on your network that prevents starting pi-hole in 2.1 and 5.3.

- Valid for at least version `SEC450_2_G01_01`

## Download and Run

- Run prior to running lab 2.1

```
sudo systemctl start systemd-resolved
wget https://raw.githubusercontent.com/dsnsalt/priv_dns_sec450_fix/main/pihole-start-fix.sh -O /labs/pihole-start-fix.sh
cd /labs
chmod +x pihole-start-fix.sh
./pihole-start-fix.sh
```

## Usage

### Apply Fix

- The script will require you to get your network's DNS server address using your host machine
- Running the script will prompt you for an action, choose option 1

```
$ /labs/pihole-start-fix.sh
Select action to perform:
        1) Apply lab DNS fix
        2) Undo lab DNS fix
[1/2]: 1
```
- You will be asked for the DNS Server you got from your host machine

```
Specify a valid DNS IP address: 192.168.145.2 <--- Replace with IP gotten from host machine
```

- Configs will be updated to use the same DNS as your host system instead of Google's

### Undo Fix

- Running the script will prompt you for an action, choose option 2

```
$ /labs/pihole-start-fix.sh
Select action to perform:
        1) Apply lab DNS fix
        2) Undo lab DNS fix
[1/2]: 2
```

- Configs will be updated to remove any fixes that were implemented
