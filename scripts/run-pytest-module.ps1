# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string[]]$test_scenario,

    [Parameter(Position=1)]
    [string]$test_transport,

    [Parameter(Position=2)]
    [string]$test_lang,

    [Parameter(Position=3)]
    [AllowEmptyString()]
    [string]$test_junitxml="",

    [Parameter(Position=4)]
    [AllowEmptyString()]
    [string]$test_o="",

    [Parameter(Position=5)]
    [AllowEmptyString()]
    [string]$test_extra_args=""
)

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$testpath = Join-Path -Path $path -ChildPath '../test-runner' -Resolve
$pypath = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve
set-location $testpath

#export IOTHUB_E2E_EDGEHUB_CA_CERT=$(sudo cat /var/lib/iotedge/hsm/certs/edge_owner_ca*.pem | base64 -w 0)

try {
    $pem_file = "/var/lib/iotedge/hsm/certs/edge_owner_ca*.pem"
    $full_pem = Resolve-Path -Path $pem_file
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($full_pem))
    Write-Host $base64string
    $env:IOTHUB_E2E_EDGEHUB_CA_CERT = $base64string
}
catch {
    Write-Host "IOTHUB_E2E_EDGEHUB_CA_CERT not found"
}

$out = sudo -H -E python3 $pypath/get_environment_variables.py
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}

foreach($env_var in $out){
    if ($env_var.StartsWith("export ")) {

        $env_line = $env_var.Replace("`"","")
        $env_line = $env_line -replace "export ", ""

        $sep_pos = $env_line.IndexOf("=")
        $var_name = $env_line.Substring(0, $sep_pos)
        $var_val = $env_line.Substring($sep_pos + 1)
        try{
            New-Item env:\$var_name -Value $var_val
        }
        catch{
            write-host "$var_name already set"
        }
    }
}

try {
    $cert_val = $env:IOTHUB_E2E_EDGEHUB_CA_CERT
    if($null -ne $cert_val){
        Write-Host "found IOTHUB_E2E_EDGEHUB_CA_CERT"
    }
catch {
    Write-Host "NOT found IOTHUB_E2E_EDGEHUB_CA_CERT"
}

write-host "pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args"
$out = sudo -H -E python3 -u -m pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrap$env_wper --junitxml=$test_junitxml -o $test_o $test_extra_args
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}
