# `Invoke-ConfirmCompromisedUser.ps1`

## Description

Confirm a user(s) is compromised in Microsoft Entra ID and revoke all sessions for them.

## Parameters

### `UserPrincipalName`

The user principal name of the user(s) to confirm compromised.

## Examples

### Example 1

Confirm as compromised and revokes all sessions for the user in Microsoft Entra ID.

```powershell
PS > Invoke-ConfirmCompromisedUser.ps1 -UserPrincipalName "jwinger@greendalecc.edu"
```

### Example 2

Confirm as compromised and revokes all sessions for multiple users in Microsoft Entra ID.

```powershell
PS > Invoke-ConfirmCompromisedUser.ps1 -UserPrincipalName @("jwinger@greendalecc.edu", "tbarnes@students.greendalecc.edu")
```

## Required Modules

| Module Name | Module Version |
| --- | --- |
| [`Microsoft.Graph.Authentication`](https://www.powershellgallery.com/packages/Microsoft.Graph.Authentication) | `2.17.0 <=` |
| [`Microsoft.Graph.Beta.Users.Actions`](https://www.powershellgallery.com/packages/Microsoft.Graph.Beta.Users.Actions) | `2.17.0 <=` |
| [`Microsoft.Graph.Users`](https://www.powershellgallery.com/packages/Microsoft.Graph.Users) | `2.17.0 <=` |
