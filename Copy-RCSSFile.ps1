function Copy-RCSSFile {
    <#
    .SYNOPSIS
    Copy files from a given path to a remote computer.
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
    
