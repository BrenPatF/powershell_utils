## API - TrapitUtils
```powershell
Import-Module TrapitUtils
```

### Write-UT_Template
```
Write-UT_Template($stem, $delimiter)
```
Writes a unit testing template JSON file in the format of the Math Function Unit Testing design pattern, with parameters:

* `$stem`: file name stem, 
* `$delimiter`: delimiter; default '|'

There are two mandatory input group structure CSV files, with header 'Group, Field, Value':
* `$stem`_inp.csv: list of group, field, value triples for input
* `$stem`_out.csv: list of group, field, value triples for output

and there is an optional scenario list CSV file, with header 'Category Set, Scenario, Active':
* `$stem`_sce.csv: list of category set, scenario, active triples for output


The function writes an output JSON file:
* `$stem`_temp.json

If there is a scenario list CSV file present, then the output file will contain a template scenario for each record; if not the output file will have a single template scenario with name 'scenario 1'. Each group has a single record with field values taken from the group CSV files. The records need to be manually updated (and added or subtracted) to reflect input and expected output values for the scenario being tested.

### Get-UT_TemplateObject
```
Get-UT_TemplateObject($inpGroupLis, $outGroupLis, $delimiter, $sceLis)
```
Gets an object with the same structure as the unit testing template JSON file, from input lists of objects for input and output groups, with parameters:

* `$inpGroupLis`: list of group, field, value triples for input
* `$outGroupLis`: list of group, field, value triples for output
* `$delimiter`: delimiter; default '|'
* `$sceLis`: list of category set, scenario, active triples

This is a pure function that is called by Write-UT_Template, which writes its return value to file in JSON format.

### Test-Unit
```
Test-Unit($inpFile, $outFile, $purelyWrapUnit)
```
Unit tests a unit using the Math Function Unit Testing design pattern with input data read from a JSON file, and output results written to an output JSON file, with parameters:

* `$inpFile`: input JSON file, with input and expected output data
* `$outFile`: output JSON file, with input, expected and actual output data
* `$purelyWrapUnit`: function to process unit test for a single scenario, passed in from test script, described below

#### $purelyWrapUnit
```
$purelyWrapUnit($inpGroups)
```
Processes unit test for a single scenario, taking inputs as an object with input group data, making calls to the unit under test, and returning the actual outputs as an object with output group data, with parameters:

* `$inpGroups`: object containing input groups with group name as key and list of delimited input records as value, of form:
                [PSCustomObject]@{
                    inpGroup1 = [rec1, rec2,...]
                    inpGroup2 = [rec1, rec2,...]
                    ...
                }
* `Return value`: object containing output groups with group name as key and list of delimited actual output records as value, of form:
                [PSCustomObject]@{
                    outGroup1 = [rec1, rec2,...]
                    outGroup2 = [rec1, rec2,...]
                    ...
                }

This function acts as a 'pure' wrapper around calls to the unit under test. It is 'externally pure' in the sense that it is deterministic, and interacts externally only via parameters and return value. Where the unit under test reads inputs from file the wrapper writes them based on its parameters, and where the unit under test writes outputs to file the wrapper reads them and passes them out in its return value. Any file writing is reverted before exit.

### Test-Format
```
Test-Format($psScript, $npmRoot)
```
Calls a powershell unit test driver script, then calls the JavaScript formatter, which writes the formatted results files to a subfolder in the script folder, based on the title, returning a summary. It has parameters:

* `$psScript`: full name of the powershell unit test driver script
* `$npmRoot`: parent folder of the JavaScript node_modules npm root folder

### Test-FormatFolder
```
Test-FormatFolder($psScriptLis, $jsonFolder, $npmRoot)
```
Calls each of a list of powershell unit test driver scripts, then calls the JavaScript formatter, which writes the formatted results files to a subfolder within a results folder, based on the titles, returning a summary. It has parameters:

* `$psScript`: array of full names of the unit test driver scripts
* `$jsonFolder`: folder where JSON files are copied, and results subfolders placed
* `$npmRoot`: parent folder of the JavaScript node_modules npm root folder

