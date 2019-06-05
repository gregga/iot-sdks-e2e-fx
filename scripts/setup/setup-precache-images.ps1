# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [AllowEmptyString()]
    [string]$language="0",

    [Parameter(Position=1)]
    [AllowEmptyString()]
    [string]$test_image="1",
    
    [Parameter(Position=2)]
    [AllowEmptyString()]
    [string]$image_edgeagent="2",
    
    [Parameter(Position=3)]
    [AllowEmptyString()]
    [string]$image_edgehub="3",
    
    [Parameter(Position=4)]
    [AllowEmptyString()]
    [string]$image_friendmod="4"
)

#Param
#(
#    [Parameter(Mandatory=$false)]
#    [Alias("lang")] 
#    [string]$language="",#

#   [Parameter(Mandatory=$false)]
#    [Alias("timg")] 
#    [string]$test_image="",

#    [Parameter(Mandatory=$false)]
#    [Alias("eaimg")] 
#    [string]$image_edgeagent="",

#    [Parameter(Mandatory=$false)]
#    [Alias("ehimg")] 
#    [string]$image_edgehub="",

#    [Parameter(Mandatory=$false)]
#    [Alias("frImg")] 
#    [string]$image_friendmod=""
#)

$horton_user = $env:IOTHUB_E2E_REPO_USER
$horton_pw = $env:IOTHUB_E2E_REPO_PASSWORD
$horton_repo = $env:IOTHUB_E2E_REPO_ADDRESS

docker login -u $horton_user -p $horton_pw $horton_repo
docker pull $repo_name/$language-e2e-v3:$test_image
docker pull $image_edgeagent
docker pull $image_edgehub
docker pull $image_friendmod
