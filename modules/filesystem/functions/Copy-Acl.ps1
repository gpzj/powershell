Function Copy-Acl {

<#
.SYNOPSIS
Copy ACL from one directory or file to another.
.DESCRIPTION
Uses Get-Acl and Set-Acl, along with methods of the System.Security.AccessControl.FileSystemSecurity Class to copy the permissions from 1 directory or file to another directory or file.
.EXAMPLE
Copy-Acl -SourcePath C:\Users\YourName\MyDirectory\ -DestinationPath C:\Users\TheirName\TheirDirectory\
.EXAMPLE
Copy-Acl -SourcePath \\smb-server\someshare\dir1 -DestinationPath \\smb-server\othershare\dir1\
.NOTES
1. This is designed to work with ADUsers as owners, used via the class System.Security.Principal.NTAccount and NOT Microsoft.ActiveDirectory.Management.ADAccount that is generated from Get-ADUser.
2. Depending on the smb server, you must have Admin/root privledges. Full Access will not suffice.
#>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            If( -Not ($_ | Test-Path) ){
                throw "File or Directory does not exist"
            }
            return $true         
        })]
        [System.IO.FileInfo]$SourcePath,
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            If( -Not ($_ | Test-Path) ){
                throw "File or Directory does not exist"
            }
            return $true         
        })]
        [System.IO.FileInfo]$DestinationPath            
    )

    # Get ACL for both source and destination. We need to edit 
    $sourceACL = Get-Acl -Path  $SourcePath
    $destinationACL = Get-Acl -Path $DestinationPath
    $owner = $sourceACL.Owner.Split('\')
    If ($owner.Count -ne 2 ) {
        throw "Owner Not Recognized As AD Account"
    }
    $ownerID = New-Object System.Security.Principal.NTAccount($owner[0],$owner[1])
    
    # Clear current access rules on destinationPath's destinationACL.
    Foreach ($ar in $destinationACL.Access) {
        $null = $destinationACL.RemoveAccessRule($ar) # didn't use |Out-Null because it throws an error if there were no access rules. Probably doesn't matter with it in the loop, but just in case.
    }
    
    # Transfer Owner
    $destinationACL.SetOwner($ownerID)
    
    Foreach ($ar in $sourceACL.Access) {
        $destinationACL.AddAccessRule($ar)
    }
    
    # Set modified ACL
    Set-Acl -Path $destinationPath -AclObject $destinationACL
  
}
