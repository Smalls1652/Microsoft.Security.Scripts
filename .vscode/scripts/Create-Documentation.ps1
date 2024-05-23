[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspacePath
)

$ignoredParameters = @(
    "Verbose",
    "Debug",
    "ErrorAction",
    "WarningAction",
    "InformationAction",
    "ProgressAction",
    "ErrorVariable",
    "WarningVariable",
    "InformationVariable",
    "OutVariable",
    "OutBuffer",
    "PipelineVariable",
    "WhatIf",
    "Confirm"
)

$workspacePathResolved = (Resolve-Path -Path $WorkspacePath -ErrorAction "Stop").Path

$scriptsPath = Join-Path -Path $workspacePathResolved -ChildPath "Scripts"
$scriptFiles = Get-ChildItem -Path $scriptsPath -File -Recurse -Include "*.ps1"

$docsPath = Join-Path -Path $workspacePathResolved -ChildPath "Docs"

if (!(Test-Path -Path $docsPath)) {
    Write-Warning "Creating directory '$($docsPath)'."
    $null = New-Item -Path $docsPath -ItemType "Directory"
}

foreach ($scriptFileItem in $scriptFiles) {
    $scriptDocsDirectoryPath = Join-Path -Path $docsPath -ChildPath $scriptFileItem.Directory.Name

    if (!(Test-Path -Path $scriptDocsDirectoryPath)) {
        Write-Warning "Creating directory '$($scriptDocsDirectoryPath)'."
        $null = New-Item -Path $scriptDocsDirectoryPath -ItemType "Directory"
    }

    $scriptDocsFilePath = Join-Path -Path $scriptDocsDirectoryPath -ChildPath "$($scriptFileItem.BaseName).md"

    $scriptFileInfo = Get-PSScriptFileInfo -Path $scriptFileItem.FullName
    $commandInfo = Get-Command -Name $scriptFileItem.FullName
    $helpData = Get-Help -Name $scriptFileItem.FullName -Full

    $docStringBuilder = [System.Text.StringBuilder]::new()

    $null = $docStringBuilder.AppendLine("# ``$($scriptFileItem.Name)``")
    $null = $docStringBuilder.AppendLine("")

    $null = $docStringBuilder.AppendLine("## Description")
    $null = $docStringBuilder.AppendLine("")

    $null = $docStringBuilder.AppendLine($scriptFileInfo.ScriptHelpComment.Description.Trim())
    $null = $docStringBuilder.AppendLine("")

    $null = $docStringBuilder.AppendLine("## Parameters")
    $null = $docStringBuilder.AppendLine("")

    $scriptParameters = $commandInfo.Parameters.Keys | Where-Object { $PSItem -notin $ignoredParameters }

    foreach ($paramterItem in $scriptParameters) {
        $parameterHelpData = $helpData.parameters.parameter | Where-Object { $PSItem.Name -eq $paramterItem }

        $null = $docStringBuilder.AppendLine("### ``$($paramterItem)``")
        $null = $docStringBuilder.AppendLine("")

        $null = $docStringBuilder.AppendLine($parameterHelpData.description[0].Text.Trim())
        $null = $docStringBuilder.AppendLine("")
    }

    $null = $docStringBuilder.AppendLine("## Examples")
    $null = $docStringBuilder.AppendLine("")

    for ($i = 0; $i -lt $helpData.examples.example.Count; $i++) {
        $null = $docStringBuilder.AppendLine("### Example $(($i + 1).ToString(00))")
        $null = $docStringBuilder.AppendLine("")

        $null = $docStringBuilder.AppendLine($helpData.examples.example[$i].remarks[0].Text.Trim())
        $null = $docStringBuilder.AppendLine("")

        $null = $docStringBuilder.AppendLine('```powershell')
        $null = $docStringBuilder.AppendLine("$($helpData.examples.example[$i].introduction.Text.Trim()) $($helpData.examples.example[$i].code)")
        $null = $docStringBuilder.AppendLine('```')
        $null = $docStringBuilder.AppendLine("")
    }

    $null = $docStringBuilder.AppendLine("## Required Modules")
    $null = $docStringBuilder.AppendLine("")

    if ($scriptFileInfo.ScriptRequiresComment.RequiredModules.Count -eq 0) {
        $null = $docStringBuilder.AppendLine("None")
        $null = $docStringBuilder.AppendLine("")
    }
    else {
        $null = $docStringBuilder.AppendLine("| Module Name | Module Version |")
        $null = $docStringBuilder.AppendLine("| --- | --- |")

        foreach ($moduleItem in $scriptFileInfo.ScriptRequiresComment.RequiredModules) {

            $moduleNameText = $null

            try {
                $null = Find-PSResource -Name $moduleItem.Name -Type "Module" -ErrorAction "Stop"
                $moduleNameText = "[``$($moduleItem.Name)``](https://www.powershellgallery.com/packages/$($moduleItem.Name))"
            }
            catch {
                $moduleNameText = "``$($moduleItem.Name)``"
            }

            $moduleVersionText = $null
            if (![string]::IsNullOrEmpty($moduleItem.Version)) {
                $moduleVersionText = "$($moduleItem.Version) <="
            }

            if (![string]::IsNullOrEmpty($moduleItem.RequiredVersion)) {
                $moduleVersionText = "$($moduleItem.RequiredVersion)"
            }

            if (![string]::IsNullOrEmpty($moduleItem.MaximumVersion)) {
                $moduleVersionText = "<= $($moduleItem.MaximumVersion)"
            }

            $null = $docStringBuilder.AppendLine("| $($moduleNameText) | ``$($moduleVersionText)`` |")
        }
    }

    $docStringBuilder.ToString() | Out-File -FilePath $scriptDocsFilePath -Force
}
