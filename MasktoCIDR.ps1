# Start of Code
Write-Host ""
[string]$inputString = Read-Host -Prompt "Enter Subnet Mask"

# Converts Split char strings into binary strings
$bin = $inputString -split '\.' | ForEach-Object{
    [System.Convert]::ToString($_, 2).PadLeft(8, '0')
}

# Joins the binary strings into 1 string
Write-Host ""
Write-Host "Binary Representation of SubnetMask:"
$bin -join ""

[int]$CIDRCount = 0;

# Counts how many bits are set in the mask to determine the CIDR 
for([int]$i = 0; $i -lt 4; $i++){
    for([int]$j = 0; $j -lt 8; $j++){
        if($bin[$i][$j] -eq "0"){
           break
        }
        $CIDRCount++
    }
}

# Formats/Prints CIDR
[string]$CIDR = "/" + $CIDRCount 

Write-Host ""
Write-Host "Calculated CIDR:" $CIDR
Write-Host ""

Pause
