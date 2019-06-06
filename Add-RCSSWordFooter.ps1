function Add-RCSSWordFooter {
    <#
    .SYNOPSIS
    Add FilePath Footer to Word Documents (.doc, .docx)
    

    .DESCRIPTION
    The script will recursively search a given path and add the filepath footer to each document. Path is mandatory as you will need the path to search for documents. 
    
    .PARAMETER Path
    The file location of the word documents

    .EXAMPLE
    ADD-RCSSWordFooter -Path C:\WordDocuments\

    The Example is going to search through the C:\WordDocuments folder recursively and add the filepath footer to each Word document. 

    .Notes
        Our Department is requiring users to add the filepath location to each word document to assist with retrieving documents for printing.

    #>
    [CmdletBinding()]

    param (
        [Parameter (Mandatory = $true,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [System.IO.FileInfo]$path
    )
BEGIN {

} #BEGIN

PROCESS {
    Write-Verbose -Message "Adding the wdFieldFileName to script"
    Set-Variable -Name wdFieldFileName -Value 29 -Option constant -Force -ErrorAction SilentlyContinue

    Write-Verbose -Message "Adding the Microsoft File Type to wdFieldFileName"
    Add-Type -AssemblyName Microsoft.Office.Interop.Word 

    Write-Verbose -Message "Looking at $path for Word Documents"
    $wordFiles = Get-ChildItem -Path $path -Include *.doc, *.docx -Recurse

    Write-Verbose -Message "Opening Word process for adding footer"
    $word = New-Object -ComObject Word.Application
    $word.Visible = $true # Remove this line later to keep the application invisible; when testing though, better to work with a visible application

    foreach ($wd in $wordFiles) { 
        Write-Verbose -Message "Opening $wd file"
        $doc = $word.documents.open($wd.fullname)
        
        Write-Verbose -Message "Creating Footer in $wd"
        $field = $doc.Fields.Add($doc.Sections.Item(1).Footers.Item(1).Range, $wdFieldFileName, '\p')

        Write-Verbose -Message  "Saving changes to $doc"
        $doc.Save() 

        Write-Verbose -Message "Closing $doc"
        $doc.Close() 
    } #foreach

    Write-Verbose "Closing the Word process"
    $word.Quit()
} #PROCESS

END{

} #END

}

