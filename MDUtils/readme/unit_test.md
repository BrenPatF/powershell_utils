## Unit Testing

### Unit Testing Prerequisites

The powershell package TrapitUtils is required to run the unit tests. This is a subproject of the same GitHub project as MDUtils, so if you have downloaded it, you will already have it. The module is referenced using a relative path, so that it does not need to be installed explicitly.

The powershell package includes an npm package to format the unit test output JSON file in HTML and/or text, but you need to have [Node.js](https://nodejs.org/en/download) installed to run it.

### Unit Testing Process

The package is tested using [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

At a high level the Math Function Unit Testing design pattern involves three main steps:

1. Create an input file containing all test scenarios with input data and expected output data for each scenario
2. Create a results object based on the input file, but with actual outputs merged in, based on calls to the unit under test
3. Use the results object to generate unit test results files formatted in HTML and/or text

<img src="png/HLS.png">

The first and third of these steps are supported by generic utilities that can be used in unit testing in any language. The second step uses a language-specific unit test driver utility.

#### Step 1: Create Input Scenarios File

##### Unit Test Wrapper Function

The diagram below shows the structure of the input and output of the wrapper function.

<img src="png/JSD-MDUtils.png">

From the input and output groups depicted we can construct CSV files with flattened group/field structures, and default values added, as follows (with `merge-linkmdfiles_inp.csv` left, `merge-linkmdfiles_out.csv` right):
<img src="png/groups - ut.png">

##### Scenario Category ANalysis (SCAN)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs. 

A useful approach to this can be to think in terms of categories of inputs, where we reduce large ranges to representative categories.  I explore this approach further in this article:

- [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html)

###### Generic Category Sets

As explained in the article mentioned above, it can be very useful to think in terms of generic category sets that apply in many situations.

!###### *Binary*

There are many situations where a category set splits into two opposing values such as Yes / No or True / False.

| Code | Description     |
|:----:|:----------------|
| Yes  | Yes / True etc. |
| No   | No / False etc. |

We apply this to:

- Special Characters
- Section Text

!###### *Multiplicity*

The generic category set of multiplicity is applicable very frequently, and we should check each of the relevant categories. In some cases we'll want to check Few / Many instance categories, but in this case we'll use None / One / Multiple.

| Code     | Description     |
|:--------:|:----------------|
| None     | No values       |
| One      | One value       |
| Multiple | Multiple values |

We apply this (with variations on categories) to:

- Component files
- Headings 
- Child links
- Parent links (None / One)
- Levels (One / Six)

###### Categories and Scenarios

After analysis of the possible scenarios in terms of categories and category sets, we can depict them on a Category Structure diagram:

<img src="png/CSD-MDUtils.png">

We can tabulate the results of the category analysis, and assign a scenario against each category set/category with a unique description.

In some cases a category in one category set can be tested by a scenario designed to test a category in another set. In this design pattern it's extremely cheap to duplicate the scenario dataset, as a dataset is just an element in a JSON file, and we do this in a number of cases. However, where it's very obvious that a category is tested implicitly by other scenarios, we can omit it from the list of scenarios, and we denote these cases using a dashed line around the category in the diagram above, and omit it from the JSON input file.

|  # | Category Set                | Category              | Scenario (* = implicitly tested via other scenarios) |
|---:|:----------------------------|:----------------------|:-----------------------------------------------------|
|  1 | File Multiplicity           | None                  | No file                                              |
|  2 | File Multiplicity           | One                   | One file                                             |
|  3 | File Multiplicity           | Multiple              | Multiple files                                       |
|  4 | Heading Multiplicity        | None                  | No heading                                           |
|  5 | Heading Multiplicity        | One                   | One heading                                          |
|  6 | Heading Multiplicity        | Multiple              | Multiple headings                                    |
|  7 | Child Link Multiplicity     | None                  | No child link                                        |
|  8 | Child Link Multiplicity     | One                   | One child link                                       |
|  9 | Child Link Multiplicity     | Multiple              | Multiple child links                                 |
| 10 | Parent Link Multiplicity    | None                  | No parent link                                       |
| 11 | Parent Link Multiplicity    | One                   | One parent link                                      |
| 12 | Level Multiplicity          | None                  | One level                                            |
| 13 | Level Multiplicity          | Six                   | Six levels                                           |
| 14 | Hash Increment              | One                   | One hash increment                                   |
| 15 | Hash Increment              | Two                   | Two hash increment                                   |
| 16 | Hash Increment              | Three                 | Three hash increment                                 |
| 17 | Root: Child? Incidence      | Root 1:N              | Root 1:N                                             |
| 18 | Root: Child? Incidence      | Root 1:Y, Root 2:Y    | Root 1:Y, Root 2:Y                                   |
| 19 | Root: Child? Incidence      | Root 1:Y, Root 2:N    | Root 1:Y, Root 2:N                                   |
| 20 | Root: Child? Incidence      | Root 1:N, Root 2:Y    | Root 1:N, Root 2:Y                                   |
| 21 | Root: Child? Incidence      | Root 1:N, Root 2:N    | Root 1:N, Root 2:N                                   |
|  * | Duplicate Headings: Linked? | None                  | (No duplicates)*                                     |
| 22 | Duplicate Headings: Linked? | Dupe 1:Y, Dupe 2:Y    | Dupe 1:Y, Dupe 2:Y                                   |
| 23 | Duplicate Headings: Linked? | Dupe 1:Y, Dupe 2:N    | Dupe 1:Y, Dupe 2:N                                   |
| 24 | Duplicate Headings: Linked? | Dupe 1:N, Dupe 2:Y    | Dupe 1:N, Dupe 2:Y                                   |
| 25 | Duplicate Headings: Linked? | Dupe 1:N, Dupe 2:N    | Dupe 1:N, Dupe 2:N                                   |
| 26 | Duplicate Headings: Linked? | Dupe 1, 2, 3:Y        | Dupe 1, 2, 3:Y                                       |
| 27 | Special Characters          | In Heading            | In heading                                           |
|  * | Special Characters          | Not in Heading        | (Not in heading)*                                    |
| 28 | Delink Flag                 | First in #-prefix     | First in #-prefix                                    |
| 29 | Delink Flag                 | Non-first in #-prefix | Non-first in #-prefix                                |
| 30 | Delink Flag                 | In Heading Text       | In heading text                                      |
| 31 | Delink Flag                 | First in Non-Heading  | First in non-heading                                 |
|  * | Section Text                | Present               | (Present)*                                           |
| 32 | Section Text                | Not Present           | Not present                                          |
| 33 | Anomaly                     | Missing File          | Missing file                                         |
| 34 | Anomaly                     | Empty File            | Empty file                                           |
| 35 | Anomaly                     | Seven Hashes          | Seven hashes                                         |

From the scenarios identified we can construct the following CSV file (`merge-linkmdfiles_sce.csv`), taking the category set and scenario columns, and adding an initial value for the active flag:

<img src="png/scenarios - ut.png">

The API can be run with the following powershell in the folder of the CSV files:

!###### *Format-MergeLinkMDFiles.ps1*
```powershell
Import-Module ..\..\TrapitUtils\TrapitUtils.psm1
Write-UT_Template 'merge-linkmdfiles' '|'
```
This creates the template JSON file, merge-linkmdfiles_temp.json, which contains an element for each of the scenarios, with the appropriate category set and active flag, with a single record in each group with default values from the groups CSV files. The template file is then updated manually with data appropriate to each scenario.

#### Step 2: Create Results Object

Step 2 requires the writing of a wrapper function that is passed into a unit test library function, Test-Unit, via the entry point API,  `Test-Format`. Test-Unit reads the input JSON file, calls the wrapper function for each scenario, and writes the output JSON file with the actual results merged in along with the expected results. 

!##### purelyWrap-Unit
This is a listing of the wrapper function, which is included in the script Test-MergeLinkMDFiles.ps1 and passed as a parameter to Test-Format.

```powershell
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
```

#### Step 3: Format Results

Step 3 involves formatting the results contained in the JSON output file from step 2, via the JavaScript formatter:

```powershell
    node ($npmRoot + '/node_modules/trapit/externals/format-external-file') $jsonFile
```

This step is executed within the TrapitUtils entry point API, `Test-Format`.

#### Unit Test Driver Script

Unit testing is executed through a driver script, Test-MergeLinkMDFiles.ps1, that contains the wrapper function and makes a call to the TrapitUtils library function `Test-Format`. This calls Test-Unit to create the output JSON file, and then calls the Javascript formatter, which writes the formatted results files to a subfolder in the script folder, with name based on the title, returning a summary of the results. 

`Test-Format` has parameters:

* `[string]$utRoot`: unit test root folder
* `[string]$npmRoot`: parent folder of the JavaScript node_modules npm root folder
* `[string]$stemInpJSON`: input JSON file name stem
* `[ScriptBlock]$purelyWrapUnit`: function to process unit test for a single scenario

Return value:

* `[string]`: summary of results

!###### Test-MergeLinkMDFiles.ps1

```powershell
Import-Module ..\..\Utils\Utils.psm1, ..\..\MDUtils\MDUtils.psm1, ..\..\TrapitUtils\TrapitUtils.psm1
function purelyWrap-Unit($inpGroups) { # input scenario groups
    ...
}
Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'merge-linkmdfiles' ${function:purelyWrap-Unit}
```
This script creates a results subfolder, with results in text and HTML formats, in the script folder, and outputs the following summary:

```
Results summary for file: ./merge-linkmdfiles_out.json
======================================================

File:          merge-linkmdfiles_out.json
Title:         Merge-LinkMDFiles
Inp Groups:    2
Out Groups:    4
Tests:         35
Fails:         0
Folder:        merge-linkmdfiles
```

### Unit Test Results

Here we show screenshots of the scenario-level summary of results, and the results page for scenario 3.

You can review the full HTML formatted unit test results here:

- [Unit Test Report: Merge-LinkMDFiles](http://htmlpreview.github.io/?https://github.com/BrenPatF/powershell_utils/blob/master/MDUtils/unit_test/merge-linkmdfiles/merge-linkmdfiles.html)

Next we show the scenario-level summary of results, followed by the results page for scenario 3.

##### Unit Test Report - Merge-LinkMDFiles

Here is the results summary in HTML format:
<img src="png/Unit Test Report.png">

##### Scenario 3: Multiple files [Category Set: File Multiplicity]

Here is the results page for scenario 3 in HTML format:
<img src="png/scenario 3.png">
