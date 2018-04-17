### Script to find all OST and PST files (by extension) on File Shares -- Doug Nelson -- 09/05/2017

### Create a variable to read in a text file list of all the File Servers
$FileServers = Get-content C:\FileServers.txt

### Use an invoke to run the command locally on all file share servers to recursively searcht the E drive for all PST and OST files by extention and output that to a text file
Invoke-Command -ComputerName $FileServers -ScriptBlock {Get-ChildItem "E:\" -Recurse | 
where {$_.extension -eq '.pst' -or $_.extension -eq '.ost'}} | 
out-file C:\OSTandPSTList.txt