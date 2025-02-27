# Set-PSDebug -Trace 1

# Find visual studio
if(Get-Command vswhere -ErrorAction SilentlyContinue) {
	$installationPath = vswhere.exe -latest -property installationPath
}

if (Test-Path($installationPath)) {
	Import-Module "$installationPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

#if(-not (Get-InstalledModule Terminal-Icons -ErrorAction SilentlyContinue)) {
#	Install-Module Terminal-Icons -Scope CurrentUser -Force
#}
#Import-Module Terminal-Icons

if(-not (Get-InstalledModule Get-ChildItemColor -ErrorAction SilentlyContinue)) {
	Install-Module Get-ChildItemColor -Scope CurrentUser -Force
}
Import-Module Get-ChildItemColor

#if(-not (Get-InstalledModule Invoke-Process -ErrorAction SilentlyContinue)) {
#	Install-Module Invoke-Process -Scope CurrentUser -Force
#}
#Import-Module Invoke-Process

function CreatePath-IfNotExists($pathName) {
    if(!(Test-Path -Path $pathName)) {
        New-Item -ItemType directory -Path $pathName
    }
}

function Compress-Subfolders
{
    param
    (
        [Parameter(Mandatory = $true)][string] $InputFolder,
        [Parameter(Mandatory = $true)][string] $OutputFolder
    )

    $subfolders = Get-ChildItem $InputFolder | Where-Object { $_.PSIsContainer }

	CreatePath-IfNotExists($outputfolder)

    ForEach ($s in $subfolders) 
    {
        $path = $s
        $path
        Set-Location $path.FullName
        $fullpath = $path.FullName
        $pathName = $path.BaseName

        #Get all items 
        $items = Get-ChildItem

        $zipname = $path.name + ".zip"
        $zippath = $outputfolder + $zipname
        Compress-Archive -Path $items -DestinationPath $zippath
    }
    
    Set-Location $outputfolder
}

Function  Get-ADGroups { 
	whoami /groups /fo list | select-string 'acl', 'rol' | select-string 'domain' -raw |sort 
}

Function  Run-Mail {
	& maildev -w 19080 -s 19025 --ip localhost -v -o
}

Function  Run-DotnetRestore {
	& dotnet restore --no-cache
}

Function  Run-DotnetBuild {
	& dotnet build --no-incremental
}

Function  Run-DotnetMigrate {
	& dotnet run migrate
}

Function  Run-DotNetApp([string]$extraParams) {
	if($extraParams -notmatch '\S') {
		& dotnet run
	}
	else {
		& dotnet run $extraParams
	}
}

Function Update-OhMyPosh {
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
	Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
}

Function Edit-PsProfile {
	Start-Process notepad $PROFILE
}

Set-Alias ep Edit-PsProfile

Set-Alias uomp Update-OhMyPosh
Set-Alias d Open-Dev

Set-Alias dnr Run-DotnetRestore
Set-Alias dnb Run-DotnetBuild
Set-Alias dnm Run-DotnetMigrate

Set-Alias groups Get-ADGroups

Set-PSReadLineOption -PredictionSource None

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
	dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
	  [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

if(-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
	Update-OhMyPosh
}

$userPoshTheme = "$env:OneDrive\Documents\PowerShell\$env:USERNAME.omp.jsonc"
$corpPoshTheme = "$env:OneDriveCommercial\Documents\PowerShell\$env:USERNAME.omp.jsonc"
$fallbackPoshTheme = "$env:POSH_THEMES_PATH\quick-term.omp.json"

if (Test-Path($userPoshTheme)) 
{
	oh-my-posh init pwsh --config $userPoshTheme | Invoke-Expression
}
elseif (Test-Path($corpPoshTheme)) 
{
	oh-my-posh init pwsh --config $corpPoshTheme | Invoke-Expression
} 
elseif (Test-Path($fallbackPoshTheme)) 
{
	oh-my-posh init pwsh --config $fallbackPoshTheme | Invoke-Expression
}
else
{
	oh-my-posh init pwsh | Invoke-Expression
}

if (Test-Path($installationPath)) {
	Enter-VsDevShell -VsInstallPath $installationPath -SkipAutomaticLocation -StartInPath ($pwd).path
}

# Set-PSDebug -Trace 0
