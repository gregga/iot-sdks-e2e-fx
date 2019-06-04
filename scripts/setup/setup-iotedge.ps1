# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$pyscripts = Join-Path -Path $path -ChildPath '../../pyscripts' -Resolve
$hh = Join-Path -Path $path -ChildPath '../../horton_helpers' -Resolve

function IsWin32 {
    $IsW32 = $false
    try {
        if ([System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        $IsW32 =  $false
    }
    return $IsW32
}

if(IsWin32 -eq $false) {
    $out = sudo -H -E apt-get install -y iotedge
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
    $out = sudo -H -E chmod 666 /etc/iotedge/config.yaml
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
}
else {
    python -m pip install --upgrade pip
    #python -m pip install iotedge
    python -m pip install -e $hh
}
