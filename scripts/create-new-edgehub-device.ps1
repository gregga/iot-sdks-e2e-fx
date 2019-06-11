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

. ./pwsh-helpers.ps1
$path = CurrentPath
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

#$hh = Join-Path -Path $path -ChildPath '../horton_helpers' -Resolve

if(IsWin32) {
    #python -m pip install -e $hh
    #python $pyscripts/create_new_edgehub_device.py
    $py = PyCmd "$pyscripts/create_new_edgehub_device.py"; Invoke-Expression  $py
    #python $pyscripts/deploy_test_containers.py
}
else {
    #SLYDBG ??
    #sudo -H -E python3 -m pip install -e $hh

    #sudo -H -E python3 $pyscripts/create_new_edgehub_device.py
    $py = PyCmd "$pyscripts/create_new_edgehub_device.py"; Invoke-Expression  $py
    sudo -H -E systemctl restart iotedge
}
