#!/usr/bin/env powershell
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.
#

function CheckVerString([string] $pyVerStr) {

    $PyVer = $pyVerStr.Split('.')
    $PvMaj = [int]$PyVer[0]
    $PvMin = [int]$PyVer[1]

    if($PvMaj -gt $PythonMinVersionMajor)
    {
        Write-Host "Found Python Version: " $pyVerStr -ForegroundColor Green
        return $true
    }
    if($PvMaj -eq $PythonMinVersionMajor)
    {
        if($PvMin -ge $PythonMinVersionMinor)
        {
            Write-Host "Found Python Version: " $pyVerStr -ForegroundColor Green
            return $true
        }
    }
    return $false
}

function SearchForPythonVersion()
{
    Write-Host "Checking for python version (minimum): $PythonMinVersionMajor.$PythonMinVersionMinor" -ForegroundColor Yellow

    try {
        $PyVerCmd = & python3 -V 2>&1
        $PyParts = $PyVerCmd.split(' ')
        return CheckVerString($PyParts[1])
    }
    catch {
        try {
            $PyVerCmd = & python -V 2>&1
            $PyParts = $PyVerCmd.split(' ')
            return CheckVerString($PyParts[1])
        }
        catch {
            Write-Host "Continuing" -ForegroundColor Yellow
        }
    }
    
    $PyPath = Which("python")
    $pyVerFound = $false
    if ($PyPath) {
        foreach($PyFile in $PyPath)
        {
            try {
                $PyVer = (Get-Item $PyFile).VersionInfo
                $pyFound =  CheckVerString($PyVer.FileVersion)
                if($pyFound)
                {
                    Write-Host "Found: $PyFile" -ForegroundColor Green
                    $pyVerFound = $true
                }
            }
            catch {
                Write-Host "Continuing." -ForegroundColor Yellow
            }
        }
    }
    return $pyVerFound
}

function which([string]$cmd) {
    if($IsWin32) {
        $cmd += '.exe'
    }
    Write-Host "Looking for $cmd in path..." -ForegroundColor Yellow
    $path = (Get-Command $cmd).Path
    if(!$path){
        Write-Host "Command $cmd NOT FOUND in path" -ForegroundColor Red
    }
    return $path
}

