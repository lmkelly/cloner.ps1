param(
    [Alias("sw")]
    [Parameter (Mandatory=$true)]
    [string]$switchName,

    [Alias("esxi")]
    [Parameter (Mandatory=$true)]
    [string]$esx_host
)

function createSwitch {
    
    $esxi_host = Get-VMHost -Name $esx_host

    $vswitch = New-VirtualSwitch -VMHost $esxi_host -Name $switchName -ErrorAction Ignore
    New-VirtualPortGroup -VirtualSwitch $vswitch -Name $switchName

}

function start {
    $c = $defaultviserver

    if($c -ne $null){
        createSwitch 

    }
    else{
        $viServer = read-host -Prompt "Enter vCenter hostname/ip address"
        Connect-VIServer -Server $viServer
        start
    }
}

start