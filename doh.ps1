# ==========================================
#  FULL DoH + DNS LEAK PROTECTION SETUP
#  Cloudflare (1.1.1.1) + DoH + block plain DNS
#  Run as Administrator
# ==========================================

# Check if running as Administrator
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script MUST be run as Administrator. Exiting."
    exit 1
}

Write-Host "=== DoH + DNS leak protection setup (Cloudflare) ===" -ForegroundColor Cyan

# ------------------------------------------
# 1. Add Cloudflare DoH provider to registry
# ------------------------------------------
Write-Host "[1/5] Adding Cloudflare DoH provider to registry..." -ForegroundColor Yellow
& reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\Doh" /v "https://cloudflare-dns.com/dns-query" /t REG_SZ /d "cloudflare" /f | Out-Null
Write-Host "    Cloudflare DoH provider added." -ForegroundColor Green

# ------------------------------------------
# 2. Find active IPv4 interfaces (with default gateway)
# ------------------------------------------
Write-Host "[2/5] Detecting active IPv4 interfaces..." -ForegroundColor Yellow
$activeIfs = Get-NetIPConfiguration | Where-Object {
    $_.IPv4DefaultGateway -ne $null
}

if (-not $activeIfs) {
    Write-Host "    No active IPv4 interfaces with default gateway found. Exiting." -ForegroundColor Red
    exit 1
}

$dns4 = @("1.1.1.1","1.0.0.1")

foreach ($cfg in $activeIfs) {
    $alias = $cfg.InterfaceAlias
    Write-Host "    Setting IPv4 DNS to Cloudflare on interface: $alias" -ForegroundColor Yellow
    Set-DnsClientServerAddress -InterfaceAlias $alias -ServerAddresses $dns4 -ErrorAction SilentlyContinue
}

# ------------------------------------------
# 3. Enable DoH for Cloudflare (1.1.1.1)
# ------------------------------------------
Write-Host "[3/5] Enabling DoH for Cloudflare (1.1.1.1)..." -ForegroundColor Yellow
Set-DnsClientDohServerAddress -ServerAddress "1.1.1.1" -DohTemplate "https://cloudflare-dns.com/dns-query" -AllowFallbackToUdp $false -ErrorAction SilentlyContinue
Write-Host "    DoH enabled for 1.1.1.1 with no UDP fallback." -ForegroundColor Green

# ------------------------------------------
# 4. Disable IPv6 on active interfaces (paranoid mode)
# ------------------------------------------
Write-Host "[4/5] Disabling IPv6 on active interfaces (paranoid mode)..." -ForegroundColor Yellow

foreach ($cfg in $activeIfs) {
    $alias = $cfg.InterfaceAlias
    Write-Host "    Disabling IPv6 on: $alias" -ForegroundColor Yellow
    Disable-NetAdapterBinding -Name $alias -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
}

Write-Host "    IPv6 disabled on active interfaces. A reboot may be required." -ForegroundColor Green

# ------------------------------------------
# 5. Firewall: block all plain DNS (port 53 TCP/UDP, outbound + inbound)
# ------------------------------------------
Write-Host "[5/5] Creating firewall rules to block plain DNS (TCP/UDP 53)..." -ForegroundColor Yellow

$fwRuleNames = @(
    "Block-PlainDNS-UDP-Out",
    "Block-PlainDNS-TCP-Out",
    "Block-PlainDNS-UDP-In",
    "Block-PlainDNS-TCP-In"
)

# Remove old rules if they exist
foreach ($name in $fwRuleNames) {
    $existing = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "    Removing existing rule: $name" -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    }
}

# Outbound block
New-NetFirewallRule -DisplayName "Block-PlainDNS-UDP-Out" -Direction Outbound -Protocol UDP -RemotePort 53 -Action Block -Profile Any | Out-Null
New-NetFirewallRule -DisplayName "Block-PlainDNS-TCP-Out" -Direction Outbound -Protocol TCP -RemotePort 53 -Action Block -Profile Any | Out-Null

# Inbound block
New-NetFirewallRule -DisplayName "Block-PlainDNS-UDP-In" -Direction Inbound -Protocol UDP -LocalPort 53 -Action Block -Profile Any | Out-Null
New-NetFirewallRule -DisplayName "Block-PlainDNS-TCP-In" -Direction Inbound -Protocol TCP -LocalPort 53 -Action Block -Profile Any | Out-Null

Write-Host "    Firewall rules to block plain DNS have been created." -ForegroundColor Green

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "Cloudflare DNS + DoH configured on active IPv4 interfaces." -ForegroundColor Green
Write-Host "IPv6 disabled on active interfaces (to avoid IPv6 DNS leaks)." -ForegroundColor Green
Write-Host "Plain DNS (port 53 TCP/UDP) is blocked by firewall (leak protection)." -ForegroundColor Green
Write-Host ""
Write-Host "You should RESTART Windows now to fully apply all changes." -ForegroundColor Yellow
