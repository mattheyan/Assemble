function GetTempDirectory {
    $tempDir = [system.io.path]::GetTempPath()
    $rndName = [system.io.path]::GetRandomFileName()
    $path = Join-Path $tempDir $rndName
    New-Item $path -Type Directory | Out-Null
    foreach ($a in $args) {
        New-Item $path\$a -Type Directory | Out-Null
    }
    return $path
}

function EnsureDirectory ([string]$path, [boolean]$defaultToCurrentLocation) {
    if ($path) {
        $path = $path.Trim()
    }

    if (!$path -and $defaultToCurrentLocation) {
        $path = Get-Location
    }
    elseif (!(Test-Path $path)) {
        Write-Error "Path '$($path)' does not exist."
        exit 1
    }
    else {
        $path = (Resolve-Path $path).Path
        if (!(Get-Item $path).PSIsContainer) {
            Write-Error "Path '$($path)' must be a directory."
            exit 1
        }
    }

    return $path
}
