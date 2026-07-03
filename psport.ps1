<#
.SYNOPSIS
    Opens firewall ports.
.DESCRIPTION
    A utility script to open inbound or outbound ports in the Windows Defender Firewall.
    Requires Administrator privileges.
.PARAMETER Ports
    An array of port numbers or ranges (e.g., 80, 443, 8000-8010) to open.
.PARAMETER Direction
    The direction of the traffic: Inbound or Outbound.
.PARAMETER Protocol
    The protocol to apply: TCP, UDP, or Both. Defaults to TCP.
.PARAMETER Action
    Whether to Allow or Block traffic. Defaults to Allow.
.EXAMPLE
    .\psport.ps1 -Ports 80, 443 -Direction Inbound -Protocol TCP
.EXAMPLE
    .\psport.ps1 -Ports 8000-8010 -Direction Inbound -Protocol UDP
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter port numbers (comma-separated, e.g., 80, 443 or a range like 8000-8010)")]
    [string[]]$Ports,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Enter direction: Inbound or Outbound")]
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction,

    [Parameter(Mandatory = $false, Position = 2)]
    [ValidateSet("TCP", "UDP", "Both")]
    [string]$Protocol = "TCP",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Allow", "Block")]
    [string]$Action = "Allow"
)

# 1. Administrator Privilege Check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[-] ERROR: This script must be run as an Administrator." -ForegroundColor Red
    Write-Host "Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    Exit 1
}

# 2. Parse and Validate Ports
$parsedPorts = @()
foreach ($p in $Ports) {
    $split = $p -split ','
    foreach ($item in $split) {
        $trimmed = $item.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }
        
        if ($trimmed -match '^\d+$') {
            $portVal = [int]$trimmed
            if ($portVal -ge 1 -and $portVal -le 65535) {
                $parsedPorts += $portVal
            } else {
                Write-Host "[-] ERROR: Invalid port number: $portVal. Ports must be between 1 and 65535." -ForegroundColor Red
                Exit 1
            }
        } elseif ($trimmed -match '^(\d+)-(\d+)$') {
            $start = [int]$Matches[1]
            $end = [int]$Matches[2]
            if ($start -ge 1 -and $start -le 65535 -and $end -ge 1 -and $end -le 65535 -and $start -le $end) {
                $parsedPorts += "$start-$end"
            } else {
                Write-Host "[-] ERROR: Invalid port range: $trimmed. Must be between 1 and 65535, with start <= end." -ForegroundColor Red
                Exit 1
            }
        } else {
            Write-Host "[-] ERROR: Invalid port format: '$trimmed'. Must be a number or a range (e.g., 80 or 8000-8010)." -ForegroundColor Red
            Exit 1
        }
    }
}

if ($parsedPorts.Count -eq 0) {
    Write-Host "[-] ERROR: No valid ports specified." -ForegroundColor Red
    Exit 1
}

# Determine protocols to apply
$protocolsToApply = @()
if ($Protocol -eq "Both") {
    $protocolsToApply += "TCP"
    $protocolsToApply += "UDP"
} else {
    $protocolsToApply += $Protocol
}

$successCount = 0
$errors = @()

# 3. Create Firewall Rules
foreach ($port in $parsedPorts) {
    foreach ($proto in $protocolsToApply) {
        # Construct rule name matching the style (appended with protocol for clarity)
        $displayName = "$Action $Direction Traffic on Port $port"
        if ($proto -ne "TCP" -or $Protocol -eq "Both") {
            $displayName += " ($proto)"
        }
        
        # Check if rule already exists
        $existingRule = Get-NetFirewallRule -DisplayName $displayName -ErrorAction SilentlyContinue
        if ($existingRule) {
            Write-Host "[*] Rule already exists: '$displayName'. Skipping." -ForegroundColor Yellow
            continue
        }

        try {
            New-NetFirewallRule -DisplayName $displayName `
                                -Direction $Direction `
                                -Action $Action `
                                -Protocol $proto `
                                -LocalPort $port `
                                -Profile Any `
                                -ErrorAction Stop | Out-Null
            
            Write-Host "[+] Successfully created rule: '$displayName'" -ForegroundColor Green
            $successCount++
        }
        catch {
            $errors += "Port $port ($proto): $($_.Exception.Message)"
        }
    }
}

# 4. Display Results
if ($errors.Count -gt 0) {
    Write-Host "`n[-] The following errors occurred while creating firewall rules:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  - $err" -ForegroundColor Red
    }
}

if ($successCount -gt 0) {
    Write-Host "`n[+] Completed! $successCount firewall rule(s) created/verified successfully." -ForegroundColor Green
}
