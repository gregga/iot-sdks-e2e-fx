# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$Repo_User,
    [Parameter(Position=0)]
    [string]$Repo_Pw,
    [Parameter(Position=0)]
    [string]$Repo_Name,
    [Parameter(Position=0)]
    [string]$Language,
    [Parameter(Position=1)]
    [string]$Test_Image,
    [Parameter(Position=2)]
    [string]$Image_EdgeAgent,
    [Parameter(Position=3)]
    [string]$Image_EdgeHub,
    [Parameter(Position=4)]
    [string]$Image_Friendmod
)


$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow



docker login -u $Repo_User -p $Repo_Pw $Repo_Name
docker pull $env:IOTHUB_E2E_REPO_ADDRESS/$Language-e2e-v3:$Test_Image
docker pull $Image_EdgeAgent
docker pull $Image_EdgeHub
docker pull $Image_Friendmod



