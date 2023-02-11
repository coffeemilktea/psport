$ports = Read-Host "Enter the port numbers you want to open:"
$direction = Read-Host "Enter whether Inbound or Outbound rule:"

# Set Array for multiple ports
$portArray = $ports.Split(',')

# Use inputs to generate firewall rules
foreach ($port in $portArray) {
  New-NetFirewallRule -DisplayName "Allow $direction Traffic on Port $port" -Direction $direction -Action Allow -Protocol TCP -LocalPort $port -Profile Any
}

Write-Host "Firewall rules created to allow $direction traffic on ports $ports"
