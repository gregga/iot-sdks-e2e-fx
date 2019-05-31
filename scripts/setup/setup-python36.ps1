#!/usr/bin/env powershell
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.
#

Write-Host "POWERSHELL SCRIPT in Setup-Python36" -ForegroundColor Red -BackgroundColor Yellow

function Which([string] $cmd) {
    $path = (($Env:Path).Split(";") | Select -uniq | Where { $_.Length } | Where { Test-Path $_ } | Get-ChildItem -filter $cmd).FullName
    return $path
  }

  



Write-Host "checking for python 3.5+" -ForegroundColor Yellow

$PyPath = Which("python*")

if ($PyPath)
{
    $PyVerCmd = & python -V 2>&1
    $PyParts = $PyVerCmd.split(' ')
    $PyVer = $PyParts[1].split('.')
    $PvMaj = [int]$PyVer[0]
    $PvMin = [int]$PyVer[1]
    $PvBld = [int]$PyVer[2]
    Write-Host $PyVer -ForegroundColor Blue
    foreach($PyFile in $PyPath)
    {
        $PyVer = (Get-Item $PyFile).VersionInfo
        Write-Host $PyFile "::VER::" $PyVer.FileVersion -ForegroundColor Green
    }
}
else {
    Write-Host "python not found" -ForegroundColor Yellow
}








