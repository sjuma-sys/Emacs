# ================================
# BLOCK MICROSOFT ACCOUNT / AAD SIGN-IN
# ================================

# Block Microsoft accounts (NoConnectedUser = 3)
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "NoConnectedUser" -PropertyType DWord -Value 3 -Force | Out-Null

# Block Azure AD / Workplace Join
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" `
    -Name "BlockAADWorkplaceJoin" -PropertyType DWord -Value 1 -Force | Out-Null

# Disable Web Sign-in
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "AllowWebSignIn" -PropertyType DWord -Value 0 -Force | Out-Null

# (Optional) Block consumer Microsoft accounts globally
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" `
    -Name "DisableUserAuth" -PropertyType DWord -Value 1 -Force | Out-Null

Write-Host "Registry changes applied. A restart or sign-out/sign-in is recommended."


# ================================
# BLOCK MICROSOFT 365 CLOUD ENDPOINTS
# ================================

$ruleNamePrefix = "Block-M365-"

$domains = @(
    "login.microsoftonline.com",
    "login.microsoft.com",
    "aadcdn.msauth.net",
    "officecdn.microsoft.com",
    "officeclient.microsoft.com",
    "graph.microsoft.com",
    "outlook.office365.com",
    "*.office.com",
    "*.microsoftonline.com",
    "*.msauth.net",
    "*.msftauth.net",
    "*.live.com"
)

foreach ($d in $domains) {
    $ruleName = "$ruleNamePrefix$d"
    # Remove existing rule with same name if present
    Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule

    New-NetFirewallRule `
        -DisplayName $ruleName `
        -Direction Outbound `
        -Action Block `
        -Enabled True `
        -Profile Any `
        -RemoteFqdn $d `
        -Description "Block Microsoft 365 / Microsoft account endpoint $d"
}

Write-Host "Firewall rules created to block Microsoft 365 endpoints."

# ================================
# OPTIONAL: BLOCK COMMON M365 IP RANGES (EXAMPLE)
# ================================
# NOTE: These are example ranges; Microsoft changes ranges over time.
# Use with caution – this can impact other Microsoft services.

$ruleName = "Block-M365-IPs"

# Remove existing rule if present
Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule

New-NetFirewallRule `
    -DisplayName $ruleName `
    -Direction Outbound `
    -Action Block `
    -Enabled True `
    -Profile Any `
    -RemoteAddress "13.64.0.0/11","40.96.0.0/12","52.96.0.0/12" `
    -Description "Broad block of common Microsoft 365 IP ranges (may affect other Microsoft services)."

Write-Host "Optional IP-based firewall rule created."

#https://linkstorage.linkfire.com/medialinks/images/663d2377-6547-4253-b79e-5bec1ef84830/artwork-600x315.jpg
#https://www.google.com/search?vsrid=COWGrc3g78nX5QEQAhgBIiQ5MGVmYzhjZS02M2E4LTQ5MDMtODZiNC00OTg4ZDhiMjdkNTUyeyICcmQoFUJzCi5sZmUtZHVtbXk6OTAxNjA2OTctNzI0YS00MzE5LTgzZTktYjYzMWE2MTdkYjZkEkEKPy9ibnMvcmQvYm9yZy9yZC9ibnMvbGVucy1mcm9udGVuZC1hcGkvcHJvZC5sZW5zLWZyb250ZW5kLWFwaS8xNziPz-r088CTAw&vsint=CAIqDAoCCAcSAggKGAEgATojChYNAAAAPxUAAAA_HQAAgD8lAACAPzABENAHGOIEJQAAgD8&udm=26&lns_mode=un&vsdim=976,610&gsessionid=bJqPTBCHlbTmjEwDdc0ea4-WZ4uFE-djro9_raQiTvOjPy7wppLyGg&lsessionid=-Jov9wbHTh3ycR-cCsa-EhRKIeiNQGPTLdRTQcpeuJjSs49W-FJtxQ&lns_surface=26&authuser=0&lns_vfs=e&qsubts=1774642882116&hl=en-GB#sv=CAMSVhoyKhBlLTVtclF6Nm5xZkR6aWNNMg41bXJRejZucWZEemljTToONm5xcGFFUlZJZDhubU0gBCocCgZtb3NhaWMSEGUtNW1yUXo2bnFmRHppY00YADABGAcgyJ31sQVKCBABGAEgASgB
#https://www.melodicmag.com/wp-content/uploads/2019/09/camila-cabello-liar-shameless-romance.jpg
