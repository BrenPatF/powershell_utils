# Trapit - PowerShell Unit Testing Utilities Module
<img src="png/mountains.png">

> The Math Function Unit Testing design pattern, implemented in PowerShell

:detective: :hammer_and_wrench:

This module supports [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html), a design pattern that can be applied in any language, and is here implemented in PowerShell. The module name is derived from 'TRansactional API Testing' (TRAPIT), and the 'unit' should be considered to be a transactional unit. The pattern avoids microtesting, is data-driven, and fully supports multi-scenario testing and refactoring.

The PowerShell Trapit module provides a generic driver program for PowerShell unit testing, with test data read from an input JSON file, results written to an output JSON file, and all specific test code contained in a callback function passed to the driver function.

Unit test results are formatted by a JavaScript program that takes the JSON output results file as its input, [Trapit - JavaScript Unit Tester/Formatter](https://github.com/BrenPatF/trapit_nodejs_tester), and renders the results in HTML and text formats.

The module also provides two utilities for more general use:

- One generates a template for the JSON input file used by the design pattern, based on simple input CSV files, and this can be used for unit testing in any language

- The other automates the running of Oracle PL/SQL unit tests and formatting of the results via the JavaScript formatter

This blog post, [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html) provides guidance on effective selection of scenarios for unit testing.

There is an extended Usage section below that illustrates the use of the PowerShell utilities, along with the JavaScript program, for unit testing, by means of two examples. The Unit Testing section also uses them in testing the pure function, Get-UT_TemplateObject, which is called by the API that generates the template JSON file.

# In This README...
[&darr; Background](#background)<br />
[&darr; Usage](#usage)<br />
[&darr; API](#api)<br />
[&darr; Installation](#installation)<br />
[&darr; Unit Testing](#unit-testing)<br />
[&darr; Folder Structure](#folder-structure)<br />
[&darr; See Also](#see-also)<br />

## Background
[&uarr; In This README...](#in-this-readme)<br />

I explained the concepts for the unit testing design pattern in relation specifically to database testing in a presentation at the Oracle User Group Ireland Conference in March 2018:

- [The Database API Viewed As A Mathematical Function: Insights into Testing](https://www.slideshare.net/brendanfurey7/database-api-viewed-as-a-mathematical-function-insights-into-testing)

I later named the approach [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html) when I applied it in JavaScript and wrote a JavaScript program to format results both in plain text and as HTML pages:
- [Trapit - JavaScript Unit Tester/Formatter](https://github.com/BrenPatF/trapit_nodejs_tester)

The module also allowed for the formatting of results obtained from testing in languages other than JavaScript by means of an intermediate output JSON file. In 2021 I developed a powershell module that included a utility to generate a template for the JSON input scenarios file required by the design pattern:
- [Powershell Trapit Unit Testing Utilities module.](https://github.com/BrenPatF/powershell_utils/tree/master/TrapitUtils)

Also in 2021 I developed a systematic approach to the selection of unit test scenarios:
- [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html)

In early 2023 I extended both the the JavaScript results formatter, and the powershell utility to incorporate Category Set as a scenario attribute. Both utilities support use of the design pattern in any language, while the unit testing driver utility is language-specific and is currently available in Powershell, JavaScript, Python and Oracle PL/SQL versions.
## Usage
[&uarr; In This README...](#in-this-readme)<br />
[&darr; General Usage](#general-usage)<br />
[&darr; Example 1 - HelloWorld](#example-1---helloworld)<br />
[&darr; Example 2 - ColGroup](#example-2---colgroup)<br />

As noted above, the JavaScript module allows for unit testing of JavaScript programs and also the formatting of test results for both JavaScript and non-JavaScript programs. Similarly, the PowerShell module mentioned allows for unit testing of PowerShell programs, and also the generation of the JSON input scenarios file template for testing in any language.

In this section we'll start by describing the steps involved in [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html) at an overview level. This will show how the generic PowerShell and JavaScript utilities fit in alongside the language-specific driver utilities.

Then we'll show how to use the design pattern in unit testing PowerShell programs by means of two simple examples.

### General Usage
[&uarr; Usage](#usage)<br />
[&darr; General Description](#general-description)<br />
[&darr; Unit Testing Process](#unit-testing-process)<br />
[&darr; Unit Test Results](#unit-test-results)<br />

At a high level the [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html) involves three main steps:

1. Create an input file containing all test scenarios with input data and expected output data for each scenario
2. Create a results object based on the input file, but with actual outputs merged in, based on calls to the unit under test
3. Use the results object to generate unit test results files formatted in HTML and/or text

<img src="png/HLS.png">

#### General Description
[&uarr; General Usage](#general-usage)<br />

The first and third of these steps are supported by generic utilities that can be used in unit testing in any language. The second step uses a language-specific unit test driver utility.

For non-JavaScript programs the results object is materialized using a library package in the relevant language. The diagram below shows how the processing from the input JSON file splits into two distinct steps:
- First, the output results object is created using the external library package which is then written to a JSON file
- Second, a script from the Trapit JavaScript library package is run, passing in the name of the output results JSON file

This creates a subfolder with name based on the unit test title within the file, and also outputs a summary of the results. The processing is split between three code units:
- Test Unit: External library function that drives the unit testing with a callback to a specific wrapper function
- Specific Test Package: This has a 1-line main program to call the library driver function, passing in the callback wrapper function
- Unit Under Test (API): Called by the wrapper function, which converts between its specific inputs and outputs and the generic version used by the library package

<img src="png/PFD-Ext.png">

In the first step the external program creates the output results JSON file, while in the second step the file is read into an object by the Trapit library package, which then formats the results.

#### Unit Testing Process
[&uarr; General Usage](#general-usage)<br />
[&darr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file)<br />
[&darr; Step 2: Create Results Object](#step-2-create-results-object)<br />
[&darr; Step 3: Format Results](#step-3-format-results)<br />

This section details the three steps involved in following [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html).

##### Step 1: Create Input Scenarios File
[&uarr; Unit Testing Process](#unit-testing-process)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function)<br />
[&darr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan)<br />
[&darr; Creating the Input Scenarios File](#creating-the-input-scenarios-file)<br />

Step 1 requires analysis to determine the extended signature for the unit under test, and to determine appropriate scenarios to test.

It may be useful during the analysis phase to create two diagrams, one for the extended signature:
- JSON Structure Diagram: showing the groups with their fields for input and output

and another for the category sets and categories:
- Category Structure Diagram: showing the category sets identified with their categories

You can see examples of these diagrams later in this document: [JSON Structure Diagram](#unit-test-wrapper-function-2) and [Category Structure Diagram](#scenario-category-analysis-scan-2), and schematic versions in the next two subsections.

###### Unit Test Wrapper Function
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file)<br />

Here is a schematic version of a JSON structure diagram, which in a real instance will  in general have multiple input and output groups, each with multiple fields:

<img src="png/JSD-Example.png">

Each group in the diagram corresponds to a property within the $inpGroups input object or $outGroups return value object of the wrapper function, and contains an array of the group records stored as delimited strings.

```powershell
function purelyWrap-Unit([PSCustomObject]$inpGroups) { # input scenario groups
    ...
    [PSCustomObject]$outGroups
}
```

###### Scenario Category ANalysis (SCAN)
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file)<br />

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach can be to think in terms of categories of inputs, where we reduce large ranges to representative categories, an idea I explore in this article:

- [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html)

Here is a schematic version of a category set diagram, which in a real instance will  in general have multiple category sets, each with multiple categories:

<img src="png/CSD-Example.png">

Each category i-j in the diagram corresponds to a scenario j for category set i.

###### Creating the Input Scenarios File
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file)<br />

The results of the analysis can be summarised in three CSV files which the first API in this PowerShell package uses as inputs to create a template for the JSON file.

The PowerShell API, `Write-UT_Template` creates a template for the JSON file, with the full meta section, and a set of template scenarios having name as scenario key, a category set attribute, and zero or more records with default values for each input and output group. The API takes as inputs three CSV files:
  - `stem`\_inp.csv: list of group, field, values tuples for input
  - `stem`\_out.csv: list of group, field, values tuples for output
  - `stem`\_sce.csv: scenario triplets - (Category set, scenario name, active flag); this file is optional

In the case where a scenarios file is present, each group has zero or more records with field values taken from the group CSV files, with a record for each value column present where at least one value is not null for the group. The template scenario represents a kind of prototype scenario, where records may be manually updated (and added or subtracted) to reflect input and expected output values for the actual scenario being tested.

The API can be run with the following PowerShell in the folder of the CSV files:

###### Format-JSON-Stem.ps1
```powershell
Import-Module TrapitUtils
Write-UT_Template 'stem' '|' 'title'
```
This creates the template JSON file, `stem`\_temp.json based on the CSV files having prefix `stem` and using the field delimiter '|', and including the unit test title passed. The PowerShell API can be used for testing in any language.

The template file is then updated manually with data appropriate to each scenario.

##### Step 2: Create Results Object
[&uarr; Unit Testing Process](#unit-testing-process)<br />

Step 2 requires the writing of a wrapper function that is passed into a unit test library function, Test-Unit, via the entry point API,  `Test-Format`. Test-Unit reads the input JSON file, calls the wrapper function for each scenario, and writes the output JSON file with the actual results merged in along with the expected results.

##### purelyWrap-Unit
```powershell
function purelyWrap-Unit([PSCustomObject]$inpGroups) { # input scenario groups
    ...
    [PSCustomObject]$outGroups
}
```

The test driver API,  `Test-Format`, is language-specific, and this one is for testing PowerShell programs. Equivalents exist under the same GitHub account (BrenPatF) for JavaScript, Python and Oracle PL/SQL at present.

##### Step 3: Format Results
[&uarr; Unit Testing Process](#unit-testing-process)<br />

Step 3 involves formatting the results contained in the JSON output file from step 2, via the JavaScript formatter, and this step can be combined with step 2 for convenience.

- `Test-Format` is the function from the TrapitUtils PowerShell package that calls the main test driver function that contains the wrapper function, then passes the output JSON file name to the JavaScript formatter and outputs a summary of the results. It takes as parameters:

    - `[String]$utRoot`: unit test root folder
    - `[String]$npmRoot`: parent folder of the JavaScript node_modules npm root folder
    - `[String]$stemInpJSON`: input JSON file name stem
    - `[ScriptBlock]$purelyWrapUnit`: function to process unit test for a single scenario

    with return value:

    - `[String]`: summary of results

##### Test-Stem.ps1
```powershell
Import-Module TrapitUtils
function purelyWrap-Unit([PSCustomObject]$inpGroups) { # input scenario groups
    ...
    [PSCustomObject]$outGroups
}
Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'stem' ${function:purelyWrap-Unit}
```

#### Unit Test Results
[&uarr; General Usage](#general-usage)<br />
[&darr; Unit Test Report - Scenario List](#unit-test-report---scenario-list)<br />
[&darr; Unit Test Report - Scenario Pages](#unit-test-report---scenario-pages)<br />

The script above creates a results subfolder, with results in text and HTML formats, in the script folder, and outputs a summary of the following form:

```
Results summary for file: [MY_PATH]/stem_out.json
=================================================

File:          stem_out.json
Title:         [Title]
Inp Groups:    [#Inp Groups]
Out Groups:    [#Out Groups]
Tests:         [#Tests]
Fails:         [#Fails]
Folder:        [Folder]
```

Within the results subfolder there is a text file containing a list of summary results at scenario level, followed by the detailed results for each scenario. In addition there are files providing the results in HTML format.

##### Unit Test Report - Scenario List
[&uarr; Unit Test Results](#unit-test-results)<br />

The scenario list page lists, for each scenario:

- \# - the scenario index
- Category Set - the category set applying to the scenario
- Scenario - a description of the scenario
- Fails (of N) - the number of groups failing, with N being the total number of groups
- Status - SUCCESS or FAIL

The scenario field is a hyperlink to the individual scenario page.

##### Unit Test Report - Scenario Pages
[&uarr; Unit Test Results](#unit-test-results)<br />

The page for each scenario has the following schematic structure:
```
SCENARIO i: Scenario [Category Set: (category set)]
  INPUTS
    For each input group: [Group name] - a heading line followed by a list of records
      For each field: Field name
      For each record: 1 line per record, with record number followed by:
        For each field: Field value for record
  OUTPUTS
    For each output group: [Group name] - a heading line followed by a list of records
      For each field: Field name
      For each record: 1 line per record, with record number followed by:
        For each field: Field expected value for record
        For each field: Field actual value for record (only if any actual differs from expected)
    Group status - #fails of #records: SUCCESS / FAIL
Scenario status - #fails of #groups: SUCCESS / FAIL
```
### Example 1 - HelloWorld
[&uarr; Usage](#usage)<br />
[&darr; Example Description](#example-description)<br />
[&darr; Unit Testing Process](#unit-testing-process-1)<br />
[&darr; Unit Test Results](#unit-test-results-1)<br />

The first example is a version of the 'Hello World' program traditionally used as a starting point in learning a new programming language. This is useful as it shows the core structures involved in following the design pattern with a minimalist unit under test.

#### Example Description
[&uarr; Example 1 - HelloWorld](#example-1---helloworld)<br />

This is a pure function form of Hello World program, returning a value rather than writing to screen itself. It is of course trivial, but has some interest as an edge case with no inputs and extremely simple JSON input structure and test code.
##### HelloWorld.psm1
```powershell
function Write-HelloWorld {
    'Hello World!'
}
```
There is a main script that shows how the function might be called outside of unit testing, run from the examples folder:
##### Show-HelloWorld.ps1
```powershell
Using Module './HelloWorld.psm1'
Write-HelloWorld
```
This can be called from a command window in the examples folder (in PowerShell 7, in earlier versions it may need to be run from the subfolder):

```powershell
$ ./helloworld/Show-HelloWorld
```
with output to console:
```
Hello World!
```
#### Unit Testing Process
[&uarr; Example 1 - HelloWorld](#example-1---helloworld)<br />
[&darr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-1)<br />
[&darr; Step 2: Create Results Object](#step-2-create-results-object-1)<br />
[&darr; Step 3: Format Results](#step-3-format-results-1)<br />

##### Step 1: Create Input Scenarios File
[&uarr; Unit Testing Process](#unit-testing-process-1)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function-1)<br />
[&darr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan-1)<br />
[&darr; Creating the Input Scenarios File](#creating-the-input-scenarios-file-1)<br />

###### Unit Test Wrapper Function
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-1)<br />

Here is a diagram of the input and output groups for this example:

<img src="png/JSD-HW.png">

From the input and output groups depicted we can construct CSV files with flattened group/field structures, and default values added, as follows (with `helloworld_inp.csv` left, `helloworld_out.csv` right):
<img src="png/groups - helloworld.png">

###### Scenario Category ANalysis (SCAN)
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-1)<br />

The Category Structure diagram for the HelloWorld example is of course trivial:

<img src="png/CSD-HW.png">

It has just one scenario, with its input being void:

|  # | Category Set | Category | Scenario |
|---:|:-------------|:---------|:---------|
|  1 | Global       | No input | No input |

From the scenarios identified we can construct the following CSV file (`helloworld_sce.csv`), taking the category set and scenario columns, and adding an initial value for the active flag:

<img src="png/scenarios - helloworld.png">

###### Creating the Input Scenarios File
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-1)<br />

The API to generate a template JSON file can be run with the following PowerShell script in the folder of the CSV files:

###### Format-JSON-HelloWorld.ps1
```powershell
Import-Module TrapitUtils
Write-UT_Template 'helloworld' '|' 'Hello World - Powershell'
```
This creates the template JSON file, helloworld_temp.json, which contains an element for each of the scenarios, with the appropriate category set and active flag. In this case there is a single scenario, with empty input, and a single record in the output group with the default value from the output groups CSV file. Here is the complete file:

##### helloworld_temp.json
```js
{
  "meta": {
    "title": "Hello World - Powershell",
    "delimiter": "|",
    "inp": {},
    "out": {
      "Group": [
        "Greeting"
      ]
    }
  },
  "scenarios": {
    "No input": {
      "active_yn": "Y",
      "category_set": "Global",
      "inp": {},
      "out": {
        "Group": [
          "Hello World!"
        ]
      }
    }
  }
}
```

##### Step 2: Create Results Object
[&uarr; Unit Testing Process](#unit-testing-process-1)<br />

Step 2 requires the writing of a wrapper function that is passed into a unit test library function, Test-Unit, via the entry point API,  `Test-Format`. Test-Unit reads the input JSON file, calls the wrapper function for each scenario, and writes the output JSON file with the actual results merged in along with the expected results.

Here we use a lambda expression as the wrapper function is so simple:

###### Wrapper Function - Lambda Expression
```powershell
{ param($inpGroups) [PSCustomObject]@{'Group' = [String[]]@(Write-HelloWorld)} }
```

This lambda expression is included in the script Test-HelloWorld.ps1 and passed as a parameter to Test-Format.

##### Step 3: Format Results
[&uarr; Unit Testing Process](#unit-testing-process-1)<br />

Step 3 involves formatting the results contained in the JSON output file from step 2, via the JavaScript formatter, and this step can be combined with step 2 for convenience.

- `Test-Format` is the function from the TrapitUtils PowerShell package that calls the main test driver function, then passes the output JSON file name to the JavaScript formatter and outputs a summary of the results.

###### Test-HelloWorld.ps1
```powershell
Using Module './HelloWorld.psm1'
Import-Module TrapitUtils

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../../TrapitUtils') 'helloworld' `
            { param($inpGroups) [PSCustomObject]@{'Group' = [String[]]@(Write-HelloWorld)} }
```
This script contains the wrapper function (here a lambda expression), passing it in a call to the TrapitUtils library function Test-Format.

#### Unit Test Results
[&uarr; Example 1 - HelloWorld](#example-1---helloworld)<br />
[&darr; Unit Test Report: Hello World](#unit-test-report-hello-world)<br />
[&darr; Scenario 1: No input](#scenario-1-no-input)<br />

The unit test script creates a results subfolder, with results in text and HTML formats, in the script folder, and outputs the following summary:

```
Results summary for file: [MY_PATH]/powershell_utils/TrapitUtils/examples/helloworld/helloworld_out.json
========================================================================================================

File:          helloworld_out.json
Title:         Hello World - Powershell
Inp Groups:    0
Out Groups:    2
Tests:         1
Fails:         0
Folder:        hello-world---powershell
```

##### Unit Test Report: Hello World
[&uarr; Unit Test Results](#unit-test-results-1)<br />

Here we show the scenario-level summary of results for this example, and also show the detail for the only scenario.

You can review the HTML formatted unit test results here:

- [Unit Test Report: Hello World](http://htmlpreview.github.io/?https://github.com/BrenPatF/powershell_utils/blob/master/TrapitUtils/examples/helloworld/hello-world---powershell/hello-world---powershell.html)


This is the summary page in text format.

```
Unit Test Report: Hello World - Powershell
==========================================

      #    Category Set  Scenario  Fails (of 2)  Status
      ---  ------------  --------  ------------  -------
      1    Global        No input  0             SUCCESS

Test scenarios: 0 failed of 1: SUCCESS
======================================
Tested: 2023-04-09 14:43:33, Formatted: 2023-04-09 14:43:33
```

##### Scenario 1: No input
[&uarr; Unit Test Results](#unit-test-results-1)<br />

This is the scenario page in text format, with only one scenario.

```
SCENARIO 1: No input [Category Set: Global] {
=============================================
   INPUTS
   ======
   OUTPUTS
   =======
      GROUP 1: Group {
      ================
            #  Greeting
            -  ------------
            1  Hello World!
      } 0 failed of 1: SUCCESS
      ========================
      GROUP 2: Unhandled Exception: Empty as expected: SUCCESS
      ========================================================
} 0 failed of 2: SUCCESS
========================
```
Note that the second output group, 'Unhandled Exception', is not specified in the CSV file: In fact, this is generated by the Test-Unit API itself in order to capture any unhandled exception.
### Example 2 - ColGroup
[&uarr; Usage](#usage)<br />
[&darr; Example Description](#example-description-1)<br />
[&darr; Unit Testing Process](#unit-testing-process-2)<br />
[&darr; Unit Test Results](#unit-test-results-2)<br />

The second example, 'ColGroup', is larger and intended to show a wider range of features, but without too much extraneous detail.

#### Example Description
[&uarr; Example 2 - ColGroup](#example-2---colgroup)<br />

This example involves a class with a constructor function that reads in a CSV file and counts instances of distinct values in a given column. The constructor function appends a timestamp and call details to a log file. The class has methods to list the value/count pairs in several orderings.

##### ColGroup.psm1 (skeleton)
```powershell
Import-Module Utils
...
Class ColGroup {
    ...
}
```

There is a main script that shows how the class might be called outside of unit testing:

##### Show-ColGroup.ps1
```powershell
Using Module './ColGroup.psm1'
$INPUT_FILE, $DELIM, $COL = ($PSScriptRoot + '/fantasy_premier_league_player_stats.csv'), ',', 'team_name'

$grp = [ColGroup]::New($INPUT_FILE, $DELIM, $COL)

$grp.WriteList('(as is)', $grp.ListAsIs())
$grp.WriteList('key',     $grp.SortByKey())
$grp.WriteList('value',   $grp.SortByValue())
```
This can be called from a command window in the examples folder (in PowerShell 7, in earlier versions it may need to be run from the subfolder):

```powershell
$ ./colgroup/Show-ColGroup
```
with output to console:

```
Counts sorted by (as is)
========================
Team         #apps
-----------  -----
Man City      1099
Southampton   1110
Stoke City    1170
...

Counts sorted by key
====================
Team         #apps
-----------  -----
Arsenal        534
Aston Villa    685
Blackburn       33
...
Counts sorted by value
======================
Team         #apps
-----------  -----
Wolves          31
Blackburn       33
Bolton          37
...
```
and to log file, fantasy_premier_league_player_stats.csv.log:
```
2023-04-10 08:02:43: File [MY_PATH]\TrapitUtils\examples\colgroup\fantasy_premier_league_player_stats.csv, delimiter ',', column team_name
```

The example illustrates how a wrapper function can handle `impure` features of the unit under test:
- Reading input from file
- Writing output to file

...and also how the JSON input file can allow for nondeterministic outputs giving rise to deterministic test outcomes:
- By using regex matching for strings including timestamps
- By using number range matching and converting timestamps to epochal offsets (number of units of time since a fixed time)

#### Unit Testing Process
[&uarr; Example 2 - ColGroup](#example-2---colgroup)<br />
[&darr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-2)<br />
[&darr; Step 2: Create Results Object](#step-2-create-results-object-2)<br />
[&darr; Step 3: Format Results](#step-3-format-results-2)<br />

##### Step 1: Create Input Scenarios File
[&uarr; Unit Testing Process](#unit-testing-process-2)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function-2)<br />
[&darr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan-2)<br />
[&darr; Creating the Input Scenarios File](#creating-the-input-scenarios-file-2)<br />

###### Unit Test Wrapper Function
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-2)<br />

Here is a diagram of the input and output groups for this example:

<img src="png/JSD-CG.png">

From the input and output groups depicted we can construct CSV files with flattened group/field structures, and default values added, as follows (with `colgrp_inp.csv` left, `colgrp_out.csv` right):
<img src="png/groups - colgroup.png">

The value fields shown correspond to a prototype scenario with records per group:

- Input
    - Log: 0
    - Scalars: 1
    - Lines: 4
- Output
    - Log: 1
    - Scalars: 1
    - listAsIs: 1
    - sortByKey: 2
    - sortByValue: 2

A PowerShell utility uses these CSV files, together with one for scenarios, discussed next, to generate a template for the JSON unit testing input file. The utility creates a prototype scenario dataset with a record in each group for each populated value column, that is used for each scenario in the template.

###### Scenario Category ANalysis (SCAN)
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-2)<br />

As noted earlier, a useful approach to scenario selection can be to think in terms of categories of inputs, where we reduce large ranges to representative categories.

###### Generic Category Sets - ColGroup

As explained in the article mentioned earlier, it can be very useful to think in terms of generic category sets that apply in many situations. Multiplicity is relevant here (as it often is):

###### Multiplicity

There are several entities where the generic category set of multiplicity applies, and we should check each of the None / One / Multiple instance categories.

| Code     | Description     |
|:--------:|:----------------|
| None     | No values       |
| One      | One value       |
| Multiple | Multiple values |

Apply to:
<ul>
<li>Lines</li>
<li>File Columns (one or multiple only)</li>
<li>Key Instance (one or multiple only)</li>
<li>Delimiter (one or multiple only)</li>
</ul>

###### Categories and Scenarios - ColGroup

After analysis of the possible scenarios in terms of categories and category sets, we can depict them on a Category Structure diagram:

<img src="png/CSD-CG.png">

We can tabulate the results of the category analysis, and assign a scenario against each category set/category with a unique description:

|  # | Category Set              | Category            | Scenario                                 |
|---:|:--------------------------|:--------------------|:-----------------------------------------|
|  1 | Lines Multiplicity        | None                | No lines                                 |
|  2 | Lines Multiplicity        | One                 | One line                                 |
|  3 | Lines Multiplicity        | Multiple            | Multiple lines                           |
|  4 | File Column Multiplicity  | One                 | One column in file                       |
|  5 | File Column Multiplicity  | Multiple            | Multiple columns in file                 |
|  6 | Key Instance Multiplicity | One                 | One key instance                         |
|  7 | Key Instance Multiplicity | Multiple            | Multiple key instances                   |
|  8 | Delimiter Multiplicity    | One                 | One delimiter character                  |
|  9 | Delimiter Multiplicity    | Multiple            | Multiple delimiter characters            |
| 10 | Key Size                  | Short               | Short key                                |
| 11 | Key Size                  | Long                | Long key                                 |
| 12 | Log file existence        | No                  | Log file does not exist at time of call  |
| 13 | Log file existence        | Yes                 | Log file exists at time of call          |
| 14 | Key/Value Ordering        | No                  | Order by key differs from order by value |
| 15 | Key/Value Ordering        | Yes                 | Order by key same as order by value      |
| 16 | Errors                    | Mismatch            | Actual/expected mismatch                 |
| 17 | Errors                    | Unhandled Exception | Unhandled Exception                      |

From the scenarios identified we can construct the following CSV file (`colgrp_sce.csv`), taking the category set and scenario columns, and adding an initial value for the active flag:

<img src="png/scenarios - colgroup.png">

###### Creating the Input Scenarios File
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-2)<br />

The API to generate a template JSON file can be run with the following PowerShell in the folder of the CSV files:

###### Format-JSON-ColGroup.ps1
```powershell
Import-Module TrapitUtils
Write-UT_Template 'colgroup' '|' 'ColGroup - Powershell'
```
This creates the template JSON file, colgroup_temp.json, which contains an element for each of the scenarios, with the appropriate category set and active flag, with zero or more records in each group with default values from the groups CSV files. Here is the "Multiple lines" element:

    "Multiple lines": {
      "active_yn": "Y",
      "category_set": "Lines Multiplicity",
      "inp": {
        "Log": [],
        "Scalars": [
          ",|col_1"
        ],
        "Lines": [
          "col_0,col_1,col_2",
          "val_01,val_11,val_21",
          "val_02,val_12,val_22",
          "val_03,val_11,val_23"
        ]
      },
      "out": {
        "Log": [
          "1|IN [0,2000]|LIKE /.*: File .*ut_group.*.csv, delimiter ',', column col_1/"
        ],
        "listAsIs": [
          "2"
        ],
        "sortByKey": [
          "val_11|2",
          "val_12|1"
        ],
        "sortByValue": [
          "val_12|1",
          "val_11|2"
        ]
      }
    },

For each scenario element, we need to update the values to reflect the scenario to be tested, in the actual input JSON file, colgroup.json. In the "Multiple lines" scenario above the prototype scenario data can be used as is, but in others it would need to be updated.

##### Step 2: Create Results Object
[&uarr; Unit Testing Process](#unit-testing-process-2)<br />

Step 2 requires the writing of a wrapper function that is passed into a unit test library function, Test-Unit, via the entry point API,  `Test-Format`. Test-Unit reads the input JSON file, calls the wrapper function for each scenario, and writes the output JSON file with the actual results merged in along with the expected results.

###### purelyWrap-Unit
```powershell
function fromCSV($csv,  # string of delimited values
                 $col) { # 0-based column index
    $csv.Split($DELIM)[$col]
}
function setup($inpGroups) { # input scenario groups
    [String[]]$linesArr = @()
    $linesArr += $inpGroups.'Lines'
    $linesArr | Out-File -FilePath $INPUT_FILE -encoding utf8
    if ($inpGroups[$GRP_LOG].length -gt 0) {
        $inpGroups[$GRP_LOG].Join('`n') | Out-File -FilePath $LOG_FILE -encoding utf8
    }
    [ColGroup]::New($INPUT_FILE, (fromCSV $inpGroups.'Scalars'[0] 0), (fromCSV $inpGroups.'Scalars'[0] 1))
}
function teardown {
    Start-Sleep -Seconds 0.1 # to avoid locking issue
    Remove-Item $INPUT_FILE
    if (Test-Path -Path $LOG_FILE) {Remove-Item $LOG_FILE}
}
function purelyWrap-Unit($inpGroups) { # input scenario groups
    [string[]]$grpLog = @()
    [string[]]$grpLai = @()
    [string[]]$grpSbk = @()
    [string[]]$grpSbv = @()
    try {
        $colGroup  = setup $inpGroups
        $linesArr  = [string[]](Get-Content -path $LOG_FILE)
        $lastLine  = $linesArr[$linesArr.length - 1]
        $diffDate  = ((date) - [datetime]$lastLine.SubString(0,19)).TotalMilliseconds
        $grpLog = ($linesArr.length).ToString() + $DELIM + $diffDate.ToString() + $DELIM + ($lastLine -Replace "\\", "-")
        $len = $colGroup.ListAsIs().length
        $grpLai = $len.ToString()
        if ($len -ne 0) {
            $grpSbk = $colGroup.SortByKey() | %{$_.name + $DELIM + $_.value}
            $grpSbv = $colGroup.SortByValue() | %{$_.name + $DELIM + $_.value}
        }
        [PSCustomObject]@{
            $GRP_LOG = $grpLog
            $GRP_LAI = $grpLai
            $GRP_SBK = $grpSbk
            $GRP_SBV = $grpSbv
        }
    }
    finally {
        teardown
    }
}
```

##### Step 3: Format Results
[&uarr; Unit Testing Process](#unit-testing-process-2)<br />

Step 3 involves formatting the results contained in the JSON output file from step 2, via the JavaScript formatter:
- `Test-Format` is the function from the TrapitUtils PowerShell package that calls the main test driver function, then passes the output JSON file name to the JavaScript formatter and outputs a summary of the results.

###### Test-ColGroup.ps1 (skeleton)
```powershell
Using Module './ColGroup.psm1'
Import-Module TrapitUtils
...
function purelyWrap-Unit($inpGroups) { # input scenario groups
    ...
}
Test-Format $PSScriptRoot ($PSScriptRoot + '/../../../TrapitUtils') 'colgroup' ${function:purely-WrapUnit}
```
This script contains the wrapper function, passing it in a call to the TrapitUtils library function Test-Format.

#### Unit Test Results
[&uarr; Example 2 - ColGroup](#example-2---colgroup)<br />
[&darr; Unit Test Report - ColGroup](#unit-test-report---colgroup)<br />
[&darr; Scenario 9: Multiple delimiter characters](#scenario-9-multiple-delimiter-characters)<br />

The unit test script creates a results subfolder, with results in text and HTML formats, in the script folder, and outputs the following summary:
```
Results summary for file: [MY_PATH]/powershell_utils/TrapitUtils/examples/colgroup/colgroup_out.json
=========================================================================================================

File:          colgroup_out.json
Title:         ColGroup - Powershell
Inp Groups:    3
Out Groups:    5
Tests:         17
Fails:         3
Folder:        colgroup---powershell
```

##### Unit Test Report - ColGroup
[&uarr; Unit Test Results](#unit-test-results-2)<br />

Here we show the scenario-level summary of results for the specific example, and show the detail for one of the failing scenarios.

You can review the HTML formatted unit test results here:

- [Unit Test Report: ColGroup](http://htmlpreview.github.io/?https://github.com/BrenPatF/powershell_utils/blob/master/TrapitUtils/examples/colgroup/colgroup---powershell/colgroup---powershell.html)

<img src="png/summary-colgroup.png">

##### Scenario 9: Multiple delimiter characters
[&uarr; Unit Test Results](#unit-test-results-2)<br />

<img src="png/scenario_9-colgroup.png">This is one of three scenarios that fail, and it fails due to an unhandled exception, which is captured by the Test-Unit API. The error message is printed in a special output group, `Unhandled Exception` that is not specified in the input JSON file but added dynamically by the API into each scenario. In the case of an unhandled exception all the other output groups have empty 'actual' record sets, which will usually be reported as failing. Note that we also use the scenario data to explicitly demonstrate behaviour of unhandled exceptions against the 'Errors' category set in scenario 17.

The error message comes from PowerShell itself and explains clearly what has gone wrong:
```
Cannot validate argument on parameter 'delimiter'. The specified delimiter ';;' must be a single character.
```
The code uses a standard PowerShell API, Import-CSV, to read in a CSV file, which takes the delimiter as a parameter. This API does not accept multi-character delimiters as the message indicates.

The Unhandled Exception group also includes the error stack:
```
at readList, C:\Users\Brend\OneDrive\Documents\Home\WIP\powershell_utils\TrapitUtils\examples\colgroup\ColGroup.psm1: line 73
at ColGroup, C:\Users\Brend\OneDrive\Documents\Home\WIP\powershell_utils\TrapitUtils\examples\colgroup\ColGroup.psm1: line 95
at setup, C:\Users\Brend\OneDrive\Documents\Home\WIP\powershell_utils\TrapitUtils\examples\colgroup\Test-ColGroup.ps1: line 95
at purelyWrap-Unit, C:\Users\Brend\OneDrive\Documents\Home\WIP\powershell_utils\TrapitUtils\examples\colgroup\Test-ColGroup.ps1: line 108
at callPWU, C:\Users\Brend\Documents\PowerShell\Modules\TrapitUtils\TrapitUtils.psm1: line 264
at main, C:\Users\Brend\Documents\PowerShell\Modules\TrapitUtils\TrapitUtils.psm1: line 300
at Test-Unit, C:\Users\Brend\Documents\PowerShell\Modules\TrapitUtils\TrapitUtils.psm1: line 319
at Test-Format, C:\Users\Brend\Documents\PowerShell\Modules\TrapitUtils\TrapitUtils.psm1: line 386
at , C:\Users\Brend\OneDrive\Documents\Home\WIP\powershell_utils\TrapitUtils\examples\colgroup\Test-ColGroup.ps1: line 132
```

## API
[&uarr; In This README...](#in-this-readme)<br />
[&darr; Write-UT_Template](#write-ut_template)<br />
[&darr; Get-UT_TemplateObject](#get-ut_templateobject)<br />
[&darr; Test-Unit](#test-unit)<br />
[&darr; Test-Format](#test-format)<br />
[&darr; Test-FormatDB](#test-formatdb)<br />
```powershell
Import-Module TrapitUtils
```

### Write-UT_Template
[&uarr; API](#api)<br />
```powershell
Write-UT_Template($stem, $delimiter, $title)
```
Writes a unit testing template JSON file in the format of the Math Function Unit Testing design pattern, with parameters:

* `[String]$stem`: file name stem,
* `[String]$delimiter`: delimiter; default '|'
* `[String]$title`: title

There are two mandatory input group structure CSV files, with header 'Group, Field, Value1, Value2,...', where there are zero or more Valuei columns:
* `$stem`_inp.csv: list of group, field, values tuples for input
* `$stem`\_out.csv: list of group, field, values tuples for output

and there is an optional scenario list CSV file, with header 'Category Set, Scenario, Active':
* `$stem`\_sce.csv: list of category set, scenario, active triples for output


The function writes an output JSON file:
* `$stem`\_temp.json

If there is a scenario list CSV file present, then the output file will contain a template scenario for each record; if not the output file will have a single template scenario with name 'scenario 1', and a single null-values record for each group.

In the case where a scenarios file is present, each group has zero or more records with field values taken from the group CSV files, with a record for each value column present where at least one value is not null for the group. The template scenario represents a kind of prototype scenario, where records may be manually updated (and added or subtracted) to reflect input and expected output values for the actual scenario being tested.

Return value:

* `[void]`

### Get-UT_TemplateObject
[&uarr; API](#api)<br />
```powershell
Get-UT_TemplateObject($inpGroupLis, $outGroupLis, $delimiter, $title, $sceLis)
```
Gets an object with the same structure as the unit testing template JSON file, from input lists of objects for input and output groups, with parameters:

* `[PSCustomObject[]]$inpGroupLis`: list of group, field, value objects for input
* `[PSCustomObject[]]$outGroupLis`: list of group, field, value objects for output
* `[String]$delimiter`: delimiter; default '|'
* `[String]$title`: title
* `[PSCustomObject[]]$sceLis`: list of category set, scenario, active objects

This is a pure function that is called by Write-UT_Template, which writes its return value to file in JSON format.

Return value:

* `[PSCustomObject]`: object with fields:
    * `[PSCustomObject]meta`: metadata object
    * `[PSCustomObject]scenarios`: scenarios object

### Test-Unit
[&uarr; API](#api)<br />
```powershell
Test-Unit($inpFile, $outFile, $purelyWrapUnit)
```
Unit tests a unit using [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html) with input data read from a JSON file, and output results written to an output JSON file, with parameters:

* `[String]$inpFile`: input JSON file, with input and expected output data
* `[String]$outFile`: output JSON file, with input, expected and actual output data
* `[ScriptBlock]$purelyWrapUnit`: function to process unit test for a single scenario, passed in from test script, described below

#### $purelyWrapUnit
```powershell
$purelyWrapUnit($inpGroups)
```
Processes unit test for a single scenario, taking inputs as an object with input group data, making calls to the unit under test, and returning the actual outputs as an object with output group data, with parameters:

* `[PSCustomObject]$inpGroups`: object containing input groups with group name as key and list of delimited input records as value, of form:
<pre>
    @{
        inpGroup1 = [rec1, rec2,...]
        inpGroup2 = [rec1, rec2,...]
        ...
    }
</pre>
Return value:

* `[PSCustomObject]`: object containing output groups with group name as key and list of delimited actual output records as value, of form:
<pre>
    @{
        outGroup1 = [rec1, rec2,...]
        outGroup2 = [rec1, rec2,...]
        ...
    }
</pre>

This function acts as a 'pure' wrapper around calls to the unit under test. It is 'externally pure' in the sense that it is deterministic, and interacts externally only via parameters and return value. Where the unit under test reads inputs from file the wrapper writes them based on its parameters, and where the unit under test writes outputs to file the wrapper reads them and passes them out in its return value. Any file writing is reverted before exit.

Test-Unit is not normally called directly, but via the Test-Format function.

### Test-Format
[&uarr; API](#api)<br />
```powershell
Test-Format($utRoot, $npmRoot, $stemInpJSON, $purelyWrapUnit)
```
The unit test driver utility function is called as effectively the main function of any specific unit test script. It calls Test-Unit, then calls the JavaScript formatter, which writes the formatted results files to a subfolder in the script folder, based on the title, returning a summary. It has parameters:

* `[String]$utRoot`: unit test root folder
* `[String]$npmRoot`: parent folder of the JavaScript node_modules npm root folder
* `[String]$stemInpJSON`: input JSON file name stem
* `[ScriptBlock]$purelyWrapUnit`: function to process unit test for a single scenario, passed in from test script, described in the section above for Test-Unit

Return value:

* `[String]`: summary of results

### Test-FormatDB
[&uarr; API](#api)<br />
```powershell
Test-FormatDB($unpw, $conn, $utGroup, $testRoot, $preSQL)
```
Automates the running of Oracle PL/SQL unit tests and formatting of the results via the JavaScript formatter. It has parameters:

* `[String]$unpw`: Oracle user name / password string
* `[String]$conn`: Oracle connection string (such as the TNS alias)
* `[String]$utGroup`: Oracle unit test group
* `[String]$testRoot`: Unit testing root folder, where results folders will be placed
* `[String]$preSQL`: SQL to execute first (optional)

Runs a SQL*Plus session calling the Oracle unit test driving function, with the test group passed as a parameter. The unit test driving function returns a list of the output JSON files created, which are then processed in a loop by the JavaScript formatter, which writes the formatted results files to subfolders based on the titles, and returns a summary of the results.

If $preSQL is set the SQL statement it contains will be executed first. It can be used, for example, to point a view to a particular table.

Return value:

* `[String]`: summary of results
## Installation
[&uarr; In This README...](#in-this-readme)<br />
[&darr; Install Prerequisites](#install-prerequisites)<br />
[&darr; Install TrapitUtils](#install-trapitutils)<br />

### Install Prerequisites
[&uarr; Installation](#installation)<br />

The powershell package Utils is required. This is a subproject of the same GitHub project as TrapitUtils, so if you have downloaded the project, you will already have it, and it will be installed automatically as part of the TrapitUtils installation.

The JavaScript npm package [Trapit - JavaScript Unit Tester/Formatter](https://github.com/BrenPatF/trapit_nodejs_tester) is required to format the unit test output JSON file in HTML and/or text. The package is included as part of the TrapitUtils subproject within the Powershell Utils GitHub project but you need to have [Node.js](https://nodejs.org/en/download) installed to run it. The root folder location for the package is passed as a parameter to the functions that need it.

### Install TrapitUtils
[&uarr; Installation](#installation)<br />

To install TrapitUtils open a powershell window in the root TrapitUtils folder, and execute as follows:
```powershell
$ ./Install-TrapitUtils
```
This will create a folder TrapitUtils under the first folder in your `PSModulePath` environment variable, and copy TrapitUtils.psm1 to it.

It will also create a folder for the prerequisite module, Utils, under the first folder in your `PSModulePath` environment variable, and copy Utils.psm1 to it.
## Unit Testing
[&uarr; In This README...](#in-this-readme)<br />
[&darr; Unit Testing Process](#unit-testing-process-3)<br />
[&darr; Unit Test Results](#unit-test-results-3)<br />

In this section the unit testing core API function Get-UT_TemplateObject is itself tested using [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html). A 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

### Unit Testing Process
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-3)<br />
[&darr; Step 2: Create Results Object](#step-2-create-results-object-3)<br />
[&darr; Step 3: Format Results](#step-3-format-results-3)<br />

This section details the three steps involved in following [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html).

#### Step 1: Create Input Scenarios File
[&uarr; Unit Testing Process](#unit-testing-process-3)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function-3)<br />
[&darr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan-3)<br />
[&darr; Creating the Input Scenarios File](#creating-the-input-scenarios-file-3)<br />

##### Unit Test Wrapper Function
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-3)<br />

The signature of the unit under test is:

```powershell
Get-UT_TemplateObject($inpGroupLis, $outGroupLis, $delimiter, $sceLis)
```
where the parameters are described in the API section above. The diagram below shows the structure of the input and output of the wrapper function.

<img src="png/JSD-TrapitUtils.png">

From the input and output groups depicted we can construct CSV files with flattened group/field structures, and default values added, as follows:

###### get_ut_template_object_inp.csv
<img src="png/groups - ut - inp.png">

The value fields shown correspond to a prototype scenario with records per input group:

- Scalars: 1
- Scenarios: 2
- Scenario Input Group: 4
- Scenario Output Group: 4

###### get_ut_template_object_out.csv (Group, Field, Value1-Value4 columns)
<img src="png/groups - ut-L - out.png">

###### get_ut_template_object_out.csv (Group, Field, Value5-Value8 columns)
<img src="png/groups - ut-R - out.png">

The value fields shown correspond to a prototype scenario with records per output group:

- Scalars: 1
- Meta Input Group: 4
- Meta Output Group: 4
- Scenarios: 2
- Scenario Input Group: 8
- Scenario Output Group: 8

A PowerShell utility uses these CSV files, together with one for scenarios, discussed next, to generate a template for the JSON unit testing input file. The utility creates a prototype scenario dataset with a record in each group for each populated value column, that is used for each scenario in the template.

##### Scenario Category ANalysis (SCAN)
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-3)<br />
[&darr; Generic Category Sets](#generic-category-sets)<br />
[&darr; Categories and Scenarios](#categories-and-scenarios)<br />

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach can be to think in terms of categories of inputs, where we reduce large ranges to representative categories, an idea I explore in this article:

- [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html)

###### Generic Category Sets
[&uarr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan-3)<br />

As explained in the article mentioned above, it can be very useful to think in terms of generic category sets that apply in many situations. Multiplicity is relevant here (as it often is):

###### *Multiplicity*

There are several entities where the generic category set of multiplicity applies, and we should check each of the applicable None / One / Multiple instance categories.

| Code     | Description     |
|:--------:|:----------------|
| None     | No values       |
| One      | One value       |
| Multiple | Multiple values |

Apply to:
<ul>
<li>Input Groups</li>
<li>Output Groups</li>
<li>Input Group Fields (one or multiple only)</li>
<li>Output Group Fields (one or multiple only)</li>
<li>Delimiter (one or multiple only)</li>
<li>Scenarios (none or multiple only)</li>
<li>Field Values (none or multiple only)</li>
</ul>

###### Categories and Scenarios
[&uarr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan-3)<br />

After analysis of the possible scenarios in terms of categories and category sets, we can depict them on a Category Structure diagram:

<img src="png/CSD-TrapitUtils.png">

We can tabulate the results of the category analysis, and assign a scenario against each category set/category with a unique description:

|  # | Category Set              | Category      | Scenario                                       |
|---:|:--------------------------|:--------------|:-----------------------------------------------|
|  1 | Input Group Multiplicity  | None          | No input groups                                |
|  2 | Input Group Multiplicity  | One           | One input group                                |
|  3 | Input Group Multiplicity  | Multiple      | Multiple input groups                          |
|  4 | Output Group Multiplicity | None          | No output groups                               |
|  5 | Output Group Multiplicity | One           | One output group                               |
|  6 | Output Group Multiplicity | Multiple      | Multiple output groups                         |
|  7 | Input Field Multiplicity  | One           | One input field                                |
|  8 | Input Field Multiplicity  | Multiple      | Multiple input fields                          |
|  9 | Output Field Multiplicity | One           | One output field                               |
| 10 | Output Field Multiplicity | Multiple      | Multiple output fields                         |
| 11 | Delimiter Multiplicity    | One           | One-character delimiter                        |
| 12 | Delimiter Multiplicity    | Multiple      | Multi-character delimiter                      |
| 13 | Scenarios Multiplicity    | None          | Scenarios file not present                     |
| 14 | Scenarios Multiplicity    | Multiple      | Multiple scenarios                             |
| 15 | Field Value Multiplicity  | Null          | All field values null                          |
| 16 | Field Value Multiplicity  | Mixed         | Some field values null, some not null          |
| 17 | Category Set              | Null/Not Null | Scenarios with null and not null category sets |
| 18 | Active Flag               | Y/N           | Scenarios with Y and N active flag             |

From the scenarios identified we can construct the following CSV file (`get_ut_template_object_sce.csv`), taking the category set and scenario columns, and adding an initial value for the active flag:

<img src="png/scenarios - ut.png">

##### Creating the Input Scenarios File
[&uarr; Step 1: Create Input Scenarios File](#step-1-create-input-scenarios-file-3)<br />

The API to generate a template JSON file can be run with the following PowerShell in the folder of the CSV files:

###### Format-JSON-Get-UT_TemplateObject

```powershell
Import-Module ..\TrapitUtils.psm1
Write-UT_Template 'get_ut_template_object' '|' 'Get UT Template Object'
```
This creates the template JSON file, trapit_py_temp.json, which contains an element for each of the scenarios, with the appropriate category set and active flag, and a prototype set of input and output records.

In the prototype record sets, each group has zero or more records with field values taken from the group CSV files, with a record for each value column present where at least one value is not null for the group. The template scenario records may be manually updated (and added or subtracted) to reflect input and expected output values for the actual scenario being tested.

#### Step 2: Create Results Object
[&uarr; Unit Testing Process](#unit-testing-process-3)<br />

Step 2 requires the writing of a wrapper function that is passed into a unit test library function, Test-Unit, via the entry point API,  `Test-Format`. Test-Unit reads the input JSON file, calls the wrapper function for each scenario, and writes the output JSON file with the actual results merged in along with the expected results.

##### purelyWrap-Unit

```powershell
function getGroupObjLis([String[]]$strLis) { (function body) }
function getSceObjLis([String[]]$strLis) { (function body) }
function getGroupFieldStrLis($obj) { (function body) }
function getGroupObjLis($strLis) { # list of delimited group/field/value strings
    [PSCustomObject[]]$objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += @{'group' = $fields[0]; 'field' = $fields[1]; 'value' = $fields[2]}
    }
    $objLis
}
function getSceObjLis($strLis) { # list of delimited Category Set/Scenario/Active strings
    [PSCustomObject[]]$objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += @{'Category Set' = $fields[0]; 'Scenario' = $fields[1]; 'Active' = $fields[2]}
    }
    $objLis
}
function getGroupFieldStrLis([PSCustomObject]$obj) { # object has a key and a value that is an array of strings
    [String[]]$strLis = @()
    foreach ($o in $obj.PSObject.Properties) {
        foreach ($v in $o.value) {
            $strLis += $o.name + $DELIM + $v
        }
    }
    $strLis
}
function purelyWrap-Unit([PSCustomObject]$inpGroups) { # input scenario groups
    $scalars = $inpGroups.'Scalars'
    $delimiter, $title = $scalars.split($DELIM)
    $utObj = Get-UT_TemplateObject (getGroupObjLis $inpGroups.'Input Group') `
                                   (getGroupObjLis $inpGroups.'Output Group') `
                                   $delimiter `
                                   $title `
                                   (getSceObjLis $inpGroups.'Scenarios')
    [String[]]$inpLis = @()
    [String[]]$outLis = @()
    [String[]]$sceLis = @()
    foreach ($p in $utObj.scenarios.PsObject.Properties) {
        $inpLis += getGroupFieldStrLis $p.value.inp | %{$p.name + $DELIM + $_}
        $outLis += getGroupFieldStrLis $p.value.out | %{$p.name + $DELIM + $_}
        $sceLis += $p.value.category_set + $DELIM + $p.name + $DELIM + $p.value.active_yn
    }
    [String[]]$metaInpLis = @()                        # direct assignment can lead to null object
    $metaInpLis += getGroupFieldStrLis $utObj.meta.inp # iso empty array
    [String[]]$metaOutLis = @()
    $metaOutLis += getGroupFieldStrLis $utObj.meta.out
    #     Object key (group name)   group object value = list of strings
    [PSCustomObject]@{
          'Scalars'               = [String[]]$utObj.meta.title
          'Meta Input Group'      = $metaInpLis
          'Meta Output Group'     = $metaOutLis
          'Scenarios'             = $sceLis
          'Scenario Input Group'  = $inpLis
          'Scenario Output Group' = $outLis
    }
}
```

#### Step 3: Format Results
[&uarr; Unit Testing Process](#unit-testing-process-3)<br />

Step 3 involves formatting the results contained in the JSON output file from step 2, via the JavaScript formatter:
- `Test-Format` is the function from the TrapitUtils PowerShell package that calls the main test driver function, then passes the output JSON file name to the JavaScript formatter and outputs a summary of the results.

##### Test-Get-UT_TemplateObject.ps1 (skeleton)
```powershell
Import-Module ..\TrapitUtils.psm1
$DELIM = ';'
function purelyWrap-Unit([PSCustomObject]$inpGroups) { # input scenario groups
    ...
}
Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'get_ut_template_object' ${function:purelyWrap-Unit}
```
This script contains the wrapper function, passing it in a call to the TrapitUtils library function Test-Format.

### Unit Test Results
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Unit Test Report - Get UT Template Object](#unit-test-report---get-ut-template-object)<br />
[&darr; Scenario 14: Multiple scenarios [Category Set: Scenarios Multiplicity]](#scenario-14-multiple-scenarios-category-set-scenarios-multiplicity)<br />

The unit test script creates a results subfolder, with results in text and HTML formats, in the script folder, and outputs the following summary:
```
Results summary for file: [MY_PATH]/TrapitUtils/unit_test/get_ut_template_object_out.json
===============================================================================================================

File:          get_ut_template_object_out.json
Title:         Get UT Template Object
Inp Groups:    4
Out Groups:    6
Tests:         18
Fails:         0
Folder:        get-ut-template-object
```

#### Unit Test Report - Get UT Template Object
[&uarr; Unit Test Results](#unit-test-results-3)<br />

Here  we show the scenario-level summary of results, and show the detail for one of the scenarios, in text format.

You can review the HTML formatted unit test results here:

- [Unit Test Report: Get UT Template Object](http://htmlpreview.github.io/?https://github.com/BrenPatF/powershell_utils/blob/master/TrapitUtils/unit_test/get-ut-template-object/get-ut-template-object.html)

```
Unit Test Report: Get UT Template Object
========================================

      #    Category Set               Scenario                                        Fails (of 7)  Status
      ---  -------------------------  ----------------------------------------------  ------------  -------
      1    Input Group Multiplicity   No input groups                                 0             SUCCESS
      2    Input Group Multiplicity   One input group                                 0             SUCCESS
      3    Input Group Multiplicity   Multiple input groups                           0             SUCCESS
      4    Output Group Multiplicity  No output groups                                0             SUCCESS
      5    Output Group Multiplicity  One output group                                0             SUCCESS
      6    Output Group Multiplicity  Multiple output groups                          0             SUCCESS
      7    Input Field Multiplicity   One input field                                 0             SUCCESS
      8    Input Field Multiplicity   Multiple input fields                           0             SUCCESS
      9    Output Field Multiplicity  One output field                                0             SUCCESS
      10   Output Field Multiplicity  Multiple output fields                          0             SUCCESS
      11   Delimiter Multiplicity     One-character delimiter                         0             SUCCESS
      12   Delimiter Multiplicity     Multi-character delimiter                       0             SUCCESS
      13   Scenario Multiplicity      Scenarios file not present                      0             SUCCESS
      14   Scenario Multiplicity      Multiple scenarios                              0             SUCCESS
      15   Field Value Multiplicity   No field values                                 0             SUCCESS
      16   Field Value Multiplicity   Multiple field values varying by group          0             SUCCESS
      17   Category Set               Scenarios with null and not null category sets  0             SUCCESS
      18   Active Flag                Scenarios with Y and N active flag              0             SUCCESS

Test scenarios: 0 failed of 18: SUCCESS
=======================================
Formatted: 8/6/2025, 15:50:19
```

#### Scenario 14: Multiple scenarios [Category Set: Scenarios Multiplicity]
[&uarr; Unit Test Results](#unit-test-results-3)<br />

```
SCENARIO 14: Multiple scenarios [Category Set: Scenario Multiplicity] {
=======================================================================
   INPUTS
   ======
      GROUP 1: Scalars {
      ==================
            #  Delimiter  Title
            -  ---------  -------------
            1  ~          Template Test
      }
      =
      GROUP 2: Scenarios {
      ====================
            #  Category Set    Scenario    Active
            -  --------------  ----------  ------
            1  Category Set 1  Scenario 1  N
            2  Category Set 2  Scenario 2  N
      }
      =
      GROUP 3: Input Group {
      ======================
            #  Group Name     Field Name       Value1            Value2
            -  -------------  ---------------  ----------------  ----------------
            1  Input Group 1  Input Field 1-1  Input Value1 1-1  Input Value2 1-1
            2  Input Group 1  Input Field 1-2  Input Value1 1-2  Input Value2 1-2
            3  Input Group 2  Input Field 2-1  Input Value1 2-1  Input Value2 2-1
            4  Input Group 2  Input Field 2-2  Input Value1 2-2  Input Value2 2-2
      }
      =
      GROUP 4: Output Group {
      =======================
            #  Group Name      Field Name        Value1             Value2
            -  --------------  ----------------  -----------------  -----------------
            1  Output Group 1  Output Field 1-1  Output Value1 1-1  Output Value2 1-1
            2  Output Group 1  Output Field 1-2  Output Value1 1-2  Output Value2 1-2
            3  Output Group 2  Output Field 2-1  Output Value1 2-1  Output Value2 2-1
            4  Output Group 2  Output Field 2-2  Output Value1 2-2  Output Value2 2-2
      }
      =
   OUTPUTS
   =======
      GROUP 1: Scalars {
      ==================
            #  Title
            -  -------------
            1  Template Test
      } 0 failed of 1: SUCCESS
      ========================
      GROUP 2: Meta Input Group {
      ===========================
            #  Group Name     Field Name
            -  -------------  ---------------
            1  Input Group 1  Input Field 1-1
            2  Input Group 1  Input Field 1-2
            3  Input Group 2  Input Field 2-1
            4  Input Group 2  Input Field 2-2
      } 0 failed of 4: SUCCESS
      ========================
      GROUP 3: Meta Output Group {
      ============================
            #  Group Name      Field Name
            -  --------------  ----------------
            1  Output Group 1  Output Field 1-1
            2  Output Group 1  Output Field 1-2
            3  Output Group 2  Output Field 2-1
            4  Output Group 2  Output Field 2-2
      } 0 failed of 4: SUCCESS
      ========================
      GROUP 4: Scenarios {
      ====================
            #  Category Set    Scenario    Active
            -  --------------  ----------  ------
            1  Category Set 1  Scenario 1  N
            2  Category Set 2  Scenario 2  N
      } 0 failed of 2: SUCCESS
      ========================
      GROUP 5: Scenario Input Group {
      ===============================
            #  Scenario    Group Name     Record
            -  ----------  -------------  ---------------------------------
            1  Scenario 1  Input Group 1  Input Value1 1-1~Input Value1 1-2
            2  Scenario 1  Input Group 1  Input Value2 1-1~Input Value2 1-2
            3  Scenario 1  Input Group 2  Input Value1 2-1~Input Value1 2-2
            4  Scenario 1  Input Group 2  Input Value2 2-1~Input Value2 2-2
            5  Scenario 2  Input Group 1  Input Value1 1-1~Input Value1 1-2
            6  Scenario 2  Input Group 1  Input Value2 1-1~Input Value2 1-2
            7  Scenario 2  Input Group 2  Input Value1 2-1~Input Value1 2-2
            8  Scenario 2  Input Group 2  Input Value2 2-1~Input Value2 2-2
      } 0 failed of 8: SUCCESS
      ========================
      GROUP 6: Scenario Output Group {
      ================================
            #  Scenario    Group Name      Record
            -  ----------  --------------  -----------------------------------
            1  Scenario 1  Output Group 1  Output Value1 1-1~Output Value1 1-2
            2  Scenario 1  Output Group 1  Output Value2 1-1~Output Value2 1-2
            3  Scenario 1  Output Group 2  Output Value1 2-1~Output Value1 2-2
            4  Scenario 1  Output Group 2  Output Value2 2-1~Output Value2 2-2
            5  Scenario 2  Output Group 1  Output Value1 1-1~Output Value1 1-2
            6  Scenario 2  Output Group 1  Output Value2 1-1~Output Value2 1-2
            7  Scenario 2  Output Group 2  Output Value1 2-1~Output Value1 2-2
            8  Scenario 2  Output Group 2  Output Value2 2-1~Output Value2 2-2
      } 0 failed of 8: SUCCESS
      ========================
      GROUP 7: Unhandled Exception: Empty as expected: SUCCESS
      ========================================================
} 0 failed of 7: SUCCESS
========================
```
## Folder Structure
[&uarr; In This README...](#in-this-readme)<br />

The project folder structure is shown below.

<img src="png/folders-TrapitUtils.png">

There are four subfolders below the trapit root folder, which has README and module:
- `examples`: Two working PowerShell examples are included in their own subfolders, with both test scripts and a main script that shows how the unit under test would normally be called
- `node_modules`: npm root
- `png`: This holds the image files for the README
- `unit_test`: Root folder for unit testing of the Get-UT_TemplateObject function, with subfolder having the results files

## See Also
[&uarr; In This README...](#in-this-readme)<br />
- [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html)
- [Trapit - JavaScript Unit Tester/Formatter](https://github.com/BrenPatF/trapit_nodejs_tester)
- [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html)
- [Powershell General Utilities Module](https://github.com/BrenPatF/powershell_utils/tree/master/Utils)
- [Node.js Downloads](https://nodejs.org/en/download)
- [Powershell Trapit Unit Testing Utilities Module](https://github.com/BrenPatF/powershell_utils/tree/master/TrapitUtils)

## Software Versions

- Windows 11
- Powershell 7
- npm 6.13.4
- Node.js v12.16.1

## License
MIT
