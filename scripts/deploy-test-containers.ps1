# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$lang,
    [Parameter(Position=1)]
    [string]$container_name
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath '/pyscripts' -Resolve

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    return $false
}

Write-Host "deploy_test_container.py --friend --$lang $container_name" -ForegroundColor Yellow

if(IsWin32) {
    python $pyscripts/deploy_test_containers.py --friend --$lang $container_name
}
else {
    sudo -H -E python3 $pyscripts/deploy_test_containers.py --friend --$lang $container_name
}

