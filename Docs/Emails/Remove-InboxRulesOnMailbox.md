# `Remove-InboxRulesOnMailbox.ps1`

## Description

Remove all inbox rules from a mailbox.

## Parameters

### `UserPrincipalName`

The user principal name of the mailbox to remove the inbox rules from.

## Examples

### Example 1

Remove all inbox rules from the mailbox.

```powershell
PS > Remove-InboxRulesOnMailbox.ps1 -UserPrincipalName "jwinger@greendalecc.edu"
```

## Required Modules

| Module Name | Module Version |
| --- | --- |
| [`ExchangeOnlineManagement`](https://www.powershellgallery.com/packages/ExchangeOnlineManagement) | `3.4.0 <=` |
