# powershell_utils/TrapitUtils
<img src="png/mountains.png">

> Powershell Trapit Unit Testing Utilities module

:hammer_and_wrench: :detective:

This module contains two powershell utility functions for unit testing following the Math Function Unit Testing design pattern. The first one supports the design pattern for testing in any language:

- `Write-UT_Template` creates a template for the JSON input file required by the design pattern, based on CSV files specifying the structure. The template file includes scenarios that may be assigned against category sets, with placeholder records to be updated manually

The second is for testing powershell programs:

- `Test-Unit` is the powershell version of the unit testing driver program required by the design pattern, using JSON files for input scenarios and output results

Within this design pattern, unit test results are formatted by a JavaScript program that takes the JSON output results file as its input: [Trapit - JavaScript Unit Tester/Formatter](https://github.com/BrenPatF/trapit_nodejs_tester).

This blog post, [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/jekyll/update/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html) provides guidance on effective  selection of scenarios for unit testing.

There is an extended Usage section below that illustrates the use of the powershell utilities, along with the JavaScript program, for unit testing, by means of two examples. The Unit Testing section also uses them in testing the pure function, Get-UT_TemplateObject, which is called by Write-UT_Template.

# In This README...

