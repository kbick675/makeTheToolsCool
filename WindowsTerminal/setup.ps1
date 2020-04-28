#Requires -RunAsAdministrator
## Install Chocolatey
$StartingLocation = Get-Location
Set-Location -Path ~\Downloads
switch (Test-Path -Path "$env:ProgramData\Chocolatey") {
    $true { Write-Output "Chocolatey is already installed." }
    $false { 
        Set-ExecutionPolicy -ExecutionPolicy Bypass
        Invoke-WebRequest -Method Get 'https://chocolatey.org/install.ps1' -OutFile .\install.ps1
        .\install.ps1
    }
    Default {}
}

## Install Packages
$packages = "pwsh", "Microsoft-Windows-Terminal"
foreach ($package in $packages) {
    choco install $package -y
}

## Install Fonts
$fonts = "Cascadia", "CascadiaMono", "CascadiaMonoPL"
switch (Test-Path -Path "$($ENV:LOCALAPPDATA)\Microsoft\Windows\Fonts") {
    $true { }
    $false { 
        New-Item -ItemType Directory -Path "$($ENV:LOCALAPPDATA)\Microsoft\Windows\Fonts"
    }
    Default {}
}
foreach ($font in $fonts) {
    switch (Test-Path -Path "$($ENV:LOCALAPPDATA)\Microsoft\Windows\Fonts\($font).ttf") {
        $true { Write-Output "$($font) is already installed." }
        $false { 
            Write-Output "Downloading: $($font)"
            Invoke-WebRequest -Method Get "https://github.com/microsoft/cascadia-code/releases/download/v1911.21/$($font).ttf" -OutFile ".\$($font).ttf"
            Write-Output "Copying $($font) to user fonts directory."
            Copy-Item -Path ".\$($font).ttf" -Destination "$($ENV:LOCALAPPDATA)\Microsoft\Windows\Fonts\($font).ttf"
        }
        Default {}
    }
}

## Install Modules
switch ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq "Trusted") {
    $true { }
    $false { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }
    Default {}
}
switch ($PSVersionTable.PSVersion.Major) {
    7 { 
        Install-Module posh-git -Scope CurrentUser
        Install-Module oh-my-posh -Scope CurrentUser
    }
    5 { 
        Install-Module posh-git
        Install-Module oh-my-posh
    }
    Default {}
}

## Modify Windows Terminal settings.json
switch (Test-Path -Path "$($env:LocalAppData)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") {
    $true {
        $settingsJsonPath = "$($env:LocalAppData)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $settingsJson = Get-Content $settingsJsonPath -Raw | ConvertFrom-Json
        switch ($null -ne $settingsJson.schemes) {
            $true {
                $schemeName = 'Monokai Vivid'
                switch ($null -eq $settingsJson.schemes.($schemeName)) {
                    $true { 
                        Import-Module .\scripts\wt.psm1
                        $newScheme = Get-WtScheme -Theme $schemeName
                        $settingsJson.schemes += $newScheme
                    }
                    $false {
                        Write-Output "$($schemeName) color scheme already installed."
                    }
                    Default {}
                }
            }
        }
        switch ($null -ne $settingsJson.profiles) {
            $true { 
                switch ($null -ne $settingsJson.profiles.defaults) {
                    $true { 
                        switch ($null -ne $settingsJson.profiles.defaults.colorScheme) {
                            $false { 
                                Write-Output "Setting Windows Terminal font size to $($schemeName)"
                                $settingsJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name 'colorScheme' -Value $schemeName }
                            $true { Write-Output "Windows Terminal default Color Scheme is already set." }
                            Default {}
                        }
                        switch ($null -ne $settingsJson.profiles.defaults.fontFace) {
                            $false { 
                                $fontFace = 'Cascadia Mono PL'
                                Write-Output "Setting Windows Terminal font size to $($fontFace)"
                                $settingsJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name 'fontFace' -Value $fontFace }
                            $true { Write-Output "Windows Terminal default font is already set." }
                            Default {}
                        }
                        switch ($null -ne $settingsJson.profiles.defaults.fontSize) {
                            $false { 
                                $fontSize = 14
                                Write-Output "Setting Windows Terminal font size to $($fontSize)"
                                $settingsJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name 'fontSize' -Value $fontSize }
                            $true { Write-Output "Windows Terminal default font size is already set." }
                            Default {}
                        }
                        switch ($null -ne $settingsJson.profiles.defaults.cursorShape) {
                            $false { 
                                $cursorShape = 'bar'
                                Write-Output "Setting Windows Terminal font size to $($cursorShape)"
                                $settingsJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name 'cursorShape' -Value $cursorShape }
                            $true { Write-Output "Windows Terminal default cursor shape is already set." }
                            Default {}
                        }
                    }
                    $false {
                        Write-Output "Delete the current Windows Terminal settings.json file and relaunch to rebuild it."
                        Write-Output "Current filepath is $($settingsJsonPath)"
                    }
                    Default {}
                }
            }
            $false { 
                Write-Output "Delete the current Windows Terminal settings.json file and relaunch to rebuild it."
                Write-Output "Current filepath is $($settingsJsonPath)"
            }
            Default {}
        }
        ConvertTo-Json -Depth 32 -InputObject $settingsJson | Set-Content $settingsJsonPath
    }
    $false {
        Write-Output "Windows Terminal settings.json file is missing."
        Write-Output "It should be at: $($env:LocalAppData)\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
        Write-Output "Starting Windows Terminal should fix this."
    }
    Default {}
}

# Finish
Set-Location $StartingLocation