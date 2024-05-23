# `Invoke-UserActionsInActiveDirectory.ps1`

## Description

Disable and/or force password reset for user(s) in Active Directory.

## Parameters

### `UserName`

The username(s) to run the action against.

### `Disable`

Disable the user account(s).

### `ForcePasswordReset`

Force a password reset for the user account(s).

### `Server`

The Active Directory server to run the action against.

### `Credential`

The credential to use for running the action.

## Examples

### Example 1

Disable and force a password reset for a user.

```powershell
PS > Invoke-UserActionsInActiveDirectory.ps1 -UserName "jwinger" -Disable -ForcePasswordReset
```

### Example 2

Disable and force a password reset for multiple users.

```powershell
PS > Invoke-UserActionsInActiveDirectory.ps1 -UserName @("jwinger", "tbarnes") -Disable -ForcePasswordReset
```

### Example 3

Disable a user.

```powershell
PS > Invoke-UserActionsInActiveDirectory.ps1 -UserName "jwinger" -Disable
```

### Example 4

Force a password reset for a user.

```powershell
PS > Invoke-UserActionsInActiveDirectory.ps1 -UserName "jwinger" -ForcePasswordReset
```

## Required Modules

| Module Name | Module Version |
| --- | --- |
| `ActiveDirectory` | `1.0.1 <=` |


