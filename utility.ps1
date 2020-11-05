param(

	[Alias("t")]
	[Parameter (Mandatory=$false)]
	[string]$type,

	[Alias("host")]
	[Parameter (Mandatory=$true)]
	[string]$VMN
	
)

function what() {
	if ($type -match "^[cC]$") {
		$vms = Get-VM
		$vms.name
		$out = read-host -Prompt "Which VM would you like to work with?"
		$1 = Get-VM -Name $out
		$interfaces = $1 | Get-NetworkAdapter
		$n = 1
		forEach ($i in $interfaces) {
			write-host "[$n] $i"
			$n = $n + 1
		}
		$out = read-host -Prompt "Which adapter would you like to modify?"
		$2 = $out - 1
		$vswitch = Get-VirtualSwitch
		$vswitch.name
		$3 = read-host -Prompt "Which Network would you like to assign to this interface?"
		setNetwork $1 $2 $3
	}
	elseif ($type -match "^[gG]$") {
		
		if ($VMN -eq $null) {
			$vms = Get-VM
			$vms.name
			$VMN = read-host -Prompt "Which VM would you like to work with?"
		}
		
		getIP $VMN
	}
	elseif ($type -match "^[mM]$") {
		if ($VMN -eq $null) {
			$vms = Get-VM
			$vms.name
			$VMN = read-host -Prompt "Which VM would you like to work with?"
		}
		getMac $VMN
	}
	elseif ($type -match "^[eE]$") {
		exit
	}
	else {
		$type = read-host -Prompt "Would you like to [C]hange a VM network adapter, [G]et the IP of a VM (Ansible Format) or Get [M]ac address of VM? [E]xit?"
		what
	}
}

function setNetwork([string] $vmName, [int] $numInterface, [string] $preferredNetwork) {
	$interfaces[$numInterface] | Set-NetworkAdapter -NetworkName $preferredNetwork -Confirm:$false
}

function getIP([string] $vmName) {
	get-vm -name $vmName | foreach-object { write-host $_.Guest.IPAddress[0] "hostname=$_"} 
}

function getMac([string] $vmName) {
	get-vm -name $vmName | Get-NetworkAdapter | Select Name,MacAddress
}

$c = $defaultviserver
if ($c -eq $null) {
	$viServer = read-host -Prompt "Enter vCenter hostname/ip address"
	Connect-VIServer -Server $viServer
}

what
