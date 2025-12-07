#powershell -ExecutionPolicy Bypass -File F:\DoH\undo_doh.ps1
#powershell -ExecutionPolicy Bypass -File F:\DoH\doh.ps1

# ==========================================
#  UNDO DoH + IPv6 Restore + DNS Restore
#  Restore Windows to default network config
# ==========================================

Write-Host "=== UNDO DoH + restore default settings ===" -ForegroundColor Cyan

# 1. Restore default DNS settings (automatic DHCP)
Write-Host "[1/5] Restoring DNS to automatic DHCP..." -ForegroundColor Yellow

$interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

foreach ($iface in $interfaces) {
    $alias = $iface.Name
    Write-Host "    Restoring DNS on: $alias" -ForegroundColor Yellow
    Set-DnsClientServerAddress -InterfaceAlias $alias -ResetServerAddresses -ErrorAction SilentlyContinue
}

Write-Host "    DNS restored to DHCP." -ForegroundColor Green

# 2. Remove Cloudflare DoH registry entry
Write-Host "[2/5] Removing Cloudflare DoH registry entries..." -ForegroundColor Yellow

reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\Doh" /f | Out-Null

Write-Host "    DoH provider removed." -ForegroundColor Green

# 3. Re-enable IPv6 on all interfaces
Write-Host "[3/5] Re-enabling IPv6 on all network interfaces..." -ForegroundColor Yellow

foreach ($iface in $interfaces) {
    $alias = $iface.Name
    Write-Host "    Enabling IPv6 on: $alias" -ForegroundColor Yellow
    Enable-NetAdapterBinding -Name $alias -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
}

Write-Host "    IPv6 re-enabled." -ForegroundColor Green

# 4. Remove firewall rules blocking port 53 (DNS)
Write-Host "[4/5] Removing firewall DNS-block rules..." -ForegroundColor Yellow

$fwRuleNames = @(
    "Block-PlainDNS-UDP-Out",
    "Block-PlainDNS-TCP-Out",
    "Block-PlainDNS-UDP-In",
    "Block-PlainDNS-TCP-In"
)

foreach ($name in $fwRuleNames) {
    if (Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue) {
        Write-Host "    Removing rule: $name" -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    }
}

Write-Host "    Firewall DNS rules removed." -ForegroundColor Green

# 5. Clear DoH server associations
Write-Host "[5/5] Clearing DoH server configuration..." -ForegroundColor Yellow

try {
    Clear-DnsClientDohServerAddress -ErrorAction SilentlyContinue
} catch {}

Write-Host "    DoH config cleared." -ForegroundColor Green

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "System restored to default DNS, IPv6, and firewall settings." -ForegroundColor Green
Write-Host "Restart Windows to fully apply changes." -ForegroundColor Yellow
