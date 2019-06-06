# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

#$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$pyscripts = Join-Path -Path $path -ChildPath '../../pyscripts' -Resolve
$hh = Join-Path -Path $path -ChildPath '../../horton_helpers' -Resolve

function IsWin32 {
    try {
        $CheckWin = [System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)
        if ($CheckWin) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        Write-Host "NotWin32" -ForegroundColor Yellow
    }
    return $false
}

if(IsWin32){
    python -m pip install --upgrade pip

    python -m  pip install --upgrade setuptools

    #python -m pip install iotedge
    python -m pip install -e $hh
}
else {
    sudo -H -E pip install --upgrade setuptools
    #$out = sudo -H -E pip install --upgrade setuptools
    #foreach($o in $out){
    #    Write-Host $o -ForegroundColor Magenta
    #}
    $out = sudo -H -E apt-get install -y iotedge
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
    $out = sudo -H -E chmod 666 /etc/iotedge/config.yaml
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
}