# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$container_name)

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
    sudo python $pyscripts/ensure-container.py $container_name
}
else {
    sudo -H -E python3 $pyscripts/ensure-container.py $container_name
}
    
