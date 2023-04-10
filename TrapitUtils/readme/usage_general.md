## Usage

As noted above, the JavaScript module allows for unit testing of JavaScript programs and also the formatting of test results for both JavaScript and non-JavaScript programs. Similarly, the powershell module mentioned allows for unit testing of powershell programs, and also the generation of the JSON input scenarios file template for testing in any language.

In this section we'll start by describing the steps involved in The Math Function Unit Testing design pattern at an overview level. This will show how the generic powershell and JavaScript utilities fit in alongside the language-specific driver utilities.

Then we'll show how to use the design pattern in unit testing powershell programs by means of two simple examples.

### General Usage

At a high level the Math Function Unit Testing design pattern involves three main steps:

1. Create an input file containing all test scenarios with input data and expected output data for each scenario
2. Create a results object based on the input file, but with actual outputs merged in, based on calls to the unit under test
3. Use the results object to generate unit test results files formatted in HTML and/or text

<img src="png/Math Function UT DP - HL Flow.png">

The first and third of these steps are supported by generic utilities that can be used in unit testing in any language. The second step uses a language-specific unit test driver utility.

For non-JavaScript programs the results object is materialized using a library package in the relevant language. The diagram below shows how the processing from the input JSON file splits into two distinct steps:
- First, the output results object is created using the external library package which is then written to a JSON file
- Second, a script from the Trapit JavaScript library package is run, passing in the name of the output results JSON file

This creates a subfolder with name based on the unit test title within the file, and also outputs a summary of the results. The processing is split between three code units:
- Test Unit: External library function that drives the unit testing with a callback to a specific wrapper function
- Specific Test Package: This has a 1-line main program to call the library driver function, passing in the callback wrapper function
- Unit Under Test: Called by the wrapper function, which converts between its specific inputs and outputs and the generic version used by the library package

<img src="png/MFUTDP - Flow-Ext.png">

In the first step the external program creates the output results JSON file, while in the second step the file is read into an object by the Trapit library package, which then formats the results.

#### Step 1: Create JSON File

Step 1 requires analysis to determine the extended signature for the unit under test, and to determine appropriate scenarios to test. 

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs. A useful approach to this can be to think in terms of categories of inputs, where we reduce large ranges to representative categories, an approach discussed in [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/jekyll/update/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html). While the examples in the blog post aimed at minimal sets of scenarios, we have since found it simpler and clearer to use a separate scenario for each category.

The results of this analysis can be summarised in three CSV files which the first API in this powershell package uses as inputs to create a template for the JSON file.

The powershell API, `Write-UT_Template` creates a template for the JSON file, with the full meta section, and a set of template scenarios having name as scenario key, a category set attribute, and a single record with default values for each input and output group. The API takes as inputs three CSV files:
  - `stem`_inp.csv: Input group triplets - (Input group name, field name, default value)
  - `stem`_out.csv: Input group triplets - (Output group name, field name, default value)
  - `stem`_sce.csv: Scenario triplets - (Category set, scenario name, active flag)


It may be useful during the analysis phase to create two diagrams, one for the extended signature:
- JSON Structure Diagram: showing the groups with their fields for input and output

and another for the category sets and categories:
- Category Structure Diagram: showing the category sets identified with their categories

You can see examples of these diagrams later in this document, eg: [JSON Structure Diagram - ColGroup](#unit-test-wrapper-function---colgroup) and [Category Structure Diagram - ColGroup](#scenario-category-analysis-scan---colgroup).


The API can be run with the following powershell in the folder of the CSV files:

!#### Format-JSON-Stem.ps1
```powershell
Import-Module TrapitUtils
Write-UT_Template 'stem' '|'
```
This creates the template JSON file, `stem`_temp.json based on the CSV files having prefix `stem` and using the field delimiter '|'.

This powershell API can be used for testing in any language.

#### Step 2: Create Results Object

Step 2 requires the writing of a wrapper function that is passed into a call to the second API.

- `Test-Unit` is the library unit test driver function that reads the input JSON file, calls the wrapper function for each scenario, and writes the output JSON file with the actual results merged in along with the expected results

It takes the names of the input and output JSON files, plus the wrapper function name, as parameters.

!##### Test-Stem.ps1 (skeleton)
```powershell
Import-Module TrapitUtils
function purelyWrap-Unit($inpGroups) { # input scenario groups
(function body)
}
Test-Unit ($PSScriptRoot + '/stem.json') ($PSScriptRoot + '/stem_out.json') ${function:purelyWrap-Unit}
```
This creates the output JSON file: `stem`_out.json. Generally it will be preferable not to call the script directly, but to include the call in a higher level script that calls it and also calls the JavaScript formatter, as in the next section.

The test driver API for step 2 is language-specific, and this one is for testing powershell programs. Equivalents exist under the same GitHub account (BrenPatF) for JavaScript, Python and Oracle PL/SQL at present.

#### Step 3: Format Results

Step 3 involves formatting the results contained in the JSON output file from step 2, via the JavaScript formatter, and this step can be combined with step 2 for convenience.

- `Test-Format` is the library function that calls the main test driver function, then passes the output JSON file name to the JavaScript formatter and outputs a summary of the results

It takes the name of the test driver script and the JavaScript root location as parameters.

!##### Run-Test-Stem.ps1
```powershell
Import-Module TrapitUtils
Test-Format ($PSScriptRoot + '/Test-Stem.ps1') ($PSScriptRoot + '/../..')
```
This script creates a results subfolder, with results in text and HTML formats, in the script folder, and outputs a summary of the following form:

```
Results summary for file: [MY_PATH]/stem_out.json
==============================================

File:          stem_out.json
Title:         [Title]
Inp Groups:    [Inp Groups]
Out Groups:    [Out Groups]
Tests:         [Tests]
Fails:         [Fails]
Folder:        [Folder]
```
#### Batch Testing

If we want to test and format the results for a batch of units at once, we can use another API function to do that:

- `Test-FormatFolder` is the library function that calls each of a list of powershell unit test driver scripts, then calls the JavaScript formatter, which writes the formatted results files to a subfolder within a results folder, based on the titles, returning a summary of the results

It takes as parameters: an array of full names of the unit test driver scripts; the folder where JSON files are copied, and results subfolders placed; the parent folder of the JavaScript node_modules npm root folder.

!##### Run-Test-Batch.ps1 (template)
```powershell
Import-Module TrapitUtils
[Define $psScriptLis, $jsonFolder, $npmRoot variables]
Test-FormatFolder $psScriptLis $jsonFolder $npmRoot
```
This script creates results subfolders within the JSON files folder for each unit, and outputs a summary of the following form:

```
Unit Test Results Summary for Folder [Folder]
=============================================
 File                 Title                     Inp Groups  Out Groups  Tests  Fails  Folder                  
--------------------  ------------------------  ----------  ----------  -----  -----  ------------------------
...
[Failed] externals failed, see [MY_PATH]/results for scenario listings
...
```

### Examples

This section illustrates the usage of the package by means of two examples. The first is a version of the 'Hello World' program traditionally used as a starting point in learning a new programming language. This is useful as it shows the core structures involved in following the design pattern with a minimalist unit under test.

The second example, 'ColGroup', is larger and intended to show a wider range of features, but without too much extraneous detail.

As noted in the general section above the formatting of results in step 3 is done by a JavaScript program that processes the JSON files.
