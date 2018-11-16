# Get, Add, and Remove Active Directory Users and Groups to Local Groups on Windows running Powershell 2.0+
# I will work on module manuscript and ReadMe soon.

Function Get-GntxLocalGroupMember {
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
        $GntxLocalGroupMember = @()
        Foreach ($cn in $ComputerName) {
            Foreach ($g in $Group) {
                $localGroup = [ADSI]"WinNT://$cn/$g,group"
                $members = $localGroup.psbase.invoke("Members")
                $Member = $members.foreach({$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)})
                $GntxLocalGroupMemberNew = New-Object -TypeName PSObject -Property @{
                                                    ComputerName = $cn
                                                    Group = $g
                                                    Member = $Member
                                                    }                
                $GntxLocalGroupMember += $GntxLocalGroupMemberNew
                Write-Output $GntxLocalGroupMemberNew
            }
        }
    }

    End {}

} # End Get-GntxLocalGroupMember

Function Add-GntxLocalGroupMember {
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

} # End Add-GntxLocalGroupMember

Function Remove-GntxLocalGroupMember {
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

} # End Remove-GntxLocalGroupMember

