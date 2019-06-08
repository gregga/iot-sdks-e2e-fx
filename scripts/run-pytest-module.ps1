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


$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$testpath = Join-Path -Path $path -ChildPath '../test-runner' -Resolve
set-location $testpath

try {
    $cert_val = $env:IOTHUB_E2E_EDGEHUB_CA_CERT
    if("$cert_val" -ne "") {
        Write-Host "found IOTHUB_E2E_EDGEHUB_CA_CERT"
    }
}
catch {
    Write-Host "NOT found IOTHUB_E2E_EDGEHUB_CA_CERT"
}

$isWin32 = RunningOnWin32

write-host "###### pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args"
if($isWin32) {
    python -u -m pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args
}
else {
    sudo -H -E python3 -u -m pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args
}
