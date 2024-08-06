<#PSScriptInfo

.VERSION 1.0.0

.GUID cc6facf9-b999-4d5a-9ccb-0202709fa170

.AUTHOR Tim Small

.COMPANYNAME Smalls.Online

.COPYRIGHT 2024

.TAGS entra entraid conditionalaccess

.LICENSEURI https://raw.githubusercontent.com/Smalls1652/Microsoft.Security.Scripts/main/LICENSE

.PROJECTURI https://github.com/Smalls1652/Microsoft.Security.Scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

.PRIVATEDATA

#>

#Requires -Module @{ ModuleName = "Microsoft.Graph.Authentication"; ModuleVersion = "2.17.0" }

<#
.SYNOPSIS
    Add an IP address range to a named location for blocking in Conditional Access.
.DESCRIPTION
    Add an IP address range to a named location for blocking in Conditional Access.
.PARAMETER NamedLocationName
    The name of the named location to add the IP address range to.
.PARAMETER CidrAddress
    The CIDR address of the IP address range to add.
.EXAMPLE
    New-ConditionalAccessIpBlock.ps1 -NamedLocationName "Block IP Range" -CidrAddress @("8.8.8.8/32")

    Add the IP address range '8.8.8.8' to the named location 'Block IP Range'.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$NamedLocationName,
    [Parameter(Position = 1, Mandatory = $true)]
    [string[]]$CidrAddress
)

# Get the named location item.
$namedLocationItem = $null
try {
    Write-Verbose "Getting named location '$($NamedLocationName)'."
    $namedLocationItem = Invoke-MgGraphRequest -Method "GET" -Uri "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations?`$filter=displayName eq '$($NamedLocationName)'" -OutputType "PSObject"
}
catch [System.Exception] {
    $PSCmdlet.ThrowTerminatingError($PSItem)
}

if ($null -eq $namedLocationItem.value -or $namedLocationItem.value.Count -eq 0) {
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new("Named location '$($NamedLocationName)' not found."),
            "NamedLocationNotFound",
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $null
        )
    )
}

# Create a new IP ranges list with the existing IP ranges and the new IP ranges.
Write-Verbose "Updating named location '$($NamedLocationName)' with new IP ranges."
$ipRanges = [System.Collections.Generic.List[pscustomobject]]::new()
foreach ($existingCidrRange in $namedLocationItem.value[0].ipRanges) {
    $ipRanges.Add(
        [pscustomobject]@{
            "@odata.type" = "#microsoft.graph.iPv4CidrRange";
            "cidrAddress" = $existingCidrRange.cidrAddress;
        }
    )
}

foreach ($newCidrRange in $CidrAddress) {
    $ipRanges.Add(
        [pscustomobject]@{
            "@odata.type" = "#microsoft.graph.iPv4CidrRange";
            "cidrAddress" = $newCidrRange;
        }
    )
}

# Create the body for the PATCH request.
$namedLocationUpdateBody = [pscustomobject]@{
    "@odata.type" = "#microsoft.graph.ipNamedLocation";
    "ipRanges"    = $ipRanges;
}
$namedLocationUpdateBodyJson = $namedLocationUpdateBody | ConvertTo-Json -Depth 4 -Compress

# Update the named location.
if ($PSCmdlet.ShouldProcess($namedLocationItem.value[0].displayName, "Update IP ranges")) {
    try {
        Invoke-MgGraphRequest -Method "PATCH" -Uri "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/$($namedLocationItem.value[0].id)" -Body $namedLocationUpdateBodyJson -OutputType "PSObject"
    }
    catch [System.Exception] {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}
