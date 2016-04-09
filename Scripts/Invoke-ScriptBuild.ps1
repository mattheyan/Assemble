param(
    [Parameter(Mandatory=$true, HelpMessage="Name of the module to build")]
    [string]$Name,

    [Parameter(Mandatory=$false, HelpMessage="Path to the directory that contains the source files for the module")]
    [string]$SourcePath,

    [Parameter(Mandatory=$false, HelpMessage="Path to the directory where the completed module will be copied")]
    [string]$TargetPath,

    [Parameter(Mandatory=$false, HelpMessage="The names of dependent modules to validate")]
    [array]$DependenciesToValidate=@(),

    [Parameter(Mandatory=$false, HelpMessage="Forcibly copy over the module file if it already exists")]
    [switch]$Force,

    [Parameter(Mandatory=$false, HelpMessage="PowerShell scripts (.ps1) to exclude from source files that are included")]
    [string[]]$Exclude,

    [Parameter(Mandatory=$false, HelpMessage="Flags used by preprocessor.")]
    [string[]]$Flags
)

#ifdef SOURCE
. .\__init__.ps1
#endif

# Ensure that the source and target paths valid directories if specified
$SourcePath = EnsureDirectory $SourcePath $true
$TargetPath = EnsureDirectory $TargetPath $true

# Create a temporary directory to build in
$buildDir = GetTempDirectory
Write-Host "Starting script build for module '$($Name)'."
Write-Host "NOTE: Building in temporary directory '$($buildDir)'..."

$moduleFile = "$buildDir\$($Name).psm1"

Write-Host "Creating empty module file..."
New-Item $moduleFile -Type File | Out-Null

# Ensure that required modules are available and loaded
$DependenciesToValidate | foreach {
    Write-Host "Adding dependency to" + $_
    Add-Content -Path $moduleFile -Value ("if (!(Get-Module " + $_ + ")) {")
    Add-Content -Path $moduleFile -Value ("`tImport-Module " + $_ + " -ErrorAction Stop")
    Add-Content -Path $moduleFile -Value "}"
    Add-Content -Path $moduleFile -Value ""
}

$symbols = @()
$sources = @()

Write-Host "Searching for source files to include..."
Get-ChildItem -Path $SourcePath -Exclude $Exclude -Filter "*.ps1" -Recurse | %{
    if ($_.Name -eq "__init__.ps1") {
        Write-Host "Found __init__ (initialize) file."
        $sources += $_.FullName
    }
    elseif ($_.Name -eq "__final__.ps1") {
        Write-Host "Found __final__ (finalize) file."
        $sources += $_.FullName
    }
    elseif ($_.Name -match "([A-Z][a-z]+`-[A-Z][A-Za-z]+)`.ps1") {
        Write-Host "Found source file $($_)."
        $symbols += $_.Name -replace ".ps1", ""
        $sources += $_.FullName
    }
    else {
        throw "Invalid file name '$($_.Name)'."
    }
}

Write-Host "Symbols: $symbols"

$initFileExpr = "^\s*\. \.\\__init__\.ps1$"

$ifExpr = "^\s*#if"
$ifDefExpr = "^\s*#ifdef\s+(.+)\s*$"

$initFile = (resolve-path $SourcePath).Path + "\__init__.ps1"
$finalFile = (resolve-path $SourcePath).Path + "\__final__.ps1"

Write-Host "Including source files..."

if ($sources -contains $initFile) {
    Write-Host "Including file __init__.ps1"
    $ignore = $false
    (Get-Content $initFile | % {
        if ($_ -match $ifExpr) {
            if ($_ -match $ifdefExpr) {
                $flag = $_ -replace $ifdefExpr, '$1'
                Write-Host "Checking for flag $($flag)..."
                if ($Flags -contains $flag) {
                    Write-Host "Found flag $flag."
                }
                else {
                    Write-Host "Did not find flag $flag. Ignoring content..."
                    $ignore = $true
                }
            }
            else {
                throw "Invalid #if block: $_"
            }
        }
        elseif ($_ -match "^\s*#endif\s*$") {
            $ignore = $false
        }
        elseif ($ignore) {
            Write-Host "Ignored: $_"
        }
        else {
            Write-Output $_
        }
    }) | Add-Content -Path $moduleFile
    Add-Content -Path $moduleFile -Value "`r`n"
}

