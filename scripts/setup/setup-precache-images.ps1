# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Mandatory)]
    [Alias("User")] 
    [string[]]$Repo_User,
    [Parameter(Mandatory)]
    [Alias("Pw")] 
    [string]$Repo_Pw,
    [Parameter(Mandatory)]
    [Alias("Repo")] 
    [string]$Repo_Name,
    [Parameter(Mandatory)]
    [Alias("Lang")] 
    [string]$Language,
    [Parameter(Mandatory)]
    [Alias("TImg")] 
    [string]$Test_Image,
    [Parameter(Mandatory)]
    [Alias("EAImg")] 
    [string]$Image_EdgeAgent,
    [Parameter(Mandatory)]
    [Alias("EHImg")] 
    [string]$Image_EdgeHub,
    [Parameter(Mandatory)]
    [Alias("FrImg")] 
    [string]$Image_Friendmod
)

docker login -u $Repo_User -p $Repo_Pw $Repo_Name
docker pull $$Repo_Name/$Language-e2e-v3:$Test_Image
docker pull $Image_EdgeAgent
docker pull $Image_EdgeHub
docker pull $Image_Friendmod



