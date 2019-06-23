# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [string]$langmod,
    [Parameter(Position=1)]
    [string]$build_dir,
    [Parameter(Position=2)]
    [string]$log_folder_name
)

$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
. $path/pwsh-helpers.ps1
$isWin32 = IsWin32
$log_folder_name = $log_folder_name.trim("/")
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
$pyscripts = Join-Path -Path $root_dir -ChildPath 'pyscripts' -Resolve
$resultsdir="$build_dir/results/logs/$log_folder_name"
$junit_file = "$build_dir/TEST-$log_folder_name.xml"
$ErrorActionPreference = 'SilentlyContinue'
Write-Host "Fetching Logs for $log_folder_name" -ForegroundColor Green

if( -Not (Test-Path -Path $resultsdir ) )
{
    New-Item -ItemType directory -Path $resultsdir
}
else {
    Get-ChildItem -Path "$resultsdir/*" -Recurse | Remove-Item -Force -Recurse
    Remove-Item -Path $resultsdir -Force -Recurse
    New-Item -ItemType directory -Path $resultsdir
}

if($isWin32 -eq $false)  {
    python3 -m pip install docker
}

$languageMod = $langmod + "Mod"
$modulefiles = @()
$modulelist = @( $languageMod, "friendMod", "edgeHub", "edgeAgent")
foreach($mod in $modulelist) {
    if("$mod.strip()" -ne "") {
        $modFile ="$resultsdir/$mod.log"
        $modulefiles += $modFile
        Write-Host "Getting log for $mod" -ForegroundColor Green

        $py = Invoke-PyCmd "$pyscripts/get_container_log.py --container $mod"
        Invoke-Expression "$py" -erroraction SilentlyContinue | Set-Content -Path $modFile
    }
}

if($isWin32 -eq $false)  {
    sudo journalctl -u iotedge -n 500 -e >$resultsdir/iotedged.log
}

Write-Host "merging logs for ($modulelist)" -ForegroundColor Green
$arglist = ""
foreach($modFile in $modulefiles) {
    if(Test-Path $modFile) {
        $arglist += "-staticfile $modFile "
    }   
}
$py = Invoke-PyCmd "$pyscripts/docker_log_processor.py $arglist"
#$py_cmd = "& `"$py`" 2>&1"
#invoke-expression $py | Out-File $resultsdir/merged.log
#invoke-expression "$py 2>&1" -erroraction SilentlyContinue | Out-File $resultsdir/merged.log
#invoke-expression "$py 2>&1" -erroraction SilentlyContinue | Out-File $resultsdir/merged.log
Invoke-Expression "$py" -erroraction SilentlyContinue | Set-Content -Path $resultsdir/merged.log
#invoke-expression "$py 2>&1" -erroraction Continue > $resultsdir/merged.log

#$py_out_array = Invoke-Expression "$py 2>&1" -ErrorAction SilentlyContinue
#$py_out_string = [string]::join("`r`n",$py_out_array)
#$py_out_string | Out-File $resultsdir/merged.log

#invoke-expression $py > $resultsdir/merged.log
#invoke-expression $py_cmd
#$py_out_array = invoke-expression $py_cmd
#$py_out_string = [string]::join("`r`n",$py_out_array)
#$py_out_string | Out-File $modFile

#$py = Invoke-PyCmd "$py_cmd"; Invoke-Expression "& '$py' > $resultsdir/merged.log"
#$command = "& `"C:\Users\myprofile\Documents\visual studio 2010\Projects\TestOutput\TestOutput\bin\Debug\testoutput.exe`" someparameter -xyz someotherparameter -abc someotherthing -rfz -a somethinghere 2>&1"
#$out_log > $resultsdir/merged.log
#| Out-File $modFile
#$out_log | Out-File $resultsdir/merged.log -Append
Write-Host "XXXX**************************************************"
Get-Content -Path $resultsdir/merged.log
Write-Host "WWWW**************************************************"

Write-Host "injecting merged.log into junit" -ForegroundColor Green
$py = Invoke-PyCmd "$pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $resultsdir/merged.log"; Invoke-Expression $py

$files = Get-ChildItem "$build_dir/TEST_*"
if($files) {
    Move-Item $files "$build_dir/results/logs"
}
if(Test-Path -Path $junit_file )
{
    Copy-Item $junit_file -Destination "$build_dir/results/logs"
}
