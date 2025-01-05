<#**************************************************************************************************
Name: Test-InstallOracleApp.ps1         Author: Brendan Furey                      Date: 03-Jan-2025

Component package in the Powershell Oracle Utility module OracleUtils. The module has a utility that
facilitates installation of an Oracle database module comprising components such as tables, views,
packages etc. by means of a set of SQL*Plus scripts. These scripts have to be created separately for
the particular Oracle module, while the Powershell utility coordinates their execution. The utility
also allows for copying of files to a folder, such as a folder used for data loading via external
tables.

    GitHub: https://github.com/BrenPatF/powershell_utils

As well as the module file, there is an install script, an example script, and a unit test script.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

It uses unit testing utility functions from the separate Powershell module, TrapitUtils.

====================================================================================================
| Script (.ps1)           | Module (.psm1) |  Notes                                                |
|==================================================================================================|
|  Install-OracleUtils    |     Installer copies module to Powershell path                         |
|-------------------------|------------------------------------------------------------------------|
|  Install-Utils          |     Example script installs Oracle PL/SQL General Utilities Module     |
|                         |------------------------------------------------------------------------|
|-------------------------| *OracleUtils*  |  Powershell Oracle utility functions                  |
|                         |----------------|-------------------------------------------------------|
|                         |  TrapitUtils   |  Trapit unit testing utility functions                |
|                         |------------------------------------------------------------------------|
| *Test-InstallOracleApp* |     Unit test script                                                   |
====================================================================================================

Unit test script.

**************************************************************************************************#>
Import-Module ..\..\Utils\Utils.psm1, ..\..\OracleUtils\OracleUtils.psm1, ..\..\TrapitUtils\TrapitUtils.psm1
function purelyWrap-Unit($inpGroups) { # input scenario groups

    $inpPath, $inpType, $callType, $hashKey1, $hashKey2, $hashKey3, $hashKey4 = $inpGroups.'Scalars'[0].Split('|')
    if($inpType -eq 'File') {
        New-Item -Path "$inpPath" -ItemType File | Out-Null
    } elseif($inpType -eq 'Folder') {
        New-Item -Path "$inpPath" -ItemType Directory | Out-Null
    }
    $itemsToDelete = [string[]]@()
    if($inpType -eq 'File' -Or $inpType -eq 'Folder') {
        $itemsToDelete = @($inpPath)
    }
    [string[]]$fileLis = @()
    [string[]]$copyFilesLis = $inpGroups.'Copy Files'
    $copyFilesLis | %{
        $fileName, $existsYN = $_.Split('|')
        $fileLis += $fileName
        if($existsYN -eq 'Y') {
            New-Item -Path ".\$fileName" -ItemType File | Out-Null
            $itemsToDelete += ".\$fileName"
        }
    }
    $installObjLis = [PSCustomObject[]]@()
    [string[]]$installLis = $inpGroups.'SQL Install List'
    $installLis | %{
        $folderNm, $folderExistsYN, $scriptNm, $scriptExistsYN, $schema, $prm1, $prm2, $prm3 = $_.Split('|')
        if($folderExistsYN -eq 'Y' -And $folderNm -ne '.') {
            if (-Not (Test-Path -PathType Container $folderNm)) {
                New-Item -Path "$folderNm" -ItemType Directory | Out-Null
                $itemsToDelete += "$folderNm"
            }
        }
        if(($folderExistsYN -eq 'Y') -And ($scriptExistsYN -eq 'Y')) {
            New-Item -Path ("$folderNm\$scriptNm") -ItemType File | Out-Null
            if($folderNm -eq '.') {
                $itemsToDelete += "$folderNm\$scriptNm"
            }
        }
        $prmLis = [string[]]@()
        if($prm1 -ne '') {
            $prmLis += $prm1
            if($prm2 -ne '') {
                $prmLis += $prm2
                if($prm3 -ne '') {
                    $prmLis += $prm3
                }
            }
        }
        $installObjLis += @{
            $hashKey1 = $folderNm
            $hashKey2 = $scriptNm
            $hashKey3 = $schema
            $hashKey4 = $prmLis
        }
    }
    $exceptionLis = [string[]]@()
    try {
        $fileCopies = [PSCustomObject]@{inputPath = $inpPath; fileLis = $fileLis}
        if($callType -eq 'File') {
            $result = Install-OracleApp -fileCopies $fileCopies -testMode $true
        } elseif($callType -eq 'SQL') {
            $result = Install-OracleApp -sqlInstalls $installObjLis -testMode $true
        } else {
            $result = Install-OracleApp -fileCopies $fileCopies -sqlInstalls $installObjLis -testMode $true
        }
        $fc = $result.fileCopy
        $inputPathLis = [string[]]@()
        if($fc) {
            $inputPathLis = @($fc.folderExists)
            $copyFilesLis = [string[]]$fc.fileLis
        }
        $installOutLis = [string[]]@()
        $al = $result.appLis
        if($al){
            foreach($a in $al) {
                $installOutLis += $a.subFolder + '|' + $a.exeStr
            }
        }
    } catch {
        $inputPathLis  = [string[]]@()
        $copyFilesLis  = [string[]]@()
        $installOutLis = [string[]]@()
        $exceptionLis  = [string[]]@(,$_)
    }
    foreach($i in $itemsToDelete) {
        Remove-Item $i -Force -Recurse
    }
    [PSCustomObject]@{
          'Input Path'       = $inputPathLis
          'Copy Files'       = $copyFilesLis
          'SQL Install List' = $installOutLis
          'Exception'        = $exceptionLis 
    }
}
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'install-oracleapp' ${function:purelyWrap-Unit}
