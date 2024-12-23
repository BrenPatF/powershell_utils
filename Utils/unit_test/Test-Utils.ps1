<#**************************************************************************************************
Name: Test-Utils.ps1                        Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module Utils. The module has general utility functions
for pretty-printing etc.

    GitHub: https://github.com/BrenPatF/powershell_utils

There is an examples main script and a unit test script. The examples script makes calls to an
example class module that uses the pretty-printing functions, and calls other functions directly.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

====================================================================================================
| Script (.ps1)   | Module (.psm1) |  Notes                                                        |
|==================================================================================================|
|  Install-Utils  |                   Install script copies module to Powershell path              |
|-----------------|--------------------------------------------------------------------------------|
|                 |  ColGroup      |  Simple file-reading and group-counting class module          |
|  Show-Examples  |----------------|---------------------------------------------------------------|
|                 |                |                                                               |
|-----------------|  Utils         |  General utility functions                                    |
|                 |                |                                                               |
| *Test-Utils*    |----------------|---------------------------------------------------------------|
|                 |  TrapitUtils   |  Trapit unit testing utility functions                        |
====================================================================================================

This file contains a unit test script for the Utils package.

The script contains a wrapper function, purelyWrap-Unit, that takes a scenario input object
containing a list of records for each input group, formatted as delimited strings. The function
makes calls to the functions in the unit under test and returns an object containing a list of
records for each output group, formatted as delimited strings.

The function is 'externally pure' in the sense that it is deterministic, interacts externally via
parameters and return value, and any file output is reverted before exit.

The main section of the script is a call to a utility function, Test-Format, passing in the unit
test root folder, the parent folder of the JavaScript node_modules npm root folder, the input JSON
file name stem, and the wrapper function.

The utility function reads the input file, calls the wrapper function passed within a loop over the
input scenarios, accumulating the output scenarios containing both expected and actual results, and
writes an output JSON file. The utility function then calls a Javascript program that reads the
output JSON file and produces output in text and HTML formats in a subfolder, returning a summary.

**************************************************************************************************#>
Import-Module ..\..\Utils\Utils.psm1, ..\..\TrapitUtils\TrapitUtils.psm1
<#**************************************************************************************************

purelyWrap-Unit: Design pattern has the unit under test calls wrapped in a 'pure' function, called
                 once per scenario, with the output 'actuals' arrays including everything affected
                 by the uut, whether as output parameters, or files, etc. The inputs are also 
                 extended from the uut parameters to include any other effective inputs.

                 In this case, the wrapper function has a nested private function for each of the
                 functions being tested that creates the inputs, calls the function, and returns
                 the result as a list of delimited strings.

                 These lists of delimited strings are assigned as values to an object with key as 
                 output group name in each case, as the return value

