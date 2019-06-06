# Script used to reboot SNP workstations that have been online for more than 20 days. 

$computers = (Get-Content -Path C:\_Code\computers.txt) #list of computers
foreach ($computer in $computers) {
    $cim = ""
    if (Test-Connection $computer -Quiet){
        $cim = Get-CimInstance -ClassName CIM_OperatingSystem -ComputerName $computer
        if ($cim.LastBootUpTime -lt (Get-Date).AddDays(-20)){
            Restart-Computer -ComputerName $computer -Force
            Write-Host "$Computer was rebooted" | C:\_Code\computerrebootlog.txt
        }
    }
}
