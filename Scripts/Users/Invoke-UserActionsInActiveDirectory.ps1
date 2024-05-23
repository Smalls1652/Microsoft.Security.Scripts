<#PSScriptInfo

.VERSION 1.0.0

.GUID bd35d973-606d-4c33-b02b-3cd3d20a1f22

.AUTHOR Tim Small

.COMPANYNAME Smalls.Online

.COPYRIGHT 2024

.TAGS activedirectory security users

.LICENSEURI https://raw.githubusercontent.com/Smalls1652/Microsoft.Security.Scripts/main/LICENSE

.PROJECTURI https://github.com/Smalls1652/Microsoft.Security.Scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

#Requires -Module @{ ModuleName = "ActiveDirectory"; ModuleVersion = "1.0.1" }

<#
.SYNOPSIS
    Disable and/or force password reset for user(s) in Active Directory.
.DESCRIPTION
    Disable and/or force password reset for user(s) in Active Directory.
.NOTES
    This script can only be run on a Windows machine with the 'ActiveDirectory' module installed.
.PARAMETER UserName
    The username(s) to run the action against.
.PARAMETER Disable
    Disable the user account(s).
.PARAMETER ForcePasswordReset
    Force a password reset for the user account(s).
.PARAMETER Server
    The Active Directory server to run the action against.
.PARAMETER Credential
    The credential to use for running the action.
.EXAMPLE
    Invoke-UserActionsInActiveDirectory.ps1 -UserName "jwinger" -Disable -ForcePasswordReset

    Disable and force a password reset for a user.
.EXAMPLE
    Invoke-UserActionsInActiveDirectory.ps1 -UserName @("jwinger", "tbarnes") -Disable -ForcePasswordReset

    Disable and force a password reset for multiple users.
.EXAMPLE
    Invoke-UserActionsInActiveDirectory.ps1 -UserName "jwinger" -Disable

    Disable a user.
.EXAMPLE
    Invoke-UserActionsInActiveDirectory.ps1 -UserName "jwinger" -ForcePasswordReset

    Force a password reset for a user.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, Mandatory)]
    [string[]]$UserName,
    [Parameter(Position = 1)]
    [switch]$Disable,
    [Parameter(Position = 2)]
    [switch]$ForcePasswordReset,
    [Parameter(Position = 3)]
    [string]$Server,
    [Parameter(Position = 4)]
    [pscredential]$Credential
)

# Create a splat to pass to the AD cmdlets.
$adCmdletSplat = @{
    "ErrorAction" = "Stop";
}

# Add the server to the splat if it was provided.
if ($null -ne $Server) {
    $adCmdletSplat.Add("Server", $Server)
}

# Add the credential to the splat if it was provided.
if ($null -ne $Credential) {
    $adCmdletSplat.Add("Credential", $Credential)
}

foreach ($userItem in $UserName) {
    $adUserObj = $null
    try {
        Write-Verbose "Getting '$($userItem)'."
        $adUserObj = Get-ADUser -Identity $userItem @adCmdletSplat
    }
    catch {
        # If an error occured getting the user,
        # continue to the next user.
        $PSCmdlet.WriteError($PSItem)
        continue
    }

    # Disable the user if the switch was provided.
    $userDisabled = $false
    if ($Disable) {
        if ($PSCmdlet.ShouldProcess($adUserObj.DistinguishedName, "Disable user")) {
            Disable-ADAccount -Identity $adUserObj @adCmdletSplat
            $userDisabled = $true
        }
    }

    # Force a password reset if the switch was provided.
    $forcedPasswordReset = $false
    if ($ForcePasswordReset) {
        if ($PSCmdlet.ShouldProcess($adUserObj.DistinguishedName, "Force password reset")) {
            Set-ADUser -Identity $adUserObj -ChangePasswordAtLogon $true @adCmdletSplat
            $forcedPasswordReset = $true
        }
    }

    # Output the results.
    [pscustomobject]@{
        "UserName" = $adUserObj.Name;
        "UserDisabled" = $userDisabled;
        "ForcedPasswordReset" = $forcedPasswordReset;
    }
}
