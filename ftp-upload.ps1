param(
    [string]$FtpHost = 'ftp.gruporiostampico.com',
    [string]$FtpUser = 'o79iaf28nxvs',
    [string]$FtpPass = 'AnimalSMF98@',
    [string]$LocalRoot = 'C:\\Users\\jaiom\\OneDrive\\Documentos\\GitHub\\grupo-rios-tampico',
    [string]$RemoteRoot = '/public_html',
    [switch]$SkipSizeCheck  # Force upload all files without checking remote sizes
)

$ErrorActionPreference = 'Stop'
$creds = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)

# Global cache for remote file sizes
$script:RemoteFileCache = @{}

# Paths/directories we must remove from server before a clean upload
$CleanDirs = @(
    '/public_html/objects',
    '/public_html/refs',
    '/public_html/ogos',
    '/public_html/s con las que trabajamos'
)

$CleanFiles = @(
    '/public_html/HEAD',
    '/public_html/FETCH_HEAD',
    '/public_html/ORIG_HEAD',
    '/public_html/description',
    '/public_html/config',
    '/public_html/COMMIT_EDITMSG'
)

# Exclusions to avoid uploading repo/aux files
$ExcludeGlobs = @('*.git*', '*.git', '*.gitignore', '*.gitattributes', '*.gitmodules', '*.DS_Store', 'ftp-upload.ps1')
$ExcludeDirs  = @('.git', '.github', '.vscode', 'node_modules', '.idea')

# Allowed file extensions (lowercase compare)
$AllowedExt = @('.html','.htm','.css','.js','.php','.png','.jpg','.jpeg','.webp','.svg','.gif','.ico','.pdf','.txt','.json','.woff','.woff2','.ttf','.eot','.htaccess')

