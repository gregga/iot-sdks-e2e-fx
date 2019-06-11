# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

. ../pwsh-helpers.ps1
$path = CurrentPath

$py = PyCmd "-m pip install --upgrade pip"; Invoke-Expression  $py
$py = PyCmd "-m pip install --upgrade setuptools"; Invoke-Expression  $py

if(IsWin32 -eq $false) {
    sudo apt-get install -y iotedge
    sudo chmod 666 /etc/iotedge/config.yaml
}
