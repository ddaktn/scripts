### WHILE loop example ###
$loop = 0
while ($loop -ne 5){
    $loop++
    $loop
}



### DO/WHILE loop example ###
$loop = 0
Do{
    $loop++
    $loop
} while ($loop -ne 5)


## Conditional LOOP ##
$loopcounter = 0
while($loopcounter -ne 5){
    if($true){
        $loopcounter++
        $loopcounter
    } else {
        $loopcounter = 5
    }
}


https://ss64.com/ps/do.html