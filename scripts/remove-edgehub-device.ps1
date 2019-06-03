# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

$out = sudo -H -E python3 $pyscripts/remove_edgehub_device.py
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}
