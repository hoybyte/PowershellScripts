function Install-ShortelCommunicator {
<#
.SYNOPSIS
Install Shortel Communicator app on remote computer


#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   Mandatory=$True)]
        [Alias('CN','MachineName','Name')]
        [string]$computername

    ) #param

    

    foreach ($computer in $computername) {
        # Create a new Powershell Session to invoke the command to
        Write-Verbose "Creating Session to $computer"
        $session = New-PSSession -ComputerName $computer

        # Invoke the scriptblock into the powershell session we created earlier
        Write-Verbose "Installing Application to $computer"

        Invoke-Command -Session $session  -ScriptBlock {
            Start-Process -FilePath C:\Install\_Code\Setup.exe -ArgumentList "/S /v /qn"
        } # invoke command

        # Grab last exit code from remote computer to make sure the install was successful.
        Write-Verbose "Retrieving Last Exit Code"
        $remotelastexitcode = Invoke-command -ScriptBlock {$lastexitcode} -Session $session

        # Print to prompt if installation was sucessful or a failure
        Write-Verbose "Evaluating Last Exit Code"
        If ($remotelastexitcode -eq '2') {
            Write-Host "Computer: $computer - LastExitCode was 2. Successful Install"
        } Else {
            Write-Host "Computer: $computer - LastExitCode was not 2, it was $remotelastexitcode. Something went wrong with install."
        } # if block

    } # foreach

} #function