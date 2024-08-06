# `New-ConditionalAccessIpBlock.ps1`

## Description

Add an IP address range to a named location for blocking in Conditional Access.

## Parameters

### `NamedLocationName`

The name of the named location to add the IP address range to.

### `CidrAddress`

The CIDR address of the IP address range to add.

## Examples

### Example 1

Add the IP address range '8.8.8.8' to the named location 'Block IP Range'.

```powershell
PS > New-ConditionalAccessIpBlock.ps1 -NamedLocationName "Block IP Range" -CidrAddress @("8.8.8.8/32")
```

## Required Modules

| Module Name | Module Version |
| --- | --- |
| [`Microsoft.Graph.Authentication`](https://www.powershellgallery.com/packages/Microsoft.Graph.Authentication) | `2.17.0 <=` |
