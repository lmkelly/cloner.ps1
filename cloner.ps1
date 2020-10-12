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
	$folder = Get-Folder -Name $out
	cls
	$out = read-host -Prompt "Enter clone name"
	cls
	$newvm = New-VM -Name $out -VM $thevm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -Location $folder
}
function rClone() {
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
	$folder = Get-Folder -Name $out
	cls
	$out = read-host -Prompt "Enter clone name"
	cls
	$newvm = New-VM -Name $out -VM $thevm -VMHost $vmhost -Datastore $dstore -Location $folder
}
function fClone() {
	$snapshot = Get-Snapshot -VM $thevm -Name "Base"
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
	$folder = Get-Folder -Name $out
	cls
	$cname = read-host -Prompt "Enter clone name"
	cls
	$newlclone = New-VM -Name "$cname-temporary-lc" -VM $thevm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -Location $folder
	$newfclone = New-VM -Name $cname -VM "$cname-temporary-lc" -VMHost $vmhost -Datastore $dstore -Location $folder
	$delete = read-host -Prompt "Would you like to delete $cname-temporary-lc? [Y/n]"
	if ($delete -match "^[nN]$") {
		exit
	}
	else {
		Remove-VM -VM "$cname-temporary-lc"
	}
	
}


cls
$viServer = read-host -Prompt "Enter vCenter hostname/ip address"
Connect-VIServer -Server $viServer
cls
$fname = Get-Folder
$fname.name
$folder = read-host -Prompt "Which folder are your VMs in?"
cls
$vms = Get-VM -Location $folder
$vms.name
$out = read-host -Prompt "Enter the VM name you'd like to clone"
cls
$thevm = Get-VM -Name $out

what