**************************************************************************************************#>
function purelyWrap-Unit($inpGroups) { # input scenario groups

    function getWriteDebug($inpRecLis) { # input record list of delimited strings

        foreach ($r in $inpRecLis) {
            $message, $new_yn, $filename = $r.Split(';')
            if ($new_yn -eq 'Y') {
                if ($filename -eq '') {
                    Write-Debug $message $true
                } else {
                    Write-Debug $message $true $filename
                }
            } else {
                if ($filename -eq '') {
                    Write-Debug $message
                } else {
                    Write-Debug $message $false $filename
                }
            }
        } 
        if ($filename -eq '') {$filename = '.\debug.log'}
        $strLis = [String[]](Get-Content $filename)
        Start-Sleep -Seconds 0.1 # to avoid locking issue
        Remove-Item $filename
        ,$strLis
    }
    function getObjLisFromCsv($inpRecLis,   # input record list of delimited strings
                              $delimiter) { # delimiter
        $OBJLIS_CSV = $PSScriptRoot + '/ObjLisFromCsv.csv'
        $inpRecLis | Out-File $OBJLIS_CSV # $filename
        if ($delimiter -eq '') {
             $objLis = Get-ObjLisFromCsv $OBJLIS_CSV
        } else {
             $objLis = Get-ObjLisFromCsv $OBJLIS_CSV $delimiter
        }
        Start-Sleep -Seconds 0.2 # to avoid locking issue
        Remove-Item $OBJLIS_CSV
        Get-StrLisFromObjLis $objLis
    }
    function getHeading($inpRecLis, # input record list of delimited strings
                        $indent) {  # indent level

        $r = $inpRecLis[0]
        if ($indent -eq '') {
             $strLis = (Get-Heading $r).Split("`n")
        } else {
             $strLis = (Get-Heading $r $indent).Split("`n")
        }
        ,$strLis
    }
    function getColHeaders($inpRecLis, # input record list of delimited strings
                           $indent) {  # indent level

        $header2Lis = @()
        foreach ($r in $inpRecLis) {
            $Value, $Length = $r.Split(';')
            $header2Lis += ,@($Value, $Length)
        }

        if ($indent -eq '') {
             $strLis = (Get-ColHeaders $header2Lis).Split("`n")
        } else {
             $strLis = (Get-ColHeaders $header2Lis $indent).Split("`n")
        }
        ,$strLis
    }
    function getColHeadersLis($inpRecLis, # input record list of delimited strings
                              $indent) {  # indent level

        $header2Lis = @()
        foreach ($r in $inpRecLis) {
            $Value, $Length = $r.Split(';')
            $header2Lis += ,@($Value, $Length)
        }

        if ($indent -eq '') {
             $strLis = (Get-ColHeadersLis $header2Lis).Split("`n")
        } else {
             $strLis = (Get-ColHeadersLis $header2Lis $indent).Split("`n")
        }
        ,$strLis
    }
    function get2LisAsLine($inpRecLis, # input record list of delimited strings
                           $indent) {  # indent level

        $line2Lis = @()
        foreach ($r in $inpRecLis) {
            $Value, $Length = $r.Split(';')
            $line2Lis += ,@($Value, $Length)
        }
        if ($indent -eq '') {
             $strLis = (Get-2LisAsLine $line2Lis).Split("`n")
        } else {
             $strLis = (Get-2LisAsLine $line2Lis $indent).Split("`n")
        }
        ,$strLis
    }
    function getStrLisFromObjLis($inpRecLis,   # input record list of delimited strings
                                 $delimiter) { # delimiter

        if (-not $inpRecLis) {
            ,@()
            return
        }
        $ObjLis = @()
        $colLis = $inpRecLis[0].Split('|')
        $valStrLis =  $inpRecLis[1..$inpRecLis.length]
        foreach ($v in $valStrLis) {
            $obj = New-Object -TypeName psobject
            $i = 0
            foreach ($oVal in $v.Split('|')) {
                $obj | Add-Member -MemberType NoteProperty -Name $colLis[(++$i)-1] -Value $oVal
            }
            $ObjLis += $obj
        }
        if ($delimiter -eq '') {
             $strLis = Get-StrLisFromObjLis $ObjLis
        } else {
             $strLis = Get-StrLisFromObjLis $ObjLis $delimiter
        }
        ,$strLis
    }
    function removeExtraLF ($inpRecLis) {
        
        $FILENAME = $PSScriptRoot + '/extralf.txt'
        $eat = (New-Item -Path $FILENAME -ItemType File)
        $inpRecLis | Out-File -FilePath $FILENAME -append
        [string[]]$retArr = @('Before content...')
        $retArr += (Get-Content -Raw $FILENAME) -split "\r\n"
        Start-Sleep -Seconds 0.2 # to avoid locking issue
        Remove-ExtraLF $FILENAME
        $retArr += 'After content...'
        $retArr += (Get-Content -Raw $FILENAME) -split "\r\n"
        Start-Sleep -Seconds 0.2 # to avoid locking issue
        Remove-Item $FILENAME
        $retArr
    }
    function installModule ($inpRecLis) {
        if (-not $inpRecLis) {
            ,@()
            return
        }
        $srcFolder, $modName = $inpRecLis[0].split(';')
        $FILENAME = $srcFolder + '/' + $modName + '.psm1'
        $eat = (New-Item -Path $FILENAME -ItemType File)
        $eat = (Install-Module $srcFolder $modName)
        $psPathFirst = $env:psmodulepath.split(';')[0]
        $newMod = $psPathFirst + '\' + $modName + '\' + $modName + '.psm1'
        ,@((get-item ($newMod)).name)
        Start-Sleep -Seconds 0.2 # to avoid locking issue
        Remove-Item $FILENAME
        Remove-Item ($psPathFirst + '\' + $modName) -Recurse
    }
    function startMySleep($inpRecLis) { # input record list of delimited strings

        if (-not $inpRecLis) {
            ,@()
            return
        }
        [float]$sleepEla, [float]$fractionCpu = $inpRecLis[0].Split(';')
        [long]$ela0 = $(Get-Date).ticks
        [long]$cpu0 = $(Get-Process -id $pid).TotalProcessorTime.ticks

        Start-MySleep $sleepEla $fractionCpu

        [float]$elaUsed = [math]::Round((($(Get-Date).ticks - $ela0) / 10000000.0), 2)
        [float]$cpuUsed = [math]::Round((($(Get-Process -id $pid).TotalProcessorTime.ticks - $cpu0) / 10000000.0), 2)
        [string[]]$strLis = @($elaUsed.ToString() + ';' + $cpuUsed.ToString())
        ,$strLis
    }
    $delimiter, $indent =  $inpGroups.'Scalars'.Split(';')

    #      Object key (group name)  Private function     Group value = list of input records  Function parameters
    [PSCustomObject]@{
          'Write-Debug'           = getWriteDebug        $inpGroups.'Write-Debug'
          'Get-ObjLisFromCsv'     = getObjLisFromCsv     $inpGroups.'Get-ObjLisFromCsv'       $delimiter
          'Get-Heading'           = getHeading           $inpGroups.'Get-Heading'             $indent
          'Get-ColHeaders'        = getColHeaders        $inpGroups.'Get-ColHeaders'          $indent
          'Get-ColHeadersLis'     = getColHeadersLis     $inpGroups.'Get-ColHeadersLis'       $indent
          'Get-2LisAsLine'        = get2LisAsLine        $inpGroups.'Get-2LisAsLine'          $indent
          'Get-StrLisFromObjLis'  = getStrLisFromObjLis  $inpGroups.'Get-StrLisFromObjLis'    $delimiter
          'Remove-ExtraLF'        = removeExtraLF        $inpGroups.'Remove-ExtraLF'    
          'Install-Module'        = installModule        $inpGroups.'Install-Module'
          'Start-MySleep'         = startMySleep         $inpGroups.'Start-MySleep'
    }
}
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'ps_utils' ${function:purelyWrap-Unit}