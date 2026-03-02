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
