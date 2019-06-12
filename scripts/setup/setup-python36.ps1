#!/usr/bin/env powershell
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.
#

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
$root_dir = Join-Path -Path $path -ChildPath '../..' -Resolve
$scripts = Join-Path -Path $root_dir -ChildPath 'scripts' -Resolve
. $scripts/pwsh-helpers.ps1
$isWin32 = IsWin32

function CheckVerString([string] $pyVerStr) {

    $PyVer = $pyVerStr.Split('.')
    $PvMaj = [int]$PyVer[0]
    $PvMin = [int]$PyVer[1]

    if($PvMaj -gt $PythonMinVersionMajor)
    {
        Write-Host "Found Python Version: " $pyVerStr -ForegroundColor Green
        return $true
    }
    if($PvMaj -eq $PythonMinVersionMajor)
    {
        if($PvMin -ge $PythonMinVersionMinor)
        {
            Write-Host "Found Python Version: " $pyVerStr -ForegroundColor Green
            return $true
        }
    }
    return $false
}

function SearchForPythonVersion()
{
    Write-Host "Checking for python version (minimum): $PythonMinVersionMajor.$PythonMinVersionMinor" -ForegroundColor Yellow

    try {
        $PyVerCmd = & python3 -V 2>&1
        $PyParts = $PyVerCmd.split(' ')
        return CheckVerString($PyParts[1])
    }
    catch {
        try {
            $PyVerCmd = & python -V 2>&1
            $PyParts = $PyVerCmd.split(' ')
            return CheckVerString($PyParts[1])
        }
        catch {
            Write-Host "Continuing" -ForegroundColor Yellow
        }
    }
    
    $PyPath = Which("python")
    $pyVerFound = $false
    if ($PyPath) {
        foreach($PyFile in $PyPath)
        {
            try {
                $PyVer = (Get-Item $PyFile).VersionInfo
                $pyFound =  CheckVerString($PyVer.FileVersion)
                if($pyFound)
                {
                    Write-Host "Found: $PyFile" -ForegroundColor Green
                    $pyVerFound = $true
                }
            }
            catch {
                Write-Host "Continuing." -ForegroundColor Yellow
            }
        }
    }
    return $pyVerFound
}

function which([string]$cmd) {
    if($isWin32) {
        $cmd += '.exe'
    }
    Write-Host "Looking for $cmd in path..." -ForegroundColor Yellow
    try{
        $path = (Get-Command $cmd).Path
    }
    catch{
        $path = $null
    }
    if($null -eq $path){
        Write-Host "Command $cmd NOT FOUND in path" -ForegroundColor Red
    }
    return $path
}

###############################################################
#### Script Starts Here ####

$PythonMinVersionMajor = 3
$PythonMinVersionMinor = 6

$foundPy = SearchForPythonVersion($PythonMinVersionMajor, $PythonMinVersionMinor)
$update_py = $true

if($update_py) {
    if($foundPy -eq $false)
    {
        Write-Host "Python version not found" -ForegroundColor Red
        if ($isWin32) {
            Write-Host "Please install python 3.6 on Windows." -ForegroundColor Red
            #exit 1
        }
        else {
                Write-Host "Installing python 3.6..." -ForegroundColor Yellow
                sudo -H -E add-apt-repository ppa:deadsnakes/ppa        
                sudo -H -E apt update
                sudo -H -E apt install python3.6
        }
        if($LASTEXITCODE -eq 0)
        {
            Write-Host "python3.6 installed successfully" -ForegroundColor Green
        } 
        else 
        {
            Write-Host "python install failed"  -ForegroundColor Red
            #exit 1
        }
    }

    if($isWin32 -eq $true) {
        Write-Host "python3.6 installed successfully" -ForegroundColor Green
    } 
    else {
        sudo -H -E update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
        sudo -H -E update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2
        sudo -H -E update-alternatives --set python3 /usr/bin/python3.6
    }
}
#$gotPip3 = $false
$Pip3Path = Which("pip3")
if($null -ne $Pip3Path -and $Pip3Path.Length -lt 1)
{
    Write-Host "Pip3 not found" -ForegroundColor Red
    Write-Host "Installing pip3..." -ForegroundColor Yellow
    $py = PyCmd "-m ensurepip"; Invoke-Expression  $py
    $py = PyCmd "-m pip install --upgrade pip"; Invoke-Expression  $py

    if($isWin32 -eq $false) {
        sudo -H -E apt-get install pip
    }
    if($LASTEXITCODE -eq 0)
    {
        Write-Host "pip3 installed successfully" -ForegroundColor Green
        #$gotPip3 = $true
    } 
    else 
    {
        Write-Host "pip3 install failed"  -ForegroundColor Red
        #exit 1
    }
}

#if($gotPip3) {
#    Write-Host "Updating pip" -ForegroundColor Yellow
#    if(IsWin32) {
#        python -m pip install --upgrade pip
#    }
#    else {
#        sudo -H -E python3 -m pip install --upgrade pip
#    }
#    if($LASTEXITCODE -eq 0)
#    {
#        Write-Host "pip updated successfully" -ForegroundColor Green
#    } 
#    else 
#    {
#       Write-Host "pip update failed"  -ForegroundColor Red
        #exit 1
#    }
#}

#ls /usr/bin/python*

Write-Host "Installing python libraries" -ForegroundColor Yellow
set-location "$root_dir/ci-wrappers/pythonpreview/wrapper"

$py = PyCmd "-m pip install setuptools"; Invoke-Expression  $py
$py = PyCmd "-m pip install -e python_glue"; Invoke-Expression  $py
$py = PyCmd "-m pip install ruamel"; Invoke-Expression  $py
if($LASTEXITCODE -eq 0)
{
    Write-Host "python libraries installed successfully" -ForegroundColor Green
} 
else 
{
    Write-Host "python libraries install failed"  -ForegroundColor Red
    #exit 1
}

$py = PyCmd "-m pip install docker"; Invoke-Expression  $py
$py = PyCmd "-m pip install colorama"; Invoke-Expression  $py

Write-Host "Installing horton_helpers" -ForegroundColor Yellow
set-location $root_dir
$py = PyCmd "-m pip install -e $root_dir/horton_helpers"; Invoke-Expression  $py
if($LASTEXITCODE -eq 0)
{
    Write-Host "horton_helpers installed successfully" -ForegroundColor Green
} 
else 
{
    Write-Host "horton_helpers install failed"  -ForegroundColor Red
    #exit 1
}

Write-Host "Installing requirements for Horton test runner" -ForegroundColor Yellow
set-location $root_dir/test-runner
$py = PyCmd "-m pip install -r requirements.txt"; Invoke-Expression  $py
if($LASTEXITCODE -eq 0)
{
    Write-Host "Horton test runner installed successfully" -ForegroundColor Green
} 
else 
{
    Write-Host "Horton test runner install failed"  -ForegroundColor Red
    #exit 1
}

Write-Host "Python3 and Python libraries installed successfully" -ForegroundColor Green
