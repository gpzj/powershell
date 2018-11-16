# Get, Add, and Remove Active Directory Users and Groups (referred to as Members) to Local Groups on Windows with Powershell 2.0 or higher and will do so remotely as long as you're on the domain.
# This is similar to the Get-LocalGroupMember commands in Powershell/WMF 5.1 however this will work on older versions of Powershell so you don't need to upgrade and reboot.
# Examples:
# Get-LocalGroupMember -ComputerName 'Some-Server' -Group 'Administrators'
#   Returns Members as a list (Use "| Select-Object -ExpandProperty Members" Or store results in a variable and expand the property by "$variable.Members" or " | Format-List" for a better view.
# Add-LocalGroupMember -ComputerName ('Server1', 'Server2', 'Sever3') -Group ('Event Log Readers', 'Remote Desktop Users') -Member ('User1', 'User2')
#   Adds User1 and User 2 to both the Event Log Readers and Remote Desktop Users Groups on all 3 Servers listed. Lists/Arrays will work on any of the commmands. 
# 
#I'll make a better module manifest/Readme soon.
#

Function Get-LocalGroupMember {
    [cmdletbinding()]
    Param (
        [parameter (Mandatory = $false, ValuefromPipelineByPropertyName = $true)]
        [array]$ComputerName = 'localhost',
        [parameter (Mandatory = $true, ValuefromPipelineByPropertyName = $true)]
        [array]$Group
    )
    
    Begin {
        $domain = $env:USERDOMAIN
    }

    Process {
        $LocalGroupMember = @()
        Foreach ($cn in $ComputerName) {
            Foreach ($g in $Group) {
                $localGroup = [ADSI]"WinNT://$cn/$g,group"
                $members = $localGroup.psbase.invoke("Members")
                $Member = $members.foreach({$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)})
                $LocalGroupMemberNew = New-Object -TypeName PSObject -Property @{
                                                    ComputerName = $cn
                                                    Group = $g
                                                    Member = $Member
                                                    }                
                $LocalGroupMember += $LocalGroupMemberNew
                Write-Output $LocalGroupMemberNew
            }
        }
    }

    End {}

} # End Get-LocalGroupMember

Function Add-LocalGroupMember {
    [cmdletbinding()]
    Param (
        [parameter (Mandatory = $false, ValuefromPipelineByPropertyName = $true)]
        [array]$ComputerName = 'localhost',
        [parameter (Mandatory = $true, ValuefromPipelineByPropertyName = $true)]
        [array]$Group,
        [parameter (Mandatory = $true, ValuefromPipelineByPropertyName = $true)]
        [array]$Member
    )
     
Begin {
    $domain = $env:USERDOMAIN
}

Process {
    Foreach ($cn in $ComputerName) {
        Foreach ($g in $Group) {
            $localGroup = [ADSI]"WinNT://$cn/$g,group"
            Foreach ($m in $Member) {
                Write-Verbose  "Performing the operation `"Add member $domain\$m`" on target `"$g`"."
                $localGroup.psbase.invoke("Add",([ADSI]"WinNT://$domain/$m").path)
            }
        }
    }
}

End {}

} # End Add-LocalGroupMember

Function Remove-LocalGroupMember {
    [cmdletbinding()]
    Param (
        [parameter (Mandatory = $false, ValuefromPipelineByPropertyName = $true)]
        [array]$ComputerName = 'localhost',
        [parameter (Mandatory = $true, ValuefromPipelineByPropertyName = $true)]
        [array]$Group,
        [parameter (Mandatory = $true, ValuefromPipelineByPropertyName = $true)]
        [array]$Member
    )
     
Begin {
    $domain = $env:USERDOMAIN
}

Process {
    Foreach ($cn in $ComputerName) {
        Foreach ($g in $Group) {
            $localGroup = [ADSI]"WinNT://$cn/$g,group"
            Foreach ($m in $Member) {
                Write-Verbose  "Performing the operation `"Remove member $domain\$m`" on target `"$g`"."
                $localGroup.psbase.invoke("Remove",([ADSI]"WinNT://$domain/$m").path)
            }
        }
    }
}

End {}

} # End Remove-LocalGroupMember

