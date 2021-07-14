# . "C:\Users\JZubia\OneDrive - Computex Technology Solutions\Desktop\IPCalculator\UtilFunctions.ps1"

. "C:\Users\Jz\OneDrive\Desktop\PowerShellScripts\IPCalculator\UtilFunctions.ps1"

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