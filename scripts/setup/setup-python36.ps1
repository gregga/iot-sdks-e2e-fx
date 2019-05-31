#!/usr/bin/env powershell
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.
#

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
        $PyVerCmd = & xpython3 -V 2>&1
        $PyParts = $PyVerCmd.split(' ')
        return CheckVerString($PyParts[1])
    }
    catch {
        try {
            $PyVerCmd = & xpython -V 2>&1
            $PyParts = $PyVerCmd.split(' ')
            return CheckVerString($PyParts[1])
        }
        catch {
            Write-Host "Continuing" -ForegroundColor Yellow
        }
    }
    
    $PyPath = Which("python*")
    $pyVerFound = $false
    if ($PyPath) {
        foreach($PyFile in $PyPath)
        {
            try {
                $PyVer = (Get-Item $PyFile).VersionInfo
                $pyFound =  CheckVerString($PyVer.FileVersion)
                if($pyFound)
                {
                    Write-Host $PyFile -ForegroundColor Green
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
    Write-Host "Looking for $cmd in path..." -ForegroundColor Yellow
    $path = (Get-Command $cmd).Path
    if($path){
        #foreach($p in $path) {
        #    Write-Host "Found $cmd in $p" -ForegroundColor Green
        #}
    }
    else {
        Write-Host "Command $cmd NOT FOUND in path" -ForegroundColor Red
    }
    return $path
}

function IsWin32 {
    $IsW32 = $false
    try {
        if ([System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            $IsW32 = $true
        }
    }
    catch {
        $IsW32 =  $false
    }
    return $IsW32
}

#### Script Starts Here ####

$PythonMinVersionMajor = 3
$PythonMinVersionMinor = 5

Write-Host "POWERSHELL SCRIPT in Setup-Python36" -ForegroundColor Red -BackgroundColor Yellow
$foundPy = SearchForPythonVersion($PythonMinVersionMajor, $PythonMinVersionMinor)

if(!$foundPy)
{
    Write-Host "Python version not found" -ForegroundColor Red
    if (IsWin32) {
        Write-Host "Please install python 3.6 on Windows." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "Installing python 3.6..." -ForegroundColor Green
    }
}

Write-Host "Looking for Pip3" -ForegroundColor Yellow
$Pip3Path = Which("pip3*")
if($Pip3Path)
{
    foreach($pip in $Pip3Path)
    {
        Write-Host $pip -ForegroundColor Yellow
    }

}

Write-Host "setup-python 3.6 SUCCESS" -ForegroundColor Green