function Get-RelativePath {
    param([string]$Base,[string]$Full)
    $baseFull = [System.IO.Path]::GetFullPath($Base.TrimEnd('\','/'))
    $fullFull = [System.IO.Path]::GetFullPath($Full)
    if ($fullFull.StartsWith($baseFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullFull.Substring($baseFull.Length).TrimStart([char[]]"\\/")
    }
    return [System.IO.Path]::GetFileName($Full)
}

function Ensure-FtpDir {
    param([string]$RemoteDir)
    $segments = $RemoteDir -split '/' | Where-Object { $_ -ne '' }
    $current = ''
    foreach ($seg in $segments) {
        $current = "$current/$seg"
        $uri = "ftp://$FtpHost$current"
        $req = [System.Net.FtpWebRequest]::Create($uri)
        $req.Credentials = $creds
        $req.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $req.UseBinary = $true
        $req.KeepAlive = $false
        try {
            $resp = $req.GetResponse()
            $resp.Close()
            Write-Host "Created $current"
        } catch {
            # Ignore errors (already exists or no permission on root)
        }
    }
}

function Get-FtpFileSize {
    param([string]$RemotePath)
    
    # Use cache if available
    if ($script:RemoteFileCache.ContainsKey($RemotePath)) {
        return $script:RemoteFileCache[$RemotePath]
    }
    
    try {
        $uri = "ftp://$FtpHost$RemotePath"
        $req = [System.Net.FtpWebRequest]::Create($uri)
        $req.Credentials = $creds
        $req.Method = [System.Net.WebRequestMethods+Ftp]::GetFileSize
        $req.UseBinary = $true
        $req.KeepAlive = $false
        $req.Timeout = 5000
        $resp = $req.GetResponse()
        $size = $resp.ContentLength
        $resp.Close()
        $script:RemoteFileCache[$RemotePath] = $size
        return $size
    } catch {
        return -1
    }
}

function Upload-FtpFile {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [switch]$Force
    )
    
    if (-not $Force) {
        $localSize = (Get-Item $LocalPath).Length
        $remoteSize = Get-FtpFileSize -RemotePath $RemotePath
        
        if ($remoteSize -ge 0 -and $remoteSize -eq $localSize) {
            Write-Host "Skipped $RemotePath (same size)" -ForegroundColor DarkGray
            return $false
        }
    }
    
    $uri = "ftp://$FtpHost$RemotePath"
    $req = [System.Net.FtpWebRequest]::Create($uri)
    $req.Credentials = $creds
    $req.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $req.UseBinary = $true
    $req.KeepAlive = $false
    $req.Timeout = 30000
    $bytes = [System.IO.File]::ReadAllBytes($LocalPath)
    $req.ContentLength = $bytes.Length
    $stream = $req.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
    $resp = $req.GetResponse()
    $resp.Close()
    Write-Host "Uploaded $RemotePath" -ForegroundColor Green
    return $true
}

function Get-FtpDetailedListing {
    param([string]$RemoteDir)
    try {
        $uri = "ftp://$FtpHost$RemoteDir"
        $req = [System.Net.FtpWebRequest]::Create($uri)
        $req.Credentials = $creds
        $req.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
        $req.UseBinary = $true
        $req.KeepAlive = $false
        $req.Timeout = 10000
        $resp = $req.GetResponse()
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $listing = $reader.ReadToEnd()
        $reader.Close(); $resp.Close()
        return $listing
    } catch {
        return ""
    }
}

function Build-RemoteFileCache {
    param([string]$BaseDir)
    Write-Host "Building remote file cache..." -ForegroundColor Yellow
    $cached = 0
    
    function Recurse-FtpDir {
        param([string]$Dir)
        $listing = Get-FtpDetailedListing -RemoteDir $Dir
        if ([string]::IsNullOrWhiteSpace($listing)) { return }
        
        $lines = $listing -split "`n" | Where-Object { $_ -ne '' }
        foreach ($line in $lines) {
            # Parse Unix-style listing: drwxr-xr-x  2 user group  4096 Jan 01 12:00 filename
            # or Windows-style: 01-01-26  12:00PM  <DIR>  dirname
            if ($line -match '^d' -or $line -match '<DIR>') {
                # Directory
                $parts = $line -split '\s+' | Where-Object { $_ -ne '' }
                $name = $parts[-1]
                if ($name -notin @('.', '..')) {
                    $subDir = "$Dir/$name" -replace '//','/'
                    Recurse-FtpDir -Dir $subDir
                }
            } elseif ($line -match '^[-rwx]') {
                # Unix file: extract size (column 4) and name (last)
                $parts = $line -split '\s+' | Where-Object { $_ -ne '' }
                if ($parts.Count -ge 5) {
                    $size = $parts[4]
                    $name = $parts[-1]
                    if ($size -match '^\d+$' -and ![string]::IsNullOrWhiteSpace($name)) {
                        $filePath = "$Dir/$name" -replace '//','/'
                        $script:RemoteFileCache[$filePath] = [long]$size
                        $script:cached++
                    }
                }
            } elseif ($line -match '\d+:\d+\s+(AM|PM)\s+\d+\s+') {
                # Windows file format
                $parts = $line -split '\s+' | Where-Object { $_ -ne '' }
                if ($parts.Count -ge 4 -and $parts[2] -match '^\d+$') {
                    $size = $parts[2]
                    $name = $parts[-1]
                    $filePath = "$Dir/$name" -replace '//','/'
                    $script:RemoteFileCache[$filePath] = [long]$size
                    $script:cached++
                }
            }
        }
    }
    
    Recurse-FtpDir -Dir $BaseDir
    Write-Host "Cached $script:cached remote files" -ForegroundColor Yellow
}

function Get-FtpItems {
    param([string]$RemoteDir)
    $uri = "ftp://$FtpHost$RemoteDir"
    $req = [System.Net.FtpWebRequest]::Create($uri)
    $req.Credentials = $creds
    $req.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $req.UseBinary = $true
    $req.KeepAlive = $false
    $resp = $req.GetResponse()
    $stream = $resp.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $items = @()
    while (-not $reader.EndOfStream) {
        $line = $reader.ReadLine()
        if ($line -and $line -notin @('.','..')) { $items += $line }
    }
    $reader.Close(); $resp.Close()
    return $items
}

function Remove-FtpTree {
    param([string]$RemoteDir)
    try {
        $entries = Get-FtpItems -RemoteDir $RemoteDir
    } catch {
        return
    }
    foreach ($entry in $entries) {
        $child = "$RemoteDir/$entry" -replace '//','/'
        # Try file delete first
        $delFile = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$child")
        $delFile.Credentials = $creds
        $delFile.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
        $delFile.UseBinary = $true
        $delFile.KeepAlive = $false
        try {
            $resp = $delFile.GetResponse(); $resp.Close(); Write-Host "Deleted file $child"; continue
        } catch {
            # If delete failed, assume directory and recurse
        }
        Remove-FtpTree -RemoteDir $child
        $delDir = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$child")
        $delDir.Credentials = $creds
        $delDir.Method = [System.Net.WebRequestMethods+Ftp]::RemoveDirectory
        $delDir.UseBinary = $true
        $delDir.KeepAlive = $false
        try { $resp2 = $delDir.GetResponse(); $resp2.Close(); Write-Host "Removed dir $child" } catch {}
    }
    # finally remove current dir (if it's not the root target)
    if ($RemoteDir -ne '/public_html') {
        $delDir2 = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemoteDir")
        $delDir2.Credentials = $creds
        $delDir2.Method = [System.Net.WebRequestMethods+Ftp]::RemoveDirectory
        $delDir2.UseBinary = $true
        $delDir2.KeepAlive = $false
        try { $r = $delDir2.GetResponse(); $r.Close(); Write-Host "Removed dir $RemoteDir" } catch {}
    }
}

Write-Host "Starting cleanup..."
foreach ($dir in $CleanDirs) { try { Remove-FtpTree -RemoteDir $dir } catch {} }
foreach ($file in $CleanFiles) {
    $req = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$file")
    $req.Credentials = $creds
    $req.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $req.UseBinary = $true
    $req.KeepAlive = $false
    try { $r = $req.GetResponse(); $r.Close(); Write-Host "Deleted file $file" } catch {}
}

# Build remote file cache once if not skipping size checks
if (-not $SkipSizeCheck) {
    Build-RemoteFileCache -BaseDir $RemoteRoot
}

Write-Host "Starting FTP upload..." -ForegroundColor Cyan

$uploadedCount = 0
$skippedCount = 0

$files = Get-ChildItem -Path $LocalRoot -Recurse -File -Force |
    Where-Object {
        $rel = Get-RelativePath -Base $LocalRoot -Full $_.FullName
        $ext = $_.Extension.ToLowerInvariant()
        $isExcludedDir = ($ExcludeDirs | Where-Object { $rel -like "$_/*" -or $rel -like "$_\\*" })
        $isExcludedGlob = ($ExcludeGlobs | Where-Object { $_ -and $rel -like $_ })
        -not $isExcludedDir -and -not $isExcludedGlob -and ($AllowedExt -contains $ext)
    }

foreach ($file in $files) {
    $relative = Get-RelativePath -Base $LocalRoot -Full $file.FullName
    $remotePath = ($relative -replace '\\','/')
    $remoteFilePath = "$RemoteRoot/$remotePath" -replace '//','/'
    $remoteDir = ([System.IO.Path]::GetDirectoryName($remoteFilePath) -replace '\\','/')
    if (![string]::IsNullOrWhiteSpace($remoteDir) -and $remoteDir -ne '/') {
        Ensure-FtpDir -RemoteDir $remoteDir
    }
    try {
        $uploaded = Upload-FtpFile -LocalPath $file.FullName -RemotePath $remoteFilePath -Force:$SkipSizeCheck
        if ($uploaded) { $uploadedCount++ } else { $skippedCount++ }
    } catch {
        Write-Host ("Failed {0}: {1}" -f $remoteFilePath, $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host "`nFTP upload complete: $uploadedCount uploaded, $skippedCount skipped" -ForegroundColor Cyan
