Function Get-EnabledNonExpiringUser {
    Get-AdUser -Filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -Properties Name, PasswordNeverExpires, PasswordExpired,PaswordLastSet, EmailAddress |
    Where-Object {$_.passwordexpired =eq $false }
} #function

Function Add-ExpiryDatatoUser {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [object[]]$InputObject
    ) #parameters

    BEGIN {
        $defaultMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop).MaxPasswordAge.Days
        Write-Verbose "Max password age $defaultMaxPasswordAge"
    } #BEGIN

    PROCESS {
        ForEach ($user in $InputObject) {
            # determine max password age for user
            # this will either be based on their policy or
            # on the domain default if no user specific policy exists
            $passpolicy = Get-ADUserResultantPasswordPolicy $user
            if (($passpolicy) -ne $null) {
                $maxAge = ($passpolicy).MaxPasswordAge.Days
            } else {
                $maxAge = $defaultMaxPasswordAge
            } #If Policy
        
            # calculate and round days to expire;
            # Create and append text message to

            # user object

            $expiresOn = $user.passwordLastSet.AddDays($maxPasswordAge)
            $daystoExpire = New-TimeSpan -Start $today -End $expiresOn

            if (($daysToExpire.Days = "0") -and ($daysToExpire.TotalHours -le $timeToMidnight.TotalHours) ) {
                $user | Add-Member -Type NoteProperty -Name UserMessage -Value "today."
            }

            if ( ($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -gt $timeToMidngiht.TotalHours) -or ($daysToExpire -eq "1") -and `
                 ($daysToExpire.TotalHours -le $timeToMidnight2.TotalHours) ) {
                $user | Add-Member -Type NoteProperty -Name UserMessage -Value "tomorrow."    
            }

            if ( ($daysToExpire -ge "1") -and ($daysToExpire.TotalHours -gt $timetoMidnight2.TotalHours) ) {
                $days = $daysToExpire.TotalDays
                $days = [math]::Round($days)
                $user | Add-Member -Type NoteProperty -Name UserMessage -Value "in $days days."
            }

            $user | Add-Member -Type NoteProperty -Name DaysToExpire -Value $daystoExpire
            $user | Add-Member -Type NoteProperty -Name ExiresOn -Value $expiresOn

            Write-Output $user
        } #foreach
    } #PROCESS

    END {
        #Intentionally Blank
    } #END
} #function

Function Send-PasswordExpiryMessageToUser {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [object]$inputObject,

        [Parameter(Mandatory=$True)]
        [string]$From,

        [Parameter(Mandatory=$True)]
        [string]$smtpserver
    ) #Parameter

    BEGIN {
        #Intentionally Empty
    } #BEGIN

    PROCESS {
        ForEach ($user in $inputObject) {
            $subject =  "Password Expires $($User.UserMessage)"
            $body = @"
                Dear $($user.name),

                Your password will expire $($user.UserMessage).
                Please change it.

                Love, the Help Desk.

"@
            if ($PSCmdlet.ShouldProcess("Send Expiry Notice", "$($User.name) who expires$($user.usermessage)") {
                Send-MailMessage -SmtpServer $smtpserver `
                                 -from $From `
                                 -to $user.emailaddress `
                                 -subject $subject `
                                 -body $body
                                 -priority High
            } # If

            Write-Output $user
        } #foreach
    }#process

    END {
        #Intentionally Empty
    } #End
} #function