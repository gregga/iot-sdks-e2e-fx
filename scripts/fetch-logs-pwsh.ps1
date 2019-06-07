# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

Param
(
    [Parameter(Position=0)]
    [AllowEmptyString()]
    [string]$langmod="",
    [Parameter(Position=1)]
    [AllowEmptyString()]
    [string]$build_dir="",
    [Parameter(Position=2)]
    [AllowEmptyString()]
    [string]$log_folder_name=""
)

#$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve

Write-Host "root_dir: $root_dir" -ForegroundColor Yellow

#if($langmod.EndsWith("xml")) {
#    $junit_file = $langmod
#    $langmod = ""
#}

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



#$(Horton.FrameworkRoot)/scripts/fetch-logs-pwsh.ps1 ${{ parameters.language }} $(Build.SourcesDirectory) ${{ parameters.log_folder_name }}.xml
#$(Horton.FrameworkRoot)/scripts/fetch-logs-pwsh.ps1 ${{ parameters.language }} $(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }}.xml $(Build.SourcesDirectory)


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
$oout = ""
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
    #$Write-Host $out
}

#$(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }}.xml
#$junit_log_dir = Join-Path -Path $build_dir $junit_name -Resolve

$out = ""
$junit_file = "$build_dir/$log_folder_name.xml"

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
Write-Host "###${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_file"

if($isWin32) {
    $out = python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_fie
}
else {
    $out = python3 ${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $log_file
}
#Write-Host $out
#$out | Out-File -Append $resultsdir/$merged.log

#echo "injecting merged.log into junit"
#pushd $resultsdir && python ${root_dir}/pyscripts/inject_into_junit.py -junit_file $2 -log_file merged.log
#$if [ $? -ne 0 ]; then
#  echo "error injecting into junit"
#fi

#$(Horton.FrameworkRoot)/scripts/fetch-logs.sh ${{ parameters.language }} $(Build.SourcesDirectory)/TEST-${{ parameters.log_folder_name }}.xml
#mkdir -p $(Build.SourcesDirectory)/results/${{ parameters.log_folder_name }}
#mv $(Horton.FrameworkRoot)/results/logs/* $(Build.SourcesDirectory)/results/${{ parameters.log_folder_name }}/
#mv $(Build.SourcesDirectory)/TEST-* $(Build.SourcesDirectory)/results

#$junit_log_dir = Join-Path -Path $build_dir $junit_name -Resolve
#$junit_file = Join-Path -Path $junit_log_dir "$junit_file.xml" -Resolve

if( -Not (Test-Path -Path $build_dir/results/$log_folder_name ) )
{
    New-Item -ItemType directory -Path $build_dir/results/$log_folder_name
}
else {
    Remove-Item -Path $build_dir/results/$log_folder_name -Force -Recurse
    New-Item -ItemType directory -Path $build_dir/results/$log_folder_name
}
$files = Get-ChildItem "$root_dir/results/logs/*"
Move-Item $files $build_dir/results/$log_folder_name

if( -Not (Test-Path -Path $build_dir/results ) )
{
    New-Item -ItemType directory -Path $build_dir/results
}
else {
    Remove-Item -Path $build_dir/results -Force -Recurse
    New-Item -ItemType directory -Path $build_dir/results
}
$files = Get-ChildItem "$build_dir/TEST-*"
Move-Item $files $build_dir/results


#try {
#    New-Item -Path $build_dir/results/$log_folder_name -ItemType Directory
#  }
#  finally {
#    #try {
    #  New-Item $(Build.SourcesDirectory)/results/${{ parameters.log_folder_name }} -ItemType Directory
    #}
    #finally {
#    $files = Get-ChildItem "$root_dir/results/logs/*"
#    Move-Item $files $build_dir/results/$log_folder_name
    #}

#  }
#  try {
#    New-Item $build_dir/results -ItemType Directory
#  }
#  finally {
#    $files = Get-ChildItem "$build_dir/TEST-*"
#    Move-Item $files $build_dir/results
#  }


