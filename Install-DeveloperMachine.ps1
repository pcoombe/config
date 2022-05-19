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
[Environment]::SetEnvironmentVariable("AZURE_CLI_DISABLE_CONNECTION_VERIFICATION", "1", "Machine")
[Environment]::SetEnvironmentVariable("NODE_TLS_REJECT_UNAUTHORIZED", "0", "Machine")
[Environment]::SetEnvironmentVariable("HOMEDRIVE", "C:", "Process")

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
$env:chocolateyVersion = '0.10.15'
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path += ";" + $env:ProgramData + "\chocolatey\bin"

#& choco source disable -n=chocolatey
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
& choco install -y powershell-core
#& choco install -y ie11

RefreshEnv

#
# General tools install (latest versions)
#

& choco install -y rsat -params "/AD"
& choco install -y 7zip
& choco install -y putty
& choco install -y winscp
& choco install -y sysinternals
& choco install -y powertoys
& choco install -y hashtab
# & choco install -y notepad2
& choco install -y notepad3
& choco install -y rapidee
& choco install -y paint.net
& choco install -y cpu-z
& choco install -y hwinfo
& choco install -y adobereader
& choco install -y googlechrome
& choco install -y microsoft-edge
& choco install -y firefox
# & choco install -y pscx		# removed to use install-module
# & choco install -y carbon 	# removed to use install-module
# & choco install -y rcdman 	# replaced with mremoteng
& choco install -y mremoteng
& choco install -y heidisql
& choco install -y citrix-receiver -ia "/includeSSON"		# should be part of SOE image
& choco install -y urlrewrite
& choco install -y nimbletext
& choco install -y vswhere

& choco pin add -n=googlechrome # chrome auto updates
& choco pin add -n=microsoft-edge # chrome auto updates

& choco install -y vcredist-all

& choco install -y openssl

& choco install -y dotnet3.5 # required for SQL Server
& choco install -y netfx-4.5.1-devpack
& choco install -y netfx-4.5.2-devpack
& choco install -y netfx-4.6.1-devpack
& choco install -y netfx-4.6.2-devpack
& choco install -y netfx-4.7.1-devpack
& choco install -y netfx-4.7.2-devpack

# & choco install -y windows-sdk-7.1
# & choco install -y windows-sdk-8.1
& choco install -y windows-sdk-10.1

#
# Optional general tools
#
& choco install -y itunes
& choco install -y icloud
& choco install -y freecommander-xe.install
# & choco install -y mpc-hc # replaced with below due to being out of date
& choco install -y mpc-hc-clsid2
# & choco install -y vlc
# & choco install -y wincdemu # not required windows 10
# & choco install -y virtualclonedrive
& choco install -y bitwarden
& choco install -y googlechrome-authy
# & choco install -y lastpass
# & choco install -y keepass
# & choco install -y keepass-plugin-keepasshttp
# & choco install -y keepass-plugin-keeagent
# & choco install -y keepass-plugin-favicon
# & choco install -y keepass-plugin-rdp
# & choco install -y keepass-plugin-mskeyimporter
# & choco install -y greenshot
# & choco install -y snagit
& choco install -y sharex

#
# Developer tools install (fixed versions)
#
& choco install -y cmdermini                            --version=1.3.15

