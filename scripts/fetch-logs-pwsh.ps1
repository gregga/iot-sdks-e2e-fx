# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [AllowEmptyString()]
    [string]$langmod="",
    [Parameter(Position=1)]
    [AllowEmptyString()]
    [string]$junit_file=""
)

#$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve

Write-Host "root_dir: $root_dir" -ForegroundColor Yellow

if($langmod.EndsWith("xml")) {
    $junit_file = $langmod
    $langmod = ""
}

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

$isWin32 = RunningOnWin32
$languageMod=""
$resultsdir="$root_dir/results/logs"

if($isWin32) {
    python -m pip install --upgrade pip
    python -m pip install -I docker
    python -m pip install -I colorama     
}
else {
    sudo -H -E python3 -m pip install --no-cache-dir --upgrade pip
    sudo python3 -m pip install --no-cache-dir --upgrade pip
    sudo -H -E python3 -m pip install --no-cache-dir -I docker
    sudo python3 -m pip install --no-cache-dir -I docker
    sudo -H -E python3 -m pip install --no-cache-dir -I colorama
    sudo python3 -m pip install --no-cache-dir -I colorama
}

try {
    New-Item -Path $resultsdir -ItemType Directory
}
finally {
    Write-Host "Got $resultsdir" -ForegroundColor Green
}

$modulelist = @( $languageMod, "friendMod", "edgeHub", "edgeAgent")
foreach($mod in $modulelist) {
    if("$mod" -ne "") {
        Write-Host "getting log for $mod" -ForegroundColor Green 
        $out = docker logs -t $mod
        #docker logs -t $mod
        $out | Out-File -Append $resultsdir/${mod}.log
    }
}

#for mod in ${languageMod} friendMod edgeHub edgeAgent; do
#  echo "getting log for $mod"
#  sudo docker logs -t ${mod} &> $resultsdir/${mod}.log 
#  if [ $? -ne 0 ]; then
#    echo "error fetching logs for ${mod}"
#  fi
#done

if($isWin32 -eq $false) {
    $out = sudo journalctl -u iotedge -n 500 -e
    $out | Out-File -Append $resultsdir/${mod}.log
}

#sudo journalctl -u iotedge -n 500 -e  &> $resultsdir/iotedged.log
#if [ $? -ne 0 ]; then
#  echo "error fetching iotedged journal"
#fi

$arglist = ""
$modlist = ""
foreach($mod in $modulelist) {
    if("$mod" -ne "") {
        $arglist += "-staticfile $resultsdir/$mod.log "
        $modlist += "$mod "
    }
}

set-location $resultsdir
Write-Host "merging logs for $modlist" -ForegroundColor Green
Write-Host "${root_dir}/pyscripts/docker_log_processor.py $arglist"
if($isWin32) {
    Write-Host "docker_log_processor: [$arglist]" -ForegroundColor Yellow
    $out = python ${root_dir}/pyscripts/docker_log_processor.py $arglist
    python ${root_dir}/pyscripts/docker_log_processor.py $arglist
    #args: -staticfile nodeMod.log -staticfile friendMod.log -staticfile edgeHub.log -staticfile edgeAgent.log :
    Write-Host "#########################" -ForegroundColor Yellow
    #$out = python ${root_dir}/pyscripts/docker_log_processor.py " -staticfile nodeMod.log -staticfile friendMod.log -staticfile edgeHub.log -staticfile edgeAgent.log"
    $out = python ${root_dir}/pyscripts/docker_log_processor.py $arglist
    #$out | Out-File -Append $resultsdir/$merged.log
}
else {
    $out = sudo -H -E python3 ${root_dir}/pyscripts/docker_log_processor.py $arglist
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "error merging logs" -ForegroundColor Red
    Write-Host $out
}
else {
    $out | Out-File -Append $resultsdir/$merged.log
    Write-Host $out
}

#args=
#for mod in ${languageMod} friendMod edgeHub edgeAgent; do
#    args="${args} -staticfile ${mod}.log"
#done
#pushd $resultsdir && python ${root_dir}/pyscripts/docker_log_processor.py $args > merged.log
#if [ $? -ne 0 ]; then
#  echo "error merging logs"
#fi

set-location $resultsdir
Write-Host "injecting merged.log into junit" -ForegroundColor Green
$log_file = "$resultsdir/merged.log"
Write-Host "${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_file"

if($isWin32) {
    $out = python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_fie
}
else {
    $out = python3 ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_file
}
Write-Host $out
#$out | Out-File -Append $resultsdir/$merged.log

#echo "injecting merged.log into junit"
#pushd $resultsdir && python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $2 -log_file merged.log
#$if [ $? -ne 0 ]; then
#  echo "error injecting into junit"
#fi
