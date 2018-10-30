[CmdletBinding()]

$computers = Get-Content  -Path C:\_IT\computers.txt

foreach ($computer in $computers) {
    Try {
        Write-Host "Checking Network connection to $Computer"
        Test-Connection 
    }
    catch {

    }
}
Test-Connection -ComputerName $ComputerName