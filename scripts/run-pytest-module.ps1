# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Mandatory)]
    [Alias("scenario")] 
    [string[]]$test_scenario,
    [Parameter(Mandatory)]
    [Alias("transport")] 
    [string]$test_transport,
    [Parameter(Mandatory)]
    [Alias("lang")] 
    [string]$test_lang,
    [Parameter(Mandatory)]
    [Alias("junitxml")] 
    [string]$test_junitxml,
    [Parameter(Mandatory)]
    [Alias("o")] 
    [string]$test_o,
    [Parameter(Mandatory)]
    [Alias("extra_args")] 
    [string]$test_extra_args
)

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
Write-Host "RealPath $path" -ForegroundColor Yellow
$testpath = Join-Path -Path $path -ChildPath '../../test-runner' -Resolve
set-location $testpath

write-host $pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args$
$out = sudo -H -E python3 -u -m pytest -v --scenario $test_scenario --transport=$test_transport --$test_lang-wrapper --junitxml=$test_junitxml -o $test_o $test_extra_args
foreach($o in $out){
    Write-Host $o -ForegroundColor Blue
}
