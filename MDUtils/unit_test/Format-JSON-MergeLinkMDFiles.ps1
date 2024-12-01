<#**************************************************************************************************
Name: Format-JSON-MergeLinkMDFiles.ps1      Author: Brendan Furey                  Date: 05-Apr-2021

Component package in the Powershell Markdown Utilities module MDUtils. The module has a utility to
create a combined markdown (MD) file from a set of constituent MD files listed in an input file. 
After merging the constituent files in order, the utility adds, after each heading, a link to any
parent heading and a list of links to any child headings. These internal links form a tree structure
that enables easy navigation for longer documents.

    GitHub: https://github.com/BrenPatF/powershell_utils

As well as the module file, there is an install script, an example script, and a unit test script.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

This file contains a wrapper script that calls the TrapitUtils function Write-UT_Template to 
generate a template for the unit testing input JSON file, based on CSV files with stem
'merge-linkmdfiles'.

**************************************************************************************************#>
Import-Module ..\..\TrapitUtils\TrapitUtils.psm1
Write-UT_Template 'merge-linkmdfiles' '|'
