$VMs = Get-VM
foreach ($vm in $VMs){
    $vm.extensiondata.config.files.VmPathName |
        select @{n="VMX Name";e={ $vm.extensiondata.config.files.VmPathName -creplace '^[^/]*/',''}} |
            Export-Csv C:\Temp\output.csv -Append -NoTypeInformation
}