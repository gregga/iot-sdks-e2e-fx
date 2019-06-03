# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$container_name)

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$pysripts = Join-Path -Path $path -ChildPath '../../pyscripts' -Resolve

$out = sudo -H -E python3 $pysripts/ensure-container.py $container_name
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}