& choco install -my dotnetcore-runtime                  --version=1.0.15
& choco install -my dotnetcore-runtime                  --version=1.1.12
& choco install -my dotnetcore-runtime                  --version=2.0.7
& choco install -my dotnetcore-runtime                  --version=2.1.30
& choco install -my dotnetcore-runtime                  --version=2.2.7
& choco install -my dotnetcore-runtime                  --version=3.0.3
& choco install -my dotnetcore-runtime                  --version=3.1.25
& choco install -my dotnetcore-windowshosting           --version=1.0.1     --params 'IgnoreMissingIIS'
& choco install -my dotnetcore-windowshosting           --version=1.1.10    --params 'IgnoreMissingIIS'
& choco install -my dotnetcore-windowshosting           --version=2.0.7     --params 'IgnoreMissingIIS'
& choco install -my dotnetcore-windowshosting           --version=2.1.30    --params 'IgnoreMissingIIS'
& choco install -my dotnetcore-windowshosting           --version=2.2.7		--params 'IgnoreMissingIIS'
& choco install -my dotnetcore-windowshosting           --version=3.0.3     --params 'IgnoreMissingIIS'
& choco install -my dotnetcore-windowshosting           --version=3.1.25	--params 'IgnoreMissingIIS'

& choco install -y dotnetcore-2.1-sdk 					--version=2.1.815
& choco install -y dotnetcore-3.1-sdk 					--version=3.1.415

& choco install -y nswagstudio                          --version=13.15.10

& choco install -y temurin8jre                     		--version=8.332.9
& choco install -y temurin8                        		--version=8.332.9
& choco install -y erlang                               --version=23.3

& choco install -y python3                    			--version=3.10.0 	--params '/InstallDir:C:\tools\python3'
& choco install -y python2                    			--version=2.7.15 	--params '/InstallDir:C:\tools\python2'

& choco install -y nvm.portable							--version=1.1.7
& choco install -y nodejs-lts                           --version=14.19.0

& choco install -y phantomjs 				            --version=1.9.8

& choco install -y git                                  --version=2.35.0 	--params '/GitAndUnixToolsOnPath /SChannel'
# & choco install -y poshgit                              --version=0.7.3
& choco install -y gitversion.portable                  --version=5.7.0

& choco install -y nuget.commandline                    --version=5.10.0
& choco install -y sonarscanner-msbuild-net46           --version=4.10.0.19059
& choco install -y sonarscanner-msbuild-netcoreapp2.0   --version=4.10.0.19059
& choco install -y sonarscanner-msbuild-netcoreapp30    --version=4.10.0.19059
& choco install -y sonarqube-scanner.portable			--version=4.3.0.2102

& choco install -y seq                             		--version=2021.2.5495
& choco install -y rabbitmq                             --version=3.8.30 /ia /RABBITMQBASE:C:\ProgramData\RabbitMQ

& choco install -y azure-cli                            --version=2.9.0
#& choco install -y azurepowershell                      --version 6.9.0
& choco install -y servicebusexplorer                   --version=4.1.112
& choco install -y microsoftazurestorageexplorer        --version=1.19.0
& choco install -y cosmosdbexplorer        				--version=0.8.0.0
& choco install -y azure-data-studio					--version=1.28.0
& choco install -y azure-functions-core-tools           --version=1.0.15

& choco install -y notepadplusplus                      --version=8.4 --x86 # 64bit does not support plugins
& choco install -y winmerge                             --version=2.14.0.20170224
# & choco install -y fiddler4                             --version 4.6.2.3
& choco install -y linqpad                              --version=5.40.0
& choco install -y scriptcs                             --version=0.17.1
& choco install -y postman                              --version=9.15.0
& choco install -y papercut                             --version=5.1.44
& choco install -y docker-cli                           --version=19.03.12
& choco install -y docker-desktop                   	--version=3.2.1
& choco install -y ilspy			                  	--version=7.2.1

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
& choco install -y vscode-prettier
& choco install -y vscode-commitizen
& choco install -y vscode-vsliveshare
& choco install -y vscode-chrome-debug
& choco install -y vscode-edge-debug
& choco install -y vscode-firefox-debug

# & choco install -y ssdt15 14.0.61709.290
& choco install -y ssdt17                               --version=14.0.16228.0
& choco install -y sqlpackage 							--version=18.6

& choco pin add -n=vscode 				# vs code auto updates

