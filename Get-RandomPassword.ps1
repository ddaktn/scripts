function Get-RandomPassword {
    
    [CmdletBinding()]
    PARAM(        
        [Parameter(Mandatory=$false,Position=1)][int]$stringLength = 10,
        [Parameter(Mandatory=$false,Position=2)][int]$nonAlphaChars = 1
    )

    [char[]]$alphaUpper = [char]'A'..[char]'Z'
    [char[]]$alphaLower = [char]'a'..[char]'z'
    [char[]]$specialChars = "~","!","@","#","$","%","^","&","*","(",")","-",":",";","'","\","[","]","{","}","|","+","=",'"','`',",","<",">","?","/","."
    [int[]]$nums = '0'..'9'         
    [array]$stringArray | Out-Null
    [array]$nonAlphaArray | Out-Null
    [array]$finalStringArray | Out-Null
    [string]$finalString | Out-Null
    [int]$i = 0
    [int]$alphaCharsLength = ($stringLength - $nonAlphaChars)
    [bool]$goodString = $false        
    
    if($stringLength -le $nonAlphaChars){
        Write-Error "OOPS! Your total string count MUST be more than your non-alphanumeric count! Script is now exiting..."
    } else {
        WHILE($i -le $alphaCharsLength){
            if($alphaCharsLength -lt 3){
                Write-Error "OOPS! Your string had too many non-alphanumeric characters or wasn't long enough! Your random string MUST contain ONE uppercase, ONE lowercase and ONE number! Script is now exiting..."
                break;
            } else {
                $goodString = $true
                $stringArray += (Get-Random -InputObject $alphaUpper)
                $i++
                if($i -ge $alphaCharsLength){
                    break;
                }
                $stringArray += (Get-Random -InputObject $alphaLower)
                $i++
                if($i -ge $alphaCharsLength){
                    break;
                }
                $stringArray += (Get-Random -InputObject $nums) 
                $i++
                if($i -ge $alphaCharsLength){
                    break;
                }
            }     
        }
        if($goodString){
            $stringArray = -join $stringArray
            if($nonAlphaChars -ne 0){
                $nonAlphaArray = Get-Random -InputObject $specialChars -Count $nonAlphaChars
            }
            $nonAlphaArray = -join $nonAlphaArray
            $finalStringArray = $nonAlphaArray + $stringArray
            $finalString = ($finalStringArray.ToCharArray() | Get-Random -Count $stringLength) -join ''        
            return $finalString
        }
    }    
}