Param
(
    [Parameter(Mandatory=$False)]
    $codeBaseDir = 'C:\Development',
    [Parameter(Mandatory=$False)]
    $fileShareDir = '',
    [Parameter(Mandatory=$False)]
    $chocoServer = '',
    [Parameter(Mandatory=$False)]
    $nodeServer = '',
    [Parameter(Mandatory=$False)]
    $borisNugetServer = '',
    [Parameter(Mandatory=$False)]
    $borisNpmServer = '',
    [Parameter(Mandatory=$False)]
    $nugetServer = '',
    [Parameter(Mandatory=$False)]
    $substDrive = 'Z:',
    [Parameter(Mandatory=$False)]
    $shareDrive = 'Y:'
)

Set-ExecutionPolicy unrestricted

#
# Developers, Developers, Developers
#
[Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "development", "Machine")

#
# Function to create a path if it does not exist
#
function CreatePathIfNotExists($pathName) {
    if(!(Test-Path -Path $pathName)) {
        New-Item -ItemType directory -Path $pathName
    }
}

#
# Function to create registry value if it does not exist
#
function CreateRegistryKeyIfNotExists($regPath,$regKey) {
    try {
        Get-ItemProperty -Path $regPath | Select-Object -ExpandProperty $regKey -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        New-Item $regPath -Force | New-ItemProperty -Name $regKey -Value "subst $substDrive $codeBaseDir" -Force | Out-Null
        return $false
    }
}