function IsWindows {
    $IsW32 = $false
    try {
        if ([System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)) {
            Write-Host "IsWin32" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        $IsW32 =  $false
    }
    return $IsW32
}

###############################################################
#### Script Starts Here ####

$PythonMinVersionMajor = 3
$PythonMinVersionMinor = 5

$IsWin32 = IsWindows
$pipTestOpts = ' --upgrade --no-deps --force-reinstall '

$script_dir = $pwd.Path
$path = $MyInvocation.MyCommand.Path
if (!$path) {$path = $psISE.CurrentFile.Fullpath}
if ( $path) {$path = split-path $path -Parent}
set-location $path

Write-Host "RealPath $path" -ForegroundColor Yellow

#$root_dir = Join-Path -Path $script_dir -ChildPath '/../..' -Resolve
$root_dir = Join-Path -Path $path -ChildPath '../..' -Resolve

Write-Host "POWERSHELL SCRIPT in Setup-Python36" -ForegroundColor Red -BackgroundColor Yellow
Write-Host "RootDir: $root_dir" -ForegroundColor Magenta
$foundPy = SearchForPythonVersion($PythonMinVersionMajor, $PythonMinVersionMinor)

if(!$foundPy)
{
    Write-Host "Python version not found" -ForegroundColor Red
    if ($IsWin32) {
        Write-Host "Please install python 3.6 on Windows." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "Installing python 3.6..." -ForegroundColor Yellow
        $out = sudo apt-get install -y python3; if ($LASTEXITCODE -ne 0) { $out }
        if($out.Length -gt 0){
            foreach($o in $out){
                Write-Host $o -ForegroundColor Blue
            }
        }
        if($LASTEXITCODE -eq 0)
        {
            Write-Host "python installed successfully" -ForegroundColor Green
        } 
        else 
        {
            Write-Host "python install failed"  -ForegroundColor Red
            exit 1
        }
    }
}

$gotPip3 = $true
$Pip3Path = Which("pip3")
if($Pip3Path.Length -lt 1)
{
    Write-Host "Pip3 not found" -ForegroundColor Red
    if($IsWin32) {
        Write-Host "Please install Pip3 on Windows." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "Installing pip3..." -ForegroundColor Yellow
        #$out = sudo apt-get install -y; if ($LASTEXITCODE -ne 0) { $out }
        $out = sudo apt-get install -y
        if($out.Length -gt 0){
            foreach($o in $out){
                Write-Host $o -ForegroundColor Blue
            }
        }
        if($LASTEXITCODE -eq 0)
        {
            Write-Host "pip3 installed successfully" -ForegroundColor Green
            $gotPip3 = $true
        } 
        else 
        {
            Write-Host "pip3 install failed"  -ForegroundColor Red
            exit 1
        }
    }
}

if($gotPip3) {
    Write-Host "Pip3 already installed" -ForegroundColor Green
    Write-Host "Updating flask" -ForegroundColor Yellow
    #$out = python.exe -m pip install --upgrade pip
    #python -m pip install flask
    if($IsWin32) {
        $out = python -m $pipcmd install --upgrade flask
    }
    else{
        $out = python3 -m $pipcmd install --upgrade flask
    }
    if($out.Length -gt 0){
        foreach($o in $out){
            Write-Host $o -ForegroundColor Blue
        }
    }
    if($LASTEXITCODE -eq 0)
    {
        Write-Host "flask installed successfully" -ForegroundColor Green
    } 
    else 
    {
        Write-Host "flask install failed"  -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Updating Pip3" -ForegroundColor Yellow 
    if($IsWin32) {
        #$out = python -m $pipcmd install --upgrade pip3
        $out = python -m pip install --upgrade pip setuptools wheel
    }
    else{
        $out = python3 -m $pipcmd install --upgrade  pip setuptools wheel
    }
    if($out.Length -gt 0){
        foreach($o in $out){
            Write-Host $o -ForegroundColor Blue
        }
    }
    if($LASTEXITCODE -eq 0)
    {
        Write-Host "pip3 updated successfully" -ForegroundColor Green
    } 
    else 
    {
        Write-Host "pip3 updated failed"  -ForegroundColor Red
        exit 1
    }
}

$pipcmd = 'pip3'
$Mypycmd = 'python'
if($IsWin32){
    $pipcmd = 'pip'
}
else {
    $pipcmd = 'pip'
    $Mypycmd = 'python3'
}

#colorecho $_yellow "Installing python libraries"
#cd ${root_dir}/ci-wrappers/pythonpreview/wrapper  &&  \
#   python3 -m pip install --user -e python_glue
#if [ $? -ne 0 ]; then 
#    colorecho $_yellow "user path not accepted.  Installing globally"
#    cd ${root_dir}/ci-wrappers/pythonpreview/wrapper  &&  \
#        python3 -m pip install -e python_glue
#    [ $? -eq 0 ] || { colorecho $_red "install python_glue failed"; exit 1; }
#fi

Write-Host "Installing python libraries" -ForegroundColor Yellow
#cd $root_dir/ci-wrappers/pythonpreview/wrapper
$out = cd $root_dir/ci-wrappers/pythonpreview/wrapper
#$runCmd = "cd $root_dir/ci-wrappers/pythonpreview/wrapper"
#write-host "Cmd: $runCmd" -ForegroundColor Magenta
#$out = $runCmd; if ($LASTEXITCODE -ne 0) { $out }
if($out.Length -gt 0){
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
}
if($LASTEXITCODE -eq 0)
{
    Write-Host "$runCmd Success" -ForegroundColor Green
} 
else 
{
    Write-Host "$runCmd FAIL"  -ForegroundColor Red
    exit 1
}

#$runCmd = "python -m $pipcmd install -e python_glue"
#$runCmd = "python -m $pipcmd install python_glue"
#write-host "Cmd: $runCmd" -ForegroundColor Yellow
#$out = $runCmd; if ($LASTEXITCODE -ne 0) { $out }
if($IsWin32) {
    $out = python -m $pipcmd install python_glue
}
else{
    $out = python3 -m $pipcmd install python_glue
}
if($out.Length -gt 0){
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
}
if($LASTEXITCODE -eq 0)
{
    Write-Host "python libraries installed successfully" -ForegroundColor Green
} 
else 
{
    Write-Host "python libraries install failed"  -ForegroundColor Red
    exit 1
}

#cd ${root_dir} &&  \
#    python3 -m pip install --user -e horton_helpers
#if [ $? -ne 0 ]; then 
#    colorecho $_yellow "user path not accepted.  Installing globally"
#    cd ${root_dir} &&  \
#        python3 -m pip install -e horton_helpers
#    [ $? -eq 0 ] || { colorecho $_red "install horton_helpers failed"; exit 1; }
#fi

Write-Host "Installing horton_helpers" -ForegroundColor Yellow
cd $root_dir
#$runCmd = "python -m $pipcmd install --user -e horton_helpers"
#$runCmd = "python -m $pipcmd $pipTestOpts -e horton_helpers"
#$runCmd = "python -m $pipcmd install horton_helpers"
#$runCmd = "python -m $pipcmd install -e horton_helpers"
#write-host "Cmd: $runCmd" -ForegroundColor Magenta
#$out = $runCmd; if ($LASTEXITCODE -ne 0) { $out }
#$out = $pycmd -m $pipcmd install horton_helpers
if($IsWin32) {
    $out = python -m $pipcmd install horton_helpers
}
else{
    $out = python3 -m $pipcmd install horton_helpers
}
if($out.Length -gt 0){
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
}
if($LASTEXITCODE -eq 0)
{
    Write-Host "horton_helpers installed successfully" -ForegroundColor Green
} 
else 
{
    Write-Host "horton_helpers install failed"  -ForegroundColor Red
    exit 1
}

# install requirements for our test runner
#cd ${root_dir}/test-runner &&  \
#    python3 -m pip install --user -r requirements.txt
#if [ $? -ne 0 ]; then 
#    colorecho $_yellow "user path not accepted.  Installing globally"
#    cd ${root_dir}/test-runner &&  \
#        python3 -m pip install -r requirements.txt
#    [ $? -eq 0 ] || { colorecho $_red "pip install requirements.txt failed"; exit 1; }
#fi

Write-Host "Installing requirements for Horton test runner" -ForegroundColor Yellow
#cd $root_dir/test-runner
#$runCmd = "cd $root_dir/test-runner"
cd $root_dir/test-runner
#write-host "root_dir: $root_dir" -ForegroundColor Red
#write-host "Cmd: $runCmd" -ForegroundColor Magenta
#$out = $runCmd; if ($LASTEXITCODE -ne 0) { $out }
#if($out.Length -gt 0){
#    foreach($o in $out){
#        Write-Host $o -ForegroundColor Blue
#    }
#}
#if($LASTEXITCODE -eq 0)
#{
#    Write-Host "$runCmd Success" -ForegroundColor Green
#} 
#else 
#{
#    Write-Host "$runCmd FAIL"  -ForegroundColor Red
#    exit 1
#}
#$runCmd = "python -m $pipcmd install --user -r requirements.txt"
#$runCmd = "python -m $pipcmd install -r requirements.txt"
#write-host "Cmd: $runCmd" -ForegroundColor Magenta
#$out = $runCmd; if ($LASTEXITCODE -ne 0) { $out }
#$out = $pycmd -m pip install -r requirements.txt
#; if ($LASTEXITCODE -ne 0) { $out }
if($IsWin32) {
    $out = python -m $pipcmd install -r requirements.txt
}
else{
    $out = python3 -m $pipcmd install -r requirements.txt
}
if($out.Length -gt 0){
    foreach($o in $out){
        Write-Host $o -ForegroundColor Blue
    }
}
if($LASTEXITCODE -eq 0)
{
    Write-Host "Horton test runner installed successfully" -ForegroundColor Green
} 
else 
{
    Write-Host "Horton test runner install failed"  -ForegroundColor Red
    exit 1
}

Write-Host "Python3 and Python libraries installed successfully" -ForegroundColor Green