#
# Optional Developer tools
#
# & choco install -y yeoman             --version=1.1.2
& choco install -y gitextensions        --version=3.5.3
# & choco install -y tortoisegit        --version=2.5.0.0
# & choco install -y sourcetree 		--version=1.10.23.1
# & choco install -y gitkraken 		    --version=3.3.3
# & choco install -y dotpeek.portable   --version=10.0.2.0
& choco install -y resharper-platform



RefreshEnv
ReloadPath

#
# Git Configuration
#
$adUser = [adsisearcher]"(samaccountname=$env:USERNAME)"
& git config --global user.name $adUser.FindOne().Properties.name
& git config --global user.email $adUser.FindOne().Properties.mail

& git config --system core.editor "notepad.exe"
& git config --system core.longpaths true


#
# NuGet Configuration
#
& nuget update -self
& nuget sources add -Name LOCAL -Source $localNugetServer
& nuget sources add -Name CACHE -Source $nugetServer
& nuget sources add -Name TEST -Source D:\Nuget
# & nuget sources disable -Name 'nuget.org'

#
# Node.JS Configuration
#
# & npm config set registry $nodeServer -g
& npm config set prefix $env:ProgramData\nodejs -g
& npm config set cache  $env:ProgramData\npm-cache -g
& npm config set "@LOCAL:registry" $localNpmServer -g

& npm install @angular/cli -g
& npm install azure-functions-core-tools@1.0.15 -g
& npm install eslint -g
& npm install gulp@3.9.1 -g
& npm install http-server -g
& npm install maildev@0.14.0 -g
& npm install newman-reporter-html
& npm install newman
& npm install node-gyp@3.6.1 -g
& npm install npm-windows-upgrade@6.0.0 -g
& npm install openssl
& npm install pnpm
& npm install rimraf
& npm install tslint
& npm install yarn

#
# VS Code Configuration
#
$env:Path += ";" + $env:ProgramFiles + "\Microsoft VS Code\bin"

# & code --install-extension ajhyndman.jslint
# & code --install-extension alefragnani.Bookmarks
# & code --install-extension dbaeumer.vscode-eslint
# & code --install-extension donjayamanne.githistory
# & code --install-extension DotJoshJohnson.xml
# & code --install-extension eg2.tslint

# & code --install-extension johnpapa.Angular2
# & code --install-extension mohsen1.prettify-json
# & code --install-extension PeterJausovec.vscode-docker
# & code --install-extension waderyan.gitblame

Set-PSRepository -name PSGallery -InstallationPolicy Trusted

Install-PackageProvider -Name NuGet -Force

Install-Module PowerShellGet -Force -AllowClobber
Install-Module Pscx -Scope CurrentUser
Install-Module Carbon -AllowClobber -Scope CurrentUser
Install-Module PSSharedGoods -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module posh-git -AllowClobber -Scope CurrentUser
Install-Module Terminal-Icons -Repository PSGallery
Install-Module Get-ChildItemColor -AllowClobber -Scope CurrentUser

if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
      'Az modules installed at the same time is not supported.')
} else {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
}


#
# Create the working directory structure
#
CreatePathIfNotExists -pathName "$codeBaseDir"
CreateRegistryKeyIfNotExists -regPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -regKey "DevSubst"

If (!(Test-Path I:))
{
    new-psdrive -name I -PsProvider FileSystem -root $fileShareDir -persist
}

#
# Setup windows firewall rule to enable external access to any locally hosted APIs
#
New-NetFirewallRule -DisplayName 'Development-Local' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 19000-19999

#
# Allow XML files to dbe downloaded in Edge
#
$regpath="HKLM:\Software\Policies\Microsoft\Edge\ExemptDomainFileTypePairsFromFileTypeDownloadWarnings"

if (!(Test-Path $regpath)) {
    New-Item -Path $regpath -Force
}

New-ItemProperty -Path $regpath -Name "1" -Value '{"domains": ["*"], "file_extension": "xml"}' -PropertyType String -Force

RefreshEnv