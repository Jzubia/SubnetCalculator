# Checks if inputted IP is valid
function isValid {
    param ([string[]]$IP)
    
    for([int]$i = 0; $i -lt $IP.Length; $i++){
        if($IP[$i] -as [int] -gt 255){
            return $false
        }
        if($null -eq $IP[$i]){
            Write-Host "Invalid IP Address Inputted: Too Few Octets"
            exit
        }
    }
    return $true
}

# If true continue, if false throw an error
function verifyIP {
    param ([string[]]$IP)

    [bool]$valid = isValid($IP)

    if($valid -eq $false){
        Write-Host "Invalid IP Address Inputted: Overflow"
        exit
    }
}

# Will convert ascii decimal to an int decimal
function toValidInt{
    param([int]$orgDecimal)

    [int]$hexVal = [Convert]::ToString($orgDecimal, 16)

    $decVal = $hexVal - 30

    return $decVal
}

# Converts the CIDR into binary
function toBinary{
    param ([int]$CIDR)

    $bMask = [string[]]::new(4)

    for([int]$i = 0; $i -lt $bMask.Length; $i++){
        for([int]$j = 0; $j -lt 8; $j++){
            if($CIDR -eq 0){
                $bMask[$i] += 0
            } 
            else{
                $bMask[$i] += 1
                $CIDR--
            }
        }
    }
    return $bMask
}

# Finds the Subnet Mask via the CIDR information
function findMask {
    param ([string[]]$bMask)
    
    $subnetMask = [string[]]::new(4)

    for([int]$i = 0; $i -lt $bMask.Length; $i++){
        $subnetMask[$i] += [convert]::ToInt32($bMask[$i], 2)
    }

    return $subnetMask
}

# Finds which Octet the network bits are in
function whichOctet {
    param ([string[]]$subnetMask)
    
    for([int]$i = 0; $i -lt $subnetMask.Length; $i++){
        if($subnetMask[$i] -ne 255){
            return $i
        }
    }
    exit
}

function findSubnet {
    param ([int]$number)
    
    $subnetsArray = $addressSubnetBounds[$Addresses]

    for([int]$i = 0; $i -lt $subnetsArray.Length; $i++){
        if($subnetsArray[$i] -gt $number){
            return ($i - 1)
        }
    }
}

function findNetworkIP {

    param ($bounds)

    $tempNetworkIP = [int[]]::new(4) 

    for([int]$i = 0; $i -lt $IP.Length; $i++){
        if($i -lt $index){
        $tempNetworkIP[$i] = $IP[$i]
        }
        elseif ($i -eq $index) {
            $tempNetworkIP[$i] = $bounds[0]
        }
        else{
            $tempNetworkIP[$i] = 0
        }
    }
    return $tempNetworkIP
}

function findNetIP {
    $tempNetworkIP = [int[]]::new(4) 

    for([int]$i = 0; $i -lt $IP.Length; $i++){
        if($i -lt $index){
        $tempNetworkIP[$i] = $IP[$i]
        }
        else{
            $tempNetworkIP[$i] = 0
        }
    }
    return $tempNetworkIP
}

function findBroadcastIP {
    param ($bounds)
    
    $tempBroadcastIP = [int[]]::new(4) 

    for([int]$i = 0; $i -lt $IP.Length; $i++){
        if($i -lt $index){
        $tempBroadcastIP[$i] = $IP[$i]
        }
        elseif ($i -eq $index) {
            $tempBroadcastIP[$i] = $bounds[1] - 1
        }
        else{
            $tempBroadcastIP[$i] = 255
        }
    }
    return $tempBroadcastIP

}

function findBroadIP {
    $tempBroadcastIP = [int[]]::new(4) 

    for([int]$i = 0; $i -lt $IP.Length; $i++){
        if($i -lt $index){
        $tempBroadcastIP[$i] = $IP[$i]
        }
        else{
            $tempBroadcastIP[$i] = 255
        }
    }
    return $tempBroadcastIP

    
}
