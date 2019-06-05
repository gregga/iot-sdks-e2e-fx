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


# Build Images:


# pre-test-steps

#/scripts/setup/setup-python36.ps1
Write-Host 'POWERSHELL: install python libs'

#/scripts/setup/setup-iotedge.ps1
Write-Host 'POWERSHELL: install iotedge packages'

#/scripts/setup/setup-precache-images.ps1 -user ${{ parameters.repo_user }} -pw ${{ parameters.repo_password }} -repo ${{ parameters.repo_address }} -lang ${{ parameters.language }} -timg ${{ parameters.test_image }} -eaimg ${{ parameters.image_edgeAgent }} -ehimg ${{ parameters.image_edgeHub }} -frImg ${{ parameters.image_friendmod }}
Write-Host 'POWERSHELL: pre-cache docker images'

#/scripts/create-new-edgehub-device.ps1
Write-Host 'POWERSHELL: Create new edgehub identity'

#/scripts/deploy-test-containers.ps1 ${{ parameters.language }} ${{ parameters.repo_address }}/${{ parameters.language }}-e2e-v3:${{ parameters.test_image }}
Write-Host 'POWERSHELL: Deploy manifest (${{ parameters.test_image }})'

#/scripts/verify-deployment-pwsh.ps1 edgeHub ${{ parameters.image_edgeHub }}
Write-Host 'POWERSHELL: Verify edgeHub deployment'

#/scripts/verify-deployment-pwsh.ps1 edgeAgent ${{ parameters.image_edgeAgent }}
Write-Host 'POWERSHELL: Verify edgeAgent deployment'

#/scripts/verify-deployment-pwsh.ps1 friendMod ${{ parameters.image_friendMod }}
Write-Host 'POWERSHELL: Verify friendMod deployment'

#/scripts/verify-deployment-pwsh.ps1 ${{ parameters.language }}Mod ${{ parameters.repo_address }}/${{ parameters.language }}-e2e-v3:${{ parameters.test_image }}
Write-Host 'POWERSHELL: Verify deploymet ${{ parameters.language }}Mod ${{ parameters.repo_address }}/${{ parameters.language }}-e2e-v3:${{ parameters.test_image }}'

#/scripts/setup/verify-container-running.ps1 ${{ parameters.language }}Mod
Write-Host 'POWERSHELL: Verify that ${{ parameters.language }}Mod is responding'

#/scripts/setup/verify-container-running.ps1 friendMod
Write-Host 'POWERSHELL: Verify that friendMod is responding'

Start-Sleep -s 30

# pytest-steps
#/scripts/run-pytest-module.ps1 ${{ parameters.scenario }} ${{ parameters.transport }} ${{ parameters.language }} $(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }}.xml junit_suite_name=${{ parameters.log_folder_name }} ${{ parameters.extra_args }}
Write-Host 'POWERSHELL: run-pytest-module.ps1 ${{ parameters.scenario }} ${{ parameters.transport }} ${{ parameters.language }} $(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }}.xml junit_suite_name=${{ parameters.log_folder_name }} ${{ parameters.extra_args }}'

# post-test-stepss

#fetch-logs
Write-Host 'POWERSHELL: Fetch logs'

$Horton.FrameworkRoot/"scripts/fetch-logs-pwsh.ps1" ${{ parameters.language }}
try {
  New-Item -Path $(Build.SourcesDirectory)/results/${{ parameters.log_folder_name }} -ItemType Directory
}
finally {
  try {
    New-Item $(Build.SourcesDirectory)/results/${{ parameters.log_folder_name }} -type directory
  }
  finally {
    $files = Get-ChildItem $(Horton.FrameworkRoot)/results/logs/*
    Move-Item $files  $(Build.SourcesDirectory)/results/${{ parameters.log_folder_name }}
  }
}
try {
 New-Item $(Build.SourcesDirectory)/results} -type directory
}
finally {
  $files = Get-ChildItem $(Build.SourcesDirectory)/TEST-*
  Move-Item $files $(Build.SourcesDirectory)/results}
}

#








