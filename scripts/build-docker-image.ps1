# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

param(
    [Parameter(Position = 0)]
    [string]$language,
    [Parameter(Position = 1)]
    [string]$repo,
    [Parameter(Position = 2)]
    [string]$commit,
    [Parameter(Position = 3)]
    [string]$variant=""
)

. ./pwsh-helpers.ps1
$path = CurrentPath

$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath 'pyscripts' -Resolve

$py = PyCmd "-m pip install --upgrade pip"; Invoke-Expression  $py
$py = PyCmd "-m pip install -r $pyscripts/requirements.txt"; Invoke-Expression  $py
$py = PyCmd "-m pip install -I docker"; Invoke-Expression  $py
$py = PyCmd "-m pip install -I colorama"; Invoke-Expression  $py

$py = PyCmd "$pyscripts/build_docker_image.py --language $language --repo $repo --commit $commit --variant $variant"; Invoke-Expression  $py

