# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve


function IsWin32 {
    $ret = $false
    try {
        $CheckWin = [System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)
        if ($CheckWin) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            $ret = $true
        }
    }
    finally {
        $ret = $false
    }
    return $ret
}

$isWin32 = IsWin32

if($isWin32) {
    python $pyscripts/remove_edgehub_device.py
}
else {
    sudo -H -E python3 $pyscripts/remove_edgehub_device.py
}
