#Requires -Module @{ ModuleName = "Microsoft.Graph.Authentication"; ModuleVersion = "2.34.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Users"; ModuleVersion = "2.34.0" }
#Requires -Module @{ ModuleName = "Microsoft.Graph.Beta.Identity.SignIns"; ModuleVersion = "2.34.0" }

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$UserId
)

$excludedAuthMethods = @(
    "#microsoft.graph.passwordAuthenticationMethod"
)

Write-Verbose -Message "Retrieving $($UserId)"
$userItem = Get-MgUser -UserId $UserId -ErrorAction "Stop"

Write-Verbose -Message "Getting auth methods for $($userItem.UserPrincipalName)"
$userAuthMethods = Get-MgBetaUserAuthenticationMethod -UserId $userItem.Id -All | Where-Object { $PSItem.AdditionalProperties."@odata.type" -notin $excludedAuthMethods }

if ($null -eq $userAuthMethods -or ($userAuthMethods | Measure-Object).Count -eq 0) {
    Write-Warning -Message "No auth methods to remove from user"
    return
}

foreach ($authMethod in $userAuthMethods) {
    $removalResult = $null
    $authMethodDisplayName = $null

    switch ($authMethod.AdditionalProperties."@odata.type") {
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

        Default {
            $authMethodDisplayName = $authMethod.AdditionalProperties."@odata.type"
            $removalResult = "Skipped"
            Write-Warning -Message "Auth type '$($authMethod.AdditionalProperties."@odata.type")' is not handled. Skipping..."
            break
        }
    }

    $operationResult = [pscustomobject]@{
        "UserId"                = $userItem.Id;
        "UserPrincipalName"     = $userItem.UserPrincipalName;
        "AuthMethodDisplayName" = $authMethodDisplayName;
        "AuthMethodId"          = $authMethod.Id;
        "Result"                = $removalResult;
    }

    Write-Output -InputObject $operationResult
}
