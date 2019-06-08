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

Write-Host "root_dir: $root_dir" -ForegroundColor Yellow

function RunningOnWin32 {
    try {
        $CheckWin = [System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)
        if ($CheckWin) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        Write-Host "Not Win32" -ForegroundColor Magenta
    }
    return $false
}

$isWin32 = RunningOnWin32
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

Write-Host "deploy_test_container.py --friend --$lang $container_name" -ForegroundColor Yellow

if($isWin32) {
    python $pyscripts/deploy_test_containers.py --friend --$lang $container_name
}
else {
    sudo -H -E python3 $pyscripts/deploy_test_containers.py --friend --$lang $container_name
}

