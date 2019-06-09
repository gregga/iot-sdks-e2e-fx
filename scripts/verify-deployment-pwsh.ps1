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

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            #Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    return $false
}

if( "$container_name" -eq "" -or "$image_name" -eq "") {
    Write-Host "Usage: verify-deployment [container_name] [image_name]" -ForegroundColor Red
    Write-Host "eg: verify-deployment nodeMod localhost:5000/node-test-image:latest" -ForegroundColor Red
    exit 1
}

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

#$allOutput = & myprogram.exe 2>&1
#$stderr = $allOutput | ?{ $_ -is [System.Management.Automation.ErrorRecord] }
#$stdout = $allOutput | ?{ $_ -isnot [System.Management.Automation.ErrorRecord] }

$out_progress = "."
Write-Host "getting image ID for .$container_name. and .$image_name. run .$i." -ForegroundColor Green
foreach($i in 1..24) {
    #Write-Host "getting image ID for $image_name run $i"
    if(IsWin32) {
        $expectedImg = docker image inspect $image_name --format="{{.Id}}"  2>&1
    }
    else {
        $expectedImg = & sudo docker image inspect $image_name --format="{{.Id}}" 2>&1
    }
    if("$expectedImg" -ne "") {
        if("$out_progress" -eq ".") {
            Write-Host "calling docker inspect $container_name" -ForegroundColor Green
        }
        if(IsWin32) {
            $running = & docker image inspect --format="{{.State.Running}}" $container_name 2>&1
        }
        else {
            $running = & sudo docker inspect --format="{{.State.Running}}" $container_name 2>&1
        }
        if($running -eq $true) {
            Write-Host "Container is running.  Checking image" -ForegroundColor Green

            if(IsWin32) {
                $actualImg = & docker inspect $container_name --format="{{.Image}}" 2>&1
            }
            else {
                $actualImg = & sudo docker inspect $container_name --format="{{.Image}}"  2>&1
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
    Write-Host "$out_progress" -ForegroundColor Blue
    $out_progress += "."
    Start-Sleep -s 10
}

Write-Host  "container $container_name deployment failed" -ForegroundColor Red
exit 1
