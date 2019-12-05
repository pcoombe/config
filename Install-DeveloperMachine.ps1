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
    $localNugetServer = '',
    [Parameter(Mandatory=$False)]
    $localNpmServer = '',
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

& choco install -y rsat -params "/AD"
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
& choco install -y microsoft-edge-insider
& choco install -y firefox
& choco install -y pscx
& choco install -y carbon
& choco install -y rdcman
& choco install -y heidisql
& choco install -y citrix-receiver -ia "/includeSSON"
& choco install -y urlrewrite
& choco install -y nimbletext
& choco install -y vswhere

& choco pin add -n=googlechrome # chrome auto updates
& choco pin add -n=microsoft-edge-insider # chrome auto updates

& choco install -y vcredist-all

& choco install -y dotnet3.5 # required for SQL Server
& choco install -y netfx-4.5.1-devpack
& choco install -y netfx-4.5.2-devpack
& choco install -y netfx-4.6.1-devpack
& choco install -y netfx-4.6.2-devpack
& choco install -y netfx-4.7.1-devpack
& choco install -y netfx-4.7.2-devpack

& choco install -y windows-sdk-7.1
& choco install -y windows-sdk-8.1
& choco install -y windows-sdk-10.1

#
# Optional general tools
#
# & choco install -y itunes
# & choco install -y icloud
# & choco install -y freecommander-xe -version 2015.685 # later version fails to install?
# & choco install -y mpc-hc
# & choco install -y vlc
# & choco install -y wincdemu # not required windows 10
# & choco install -y virtualclonedrive
# & choco install -y lastpass
& choco install -y keepass
# & choco install -y keepass-plugin-keepasshttp
# & choco install -y keepass-plugin-keeagent
# & choco install -y keepass-plugin-favicon
# & choco install -y keepass-plugin-rdp
# & choco install -y keepass-plugin-mskeyimporter
& choco install -y greenshot
# & choco install -y snagit

#
# Developer tools install (fixed versions)
#
& choco install -y cmdermini                            --version 1.3.12

& choco install -my dotnetcore-runtime                  --version 1.0.1
& choco install -my dotnetcore-runtime                  --version 1.1.2
& choco install -my dotnetcore-runtime                  --version 2.0.7
& choco install -my dotnetcore-runtime                  --version 2.1.14
& choco install -my dotnetcore-runtime                  --version 2.2.7
& choco install -my dotnetcore-runtime                  --version 3.0.1
& choco install -my dotnetcore-windowshosting           --version 1.0.1
& choco install -my dotnetcore-windowshosting           --version 1.1.2
& choco install -my dotnetcore-windowshosting           --version 2.0.7
& choco install -my dotnetcore-windowshosting           --version 2.1.14
& choco install -my dotnetcore-windowshosting           --version 2.2.7
& choco install -my dotnetcore-windowshosting           --version 3.0.1
& choco install -y dotnetcore-sdk                       --version 2.1.400

& choco install -y adoptopenjdk8jre                     --version 8.222
& choco install -y adoptopenjdk8                        --version 8.222
& choco install -y erlang                               --version 22.0

& choco install -y python3                    			--version 3.7.5 	--params '/InstallDir:C:\tools\python3'
& choco install -y python2                    			--version 2.7.15 	--params '/InstallDir:C:\tools\python2'
& choco install -y nodejs-lts                           --version 10.16.0
& choco install -y phantomjs 				            --version 1.9.8
                                             
& choco install -y git                                  --version 2.22.0 	--params '/GitAndUnixToolsOnPath /SChannel'
& choco install -y poshgit                              --version 0.7.3
& choco install -y gitversion.portable                  --version 5.0.0

& choco install -y nuget.commandline                    --version 5.3.0
& choco install -y sonarscanner-msbuild-net46           --version 4.8.0.12008
& choco install -y sonarscanner-msbuild-netcoreapp2.0   --version 4.8.0.12008
& choco install -y sonarscanner-msbuild-netcoreapp30    --version 4.8.0.12008
& choco install -y sonarqube-scanner.portable			--version 4.2.0.1873

& choco install -y seq                             		--version 5.1.3200
& choco install -y rabbitmq                             --version 3.7.20 /ia /RABBITMQBASE:C:\ProgramData\RabbitMQ

& choco install -y azure-cli                            --version 2.0.75
& choco install -y azurepowershell                      --version 6.9.0
& choco install -y servicebusexplorer                   --version 4.1.112
& choco install -y microsoftazurestorageexplorer        --version 1.11.0
& choco install -y azure-functions-core-tools           --version 1.0.15
                                             
& choco install -y notepadplusplus                      --version 7.8 --x86 # 64bit does not support plugins
& choco install -y winmerge                             --version 2.16.4
& choco install -y notepadplusplus                      --version 7.5 --x86 # 64bit does not support plugins
& choco install -y winmerge                             --version 2.14.0
& choco install -y fiddler4                             --version 4.6.2.3
& choco install -y linqpad                              --version 5.40.0
& choco install -y scriptcs                             --version 0.17.1
& choco install -y postman                              --version 7.10.0
& choco install -y papercut                             --version 5.1.44
& choco install -y docker-cli                           --version 19.03.3
& choco install -y docker-desktop                   	--version 2.1.0.5
& choco install -y ilspy			                  	--version 5.0.2

& choco install -y vscode           					--params '/NoDesktopIcon'
& choco install -y vscode-csharp
& choco install -y vscode-powershell
& choco install -y vscode-cake
& choco install -y vscode-eslint
& choco install -y vscode-tslint
& choco install -y vscode-mssql
& choco install -y vscode-docker
& choco install -y vscode-editorconfig
& choco install -y vscode-markdownlint

# & choco install -y ssdt15 14.0.61709.290
& choco install -y ssdt17 14.0.16194.0

& choco pin add -n=visualstudiocode 				# vs code auto updates

#
# Optional Developer tools
#
# & choco install -y yeoman             --version 1.1.2
& choco install -y gitextensions        --version 3.2.1
# & choco install -y tortoisegit        --version 2.5.0.0
# & choco install -y sourcetree 		--version 1.10.23.1
# & choco install -y gitkraken 		    --version 3.3.3
# & choco install -y dotpeek.portable   --version 10.0.2.0
& choco install -y resharper-platform



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
& nuget sources add -Name LOCAL -Source $localNugetServer
& nuget sources add -Name CACHE -Source $nugetServer
& nuget sources add -Name TEST -Source D:\Nuget
& nuget sources disable -Name 'nuget.org'

#
# Node.JS Configuration
#
& npm config set registry $nodeServer -g
& npm config set prefix $env:ProgramData\nodejs -g
& npm config set @LOCAL:registry $localNpmServer
& npm install @angular/cli@8.2.2 -g
& npm install azure-functions-core-tools@1.0.15 -g
& npm install eslint@6.3.0 -g
& npm install gulp@3.9.1 -g
& npm install http-server@0.11.1 -g
& npm install maildev@0.14.0 -g
& npm install newman-reporter-html@1.0.3
& npm install newman@4.5.4 -g
& npm install node-gyp@3.6.1 -g
& npm install npm-windows-upgrade@6.0.0 -g
& npm install openssl@1.1.0 -g
& npm install pnpm@4.3.3 -g
& npm install rimraf@3.0.0 -g
& npm install tslint@5.19.0 -g
& npm install yarn@1.21.0 -g

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