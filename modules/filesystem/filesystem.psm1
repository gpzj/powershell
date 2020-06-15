$functionPath = Join-Path -Path $PSScriptRoot -ChildPath 'functions'

If (Test-Path $functionPath) {
$functions = Get-ChildItem -Path $functionPath -File -Recurse | Where-Object {$_.Extension -eq '.ps1'}
}

ForEach ($function in $functions.FullName) {
        . $function
    }

Export-ModuleMember -Function *Gntx* -Cmdlet *Gntx* -Variable * -Alias *
