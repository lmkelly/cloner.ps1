function what() {
	$type = read-host -Prompt "Would you like to create a [F]ull clone, a [L]inked clone, or a [R]egular clone of the VM State? [E]xit?"
	if ($type -match "^[lL]$") {
		lClone
	}
	elseif ($type -match "^[rR]$") {
		rClone
	}
	elseif ($type -match "^[fF]$") {
		fClone
	}
	elseif ($type -match "^[eE]$") {
		exit
	}
	else {
		what
	}
}
function lClone() {
	$snapshot = Get-Snapshot -VM $thevm -Name "Base"
	cls
	$cname = read-host -Prompt "Enter clone name"
	cls
	$newvm = New-VM -Name  $cname -VM $thevm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -Location $outputf
	$vm2 = Get-VM -Name $cname
	$ada = Get-VM $vm2 | Get-NetworkAdapter
	foreach ($item in $ada.name) {
		$sw = Get-VM $vm | Get-NetworkAdapter -Name $item | `
		Set-NetworkAdapter -NetworkName $pn -Confirm:$false
	
	}
}
function rClone() {
	cls
	$cname = read-host -Prompt "Enter clone name"
	cls
	$newvm = New-VM -Name $cname -VM $thevm -VMHost $vmhost -Datastore $dstore -Location $outputf
	$vm2 = Get-VM -Name $cname
	$ada = Get-VM $vm2 | Get-NetworkAdapter
	foreach ($item in $ada.name) {
		$sw = Get-VM $vm | Get-NetworkAdapter -Name $item | `
		Set-NetworkAdapter -NetworkName $pn -Confirm:$false
	
	}
}
function fClone() {
	$snapshot = Get-Snapshot -VM $thevm -Name "Base"
	cls
	$cname = read-host -Prompt "Enter clone name"
	cls
	$newlclone = New-VM -Name "$cname-temporary-lc" -VM $thevm -LinkedClone -ReferenceSnapshot $snapshot  -VMHost $vmhost -Datastore $dstore -Location $outputf
	$newfclone = New-VM -Name $cname -VM "$cname-temporary-lc" -VMHost $vmhost -Datastore $dstore -Location $outputf
	$vm2 = Get-VM -Name $cname
	$ada = Get-VM $vm2 | Get-NetworkAdapter
	foreach ($item in $ada.name) {
		$sw = Get-VM $vm | Get-NetworkAdapter -Name $item | `
		Set-NetworkAdapter -NetworkName $pn -Confirm:$false
	
	}
	$delete = read-host -Prompt "Would you like to delete $cname-temporary-lc? [Y/n]"
	if ($delete -match "^[nN]$") {
		exit
	}
	else {
		Remove-VM -VM "$cname-temporary-lc"
	}
	
}

$config_path = "cloner.json"
$conf=""
$c = $defaultviserver

if (Test-Path $config_path) {

	Write-Host "Using saved config"
	$conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)

	if ($c -eq $null) {
		Connect-VIServer -Server $conf.vcenter_server
	}

	$folder = $conf.base_folder
	$vmhost = Get-VMHost -Name $conf.esxi_server
	$dstore = Get-Datastore -Name $conf.preferred_datastore
	$pn = Get-VirtualSwitch -Name $conf.preferred_network
	$outputf = Get-Folder -Name $conf.base_folder

} else {

	Write-Host "Interactive Mode"
	if ($c -eq $null) {
		$viServer = read-host -Prompt "Enter vCenter hostname/ip address"
		Connect-VIServer -Server $viServer
	}

	cls
	$fname = Get-Folder
	$fname.name
	$folder = read-host -Prompt "Which folder are your VMs in?"
	cls
	$hst = Get-VMHost
	$hst.name
	$out = read-host -Prompt "Which host would you like to run this on?"
	$vmhost = Get-VMHost -Name $out
	cls
	$dst = Get-Datastore
	$dst.name
	$out = read-host -Prompt "Enter the Datastore you'd like to use"
	$dstore = Get-Datastore -Name $out
	cls
	$fld = Get-Folder
	$fld.name
	$out = read-host -Prompt "Which folder would you like to put this into?"
	$outputf = Get-Folder -Name $out
}

cls
$vms = Get-VM -Location $folder
$vms.name
$out = read-host -Prompt "Enter the VM name you'd like to clone"
$thevm = Get-VM -Name $out
cls


what
