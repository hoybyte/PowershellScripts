function Get-RCSSFolderSize {
    [CmdletBinding()]
    Param (
        [Parameter(Mandator = $true,
                   ValueFromPipeline = $True,
                   ValueFromPipelineByPropertyName = $True)]
        [string[]]$Path
    )

    BEGIN {
        #Intentionally Empty
    } #BEGIN

    PROCESS {
        ForEach ($Folder in $path) {
            Write-Verbose "Checking $folder"
            if (Test-Path -Path $folder) {
                Write-Verbose " + Path exists"
                $params = @{'Path'=$Folder
                            'Recurse'=$true
                            'File'=$true}
                $measure = Get-Childitem @params | Measure-Object -Property Length -Sum
                [pscustomobject]@{'Path'=$Folder
                                  'Files'=$measure.Count
                                  'Bytes'=$measure.sum}     
            } else {
                Write-Verbose " - Path does not exist"
                [pscustomobject]@{'Path'=$Folder
                                  'Files'=0
                                  'Bytes'=0}
            } #if folder exists
        } #foreach
    } #process

    END{
        #Intentionally Empty
    } #END
} #function