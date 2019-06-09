# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            #Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    return $false
}

if(IsWin32) {
    python $pyscripts/remove_edgehub_device.py
}
else {
    sudo -H -E python3 $pyscripts/remove_edgehub_device.py
}
