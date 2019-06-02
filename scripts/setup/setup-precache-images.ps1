# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Mandatory)]
    [Alias("user")] 
    [string[]]$repo_User,
    [Parameter(Mandatory)]
    [Alias("pw")] 
    [string]$repo_pw,
    [Parameter(Mandatory)]
    [Alias("repo")] 
    [string]$repo_name,
    [Parameter(Mandatory)]
    [Alias("lang")] 
    [string]$language,
    [Parameter(Mandatory)]
    [Alias("timg")] 
    [string]$test_image,
    [Parameter(Mandatory)]
    [Alias("eaimg")] 
    [string]$image_edgeagent,
    [Parameter(Mandatory)]
    [Alias("ehimg")] 
    [string]$image_edgehub,
    [Parameter(Mandatory)]
    [Alias("frImg")] 
    [string]$image_friendmod
)

docker login -u $repo_user -p $repo_pw $repo_name
docker pull $repo_name/$language-e2e-v3:$test_image
docker pull $image_edgeagent
docker pull $image_edgehub
docker pull $image_friendmod



