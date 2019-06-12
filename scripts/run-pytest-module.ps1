# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$test_scenario,

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

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
. $path/pwsh-helpers.ps1
$isWin32 = IsWin32
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$testpath = Join-Path -Path $path -ChildPath '../test-runner' -Resolve
$scriptpath = Join-Path -Path $path -ChildPath '../scripts' -Resolve
$setuppath = Join-Path -Path $scriptpath -ChildPath 'setup' -Resolve

#set-location $setuppath
#& ./setup-python36.ps1

try {
    $cert_val = $env:IOTHUB_E2E_EDGEHUB_CA_CERT
    if("$cert_val" -ne "") {
        Write-Host "found IOTHUB_E2E_EDGEHUB_CA_CERT"
    }
}
catch {
    Write-Host "NOT found IOTHUB_E2E_EDGEHUB_CA_CERT"
}

set-location $root_dir/scripts

#./get-environment.ps1

if($isWin32 -eq $false) {
    $EncodedText = sudo -H -E  cat /var/lib/iotedge/hsm/certs/edge_owner_ca*.pem | base64 -w 0
    if( "$EncodedText" -ne "") {
        Set-Item -Path Env:IOTHUB_E2E_EDGEHUB_CA_CERT -Value $EncodedText
        }
}

set-location $testpath
write-host "pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args"
if($isWin32 -eq $false) {
    sudo -H -E add-apt-repository ppa:deadsnakes/ppa        
    sudo -H -E apt update
    sudo -H -E apt install python3.6
    sudo -H -E update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
    sudo -H -E update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2
    sudo -H -E update-alternatives --set python3 /usr/bin/python3.6
    sudo -H -E pip install --upgrade pip
    $py = PyCmd "-m pip install -r requirements.txt"; Invoke-Expression  $py
    $hh = Join-Path -Path $path -ChildPath '../horton_helpers' -Resolve
    $py = PyCmd "-m pip install -e $hh"; Invoke-Expression  $py
    sudo -H -E python3 -m pip install pytest
    sudo -H -E python3 -u -m pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o
}
else {
    $py = PyCmd " -u -m pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o"; Invoke-Expression  $py  
}

