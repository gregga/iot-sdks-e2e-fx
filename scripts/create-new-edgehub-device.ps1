# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [AllowEmptyString()]
    [string]$arg1="",
    [Parameter(Position=1)]
    [AllowEmptyString()]
    [string]$arg2=""
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
set-location $root_dir
$hh = Join-Path -Path $path -ChildPath '../horton_helpers' -Resolve
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            return $true
        }
    }
    return $false
}

if(IsWin32) {
    #python -m pip install -e $hh
    python $pyscripts/create_new_edgehub_device.py
    #python $pyscripts/deploy_test_containers.py
}
else {
    #sudo -H -E python3 -m pip install -e $hh
    sudo python3 $pyscripts/create_new_edgehub_device.py
    sudo systemctl restart iotedge
}
