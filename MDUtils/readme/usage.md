## Usage

To use this utility, start by creating one or more markdown files along with a file that lists them. Then, run the PowerShell utility, providing the input file name and the target merged file name.

In this section we'll show how it works by means of two examples, the first a simple demonstration example, and the second using the current README\.md file.

### Small Multilevel Example

Here is the Powershell script for the simple example, with input file, small_multilevel.lis, and target file SMALL_MULTILEVEL.md. The function Merge-LinkMDFiles writes to standard output a listing of the headings processed, which shows the heading tree structure.

```powershell
Import-Module MDUtils
Merge-LinkMDFiles small_multilevel.lis ..\SMALL_MULTILEVEL.md
```
#### Component File List

This example has a single `input.md` file in the component file list, in small_multilevel.lis:

```
input.md
```

#### Input Markdown File

The input markdown file input\.md is listed below:

	A small introduction for a single file example with multiple levels, including two top level headings, a duplicated heading, and a heading marked as not to be included in the link tree.
	
	# Contents
	
	## Level 2
	
	Level 2 text.
	
	### Level 3
	
	Level 3 text.
	
	#### Level 4 - 1
	
	First level 4 text.
	
	#### Level 4 - 2
	
	Second level 4 text.
	
	!##### Level 5 with leading !
	
	Level 5 text. Headings with a leading ! in heading are not processed for internal links, but should still function as headings.
	
	##### Level 5
	
	Level 5 text.
	
	###### Level 6
	
	Level 6 text. Level 6 headings are valid but don't have children as level 7 is not considered a heading.
	
	####### 7-hash line prefix
	
	Lines with 7 or more hashes as prefix are treated as plain text in markdown.
	
	# Second Level 1 Heading
	
	## Level 2
	
	This is a duplicate heading, and the url has a '-1' suffix


#### Target Markdown File

The target markdown file SMALL_MULTILEVEL.md is listed below, showing the links added:

	A small introduction for a single file example with multiple levels, including two top level headings, a duplicated heading, and a heading marked as not to be included in the link tree.
	
	# Contents
	[&darr; Level 2](#level-2)<br />
	
	## Level 2
	[&uarr; Contents](#contents)<br />
	[&darr; Level 3](#level-3)<br />
	
	Level 2 text.
	
	### Level 3
	[&uarr; Level 2](#level-2)<br />
	[&darr; Level 4 - 1](#level-4---1)<br />
	[&darr; Level 4 - 2](#level-4---2)<br />
	
	Level 3 text.
	
	#### Level 4 - 1
	[&uarr; Level 3](#level-3)<br />
	
	First level 4 text.
	
	#### Level 4 - 2
	[&uarr; Level 3](#level-3)<br />
	[&darr; Level 5](#level-5)<br />
	
	Second level 4 text.
	
	##### Level 5 with leading !
	
	Level 5 text. Headings with a leading ! in heading are not processed for internal links, but should still function as headings.
	
	##### Level 5
	[&uarr; Level 4 - 2](#level-4---2)<br />
	[&darr; Level 6](#level-6)<br />
	
	Level 5 text.
	
	###### Level 6
	[&uarr; Level 5](#level-5)<br />
	
	Level 6 text. Level 6 headings are valid but don't have children as level 7 is not considered a heading.
	
	####### 7-hash line prefix
	
	Lines with 7 or more hashes as prefix are treated as plain text in markdown.
	
	# Second Level 1 Heading
	[&darr; Level 2](#level-2-1)<br />
	
	## Level 2
	[&uarr; Second Level 1 Heading](#second-level-1-heading)<br />
	
	This is a duplicate heading, and the url has a '-1' suffix

#### Screenshot of File in Chrome

Below is a screenshot of the file SMALL_MULTILEVEL.md when viewed in a Chrome browser, with the Chrome markdown extension active:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="png/small_screen.png">

#### Output Heading Tree

The output heading tree produced is: 

	# Contents
	## Level 2
	### Level 3
	#### Level 4 - 1
	#### Level 4 - 2
	##### Level 5
	###### Level 6
	# Second Level 1 Heading
	## Level 2

### This README\.md

Here is the Powershell script for this README, with input file, merge_linkmdfiles.lis, and target file README\.md.

```powershell
Import-Module MDUtils
Merge-LinkMDFiles 'merge-linkmdfiles.lis' '..\README.md'
```
#### Component File List

This example has seven files in the component file list, in merge-linkmdfiles.lis:

```
intro.md
usage.md
api.md
installation.md
unit_test.md
folders.md
```

You can see these files in the readme folder, and of course the links created can be seen in the current document.

#### Screenshot of Contents Heading Section in Chrome

The links created below the top level heading are shown in this screenshot:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="png/TOC.png">

#### Output Heading Tree

The output heading tree produced is: 

	# In This README...
	## Usage
	### Small Multilevel Example
	#### Component File List
	#### Input Markdown File
	#### Target Markdown File
	#### Screenshot of File in Chrome
	#### Output Heading Tree
	### This README\.md
	#### Component File List
	#### Screenshot of Contents Heading Section in Chrome
	#### Output Heading Tree
	## API
	## Installation
	### Installation Prerequisites
	### Install MDUtils
	## Unit Testing
	### Unit Testing Prerequisites
	### Unit Testing Process
	#### Step 1: Create JSON File
	##### Unit Test Wrapper Function
	##### Scenario Category ANalysis (SCAN)
	###### Generic Category Sets
	###### Categories and Scenarios
	#### Step 2: Create Results Object
	#### Step 3: Format Results
	##### Unit Test Report - Merge-LinkMDFiles
	##### Scenario 3: Multiple files [Category Set: File Multiplicity]
	## Folder Structure
	## See Also


