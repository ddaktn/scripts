### projecteuler.net/problem=5 ###

<#
2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.
What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?
#>


###Powershell way

for($i = 20; $i -le 1000000000; $i++){
    $found = $true
    for($e = 2; $e -le 20; $e++){
        if($i % $e -ne 0){
            $found = $false;
            break;            
        }
    }
    if($found){
        $i
    }
}

################################
### JAVASCRIPT IS WAY FASTER ###
################################


###Javascript way


for(var i = 20; i <= 1000000000; i++){
    var found = true;
    for(var e = 2; e <= 20; e++){
        if (i % e != 0) {
            found = false;
			break;
        }
    }
    if (found) {
        console.log(i);
    }
}
