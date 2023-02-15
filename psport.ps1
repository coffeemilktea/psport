#Script made to open firewall ports
#Testing

$ports = Read-Host "Enter the port numbers you want to open:"
# direction must be Inbound or Outbound
$direction = Read-Host "Enter whether Inbound or Outbound:"

# Validate user input for direction
if ($direction -ne "Inbound" -and $direction -ne "Outbound") {
  Write-Host "Invalid direction. Please enter either 'Inbound' or 'Outbound'."
  Exit
}

# Set Array for multiple ports
$portArray = $ports.Split(',')

# Use inputs to generate firewall rules
$errors = foreach ($port in $portArray) {
  try {
    New-NetFirewallRule -DisplayName "Allow $direction Traffic on Port $port" -Direction $direction -Action Allow -Protocol TCP -LocalPort $port -Profile Any -ErrorAction Stop
  }
  catch {
    $_.Exception.Message
  }
}

# Check for errors and output message
if ($errors) {
  Write-Host "The following errors occurred while creating firewall rules:`n$errors" -ForegroundColor Red
}
else {
  Write-Host "Firewall rules created to allow $direction traffic on ports $ports"
}
