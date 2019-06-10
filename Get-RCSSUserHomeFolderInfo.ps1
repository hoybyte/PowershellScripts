function Get-RCSSUserHomeFolderInfo {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$HomeRootPath
    )
    BEGIN {
        #Intentionally Blank
    } #BEGIN

    PROCESS {
        Write-Verbose "Enumerating $HomeRootPath"
        $params = @{'Path'=$HomeRootPath
                    'Directory'=$True}
        ForEach ($folder in (Get-Childitem @params)) {

            Write-Verbose "Checking $($folder.name)"
            $params = @{'Identity'=$folder.name
                        'ErrorAction'='SilentlyContinue'}
            $user = Get-ADUser @params

            if ($user) {
                Write-Verbose " + User exists"
                $result = Get-RCSSFolderSize -Path -$folder.fullname
                [pscustomobject]@{'User'=$folder.name
                                  'Path'=$folder.fullname
                                  'Files'=$result.Files
                                  'Bytes'=$result.Bytes
                                  'Status'='OK'}
            } else {
                Write-Verbose " - User does not exist"
                [pscustomobject]@{'User'=$folder.name
                                  'Path'=$folder.fullname
                                  'Files'=0
                                  'Bytes'=0
                                  'Status'="Orphan"}
            } #if user exists
        } #foreach
    } #PROCESS

    END{
        #intentionally blank
    } #END
    
} #function