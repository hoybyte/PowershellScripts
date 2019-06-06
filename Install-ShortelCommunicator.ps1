function Install-ShortelCommunicator {
<#

#>

    param (
        [Parameter(ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   Mandatory=$True)]
        [Alias('CN','MachineName','Name')]
        [sring]$computername

    ) #param

    [CmdletBinding]

    foreach ($computer in $computername) {
        # Create a new Powershell Session to invoke the command to
        Write-Verbose "Creating Session to $computer"
        $session = New-PSSession -ComputerName $computer

        # Output to prompt what computer we are sending the command to
        Write-Verbose "Invoking Shortel Communicator Start-Process command on computer: $computer"

        # Invoke the scriptblock into the powershell session we created earlier
        Write-Verbose "Invoking Command to $computer"
        Invoke-Command -Session $session -ScriptBlock {
            $currentlocation = "C:\Install\_Code"
            $exe = "setup.exe"
            $arguments = "S /v/qn"
            
            Write-Verbose "Installing application ($exe) using $arguments"
            Start-Process -FilePath "$currentlocation\$exe" -ArgumentList $arguments
        } # invoke Command

        # Grab last exit code from remote computer to make sure the install was successful.
        Write-Verbose "Retrieving Last Exit Code"
        $remotelastexitcode = Invoke-command -ScriptBlock {$lastexitcode} -Session $remotesession

        # Print to prompt if installation was sucessful or a failure
        Write-Verbose "Evaluating Last Exit Code"
        If ($remotelastexitcode -eq '2') {
            Write-Host "Computer: $computer - LastExitCode was 2. Successful Install"
        } Else {
            Write-Host "Computer: $computer - LastExitCode was not 2, it was $remotelastexitcode. Something went wrong with install."
        } # if block

    } # foreach

} #function