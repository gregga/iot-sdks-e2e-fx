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

#$root_dir + "/scripts/setup/setup-python36.ps1"

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

#$isWin32 = RunningOnWin32
$args = ""
if("$lang" -ne "") { $args += " --language $lang"}
if("$repo" -ne "") { $args += " --repo $repo"}
if("$commit" -ne "") { $args += " --commit $commit"}
if("$commit" -ne "") { $args += " --variant $variant"}

$out = sudo -H -E python3 $pyscripts/build_docker_image.py $args
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}
 

