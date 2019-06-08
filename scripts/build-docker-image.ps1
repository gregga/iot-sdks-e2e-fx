# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

param(
    [Parameter(Position = 0)]
    $language="",
    [Parameter(Position = 1)]
    $repo="",
    [Parameter(Position = 2)]
    $commit="",
    [Parameter(Position = 3)]
    $variant=""
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath 'pyscripts' -Resolve

function IsWin32 {
    $ret = $false
    try {
        $CheckWin = [System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)
        if ($CheckWin) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            $ret = $true
        }
    }
    finally {
        $ret = $false
    }
    return $ret
}

$isWin32 = IsWin32

if($isWin32) {
    python -m pip install --upgrade pip
    python -m pip install -I docker
    python -m pip install -I colorama     
}
else {
    sudo -H -E python3 -m pip install --upgrade pip
    sudo python3 -m pip install --upgrade pip
    sudo -H -E python3 -m pip install -I docker
    sudo python3 -m pip install -I docker
    sudo -H -E python3 -m pip install -I colorama
    sudo python3 -m pip install -I colorama
}

$args = ""
if("$language" -ne "") { $args += "--language ""$language"" "}
if("$repo" -ne "") { $args += "--repo ""$repo"" "}
if("$commit" -ne "") { $args += "--commit ""$commit"" "}
if("$variant" -ne "") { $args += "--variant ""$variant"""}

Write-Host "build-docker-image $args"

if($isWin32) {
    python $pyscripts/build_docker_image.py $args
}
else {
    sudo -H -E python3 $pyscripts/build_docker_image.py $args
    #$out = sudo -H -E python3 $pyscripts/build_docker_image.py $args
    #foreach($o in $out) {
    #    Write-Host $o -ForegroundColor Blue
    #}    
}

 

