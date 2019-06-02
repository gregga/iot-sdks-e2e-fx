# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow

$out = python3 $path/../pyscripts/create_new_edgehub_device.py
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}

$out = python3 $path/../pyscripts/deploy_test_containers.py
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}

$out = sudo systemctl restart iotedge
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}



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