$sources | sort Name | foreach {
    if ($_ -ne $initFile -and $_ -ne $finalFile) {
        $n = ((Split-Path -Path $_ -Leaf) -replace ".ps1", "")
        Write-Host "Including file $($n).ps1"
        if ($n -ne "__init__") {
            Add-Content -Path $moduleFile -Value ("function " + $n + " {")
        }
        $ignore = $false
        ((Get-Content $_) | % {
            if ($_ -match $ifExpr) {
                if ($_ -match $ifdefExpr) {
                    $flag = $_ -replace $ifdefExpr, '$1'
                    Write-Host "Checking for flag $($flag)..."
                    if ($Flags -contains $flag) {
                        Write-Host "Found flag $flag."
                    }
                    else {
                        Write-Host "Did not find flag $flag. Ignoring content..."
                        $ignore = $true
                    }
                }
                else {
                    throw "Invalid #if block: $_"
                }
            }
            elseif ($_ -match "^\s*#endif\s*$") {
                $ignore = $false
            }
            elseif ($ignore) {
                Write-Host "Ignored: $_"
            }
            else {
                $newLine = "`t" + $_
                $foundFileRefs = $false
                if ($newLine -match $initFileExpr) {
                    $newLine = ""
                    $foundFileRefs = $true
                    Write-Host "Removed dot-source of '__init__.ps1'."
                }
                else {
                    $symbols | foreach {
                        $symbolExpr = "\.\\" + $_ + "\.ps1"
                        if ($newLine -match $symbolExpr) {
                            $foundFileRefs = $true
                            Write-Host "Found file reference to symbol '$($_)'."
                        }
                        $newLine = $newLine -replace $symbolExpr, $_
                    }
                    if ($foundFileRefs -eq $true) {
                        Write-Host "Result: $newLine"
                    }
                }
                if ($newLine) {
                    Write-Output $newLine
                }
            }
        }) | Add-Content -Path $moduleFile
        if ($n -ne "__init__") {
            Add-Content -Path $moduleFile -Value "}`r`n"
        }
    }
}

Write-Host "Registering export for symbols..."
$symbols | foreach {
    Add-Content -Path $moduleFile -Value ("Export-ModuleMember -Function " + $_)
}

if ($sources -contains $finalFile) {
    Write-Host "Including file __final__.ps1"
    $ignore = $false
    (Get-Content $finalFile | % {
        if ($_ -match $ifExpr) {
            if ($_ -match $ifdefExpr) {
                $flag = $_ -replace $ifdefExpr, '$1'
                Write-Host "Checking for flag $($flag)..."
                if ($Flags -contains $flag) {
                    Write-Host "Found flag $flag."
                }
                else {
                    Write-Host "Did not find flag $flag. Ignoring content..."
                    $ignore = $true
                }
            }
            else {
                throw "Invalid #if block: $_"
            }
        }
        elseif ($_ -match "^\s*#endif\s*$") {
            $ignore = $false
        }
        elseif ($ignore) {
            Write-Host "Ignored: $_"
        }
        else {
            Write-Output $_
        }
    }) | Add-Content -Path $moduleFile
    Add-Content -Path $moduleFile -Value "`r`n"
}

# Copy completed module to the current directory
if ((test-path -Path .\$($Name).psm1) -and !$Force.IsPresent) {
    throw "File '$($Name).psm1' already exists!"
}
Write-Host "Moving completed module..."
Copy-Item $moduleFile $TargetPath -Force | Out-Null

$PSBuildSuccess = $true
