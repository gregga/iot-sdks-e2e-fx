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
        exit 0
    }
    if($PvMaj -eq $PythonMinVersionMajor)
    {
        if($PvMin -ge $PythonMinVersionMinor)
        {
            Write-Host "Found Python Version: " $pyVerStr -ForegroundColor Green
            exit 0
        }
    }
}


function SearchForPythonVersion()
{
    Write-Host "Checking for python version (minimum): $PythonMinVersionMajor.$PythonMinVersionMinor" -ForegroundColor Yellow

    try {
        $PyVerCmd = & python -V 2>&1
        $PyParts = $PyVerCmd.split(' ')
        CheckVerString($PyParts[1])
    }
    catch {
        Write-Host "Looking for python in path..." -ForegroundColor Yellow
    }
    
    $PyPath = Which("python*")
    
    if ($PyPath) {
        foreach($PyFile in $PyPath)
        {
            try {
                $PyVer = (Get-Item $PyFile).VersionInfo
                CheckVerString($PyVer, $vMajor, $vMinor)
            }
            catch {
                Write-Host "Looking for python in path..." -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "python not found" -ForegroundColor Red
        exit 1
    }    
}

function Which([string] $cmd) {
    $path = (($Env:Path).Split(";") | Select -uniq | Where { $_.Length } | Where { Test-Path $_ } | Get-ChildItem -filter $cmd).FullName
    return $path
}


$PythonMinVersionMajor = 3
$PythonMinVersionMinor = 5

Write-Host "POWERSHELL SCRIPT in Setup-Python36" -ForegroundColor Red -BackgroundColor Yellow
SearchForPythonVersion($PythonMinVersionMajor, $PythonMinVersionMinor)


