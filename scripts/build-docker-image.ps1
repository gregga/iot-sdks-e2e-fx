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

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath 'pyscripts' -Resolve

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            return $true
        }
    }
    return $false
}

if(IsWin32) {
    python -m pip install -r $pyscripts/requirements.txt
    #python -m pip install --upgrade pip
    #python -m pip install -I docker
    #python -m pip install -I colorama     
}
else {
    python3 -m pip install -r $pyscripts/requirements.txt
    #sudo -H -E python3 -m pip install --upgrade pip
    sudo python3 -m pip install --upgrade pip
    #sudo -H -E python3 -m pip install -I docker
    sudo python3 -m pip install -I docker
    #sudo -H -E python3 -m pip install -I colorama
    sudo python3 -m pip install -I colorama
}

if(IsWin32) {
    python $pyscripts/build_docker_image.py --language $language --repo $repo --commit $commit --variant $variant
}
else {
    sudo python3 $pyscripts/build_docker_image.py --language $language --repo $repo --commit $commit --variant $variant
}

