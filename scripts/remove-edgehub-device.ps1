# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

. ./pwsh-helpers.ps1
$path = CurrentPath
$pyscripts = Join-Path -Path $path -ChildPath '../pyscripts' -Resolve

$py = PyCmd "$pyscripts/remove_edgehub_device.py"; Invoke-Expression  $py