#
# Function to reload the system and user path
#
function ReloadPath
{
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
        + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

#
# Install Chocolatey
#
$env:chocolateyVersion = '0.9.10.3' # current version is 0.10 requires checksums
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path += ";$env:ProgramData\chocolatey\bin"

& choco source disable -n=chocolatey
& choco source add -n=ProGet -s $chocoServer
& choco pin add -n=chocolatey # lock to old version


#
# Windows features
#
#cinst Microsoft-Hyper-V-All -source windowsFeatures
#cinst IIS-WebServerRole -source windowsfeatures
#cinst IIS-HttpCompressionDynamic -source windowsfeatures
#cinst IIS-ManagementScriptingTools -source windowsfeatures
#cinst IIS-WindowsAuthentication -source windowsfeatures
#cinst DotNet3.5 # Not automatically installed

& choco install -y powershell
& choco install -y ie11

RefreshEnv

#
# General tools install (latest versions)
#

& choco install -y 7zip
& choco install -y putty
& choco install -y sysinternals
& choco install -y hashtab
& choco install -y notepad2
& choco install -y rapidee -version 9.0.930 # later version fails to install?
& choco install -y paint.net
& choco install -y cpu-z
& choco install -y adobereader
& choco install -y googlechrome
& choco install -y pscx
& choco install -y carbon
& choco install -y rdcman
& choco install -y heidisql
& choco install -y citrix-receiver -ia "/includeSSON"
& choco install -y urlrewrite
& choco install -y nimbletext

& choco pin add -n=googlechrome # chrome auto updates

& choco install -y vcredist2005
& choco install -y vcredist2008
& choco install -y vcredist2010
& choco install -y vcredist2012
& choco install -y vcredist2013
& choco install -y vcredist2015
& choco install -y vcredist2017

& choco install -y dotnet3.5 # required for SQL Server
& choco install -y netfx-4.5.1-devpack
& choco install -y netfx-4.5.2-devpack
& choco install -y netfx-4.6.1-devpack
& choco install -y netfx-4.6.2-devpack

& choco install -y windows-sdk-7.1
& choco install -y windows-sdk-8.1
& choco install -y windows-sdk-10.1

#
# Optional general tools
#
# & choco install -y itunes
# & choco install -y freecommander-xe -version 2015.685 # later version fails to install?
# & choco install -y mpc-hc
# & choco install -y vlc
# & choco install -y wincdemu # not required windows 10
# & choco install -y virtualclonedrive
# & choco install -y lastpass
& choco install -y keepass
& choco install -y keepass-plugin-keepasshttp
& choco install -y keepass-plugin-keeagent
& choco install -y keepass-plugin-favicon
& choco install -y keepass-plugin-rdp
& choco install -y keepass-plugin-mskeyimporter
& choco install -y greenshot
# & choco install -y snagit

#
# Developer tools install (fixed versions)
#
& choco install -y cmdermini                  --version 1.3.2

& choco install -my dotnetcore-runtime        --version 1.0.1
& choco install -my dotnetcore-runtime        --version 1.1.2
& choco install -my dotnetcore-windowshosting --version 1.0.1
& choco install -my dotnetcore-windowshosting --version 1.1.2
& choco install -y dotnetcore-sdk             --version 2.0.0
& choco install -y jre8                       --version 8.0.144 # already defaults to both 32 and 64 bit
& choco install -y jdk8                       --version 8.0.144 -params "both=true"
& choco install -y erlang                     --version 18.3
                                             
& choco install -my python                    --version 3.6.1
& choco install -my python                    --version 2.7.11
& choco install -y nodejs-lts                 --version 6.11.5
& choco install -y phantomjs 				  --version 1.9.8
                                             
& choco install -y git                        --version 2.14.0
& choco install -y poshgit                    --version 0.7.1
                                             
& choco install -y nuget.commandline          --version 4.3.0
& choco install -y msbuild-sonarqube-runner   --version 3.0.2
& choco install -y sonarcube-scanner		  --version 3.0.3.778
                                             
& choco install -y rabbitmq                   --version 3.6.10
                                             
& choco install -y notepadplusplus            --version 7.5 --x86 # 64bit does not support plugins
& choco install -y winmerge                   --version 2.14.0
& choco install -y fiddler4                   --version 4.6.2.3
& choco install -y linqpad                    --version 5.22.02
& choco install -y docker                     --version 17.06.0
& choco install -y docker-for-windows         --version 17.06.2.13194

& choco install -y visualstudiocode           -params '/nodesktopicon'
& choco install -y vscode-csharp
& choco install -y vscode-powershell
& choco install -y vscode-cake
& choco install -y vscode-eslint
& choco install -y vscode-tslint
& choco install -y vscode-mssql
& choco install -y vscode-docker
& choco install -y vscode-editorconfig
& choco install -y vscode-markdownlint

& choco pin add -n=visualstudiocode 				# vs code auto updates

#
# Optional Developer tools
#
# & choco install -y yeoman             --version 1.1.2
& choco install -y gitextensions        --version 2.50
# & choco install -y tortoisegit        --version 2.3.0.0
# & choco install -y sourcetree 		--version 1.9.6.0
# & choco install -y gitkraken 		    --version 2.4.0
& choco install -y dotpeek.portable     --version 10.0.2.0
# & choco install -y resharper          --version 10.0.2.0



RefreshEnv
ReloadPath

#
# Git Configuration
#
$adUser = [adsisearcher]"(samaccountname=$env:USERNAME)"
& git config --global user.name $adUser.FindOne().Properties.name
& git config --global user.email $adUser.FindOne().Properties.mail
& git config --global core.editor "notepad.exe"

#
# NuGet Configuration
#
& nuget update -self
& nuget sources add -Name BORIS -Source $borisNugetServer
& nuget sources add -Name CACHE -Source $nugetServer
& nuget sources disable -Name 'nuget.org'

#
# Node.JS Configuration
#
& npm config set registry $nodeServer -g
& npm config set prefix $env:ProgramData\nodejs -g
& npm config set @BORIS:registry $borisNpmServer

& npm install npm@5.3.0 -g
& npm install bower@1.8.0 -g
& npm install gulp@3.9.1 -g
& npm install grunt@1.0.1 -g
& npm install typescript@2.5.2 -g
& npm install jspm@0.16.48 -g
& npm install eslint@3.13.1 -g
& npm install jslint@0.10.3 -g
& npm install tslint@3.15.1 -g
& npm install webpack@1.14.0 -g
& npm install rimraf@2.5.4 -g
& npm install tfx-cli@0.3.45 -g
& npm install yo@1.8.5 -g
& npm install node-gyp@3.6.1 -g

#
# VS Code Configuration
#
$env:Path += ";$env:ProgramFiles(x86)\Microsoft VS Code\bin"

& code --install-extension msjsdiag.debugger-for-chrome
& code --install-extension msjsdiag.debugger-for-edge

# & code --install-extension ajhyndman.jslint
# & code --install-extension alefragnani.Bookmarks
# & code --install-extension dbaeumer.vscode-eslint
# & code --install-extension donjayamanne.githistory
# & code --install-extension DotJoshJohnson.xml
# & code --install-extension eg2.tslint
# & code --install-extension hbenl.vscode-firefox-debug
# & code --install-extension johnpapa.Angular2
# & code --install-extension mohsen1.prettify-json
# & code --install-extension PeterJausovec.vscode-docker
# & code --install-extension waderyan.gitblame


#
# Create the working directory structure
#
CreatePathIfNotExists -pathName "$codeBaseDir"
CreateRegistryKeyIfNotExists -regPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -regKey "DevSubst"

If (!(Test-Path I:))
{
    new-psdrive -name I -PsProvider FileSystem -root $fileShareDir -persist
}

RefreshEnv