# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$lang,
    [Parameter(Position=1)]
    [string]$container_name
)

. ./pwsh-helpers.ps1
$path = CurrentPath
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath '/pyscripts' -Resolve

Write-Host "deploy_test_container.py --friend --$lang $container_name" -ForegroundColor Yellow

$py = PyCmd "$pyscripts/deploy_test_containers.py --friend --$lang $container_name"; Invoke-Expression  $py

