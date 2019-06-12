# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            return $true
        }
    }
    return $false
}

function PyCmd-Run($py_cmd) {
    if($isWin32) {
        return "python $py_cmd"
    }
    else { 
        return "sudo -H -E python3 $py_cmd"
    }
}

function CurrenthPath-Get {
    $path = ""
    if (!$path) { $path = $MyInvocation.InvocationName }
    if (!$path) { $path = split-path -Path $MyInvocation.MyCommand.Path -Parent }
    if (!$path) { $path = split-path -Path $psISE.CurrentFile.Fullpath -Parent }
    if (!$path) { $path = ($pwd).path }
    return $path
}

function PyEnvironment-Set {
    $isWin32 = IsWin32
    $path = ($pwd).path
    if (!$path) { $path = split-path -Path $MyInvocation.MyCommand.Path -Parent }
    if (!$path) { $path = split-path -Path $psISE.CurrentFile.Fullpath -Parent }
    $root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
    $hh = Join-Path -root_dir $path -ChildPath 'horton_helpers' -Resolve
    if($isWin32 -eq $false) {
        sudo -H -E add-apt-repository ppa:deadsnakes/ppa        
        sudo -H -E apt update
        sudo -H -E apt install python3.6
        sudo -H -E update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
        sudo -H -E update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2
        sudo -H -E update-alternatives --set python3 /usr/bin/python3.6
        sudo -H -E pip install --upgrade pip
        set-location = $root_dir/pyscripts
        $py = PyCmd-Run "-m pip install -r requirements.txt"; Invoke-Expression  $py
        set-location = $root_dir/horton_helpers
        $py = PyCmd-Run "-m pip install -e $hh"; Invoke-Expression  $py
        set-location = $root_dir/testscripts
        $py = PyCmd-Run "-m pip install -r requirements.txt"; Invoke-Expression  $py
        sudo -H -E python3 -m pip install pytest
    }
}

