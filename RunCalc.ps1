# This is just the full combination of four individual powershell scripts
# Just for the use of the .exe file

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

# Reduced form of the CIDR lookup table, hash function with CIDR will return one of these values
$maskAddressTable = @{
    1 = 128
    2 = 64
    3 = 32
    4 = 16
    5 = 8
    6 = 4
    7 = 2
    0 = 1
}

# mask to address table will serve as the lookup for this table, to see how many subnets can be created
$addressNetworksTable = @{
    128 = 2
    64  = 4
    32  = 8
    16  = 16
    8   = 32
    4   = 64
    2   = 128
    1   = 256
}

$addressSubnetBounds = @{
    128 = @(0, 128, 256)
    64  = @(0, 64, 128, 192, 256)
    32  = @(0, 32, 64, 96, 128, 160, 192, 224, 256)
    16  = @(0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240, 256)
    8   = @(0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 128, 136, 144, 152, 160, 168, 176, 184, 192, 200, 208, 216, 224, 232, 240, 248, 256)
    4   = @(0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172, 176, 180, 184, 188, 192, 196, 200, 204, 208, 212, 216, 220, 224, 228, 232, 236, 240, 244, 248, 252, 256)
    2   = @(0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138, 140, 142, 144, 146, 148, 150, 152, 154, 156, 158, 160, 162, 164, 166, 168, 170, 172, 174, 176, 178, 180, 182, 184, 186, 188, 190, 192, 194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 218, 220, 222, 224, 226, 228, 230, 232, 234, 236, 238, 240, 242, 244, 246, 248, 250, 252, 254, 256)
    1   = @(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255)
}

# Simple hash function for our hash tables
function Hash {
    param ([int]$CIDR)
    
    $hashedValue = $CIDR % 8 

    return $hashedValue
}

# Globals to be used by the functions
$firstOctet = [int[]]::new(3) 
$secondOctet = [int[]]::new(3) 
$thirdOctet = [int[]]::new(3) 
$fourthOctet = [int[]]::new(3) 
$tempIP = $firstOctet, $secondOctet, $thirdOctet, $fourthOctet
$stringIP = [string[]]::new(4)

# Gives us the octets in a 2D array still in ascii decimal values
function toOctets{
    param ($charArray)

    [int]$k = 0

    for([int]$i = 0; $i -lt $charArray.Length; $i++){
        if($i -eq 4){
            Write-Host "Invalid IP Address Inputted: Too Many Octets"
            exit
        }
        for([int]$j = 0; $charArray[$k] -ne '.'; $j++){
            if(($null -eq $charArray[$k])){
                break
            }
            if($j -eq 3){
                Write-Host "Invalid IP Address Inputted: Overflow"
                exit
            }
            $tempIP[$i][$j] = $charArray[$k]
            $k++
        }
        if(($null -eq $charArray[$k])){
            break
        }
        $k++
    }
} 

# Will give us an array of the octets
function toSolidInt{
    for([int]$i = 0; $i -lt $tempIP.Length; $i++){
        for([int]$j = 0; $j -lt $tempIP[$i].Length; $j++){
            if($tempIP[$i][$j] -eq 0){
                break
            }
            else{
                $stringIP[$i] += toValidInt($tempIP[$i][$j])
            }
        }
    }
}

function toUsableIP {

    $numIP = [int[]]::new(4) 

    for([int]$i = 0; $i -lt $stringIP.Length; $i++){
        $numIP[$i] = $stringIP[$i] -as [int]
    }
    return $numIP
}

# Start of code
Write-Host ""
[string]$inputString = Read-Host -Prompt "Enter in target IP Address"
$charArray = $inputString.ToCharArray()

# Function Calls

# Breaks IP into 2D array with each octet in its own array, held within an array
toOctets($charArray)

# Will take 2D array and converge it into a single array of strings
toSolidInt

# Verifies that the IP entered was a valid entry
verifyIP($stringIP)

# Converts array of String octects into ints for computations.
$IP = toUsableIP

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

# Runs the main program
run

# Pauses the program to view results
Pause

# To convert PowerShell Script to a .exe file
# ps2exe .\source.ps1 .\target.exe
