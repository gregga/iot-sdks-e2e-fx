# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$pyscripts = Join-Path -Path $path -ChildPath '../../pyscripts' -Resolve
$hh = Join-Path -Path $path -ChildPath '../../horton_helpers' -Resolve


function IsWin32 {
    $ret = $false
    try {
        $CheckWin = [System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)
        if ($CheckWin) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            ret $true
        }
    }
    finally {
        ret = false
    }
    return $ret
}

if(IsWin32){
    python -m pip install --upgrade pip
    python -m  pipinstall --upgrade setuptools

    #python -m pip install iotedge
    python -m pip install -e $hh
}
else {
    sudo pip install --upgrade setuptools
    sudo apt-get install -y iotedge
    sudo chmod 666 /etc/iotedge/config.yaml

    sudo -H -E pip install --upgrade setuptools
    sudo -H -E apt-get install -y iotedge
    sudo -H -E chmod 666 /etc/iotedge/config.yaml
}
