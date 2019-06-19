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
$root_dir = Join-Path -Path $path -ChildPath '..' -Resolve
#$resultsdir="$build_dir/results/logs/$log_folder_name"
$log_folder_name = $log_folder_name.trim("/\\")
$junit_file = Join-Path -Path $build_dir -ChildPath "TEST-$log_folder_name.xml".Trim() -Resolve
#$resultsdir="$build_dir/results/logs/$log_folder_name"
$resultsdir = Join-Path -Path $build_dir -ChildPath "results/logs/$log_folder_name" -Resolve
#$junit_file = "$build_dir/TEST-$log_folder_name.xml".Trim()

Write-Host "Fetching Logs"
if( -Not (Test-Path -Path $resultsdir ) )
{
    New-Item -ItemType directory -Path $resultsdir
}
else {
    Get-ChildItem -Path "$resultsdir/*" -Recurse | Remove-Item -Force -Recurse
    Remove-Item -Path $resultsdir -Force -Recurse
    New-Item -ItemType directory -Path $resultsdir
}

$stdout = @()
$stderr = @()
$languageMod = $langmod + "Mod"
$modulelist = @( $languageMod, "friendMod", "edgeHub", "edgeAgent")
foreach($mod in $modulelist) {
    if("$mod" -ne "") {
        Write-Host "getting log for $mod" -ForegroundColor Green 
        if($isWin32) {
            #$dock_log = Invoke-Expression  "docker logs -t $mod"
            #Invoke-Expression "docker logs -t $mod 2>&1 | Out-File "$resultsdir/$mod.log" -Append"
            $stdout = docker logs -t $mod 2>($tmpFile=New-TemporaryFile)
            $stderr = Get-Content $tmpFilexa; Remove-Item $tmpFile

        }
        else {
            #Invoke-Expression "sudo docker logs -t $mod 2>&1 | Out-File "$resultsdir/$mod.log" -Append"
            #$dock_log = Invoke-Expression  "sudo docker logs -t $mod"
            $stdout = & sudo docker logs -t $mod 2>($tmpFile=New-TemporaryFile)
            $stderr = Get-Content $tmpFile; Remove-Item $tmpFile
        }
        #$stderr = Get-Content $tmpFile; Remove-Item $tmpFile
        #$dock_log | Out-File "$resultsdir/$mod.log"
        if("$stderr" -ne "") {
            $stdout | Out-File $resultsdir/$mod.log -Append
            foreach($o in $stderr) {
                Write-Host $o -ForegroundColor Red
            }
        }
        if("$stdout" -ne "") {
            foreach($o in $stderr) {
                $o | Out-File $resultsdir/$mod.log -Append
            }
        }
    }
}

if($isWin32 -eq $false)  {
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
$out = @()
Write-Host "merging logs for $modlist" -ForegroundColor Green

$py = PyCmd-Run "${root_dir}/pyscripts/docker_log_processor.py $arglist"; $out = Invoke-Expression  $py

if ($LASTEXITCODE -ne 0) {
    Write-Host "error merging logs" -ForegroundColor Red
    foreach($o in $out) {
        Write-Host $o
    }
}
else {
    $out | Out-File $resultsdir/merged.log
}

set-location $resultsdir
Write-Host "injecting merged.log into junit" -ForegroundColor Green

$py = PyCmd-Run "${root_dir}/pyscripts/inject_into_junit.py -junit_file $junit_file -log_file $resultsdir/merged.log"; $out = Invoke-Expression  $py
foreach($o in $out) {
    Write-Host $o
}

$files = Get-ChildItem "$build_dir/TEST-*" | Where-Object { !$_.PSIsContainer }
if($files) {
    Move-Item $files "$build_dir/results/logs"
}
exit 0
