#Requires -Module @{ ModuleName = "ActiveDirectory"; ModuleVersion = "1.0.1" }
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

$adCmdletSplat = @{
    "ErrorAction" = "Stop";
}

if ($null -ne $Server) {
    $adCmdletSplat.Add("Server", $Server)
}

if ($null -ne $Credential) {
    $adCmdletSplat.Add("Credential", $Credential)
}

foreach ($userItem in $UserName) {
    $adUserObj = $null
    try {
        $adUserObj = Get-ADUser -Identity $userItem @adCmdletSplat
    }
    catch {
        $PSCmdlet.WriteError($PSItem)
        continue
    }

    $userDisabled = $false
    if ($Disable) {
        if ($PSCmdlet.ShouldProcess($adUserObj.DistinguishedName, "Disable user")) {
            Disable-ADAccount -Identity $adUserObj @adCmdletSplat
            $userDisabled = $true
        }
    }

    $forcedPasswordReset = $false
    if ($ForcePasswordReset) {
        if ($PSCmdlet.ShouldProcess($adUserObj.DistinguishedName, "Force password reset")) {
            Set-ADUser -Identity $adUserObj -ChangePasswordAtLogon $true @adCmdletSplat
            $forcedPasswordReset = $true
        }
    }

    [pscustomobject]@{
        "UserName" = $adUserObj.Name;
        "UserDisabled" = $userDisabled;
        "ForcedPasswordReset" = $forcedPasswordReset;
    }
}
