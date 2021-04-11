Import-Module Utils
Import-Module Trapit-Utils -Force
$DELIM = ';'
function getGroupFieldObjLis($strLis) {
    $objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += @{group = $fields[0]; field = $fields[1]}
    }
    $objLis
}
function getGroupFieldStrLis($obj) { # object has a key and a value that is an array of strings
    $strLis = @()
    foreach ($o in $obj.PSObject.Properties) {
        foreach ($v in $o.value) {
            $strLis += $o.name + $DELIM + $v
        }
    }
    ,$strLis
}
function purelyWrap-Unit($callScenario) {

    $scalars = $callScenario.inp.'Scalars'
    if ($scalars.length -eq 0) {
        $utObj = Get-UT_TemplateObject (getGroupFieldObjLis $callScenario.inp.'Input Group') (getGroupFieldObjLis $callScenario.inp.'Output Group')
    } else {
        $utObj = Get-UT_TemplateObject (getGroupFieldObjLis $callScenario.inp.'Input Group') (getGroupFieldObjLis $callScenario.inp.'Output Group') $scalars[0]
    }
    $actObj = [PSCustomObject]@{
                    'Meta Input Group'      = getGroupFieldStrLis     $utObj.meta.inp
                    'Meta Output Group'     = getGroupFieldStrLis     $utObj.meta.out
                    'Scenario Input Group'  = getGroupFieldStrLis     $utObj.scenarios.'scenario 1'.inp
                    'Scenario Output Group' = getGroupFieldStrLis     $utObj.scenarios.'scenario 1'.out
              }
    Get-UT_OutScenario $callScenario $actObj
}
<#**************************************************************************************************

Main section: Every testing main section should be similar to this:

              - read the scenarios from JSON file into an object
              - loop over active scenarios making a 'pure' call to local function purelyWrap-Unit
                  - pass in the input scenario value
                  - assign the return value to scenarios object, with key as the input scenario name
              - call utility passing input object and scenarios to write the output JSON file

**************************************************************************************************#>
$json = Get-Content '.\get_ut_template_object.json' | Out-String | ConvertFrom-Json
$scenarios = New-Object -TypeName psobject
foreach ($s in $json.scenarios.PSObject.Properties) {
    if ($s.value.active_yn -eq 'Y') {
        $scenarios | Add-Member -MemberType NoteProperty -Name $s.name -Value (purelyWrap-Unit $s.value $delimiter)
    }
}
Write-UT_OutJson $json $scenarios '.\get_ut_template_object_out.json'