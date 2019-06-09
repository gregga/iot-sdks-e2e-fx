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
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve

#$(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }},xml
$junit_file = "$build_dir/TEST-$log_folder_name.xml".Trim()


function IsWin32 {
    if("$env:OS" -ne "") {
        if ($env:OS.Indexof('Windows') -ne -1) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    return $false
}

$isWin32 = IsWin32

$resultsdir="$build_dir/results/logs/$log_folder_name"
if( -Not (Test-Path -Path $resultsdir ) )
{
    New-Item -ItemType directory -Path $resultsdir
}
else {
    Get-ChildItem -Path "$resultsdir/*" -Recurse | Remove-Item -Force -Recurse
    Remove-Item -Path $resultsdir -Force -Recurse
    New-Item -ItemType directory -Path $resultsdir
}

if($isWin32) {
    python -m pip install --upgrade pip
    python -m pip install -I docker
    python -m pip install -I colorama     
}
else {
    #sudo -H -E python3 -m pip install --no-cache-dir --upgrade pip
    #sudo python3 -m pip install --no-cache-dir --upgrade pip
    #sudo -H -E python3 -m pip install --no-cache-dir -I docker
    #sudo python3 -m pip install --no-cache-dir -I docker
    #sudo -H -E python3 -m pip install --no-cache-dir -I colorama
    #sudo python3 -m pip install --no-cache-dir -I colorama
}

$languageMod = $langmod + "Mod"
$modulelist = @( $languageMod, "friendMod", "edgeHub", "edgeAgent")
foreach($mod in $modulelist) {
    if("$mod" -ne "") {
        Write-Host "getting log for $mod" -ForegroundColor Green 
        $out = docker logs -t $mod
        $out | Out-File $resultsdir/${mod}.log
    }
}

if($isWin32 -eq $false) {
    sudo journalctl -u iotedge -n 500 -e
}

$arglist = ""
$modlist = ""
foreach($mod in $modulelist) {
    if("$mod" -ne "") {
        $arglist += "-staticfile $resultsdir/$mod.log "
        $modlist += "$mod "
    }
}

set-location $resultsdir
$out = ""
Write-Host "merging logs for $modlist" -ForegroundColor Green
Write-Host "${root_dir}/pyscripts/docker_log_processor.py $arglist"
if($isWin32) {
    Write-Host "docker_log_processor: [$arglist]" -ForegroundColor Yellow
    $out = python ${root_dir}/pyscripts/docker_log_processor.py $arglist
}
else {
    $out = sudo -H -E python3 ${root_dir}/pyscripts/docker_log_processor.py $arglist
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "error merging logs" -ForegroundColor Red
    Write-Host $out
}
else {
    $out | Out-File $resultsdir/merged.log
    #$Write-Host $out
}

$out = ""
#$junit_file = "$build_dir/$log_folder_name.xml"
#$junit_save_file = "$build_dir/logs/$log_folder_name.xml"
if(-Not (Test-Path $junit_file)) {
    #Copy-Item $junit_file -Destination "$build_dir"
    Write-Host "NOT Found: $junit_file" -ForegroundColor Red
}

set-location $resultsdir
Write-Host "injecting merged.log into junit" -ForegroundColor Green
$log_file = "$resultsdir/merged.log"
Write-Host "###${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_file"

if($isWin32) {
    $out = python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_fie
}
else {
    $out = python3 ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_file
}
foreach($o in $out) {
    Write-Host $o
}

if(Test-Path $junit_file) {
    #Copy-Item $junit_file -Destination "$build_dir"
    Write-Host "Found: $junit_file" -ForegroundColor Green
}
else {
    Write-Host "NOT Found: $junit_file" -ForegroundColor Green
    Get-ChildItem '/' -s -Include '*test_iothub_module*' | Where-Object {$_.PSIsContainer -eq $false} | %{$_.FullName}
}

$files = Get-ChildItem "$build_dir/TEST-*"  | Where-Object { !$_.PSIsContainer }
if($files) {
    foreach($f in $files) {
        Write-Host "FILE: $f"
    }
    Move-Item $files "$build_dir/results/logs/$log_folder_name"
}
