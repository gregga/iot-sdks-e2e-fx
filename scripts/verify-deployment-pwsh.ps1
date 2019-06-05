# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [AllowEmptyString()]
    [string]$container_name="",
    
    [Parameter(Position=1)]
    [AllowEmptyString()]
    [string]$image_name=""
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve

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

if( "$container_name" -eq "" -or "$image_name" -eq "") {
  Write-Host "Usage: verify-deployment [container_name] [image_name]" -ForegroundColor Red
  Write-Host "eg: verify-deployment nodeMod localhost:5000/node-test-image:latest" -ForegroundColor Red
  exit 1
}

foreach($i in 1..24) {
  Write-Host "getting image ID for $image_name run $i"
  $out = docker image inspect $image_name
  foreach($o in $out){
    Write-Host $o -ForegroundColor Magenta
  }
  Start-Sleep -s 10
}

#--format="{{.Id}}


# each iteration = ~ 10 seconds
#for i in {1..24}; do
#  echo "getting image ID for $IMAGENAME"
#  EXPECTED_IMAGE_ID=$(sudo docker image inspect $IMAGENAME --format="{{.Id}}")
#  if [ $? -eq 0 ]; then
#    echo "expected image ID is $EXPECTED_IMAGE_ID"

#    echo "calling \"docker inspect $CONTAINERNAME\""
#    RUNNING=$(sudo docker inspect --format="{{.State.Running}}" $CONTAINERNAME)
#    if [ $? -eq 0 ] && [ "$RUNNING" = "true" ]; then
#      echo "Container is running.  Checking image"

#      ACTUAL_IMAGE_ID=$(sudo docker inspect $CONTAINERNAME --format="{{.Image}}")
#      [ $? -eq 0 ] || { echo "docker inspect failed"; exit 1; }
#      echo "actual image ID is $ACTUAL_IMAGE_ID"

#      if [ $EXPECTED_IMAGE_ID = $ACTUAL_IMAGE_ID ]; then
#        echo "ID's match.  Deployment is complete"
#        exit 0
#      else
#        echo "no match.  waiting"
#      fi
#    else
#      echo "container is not running.  Waiting"
#    fi
#  else
#    print "container is unkonwn.  Waiting."
#  fi
#  sleep 10
#done

#echo "container $CONTAINERNAME deployment failed"
#exit 1


