Function Get-RCSSDomainControllerInfo {
    ForEach ($domain in (Get-ADForest).domains) {
        $hosts = Get-ADDomainController -Filter * -server $domain | Sort-Object -Property hostname
        ForEach ($host in $hosts) {
            $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $host
            $props = @{'ComputerName'=$host
                        'DomainController'=$host
                        'Manufacturer'=$cs.Manufacturer
                        'Model'=$cs.Model
                        'TotalPhysicalMemory(GB)'=$cs.TotalPhysicalMemory / 1GB }
            New-Object -Type psobject -Property $props
        } #foreach $host
    } #foreach $domain
}#Function


