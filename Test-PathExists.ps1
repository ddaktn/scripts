
### Check to see if a path exists ###
## If it exists ##

$path = "UNC path"

if (Test-Path $path) {
Write-Host "Path exists"
}
Else {
Write-Host "Path does NOT exist"
}


### Using the -not operator for the OPPOSITE logic ###
## If DOESN'T exist ##

$path = "UNC path"

if (-not (Test-Path $path)) {
Write-Host "Path does NOT exist"
}

# Same logic with alternate -not (!) logical operator #

$path = "UNC path"

if (!(Test-Path $path)) {
Write-Host "Path does NOT exist"
}