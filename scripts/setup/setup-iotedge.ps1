# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

#script_dir=$(cd "$(dirname "$0")" && pwd)
$IsWin32 = IsWindows
$pipTestOpts = ' --upgrade --no-deps --force-reinstall '

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow

function IsWindows {
    $IsW32 = $false
    try {
        if ([System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        $IsW32 =  $false
    }
    return $IsW32
}

if(!IsWindows) {
    $out = sudo apt-get install -y iotedge
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
    $out = sudo chmod 666 /etc/iotedge/config.yaml
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
}
# install iotedge
#sudo apt-get install -y iotedge
#[ $? -eq 0 ] || { echo "apt-get install iotedge failed"; exit 1; }

#sudo chmod 666 /etc/iotedge/config.yaml
#[ $? -eq 0 ] || { echo "sudo chmod"; exit 1; }

