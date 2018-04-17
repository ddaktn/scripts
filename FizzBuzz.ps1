## FizzBuzz in Powershell ##

$range = 1..100

foreach ($value in $range) {
    if(($value%3 -eq 0) -and ($value%5 -eq 0)){
        Write-Host "FizzBuzz"
    }
    elseif($value%3 -eq 0){
        Write-Host "Fizz"
    }
    elseif($value%5 -eq 0){
        Write-Host "Buzz"
    }
    else{
        $value
    }
}

#region
## FizzBuzz in JavaScript ##
// fizzbuzz test
var fizzbuzz = function (numCount) {

	for (var i=1; i <= numCount; i++) {
 
		if ((i%3) === 0 && (i%5) === 0) {
			console.log("FizzBuzz");	
		}
		else if ((i%3) === 0) {
			console.log("Fizz");
		}
		else if ((i%5) === 0) {
			console.log("Buzz");		
		}
		else {
   		    console.log(i);

		}
	}

};
fizzbuzz(100)
#endregion
