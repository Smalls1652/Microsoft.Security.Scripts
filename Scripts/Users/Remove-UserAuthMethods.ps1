<#PSScriptInfo

.VERSION 1.0.0

.GUID 63bf0176-7adb-498a-9bb2-bb307aa0d9f0

.AUTHOR Tim Small

.COMPANYNAME Smalls.Online

.COPYRIGHT 2026

.TAGS entra entraid authmethods

.LICENSEURI https://git.smalls.online/smalls/Microsoft.Security.Scripts/raw/branch/main/LICENSE

.PROJECTURI https://git.smalls.online/smalls/Microsoft.Security.Scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

.PRIVATEDATA

#>

#Requires -Module @{ ModuleName = "Microsoft.Graph.Authentication"; ModuleVersion = "2.34.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Users"; ModuleVersion = "2.34.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Beta.Identity.SignIns"; ModuleVersion = "2.34.0" }

<#
.SYNOPSIS
    Removes all user auth methods
.DESCRIPTION
    Remove all authentication methods from a user in Entra ID.
.PARAMETER UserId
    The user principal name or the user's ID in Entra ID.
.EXAMPLE
    Remove-UserAuthMethods.ps1 -UserId "jwinger@greendalecc.edu"

    Removes all authentication methods from the user "jwinger@greendalecc.edu".
.EXAMPLE
    Remove-UserAuthMethods.ps1 -UserId "jwinger@greendalecc.edu" -WhatIf

    Does a dry-run/what-if on the removal of all authentication methods from the user "jwinger@greendalecc.edu".
#>


[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$UserId
)

# Methods that **must** be excluded. Typically because
# they can't be removed.
$excludedAuthMethods = @(
    "#microsoft.graph.passwordAuthenticationMethod"
)

# Retrieve the user and their auth methods.
Write-Verbose -Message "Retrieving $($UserId)"
$userItem = Get-MgUser -UserId $UserId -ErrorAction "Stop"

Write-Verbose -Message "Getting auth methods for $($userItem.UserPrincipalName)"
$userAuthMethods = Get-MgBetaUserAuthenticationMethod -UserId $userItem.Id -All | Where-Object { $PSItem.AdditionalProperties."@odata.type" -notin $excludedAuthMethods }

# If no auth methods were found, then return early.
if ($null -eq $userAuthMethods -or ($userAuthMethods | Measure-Object).Count -eq 0) {
    Write-Warning -Message "No auth methods to remove from user"
    return
}

# Process each auth method for removal.
foreach ($authMethod in $userAuthMethods) {
    $removalResult = $null
    $authMethodDisplayName = $null

    # There are different Graph API endpoints available for each type of method,
    # so we're having to handle them differently based off it's type.
    switch ($authMethod.AdditionalProperties."@odata.type") {
        # Email
        "#microsoft.graph.emailAuthenticationMethod" {
            $authMethodDisplayName = "Email"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove email auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationEmailMethod -UserId $userItem.Id -EmailAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Phone
        "#microsoft.graph.phoneAuthenticationMethod" {
            $authMethodDisplayName = "Phone"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove phone auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationPhoneMethod -UserId $userItem.Id -PhoneAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Software OATH
        "#microsoft.graph.softwareOathAuthenticationMethod" {
            $authMethodDisplayName = "Software OATH"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove software OATH auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationSoftwareOathMethod -UserId $userItem.Id -SoftwareOathAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Temporary Access Pass
        "#microsoft.graph.temporaryAccessPassAuthenticationMethod" {
            $authMethodDisplayName = "Temporary Access Pass"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove temporary access pass auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationTemporaryAccessPassMethod -UserId $userItem.Id -TemporaryAccessPassAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Windows Hello for Business
        "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" {
            $authMethodDisplayName = "Windows Hello for Business"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove Windows Hello auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationWindowsHelloForBusinessMethod -UserId $userItem.Id -WindowsHelloForBusinessAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Microsoft Authenticator
        "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" {
            $authMethodDisplayName = "Microsoft Authenticator"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove Microsoft Authenticator auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationMicrosoftAuthenticatorMethod -UserId $userItem.Id -MicrosoftAuthenticatorAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Platform credential
        "#microsoft.graph.platformCredentialAuthenticationMethod" {
            $authMethodDisplayName = "Platform Credential"

            if ($PSCmdlet.ShouldProcess($authMethod.Id, "Remove platform credential auth method")) {
                try {
                    $null = Remove-MgBetaUserAuthenticationPlatformCredentialMethod -UserId $userItem.Id -PlatformCredentialAuthenticationMethodId $authMethod.Id -ErrorAction "Stop"

                    $removalResult = "Removed"
                }
                catch [System.Exception] {
                    $errorDetails = $PSItem
                    $removalResult = $errorDetails.Exception.Message
                }
            }
            else {
                $removalResult = "What if"
            }
            break
        }

        # Skip if a method isn't defined above.
        Default {
            $authMethodDisplayName = $authMethod.AdditionalProperties."@odata.type"
            $removalResult = "Skipped"
            Write-Warning -Message "Auth type '$($authMethod.AdditionalProperties."@odata.type")' is not handled. Skipping..."
            break
        }
    }

    # Write the results of the removal to the console.
    $operationResult = [pscustomobject]@{
        "UserId"                = $userItem.Id;
        "UserPrincipalName"     = $userItem.UserPrincipalName;
        "AuthMethodDisplayName" = $authMethodDisplayName;
        "AuthMethodId"          = $authMethod.Id;
        "Result"                = $removalResult;
    }
    Write-Output -InputObject $operationResult
}
