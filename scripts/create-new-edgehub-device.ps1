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
. $path/pwsh-helpers.ps1
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve
$hh = Join-Path -Path $path -ChildPath '../horton_helpers' -Resolve

$py = PyCmd "-m pip install -e $hh"; Invoke-Expression  $py
$py = PyCmd "$pyscripts/create_new_edgehub_device.py"; Invoke-Expression  $py

if(IsWin32 -eq $false) {
    sudo -H -E systemctl restart iotedge
}
