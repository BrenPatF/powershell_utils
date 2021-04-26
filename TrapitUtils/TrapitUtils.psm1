<#**************************************************************************************************
Name: Trapit-Utils.psm1                     Author: Brendan Furey                  Date: 05-Apr-2021

Component package in the Powershell Utilities module Trapit Utils. The module has utility functions
for unit testing following the Math Function Unit Testing design pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.

This utility module has two main entry point functions to facilitate the design pattern.

Write-UT_Template writes a template for the unit test scenarios JSON file based on two simple input
csv files holding the specific group/field structure for input and output groups. It performs the
'impure' reading and writing parts of the process, and calls a pure function, Get-UT_TemplateObject,
to do most of the logic. This was designed with the Functional Programming idea in mind that pure
functions are preferable to impure ones, and that we should try to organise our code accordingly. In
this way we can unit test the pure function more easily, while there is little complexity in the 
impure one, and it may not need explicit unit testing.

Test-Unit is a utility that is called as effectively the main function of any specific unit test
script. It reads the input JSON scenarios file, then loops over the scenarios making calls to a 
function passed in as a parameter from the calling script. The function acts as a 'pure' wrapper
around calls to the unit under test. It is 'externally pure' in the sense that it is deterministic,
and interacts externally only via parameters and return value. Where the unit under test reads 
inputs from file the wrapper writes them based on its parameters, and where the unit under test 
writes outputs to file the wrapper reads them and passes them out in its return value. Any file
writing is reverted before exit. Test-Unit is called as part of any unit test driver script,
including the one that tests Get-UT_TemplateObject, and is considered to be thereby tested
implicitly.

There is a unit test script for the pure function  Get-UT_TemplateObject, and there is an example
script which uses the impure function that calls it, and creates the template JSON file for it.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://github.com/BrenPatF/trapit_nodejs_tester#trapit

====================================================================================================
| Script (.ps1)               | Module (.psm1) |  Notes                                            |
|==================================================================================================|
|  Install-TrapitUtils        |                   Install script copies module to Powershell path  |
|-----------------------------|--------------------------------------------------------------------|
|  Show-Examples              |                |                                                   |
|-----------------------------| *Trapit-Utils* |  Trapit unit testing utility functions            |
|  Test-GetUT_TemplateObject  |----------------|---------------------------------------------------|
|                             |  Utils         |  General utility functions                        |
====================================================================================================

Trapit Utils package for unit testing following the Math Function Unit Testing design pattern, with
functions called by Show-Examples and Test-GetUT_TemplateObject scripts

**************************************************************************************************#>
Import-Module Utils
<#**************************************************************************************************

