# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$lang,
    [Parameter(Position=1)]
    [string]$container_name
)

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

#$out = sudo -H -E python3 -m pip install --user ruamel.yaml
#foreach($o in $out){
#    Write-Host $o -ForegroundColor Magenta
#}

Write-Host "deploy_test_container.py --friend --$lang $container_name" -ForegroundColor Yellow
#python3 $pyscripts/deploy_test_containers.py --friend $friend
$out = sudo -H -E python3 $pyscripts/deploy_test_containers.py --friend --$lang $container_name
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}

