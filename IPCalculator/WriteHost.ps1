. "C:\Users\Jz\OneDrive\Desktop\PowerShellScripts\IPCalculator\GetIP.ps1"
. "C:\Users\Jz\OneDrive\Desktop\PowerShellScripts\IPCalculator\LookupTable.ps1"

# Globals hold total number of address and subnets possible
[int]$Addresses = 0
[int]$Subnets = 0

# Start of Code
function run{
    [int]$CIDR = Read-Host -Prompt "Enter in CIDR"

    $hasedValue = Hash($CIDR)

    # Returns number of possible addresses
    $Addresses = $maskAddressTable[$hasedValue] 

    # Returns number of possible subnets
    $Subnets = $addressNetworksTable[$Addresses]

    $enteredInfo = $inputString + "/" + $CIDR

    Write-Host "Information entered:" $enteredInfo

    Write-Host ""

    Write-Host "Possible number of Subnets:" $Subnets
    Write-Host "Possible number of Addresses per subnet:" $Addresses

    $subnetMask = findMask(toBinary($CIDR))
    $printMask = $subnetMask -join "."

    Write-Host ""
    Write-Host "Calculated Subnet Mask:" $printMask

    $index = whichOctet($subnetMask)

    [int]$num = $stringIP[$index] -as [int]

    [int]$tableIndex = findSubnet($num)

    # For standard Classes A-C
    if($Addresses -eq 1){
        $tempNetworkIP = findNetIP
        $tempBroadcastIP = findBroadIP
    }
    # For all other Masks and CIDRs
    else{
        $bounds = [int[]]::new(2)

        $Lookup = $addressSubnetBounds[$Addresses]

        $bounds[0] = $Lookup[$tableIndex] 
        $bounds[1] = $Lookup[$tableIndex + 1]

        $tempNetworkIP = findNetworkIP($bounds)
        $tempBroadcastIP = findBroadcastIP($bounds)
    }

    [string]$networkIP = $tempNetworkIP -join "."

    $firstIP = $tempNetworkIP

    $firstIP[3] = $firstIP[3] + 1

    [string]$firstUsableIP = $firstIP -join "."

    Write-Host "Calculated Network IP:" $networkIP
    Write-Host "First Usable Hostname:" $firstUsableIP

    [string]$broadcastIP = $tempBroadcastIP -join "."

    $lastIP = $tempBroadcastIP

    $lastIP[3] = $lastIP[3] - 1

    [string]$lastUsableIP = $lastIP -join "."

    Write-Host "Calculated Broadcast IP:" $broadcastIP
    Write-Host "Last Usable Hostname:" $lastUsableIP
    Write-Host ""
}

run
