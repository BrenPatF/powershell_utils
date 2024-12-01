<#**************************************************************************************************
Name: Test-MergeLinkMDFiles.psm1        Author: Brendan Furey                      Date: 17-Nov-2024

Component package in the Powershell Markdown Utilities module MDUtils. The module has a utility to
create a combined markdown (MD) file from a set of constituent MD files listed in an input file. 
After merging the constituent files in order, the utility adds, after each heading, a link to any
parent heading and a list of links to any child headings. These internal links form a tree structure
that enables easy navigation for longer documents.

    GitHub: https://github.com/BrenPatF/powershell_utils

As well as the module file, there is an install script, an example script, and a unit test script.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

====================================================================================================
| Script (.ps1)           | Module (.psm1) |  Notes                                                |
|==================================================================================================|
|  Install-MDUtils        |                   Installer copies module to Powershell path           |
|-------------------------|------------------------------------------------------------------------|
|  Small-Multilevel       |                   Example script                                       |
|                         |------------------------------------------------------------------------|
|-------------------------|  MDUtils       |  Markdown utility functions                           |
|                         |--------------- |-------------------------------------------------------|
|                         |  TrapitUtils   |  Trapit unit testing utility functions                |
|                         |------------------------------------------------------------------------|
| *Test-MergeLinkMDFiles* |                   Unit test script                                     |
====================================================================================================

This file contains a unit test script for the MDUtils package.

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
Import-Module ..\..\Utils\Utils.psm1, ..\..\MDUtils\MDUtils.psm1, ..\..\TrapitUtils\TrapitUtils.psm1
$INP_FILE,          $OUT_MD_FILE = 
'.\ut_inp_file.txt',    '.\ut_out_file.md'
function purelyWrap-Unit($inpGroups) { # input scenario groups

    $inp_files = $inpGroups.'Input Files'
    [string[]]$outStringLis = @()
    [string[]]$inputFilesList = $inpGroups.'Input Files List'
    $inputFilesList | %{
        $fileName, $emptyYN = $_.Split('|')
        $outStringLis += $fileName
        $fileLines = @()
        $inp_files -match "^$fileName.*" | %{
            $fileLines += $_.Substring($fileName.length + 1)
        }
        If ($emptyYN -eq 'Y') {
            $capture = New-Item $fileName
        } Else {
            $fileLines | Out-File -FilePath $fileName -encoding utf8
            if($fileLines.length -gt 0) {
                Remove-ExtraLF $fileName
            }
        }
    }
    [string[]]$errMsg = @()
    [string[]]$retValue = @()
    [string[]]$mdLines = @()
    $outStringLis | Out-File -FilePath $INP_FILE -encoding utf8
    if($outStringLis.length -gt 0) {
        Remove-ExtraLF $INP_FILE
        try {
            $retValue = Merge-LinkMDFiles $INP_FILE $OUT_MD_FILE
            if($retValue -eq $null) {
                $retValue = @()
            }
            $mdLines = Get-Content -path $OUT_MD_FILE
            Start-Sleep -Milliseconds 100
            Remove-Item $OUT_MD_FILE
        } catch {
            [string[]]$errMsg = $_.Exception.Message
        }
        Start-Sleep -Milliseconds 100
        Remove-Item $INP_FILE
        $inputFilesList | %{
            $fileName, $emptyYN = $_.Split('|')
            Remove-Item $fileName
        }
    }
    [PSCustomObject]@{
          'Merged Output File' = $mdLines
          'Return Headings'    = $retValue
          'Error Message'      = $errMsg
    }
}
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'merge-linkmdfiles' ${function:purelyWrap-Unit}
