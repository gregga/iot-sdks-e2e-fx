# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$arg1
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath '/pyscripts' -Resolve

function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            return $true
        }
    }
    return $false
}

$edge_cert1 = "$env:IOTHUB_E2E_EDGEHUB_CA_CERT"

#export IOTHUB_E2E_EDGEHUB_CA_CERT=$(sudo cat /var/lib/iotedge/hsm/certs/edge_owner_ca*.pem | base64 -w 0)

if(IsWin32 -eq $false) {
    #$cert_path = Join-Path -Path "/var/lib/iotedge/hsm/certs" -ChildPath "edge_owner_ca*.pem" -Resolve
    #if (Test-Path $cert_path) {
    #    #$cert_text  = Get-Content $cert_path
    #    $cert_text = sudo python3 $pyscripts/get_environment_variables.py "raw" $cert_path
    #    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($cert_text)
    #    $EncodedText =[Convert]::ToBase64String($Bytes)
    $EncodedText = sudo cat /var/lib/iotedge/hsm/certs/edge_owner_ca*.pem | base64 -w 0
    if( "$EncodedText" -ne "") {
        Set-Item -Path Env:IOTHUB_E2E_EDGEHUB_CA_CERT -Value $EncodedText
    
    }
}

$edge_cert2 = "$env:IOTHUB_E2E_EDGEHUB_CA_CERT"

# force re-fetch of the device ID
#unset IOTHUB_E2E_EDGEHUB_DEVICE_ID
if( "$env:IOTHUB_E2E_EDGEHUB_CA_CERT" -eq "") {
    Write-Host "ERROR: IOTHUB_E2E_EDGEHUB_CA_CERT not set" -ForegroundColor Red
}
else {
    Remove-Item Env:IOTHUB_E2E_EDGEHUB_CA_CERT
}

$out = @()
if(IsWin32) {
    $out = python $pyscripts/get_environment_variables.py "powershell"
}
else {
#    $out = sudo -H -E python3 $pyscripts/get_environment_variables.py "powershell"
    $out = sudo -python3 $pyscripts/get_environment_variables.py "powershell"
}

foreach($o in $out) {
    $var_name,$var_value = $o.split('=')
    if("env:$var_name" -eq "") {
        Write-Host "Setting: $o" -ForegroundColor Magenta
        Set-Item -Path Env:$var_name -Value $var_value
    }
}

$edge_cert3 = "$env:IOTHUB_E2E_EDGEHUB_CA_CERT"

Write-Host "######################################" -ForegroundColor Yellow
if($edge_cert3.Length() -gt 12) {
    Write-Host "EC3: " + $edge_cert3.SubString(0,12)
}
if($edge_cert2.Length() -gt 12) {
    Write-Host "EC2: " + $edge_cert2.SubString(0,12)
}
if($edge_cert1.Length() -gt 12) {
    Write-Host "EC1: " + $edge_cert1.SubString(0,12)
}
#Set-Item -Path Env:IOTHUB_E2E_EDGEHUB_CA_CERT -Value $edge_cert

if("$env:IOTHUB_E2E_EDGEHUB_CA_CERT" -eq "") {
    Write-Host "Reverting to previous IOTHUB_E2E_EDGEHUB_CA_CERT" -ForegroundColor Red
    Set-Item -Path Env:IOTHUB_E2E_EDGEHUB_CA_CERT -Value $edge_cert
}

if("$env:IOTHUB_E2E_EDGEHUB_DEVICE_ID" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_EDGEHUB_DEVICE_ID" -ForegroundColor Red
}
if("$env:IOTHUB_E2E_EDGEHUB_DNS_NAME" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_EDGEHUB_DNS_NAME" -ForegroundColor Red
}
if("$env:IOTHUB_E2E_EDGEHUB_CA_CERT" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_EDGEHUB_CA_CERT" -ForegroundColor Red
}
if("$env:IOTHUB_E2E_CONNECTION_STRING" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_CONNECTION_STRING" -ForegroundColor Red
}
if("$env:IOTHUB_E2E_REPO_ADDRESS" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_REPO_ADDRESS" -ForegroundColor Red
}
if("$env:IOTHUB_E2E_REPO_USER" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_REPO_USER" -ForegroundColor Red
}
if("$env:IOTHUB_E2E_REPO_PASSWORD" -eq "") {
    Write-Host "NOT Set: IOTHUB_E2E_REPO_PASSWORD" -ForegroundColor Red
}

