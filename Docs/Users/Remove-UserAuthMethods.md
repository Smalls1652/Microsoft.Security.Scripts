# `Remove-UserAuthMethods.ps1`

## Description

Remove all authentication methods from a user in Entra ID.

## Parameters

### `UserId`

The user principal name or the user's ID in Entra ID.

## Examples

### Example 1

Removes all authentication methods from the user "jwinger@greendalecc.edu".

```powershell
PS > Remove-UserAuthMethods.ps1 -UserId "jwinger@greendalecc.edu"
```

### Example 2

Does a dry-run/what-if on the removal of all authentication methods from the user "jwinger@greendalecc.edu".

```powershell
PS > Remove-UserAuthMethods.ps1 -UserId "jwinger@greendalecc.edu" -WhatIf
```

## Required Modules

| Module Name | Module Version |
| --- | --- |
| [`Microsoft.Graph.Authentication`](https://www.powershellgallery.com/packages/Microsoft.Graph.Authentication) | `2.34.0 <=` |
| [`Microsoft.Graph.Users`](https://www.powershellgallery.com/packages/Microsoft.Graph.Users) | `2.34.0 <=` |
| [`Microsoft.Graph.Beta.Identity.SignIns`](https://www.powershellgallery.com/packages/Microsoft.Graph.Beta.Identity.SignIns) | `2.34.0 <=` |
