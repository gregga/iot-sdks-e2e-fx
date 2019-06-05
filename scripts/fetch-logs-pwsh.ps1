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

Write-Host "rootpath: $rootpath" -ForegroundColor Yellow

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

try {
    New-Item -Path $resultsdir -ItemType Directory
}
finally {
    Write-Host "fetching docker logs" -ForegroundColor Green
    if("$langmod" -ne "") {
        $languageMod = $langmod + "Mod"
        Write-Host "Including: $languageMod" -ForegroundColor Magenta
    }    
}


$modulelist = @( $languageMod, "friendMod", "edgeHub", "edgeAgent")
foreach($mod in $modulelist) {
    if("$mod" -ne "") {
        Write-Host "getting log for $mod" -ForegroundColor Green 
        $out = docker logs -t $mod; if ($LASTEXITCODE -ne 0) { Write-Host "error fetching logs for $mod" -ForegroundColor Red; $out }
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
    $out = sudo journalctl -u iotedge -n 500 -e; if ($LASTEXITCODE -ne 0) { Write-Host "error fetching iotedged journal" -ForegroundColor Red; $out }
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
        $arglist += "-staticfile $mod.log "
        $modlist += "$mod "
    }
}

set-location $resultsdir
Write-Host "merging logs for $modlist" -ForegroundColor Green 
if($isWin32) {
    Write-Host "docker_log_processor: [$arglist]" -ForegroundColor Yellow
    $out = python ${root_dir}/pyscripts/docker_log_processor.py $arglist; if ($LASTEXITCODE -ne 0) { Write-Host "error merging logs" -ForegroundColor Red; $out }
    python ${root_dir}/pyscripts/docker_log_processor.py $arglist.
}
else {
    python3 ${root_dir}/pyscripts/docker_log_processor.py $arglist; if ($LASTEXITCODE -ne 0) { Write-Host "error merging logs" -ForegroundColor Red; $out }
}
$out | Out-File -Append $resultsdir/${mod}.log

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

if($isWin32) {
    $out = python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file merged.log; if ($LASTEXITCODE -ne 0) { Write-Host "error injecting into junit" -ForegroundColor Red; $out }
}
else {
    $out = python3 python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file merged.log; if ($LASTEXITCODE -ne 0) { Write-Host "error injecting into junit" -ForegroundColor Red; $out }
}
$out | Out-File -Append $resultsdir/${mod}.log

#echo "injecting merged.log into junit"
#pushd $resultsdir && python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $2 -log_file merged.log
#$if [ $? -ne 0 ]; then
#  echo "error injecting into junit"
#fi
