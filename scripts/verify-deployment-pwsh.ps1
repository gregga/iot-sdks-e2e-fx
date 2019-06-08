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

$isWin32 = RunningOnWin32
Write-Host "######################################Cntr"
docker container ps
Write-Host "######################################Img"
docker image ls
Write-Host "######################################"
Write-Host "image_name: $image_name"
Write-Host "container_name: $container_name"
Write-Host "######################################"

$expectedImg = ""
$actualImg = ""
$expectedImg = ""
$running = $false
foreach($i in 1..24) {
    Write-Host "getting image ID for $image_name run $i"
    if($isWin32) {
        $expectedImg = docker image inspect $image_name --format="{{.Id}}"
    }
    else {
        $expectedImg = sudo docker image inspect $image_name --format="{{.Id}}"
    }
    if("$expectedImg" -ne "") {
        Write-Host "calling docker inspect $container_name" -ForegroundColor Green
        if($isWin32) {
            $running = docker image inspect --format="{{.State.Running}}" $container_name
        }
        else {
            $running = sudo docker inspect --format="{{.State.Running}}" $container_name
        }

        if($running -eq $true) {
            Write-Host "Container is running.  Checking image" -ForegroundColor Green

            if($isWin32) {
                $actualImg = docker inspect $container_name --format="{{.Image}}"
            }
            else {
                $actualImg = sudo docker inspect $container_name --format="{{.Image}}"
            }
            Write-Host "Actual ImageId: $actualImg" -ForegroundColor Green

            if($expectedImg -eq $actualImg) {
                Write-Host "IDs match.  Deployment is complete"  -ForegroundColor Green
                exit 0
            }
            else {
                Write-Host "container is not running.  Waiting"  -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "container is unkonwn.  Waiting." -ForegroundColor Yellow
    }
    Write-Host "Sleeping..."
    Start-Sleep -s 10
}

Write-Host  "container $container_name deployment failed" -ForegroundColor Red
exit 1
