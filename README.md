# SEC450 DNS Fix

Use if there are DNS restrictions on your network that prevents starting pi-hole in 2.1 and 5.3.

- Valid for version `SEC450_2_G01_01`

## Download and Run

```
wget https://raw.githubusercontent.com/dsnsalt/priv_dns_sec450_fix/main/pihole-start-fix.sh -O /labs/pihole-start-fix.sh
cd /labs
chmod +x pihole-start-fix.sh
./pihole-start-fix.sh
```

## Requirements

- Ensure Network adapter is set to `NAT` or `Bridged`
- Must be run before the **Exercise Preparation** step of Lab
    - If running after the **Exercise Preparation** step, run the `reset_vm.sh` script and the attempt to run the above commands again
    ```
    /labs/reset_vm.sh 
    ```
    - Once the script has been downloaded and run, repeat the steps in the **Exercise Preparation** step
    
## Usage

```
$ pihole-start-fix.sh <option> [IP ADDRESS]
```

### Options

- **apply**: Apply the fix using the VM's default DNS server. Default option.
- **reset**: Remove the defined DNS servers and use the default configuration.
- **override**: Override the default use of the VM's default DNS server and specify the DNS server IPv4 address to use.
    - Requires an IPv4 address to be supplied when invoking.

### Apply Fix

- Running the script with the `apply` option will automatically use the VM's DNS server.
- The `apply` option is the default option when running the script and will used if no argument is provided.
```
/labs/pihole-start-fix.sh apply
```

```
$ /labs/pihole-start-fix.sh apply
Fix applied to 2.1
Fix applied to 5.3
```

- Configs will be updated to use the same DNS as your host system instead of Google's

- You will be asked for the DNS Server you got from your host machine


- Configs will be updated to use the same DNS as your VM instead of Google's.

### Undo Fix

- Running the script with the `reset` option will remove the fix.
```
/labs/pihole-start-fix.sh reset
```

```
$ /labs/pihole-start-fix.sh reset
Fix has been removed from 2.1
Fix has been removed from 5.3
```

- Configs will be updated to remove any fixes that were implemented.

### Overide

- To override the use of the VM's DNS server, use the `override` option and provide an IPv4 address as an argument.

```
/labs/pihole-start-fix.sh override <IPv4 Address>
```

```
$ /labs/pihole-start-fix.sh override 192.168.0.50
Fix applied to 2.1
Fix applied to 5.3
```

- Configs will be updated to use the supplied DNS address.

## Troubleshooting

### Requesting IP Address

- Occurs during the use of the `apply` or `override` options.

```
Specify a valid DNS IP address: 192.168.0.50 <--- Replace with IPv4 address
```

**Reason**:
    - The VM's DNS or the supplied DNS address cannot be queried for a record or is not a valid IPv4 address.

**Fix**:
    - Check that the DNS configuration on the VM and ensure that the resolver service has a valid address.
    - On the host machine (not the VM), get the DNS server that host uses and enter it instead of the VM's DNS.

### IP Already Exists

- Occurs during the use of the `apply` or `override` options.

```
Cannot use 192.168.0.50 as the DNS server, it already exists as a DNS server in the lab config file
```

**Reason**:
    - The IP from the VM or the provided override IP already exists in the VM.

**Fix**:
    - Specify a different VM or reset the labs use the lab reset script.