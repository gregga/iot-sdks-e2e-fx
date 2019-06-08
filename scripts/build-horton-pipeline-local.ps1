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
#$Horton.FrameworkRoot = $root_dir

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

set-location $root_dir
$isWin32 = RunningOnWin32
$horton_user = $env:IOTHUB_E2E_REPO_USER
$horton_pw = $env:IOTHUB_E2E_REPO_PASSWORD
$horton_repo = $env:IOTHUB_E2E_REPO_ADDRESS

# export to global ENV
Set-Item "env:IOTHUB-E2E-REPO-USER" $horton_user
Set-Item "env:IOTHUB-E2E-REPO-PASSWORD" $horton_pw
Set-Item "env:IOTHUB-E2E-REPO-ADDRESS" $horton_repo

set-location $root_dir
# Build Images:


# pre-test-steps

Write-Host 'POWERSHELL: install python libs' -ForegroundColor Blue
scripts/setup/setup-python36.ps1

if(!$isWin32) {
    Write-Host 'POWERSHELL: install iotedge packages' -ForegroundColor Blue
    scripts/setup/setup-iotedge.ps1    
}

Write-Host 'POWERSHELL: pre-cache docker images' -ForegroundColor Blue
$lang = "node"
$timg = "none"
$eaimg = "mcr.microsoft.com/azureiotedge-agent:1.0.6"
$ehimg = "mcr.microsoft.com/azureiotedge-hub:1.0.6"
$frimg = "$horton_repo/default-friend-module:latest"

set-location $root_dir

#D:\repos\iot\iot-sdks-e2e-fx-fork\scripts\setup\setup-precache-images.ps1
#scripts/setup/setup-precache-images.ps1
scripts/setup/setup-precache-images.ps1 $lang $timg $eaimg $ehimg $frimg

Write-Host 'POWERSHELL: Create new edgehub identity' -ForegroundColor Blue
scripts/create-new-edgehub-device.ps1

Write-Host 'POWERSHELL: Deploy manifest (${{ parameters.test_image }})' -ForegroundColor Blue
Write-Host "#### scripts/deploy-test-containers.ps1 $lang $horton_repo/$lang-e2e-v3:$timg" -ForegroundColor Yellow
scripts/deploy-test-containers.ps1 $lang $horton_repo/$lang-e2e-v3:$timg

Write-Host 'POWERSHELL: Verify edgeHub deployment' -ForegroundColor Blue
set-location $root_dir
#scripts/verify-deployment-pwsh.ps1 edgeHub $ehimg
scripts/verify-deployment-pwsh.ps1 edgeHub $ehimg

Write-Host 'POWERSHELL: Verify edgeAgent deployment' -ForegroundColor Blue
scripts/verify-deployment-pwsh.ps1 edgeAgent $eaimg

Write-Host 'POWERSHELL: Verify friendMod deployment' -ForegroundColor Blue
scripts/verify-deployment-pwsh.ps1 friendMod $frimg

Write-Host "POWERSHELL: Verify deploymet $lang-Mod $horton_repo/$lang-e2e-v3:$timg" -ForegroundColor Blue
scripts/verify-deployment-pwsh.ps1 $lang+"-Mod" $horton_repo/$lang-e2e-v3:$timg

Write-Host 'POWERSHELL: Verify that $lang-Mod is responding' -ForegroundColor Blue
scripts/setup/verify-container-running.ps1 $lang + "-Mod"

Write-Host 'POWERSHELL: Verify that friendMod is responding' -ForegroundColor Blue
scripts/setup/verify-container-running.ps1 friendMod

Write-Host 'POWERSHELL: give edgeHub 30 seconds to start up' -ForegroundColor Yellow
Start-Sleep -s 30

$logdir = "$root_dir/testlogs"
New-Item -Path $logdir -Type Directory

# pytest-steps
$scenario = "edgehub_module"
$xport = "mqtt"
$build_dir = ""
$junit_xml = "$logdir/TEST-test_edgehub_module_mqtt.xml"
$opts = "test_edgehub_module_mqtt"
$xtra_params = ""

#pytest -v --scenario edgehub_module --transport=mqtt --node-wrapper --junitxml=/home/vsts/work/1/s/TEST-test_edgehub_module_mqtt.xml -o junit_suite_name=test_edgehub_module_mqtt 

Write-Host 'POWERSHELL: run PYTEST module' -ForegroundColor Green
scripts/setup/run-pytest-module.ps1 $scenario $xport $lang $junit_xml $opts $xtra_params

#$(Horton.FrameworkRoot)/scripts/run-pytest-module.ps1 ${{ parameters.scenario }} ${{ parameters.transport }} ${{ parameters.language }} $(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }}.xml junit_suite_name=${{ parameters.log_folder_name }} ${{ parameters.extra_args }}
#Write-Host "POWERSHELL: run-pytest-module.ps1 $scenario $xport $lang $build_dir'/TEST-'$log_folder'.xml' junit_suite_name=$log_folder $xtra_params"
#scripts/run-pytest-module.ps1 $scenario $xport $lang $build_dir'/TEST-'$log_folder'.xml' junit_suite_name=$log_folder $xtra_params

# post-test-steps

#fetch-logs
Write-Host 'POWERSHELL: Fetch logs' -ForegroundColor Green

scripts/fetch-logs-pwsh.ps1 $lang

try {
    New-Item -Path $build_dir/results/$log_folder -ItemType Directory
}
finally {
    Write-Host "Nope"
}

#try {
#    New-Item $xtra_params -type directory
#}
#finally {
#    $files = Get-ChildItem $xtra_params/'TEST-'
#    Move-Item $files $xtra_params/results}
#}


