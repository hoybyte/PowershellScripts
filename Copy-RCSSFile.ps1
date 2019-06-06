function Copy-RCSSFile {
    <#
    .SYNOPSIS
    Copy files from a given path to a remote computer.

    .DESCRIPTION
    The purpose of the script is to copy files from main computer to remote computers. The user will need admin access to create the connection to the remote computer as well add the folder if not present. I had to use the $using: variable as the $destinationfolder variable was not passing to the remote computers. Then, I had to add the variable again into the try block as I learned that the $using: variable only passes the local variable into one command and not recursively. 
    
    .PARAMETER computername
    The remote computer you wish to send files to.

    .PARAMETER path
    The location of which the file you want to transfer.

    .PARAMETER destination
    The file path on the remote computer


    .PARAMETER destinationfolder
    The folder path on the remote computer in which you want to place the file.

    .EXAMPLE
    "Server1","Server2" | Copy-RCSSFile -path "\\Server3\D$\Software\Applications\Shoretel Communicator\setup.exe" -destination "C:\Install\_Code\setup.exe" -Verbose

    IN this example, we are sending computernames into the pipeline and is fed into the Copy-RCSSFile function. This will copy the file in the path paramater into the remote computer destination folder.

    .EXAMPLE
    Copy-RCSSFile -computername "Server1","Server2" -path "\\Server3\D$\Software\Applications\Shoretel Communicator\setup.exe" -destination "C:\Install\_Code\setup.exe" -Verbose

    Using the whole function to pass the paramaters. Sends the path file to the remote computer(computername) in the destination folder.

    #>    
    
        [CmdletBinding()]
    
        param (
            [Parameter(Mandatory=$True,
                           ValueFromPipeline=$True,
                           ValueFromPipelineByPropertyName=$True)]
            [string]$computername,
              
            [Parameter(Mandatory=$True,
                            ValueFromPipelineByPropertyName=$True)]
            [string]$path,
            
            [Parameter(Mandatory=$True,
                            ValueFromPipelineByPropertyName=$True)]
            [string]$destination,

            [Parameter(ValueFromPipelineByPropertyName=$True)]
            [string]$destinationfolder

        ) # param
    BEGIN {
        # Setting up DestinationFolder
        Write-Verbose "Setting $destinationfolder variable"
        $destinationfolder = "C:\Install\_Code"
    } #BEGIN
    
    PROCESS {
        foreach ($computer in $ComputerName) {
            # Setting up Session to remote computer
            Write-Verbose "Connecting to $computer to copy items"
            $session = New-PSSession -ComputerName $computer
            Write-Verbose "Checking to see if $destinationfolder exists on $computer"
            Invoke-Command -Session $session -ScriptBlock {
                If (-not (Test-Path -LiteralPath $using:destinationfolder)) {
                    Try {
                        $destinationfolder = "C:\Install\_Code"
                        Write-Verbose "Creating $destinationfolder on $computer"
                        New-Item -Path $destinationfolder -ItemType Directory -ErrorAction Stop
                    } #try
    
                    Catch {
                        Write-Error -Message "Unable to create directory '$destinationfolder'. Error was: $_" -ErrorAction Stop
                    } #catch
                } Else {
                    Write-Verbose "Directory already exists"
                } #else
            } #invoke

            Write-Verbose "Copying files to $computer"
            Copy-Item -Path $path -Destination $destination -ToSession $session
            Write-Verbose "Closing $computer session" 
            Remove-PSSession -Session $session
        } # foreach
    } #PROCESS
    
    END {
    
    } #END
} #function
    
