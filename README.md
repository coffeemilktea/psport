# psport

A quick and robust PowerShell tool to manage Windows Defender Firewall rules for TCP/UDP ports and ranges.

## Features

- 🛡️ **Administrator Check**: Automatically verifies that the script is running with elevated privileges.
- ⚙️ **PowerShell parameter support**: Can be run fully interactively (prompting for inputs) or via command-line arguments.
- 🔄 **TCP/UDP & Both protocols**: Choose between `TCP`, `UDP`, or `Both` (creates dual rules).
- 🔀 **Allow/Block Action**: Support for both allowing or blocking traffic.
- 🔢 **Port Ranges**: Supports opening single ports, lists (e.g., `80,443`), or ranges (e.g., `8000-8010`).
- 🛑 **Duplicate Prevention**: Queries existing rules first to prevent cluttering your firewall configuration with duplicate rules.

## Prerequisites

- **Windows PowerShell 5.1** or **PowerShell Core (6+)**.
- **Administrator privileges**: The script must be run from an elevated PowerShell console.

## Usage

### Interactive Mode

Simply execute the script in an elevated PowerShell session, and you will be prompted for the required arguments:

```powershell
.\psport.ps1
```

PowerShell will prompt you to enter the ports and the direction.

### Command-line Parameters

You can bypass interactive prompts by specifying parameters directly:

```powershell
.\psport.ps1 -Ports <PortListOrRange> -Direction <Inbound|Outbound> [-Protocol <TCP|UDP|Both>] [-Action <Allow|Block>]
```

### Parameters

- `-Ports` *(Mandatory)*: A comma-separated list of ports, a single port, or a range (e.g., `80`, `80,443`, `8000-8010`).
- `-Direction` *(Mandatory)*: Either `Inbound` or `Outbound`.
- `-Protocol` *(Optional)*: Either `TCP`, `UDP`, or `Both`. Defaults to `TCP`.
- `-Action` *(Optional)*: Either `Allow` or `Block`. Defaults to `Allow`.

---

## Examples

### 1. Open HTTP/HTTPS Ports (TCP, Inbound)
```powershell
.\psport.ps1 -Ports 80,443 -Direction Inbound -Protocol TCP
```

### 2. Open a Port Range (UDP, Inbound)
```powershell
.\psport.ps1 -Ports 8000-8010 -Direction Inbound -Protocol UDP
```

### 3. Open a Port for Both TCP and UDP (Inbound)
```powershell
.\psport.ps1 -Ports 3389 -Direction Inbound -Protocol Both
```

### 4. Block a Port (Inbound)
```powershell
.\psport.ps1 -Ports 21 -Direction Inbound -Action Block
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
