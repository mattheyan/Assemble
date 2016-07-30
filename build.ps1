# Import local assemble to ensure that it can always build itself...
$reloadAssemble = $false
if (Get-Module Assemble -ErrorAction SilentlyContinue) {
    $reloadAssemble = $true
}
try {
    Import-Module .\Modules\Assemble\Assemble.psd1 -Scope Local -Force
    Invoke-ScriptBuild -Name Assemble -SourcePath .\Scripts -TargetPath .\Assemble -Force
} finally {
    Remove-Module Assemble
	if ($reloadAssemble) {
		Import-Module Assemble -Scope Global -Force
	}
}
