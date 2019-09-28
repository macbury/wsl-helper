# Run as administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Get lan ip of the computer
$lanIp = $(ipconfig | where {$_ -match 'IPv4.+\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' } | out-null; $Matches[1])

# Get lan ip of the wsl container
$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $remoteport = $matches[0];
  echo "Wsl ip: $remoteport";
} else{
  echo "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

# Fix expo mapping of the hostname
bash.exe -c "echo 'export EXPO_PACKAGER_HOSTNAME=$lanIp' > /home/macbury/.env.global"
# Update windows host name
python C:\Users\me\Projects\fix_hosts.py $remoteport;

# #[Ports]

# All the ports you want to forward separated by coma
$ports=@(80,8080,443,10000,3000,5000,4555,19000,19001,19002,19003,19004,19005,19006,5037,8081);


#[Static ip]
#You can change the addr to your ip config to listen to a specific address
$addr='127.0.0.1'; # point always to localhost, this can break mapping!
$secAddr='0.0.0.0';
$ports_a = $ports -join ",";

Start-Process powershell -Verb runas

#Remove Firewall Exception Rules
iex "Remove-NetFireWallRule -DisplayName 'MyWSL 2 Firewall Unlock' ";

#adding Exception Rules for inbound and outbound Rules
iex "New-NetFireWallRule -DisplayName 'MyWSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'MyWSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  echo "Setup port $port to $remoteport"
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr";
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$secAddr";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$secAddr connectport=$port connectaddress=$remoteport";
}
