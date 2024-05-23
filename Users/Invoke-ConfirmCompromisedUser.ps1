#Requires -Module @{ ModuleName = "Microsoft.Graph.Authentication"; ModuleVersion = "2.17.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Beta.Users.Actions"; ModuleVersion = "2.17.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Users"; ModuleVersion = "2.17.0" }
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
            $revokedSessionsStatus = Invoke-MgBetaInvalidateAllUserRefreshToken -UserId $userObj.Id -ErrorAction "Stop"
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
