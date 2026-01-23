[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$InternetMessageIds,
    [Parameter(Position = 1)]
    [int]$BatchAmount = 50
)

$messages = for ($i = 0; $i -lt $InternetMessageIds.Length; $i++) {
    Write-Verbose -Message "Getting email $($i + 1) of $($InternetMessageIds.Length)"

    Get-QuarantineMessage -MessageId $InternetMessageIds[$i]
}

for ($startIndex = 0; $startIndex -lt $messages.Length; $startIndex += $BatchAmount) {
    $endIndex = [Math]::Min($startIndex + $BatchAmount - 1, $messages.Length - 1)
    
    Write-Warning -Message "[$($startIndex)..$($endIndex)] Releasing emails $($startIndex + 1)-$($endIndex) of $($messages.Length)"

    Release-QuarantineMessage -Identities $messages[$startIndex..$endIndex].Identity -ReleaseToAll -ActionType "Release" -Force -Verbose:$false
}
