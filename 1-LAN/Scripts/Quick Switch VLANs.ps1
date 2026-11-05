# I use this to quickly swwap between MGMT VLAN and VLAN10 which is like... acual LAN on my network I guess. Realtek 2.5Gb NIC btw.
# https://ss64.com/ps/syntax-elevate.html
# Snippet from there ^
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}
# For later:
# https://learn.microsoft.com/en-us/powershell/module/netadapter/get-netadapteradvancedproperty?view=windowsserver2025-ps
# https://learn.microsoft.com/powershell/module/microsoft.powershell.core/where-object
# https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_Operators
$currentVID = (Get-NetAdapterAdvancedProperty -Name "Ethernet" | Where-Object { $_.RegistryKeyword -eq "RegVlanid" }).RegistryValue
# These are just named vars for re-use across script
$adapter = "Ethernet"
$property = "RegVlanid"
# PowerShell seems to be using logical and comparison operators unlike bash where you can do $Value == "10"
If ($currentVID -eq 10) {
  Set-NetAdapterAdvancedProperty -Name $adapter -RegistryKeyword $property -RegistryValue 50
  Set-DnsClientServerAddress -InterfaceAlias $adapter -ResetServerAddresses
  Restart-NetAdapter -Name $adapter
  exit
} ElseIf ($currentVID -eq 50) {
  Set-NetAdapterAdvancedProperty -Name $adapter -RegistryKeyword $property -RegistryValue 10
  # For some reason resetting DNS server addresses makes this get DHCP instantly? xdd
  Set-DnsClientServerAddress -InterfaceAlias $adapter -ResetServerAddresses
  Restart-NetAdapter -Name $adapter
  exit
}