Write-UT_Template: Writes a template for the unit test scenarios JSON file used in the Math Function
                   Unit Testing design pattern (https://github.com/BrenPatF/trapit_nodejs_tester)

                   Construct inp/out csv and out json file names from stem; call function to get the
                   psobject structure; convert to json and write it

**************************************************************************************************#>
function Write-UT_Template($stem,              # filename stem
                           $delimiter = '|') { # delimiter

    $path = '.\' + $stem
    $csvInp = $path + '_inp.csv'
    $csvOut = $path + '_out.csv'
    $json = $path + '_temp.json' 

    Get-UT_TemplateObject (Get-ObjLisFromCsv $csvInp) (Get-ObjLisFromCsv $csvOut) $delimiter | ConvertTo-Json -depth 4 | Set-Content $json

}
<#**************************************************************************************************

Get-UT_TemplateObject: Gets a template in object form for the unit test scenarios JSON file used in
                       the Math Function Unit Testing design pattern
                       https://github.com/BrenPatF/trapit_nodejs_tester

                       Constructs object in required format from the input object lists

**************************************************************************************************#>
function Get-UT_TemplateObject($inpGroupLis,       # List of group, field pairs for input
                               $outGroupLis,       # List of group, field pairs for output
                               $delimiter = '|') { # delimiter

<#**************************************************************************************************

groupObjectFromLis: Takes either an input or an output group, returns meta and scenarios objects for
                    the group within outer object wrapper; special handling for empty group

**************************************************************************************************#>
    function groupObjectFromLis($groupLis) { # List of group, field pairs

        function nonEmptyObject($groupLis) { # List of group, field pairs

            $metaObj = New-Object -TypeName psobject
            $sceObj = New-Object -TypeName psobject

            $oldGroup = "oldGroup"
            $fieldLis = @()
            $groupLis | % {
                If ($_.group -ne $oldGroup) {
                    If ($fieldLis) {
                        $metaObj | Add-Member -MemberType NoteProperty -Name $oldGroup -Value $fieldLis
                        $sceObj | Add-Member -MemberType NoteProperty -Name $oldGroup -Value @($delimiter * ($fieldLis.length - 1))
                        $fieldLis = @()
                    }
                    $oldGroup = $_.group 
                }
                $fieldLis += $_.field
            }
            $metaObj | Add-Member -MemberType NoteProperty -Name $oldGroup -Value $fieldLis
            $sceObj | Add-Member -MemberType NoteProperty -Name $oldGroup -Value @($delimiter * ($fieldLis.length - 1))
            @{
                meta = $metaObj
                sce = $sceObj
            }
        }
        If ($groupLis) {
            nonEmptyObject($groupLis)
        } Else {
            @{
                meta = [PSCustomObject]@{}
                sce = [PSCustomObject]@{}
            }
        }
    }
    $inpGroupObject = groupObjectFromLis($inpGroupLis)
    $outGroupObject = groupObjectFromLis($outGroupLis)
    $metaObj = [PSCustomObject]@{
        title = 'title'
        delimiter = $delimiter
        inp = $inpGroupObject.meta
        out = $outGroupObject.meta
    }
    $sce_1Obj = [PSCustomObject]@{
        active_yn = 'Y'
        inp = $inpGroupObject.sce
        out = $outGroupObject.sce
    }
    $sceObj = [PSCustomObject]@{
        'scenario 1' = $sce_1Obj
    }
    [PSCustomObject]@{
        meta = $metaObj
        scenarios = $sceObj
    }
}
<#**************************************************************************************************

Test-Unit: Main unit testing function, called like this:

                Test-Unit '.\utils.json' '.\utils_out.json' ${function:purelyWrap-Unit}

           There is a simple call to a private function, main, passing the parameters received. This
           function main creates the output JSON file with the help of two functions:

           - $purelyWrapUnit is a function passed in from the client unit tester that returns an 
           object with result output groups consisting of lists of delimited strings
           - getUT_OutScenario is a local private function that takes an input scenario object and
           the output from the function above and returns the complete output scenario with groups
           containing both expected and actual result lists

**************************************************************************************************#>
function Test-Unit($inpFile,          # input file
                   $outFile,          # output file
                   $purelyWrapUnit) { # function that takes as input an object with lists of records 
                                      # by group, returning an object with lists of output records by
                                      # group

    <#**************************************************************************************************

    getUT_OutScenario: Gets unit test scenario output object by merging the actuals lists for each
                       group into the input object, as act, alongside the input lists, as exp

    **************************************************************************************************#>
    function getUT_OutScenario($inpScenario, # input scenario
                               $actObj) {    # object with lists of actuals for each output group

        $retObj = New-Object -TypeName psobject
        foreach ($o in $actObj.PSObject.Properties) {

            $grpName = $o.name
            $value = [PSCustomObject]@{
                                        exp = $inpScenario.out.$grpName
                                        act = $o.value
                                      }
            $retObj | Add-Member -MemberType NoteProperty -Name $grpName -Value $value

        }

        [PSCustomObject]@{
            inp = $inpScenario.inp
            out = $retObj
        }
    }
    <#**************************************************************************************************

    main: Main unit testing section

          Logic:
          - read the scenarios from JSON input file into an object
          - loop over active scenarios making a 'pure' call to function purelyWrapUnit passed in
              - pass in the scenario input value
              - pass the return value, along with the input scenario, to getUT_OutScenario
              - assign the return value to scenarios object, with key as the input scenario name
          - create object with properties meta from input JSON and scenarios from the calls 
          - convert the object to JSON and write to the output json file

    **************************************************************************************************#>
    function main($inpFile,          # input file
                  $outFile,          # output file
                  $purelyWrapUnit) { # function that takes scenario input value as input, returning actual output value

        $json = Get-Content $inpFile | Out-String | ConvertFrom-Json

        $scenarios = New-Object -TypeName psobject
        foreach ($s in $json.scenarios.PSObject.Properties) {

            if ($s.value.active_yn -ne 'N') {
                $scenarios | Add-Member -MemberType NoteProperty -Name $s.name -Value (getUT_OutScenario $s.value (&$purelyWrapUnit $s.value.inp))
            }
        }
        $outObj = New-Object -TypeName psobject
        $outObj | Add-Member -MemberType NoteProperty -Name meta -Value $json.meta
        $outObj | Add-Member -MemberType NoteProperty -Name scenarios -Value $scenarios

        $outObj | ConvertTo-Json -depth 6 | Set-Content $outFile
    }
    main $inpFile $outFile $purelyWrapUnit
}
