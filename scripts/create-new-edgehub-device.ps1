# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [AllowEmptyString()]
    [string]$arg1="",
    [Parameter(Position=1)]
    [AllowEmptyString()]
    [string]$arg2=""
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$Horton.FrameworkRoot = $root_dir

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
$horton_user = $env:IOTHUB_E2E_REPO_USER
$horton_pw = $env:IOTHUB_E2E_REPO_PASSWORD
$horton_repo = $env:IOTHUB_E2E_REPO_ADDRESS

# export to global ENV
Set-Item "env:IOTHUB-E2E-REPO-USER" $horton_user
Set-Item "env:IOTHUB-E2E-REPO-PASSWORD" $horton_pw
Set-Item "env:IOTHUB-E2E-REPO-ADDRESS" $horton_repo

set-location $root_dir

$hh = Join-Path -Path $path -ChildPath '../horton_helpers' -Resolve
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

if($isWin32) {
    $out = python -m pip install -e $hh
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
    
    $out = python $pyscripts/create_new_edgehub_device.py
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
    
    $out = python $pyscripts/deploy_test_containers.py
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
}
else {
    $out = sudo -H -E python3 -m pip install -e $hh
    foreach($o in $out){
        Write-Host $o -ForegroundColor Magenta
    }
    
    $out = sudo -H -E python3 $pyscripts/create_new_edgehub_device.py
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
    
    $out = sudo -H -E python3 $pyscripts/deploy_test_containers.py
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
    
    $out = sudo -H -E  systemctl restart iotedge
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }    
}
#$out = sudo -H -E python3 -m pip install --user ruamel.yaml
#foreach($o in $out){
#    Write-Host $o -ForegroundColor Magenta
#}

#python3 $(dirname "$0")/../pyscripts/create_new_edgehub_device.py $1
#[ $? -eq 0 ] || { echo "create_new_edgehub_device.py failed"; exit 1; }

#python3 $(dirname "$0")/../pyscripts/deploy_test_containers.py
#[ $? -eq 0 ] || { echo "deploy_test_containers.py failed"; exit 1; }

#echo "restarting iotedge"
#sudo systemctl restart iotedge
#if [ $? -eq 0 ]; then 
#    echo "iotedge restart complete"
#else
#    echo "restart iotedge failed" 
#    echo "This is OK to ignore if running as part of a VSTS job."
#    echo "It looks like iotedge has a back-off on restart and it's"
#    echo "unable to restart right now.  It will restart on its own"
#    echo "once it's ready."
#fi

