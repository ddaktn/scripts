$directory = Get-Item .

$directory | Get-ChildItem | Measure-Object -Sum Length | Select-Object @{Name="Path"; Expression={$directory.FullName}}, @{Name="Files"; Expression={$_.Count}}, @{Name="Size"; Expression={$_.Sum}}
