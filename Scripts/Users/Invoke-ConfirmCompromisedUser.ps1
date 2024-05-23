<#PSScriptInfo

.VERSION 1.0.0

.GUID 30962848-1ced-4ae2-8d85-6d063ea8fa67

.AUTHOR Tim Small

.COMPANYNAME Smalls.Online

.COPYRIGHT 2024

.TAGS entraid security users

.LICENSEURI https://raw.githubusercontent.com/Smalls1652/Microsoft.Security.Scripts/main/LICENSE

.PROJECTURI https://github.com/Smalls1652/Microsoft.Security.Scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

#Requires -Module @{ ModuleName = "Microsoft.Graph.Authentication"; ModuleVersion = "2.17.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Beta.Users.Actions"; ModuleVersion = "2.17.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Users"; ModuleVersion = "2.17.0" }

<#
.SYNOPSIS
    Confirm a user(s) is compromised in Microsoft Entra ID.
.DESCRIPTION
    Confirm a user(s) is compromised in Microsoft Entra ID and revoke all sessions for them.
.PARAMETER UserPrincipalName
    The user principal name of the user(s) to confirm compromised.
.EXAMPLE
    Invoke-ConfirmCompromisedUser.ps1 -UserPrincipalName "jwinger@greendalecc.edu"

    Confirm as compromised and revokes all sessions for the user in Microsoft Entra ID.
.EXAMPLE
    Invoke-ConfirmCompromisedUser.ps1 -UserPrincipalName @("jwinger@greendalecc.edu", "tbarnes@students.greendalecc.edu")

    Confirm as compromised and revokes all sessions for multiple users in Microsoft Entra ID.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, Mandatory)]
    [string[]]$UserPrincipalName
)

foreach ($userItem in $UserPrincipalName) {
    $userObj = $null
    try {
        $userObj = Get-MgUser -UserId $userItem -ErrorAction "Stop"
    }
    catch {
        $PSCmdlet.WriteError($PSItem)
        continue
    }

    $confirmedCompromisedStatus = $false
    if ($PSCmdlet.ShouldProcess($userObj.UserPrincipalName, "Confirm compromised")) {
        $confirmCompromisedPostBody = [pscustomobject]@{
            "userIds" = @(
                $userObj.Id
            );
        } | ConvertTo-Json

        try {
            Invoke-MgGraphRequest -Method "POST" -Uri "https://graph.microsoft.com/beta/riskyUsers/confirmCompromised" -Body $confirmCompromisedPostBody -ContentType "application/json" -ErrorAction "Stop"
            $confirmedCompromisedStatus = $true
        }
        catch {
            $confirmedCompromisedStatus = $false
        }
    }

    $revokedSessionsStatus = $false
    if ($PSCmdlet.ShouldProcess($userObj.UserPrincipalName, "Revoke sessions")) {
        try {
            $revokedSessionsStatus = (Invoke-MgBetaInvalidateAllUserRefreshToken -UserId $userObj.Id -ErrorAction "Stop").Value
        }
        catch {
            $revokedSessionsStatus = $false
        }
    }

    [pscustomobject]@{
        "UserId"               = $userObj.Id;
        "UserPrincipalName"    = $userObj.UserPrincipalName;
        "ConfirmedCompromised" = $confirmedCompromisedStatus;
        "RevokedSessions"      = $revokedSessionsStatus;
    }
}
