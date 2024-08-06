<#PSScriptInfo

.VERSION 1.0.0

.GUID c1dd79fc-ee9c-4f78-80ae-d5c4434554ad

.AUTHOR Tim Small

.COMPANYNAME Smalls.Online

.COPYRIGHT 2024

.TAGS exchangeonline security inboxrules

.LICENSEURI https://raw.githubusercontent.com/Smalls1652/Microsoft.Security.Scripts/main/LICENSE

.PROJECTURI https://github.com/Smalls1652/Microsoft.Security.Scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

#Requires -Module @{ ModuleName = "ExchangeOnlineManagement"; ModuleVersion = "3.4.0" }

<#
.SYNOPSIS
    Remove all inbox rules from a mailbox.
.DESCRIPTION
    Remove all inbox rules from a mailbox.
.PARAMETER UserPrincipalName
    The user principal name of the mailbox to remove the inbox rules from.
.EXAMPLE
    Remove-InboxRulesOnMailbox.ps1 -UserPrincipalName "jwinger@greendalecc.edu"

    Remove all inbox rules from the mailbox.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, Mandatory)]
    [string]$UserPrincipalName
)

# Get the mailbox.
Write-Verbose "Getting mailbox for '$($UserPrincipalName)'."
$mailbox = $null
try {
    $mailbox = Get-EXOMailbox -UserPrincipalName $UserPrincipalName -ErrorAction "Stop" -Verbose:$false
}
catch [Microsoft.Exchange.Management.RestApiClient.RestClientException] {
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new("Failed to get mailbox for '$($UserPrincipalName)'.", $PSItem.Exception),
            "FailedToGetMailbox",
            [System.Management.Automation.ErrorCategory]::InvalidResult,
            $null
        )
    )
}
catch [System.Exception] {
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new("An unknown error occurred getting the mailbox for '$($UserPrincipalName)'.", $PSItem.Exception),
            "UnknownError",
            [System.Management.Automation.ErrorCategory]::InvalidResult,
            $null
        )
    )
}

# Get the inbox rules.
Write-Verbose "Getting inbox rules for '$($UserPrincipalName)'."
$inboxRules = $null
try {
    $inboxRules = Get-InboxRule -Mailbox $mailbox -ErrorAction "Stop" -Verbose:$false
}
catch [System.Exception] {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}

if ($null -eq $inboxRules) {
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new("No inbox rules found for '$($UserPrincipalName)'."),
            "NoInboxRulesFound",
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $null
        )
    )
}

# Remove the inbox rules.
foreach ($rule in $inboxRules) {
    if ($PSCmdlet.ShouldProcess($rule.Name, "Remove inbox rule")) {
        try {
            Remove-InboxRule -Identity $rule.Identity -Confirm:$false -ErrorAction "Stop" -Verbose:$false
        }
        catch [System.Exception] {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
