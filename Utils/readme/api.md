## API - Utils

```powershell
Import-Module Utils
```

### Write-Debug
```
Write-Debug($msg, $new, $filename)
```
Writes a line of text to a debug file, with parameters:

* `$msg`: timer name
* `$new`: overwrite file if $true; default $false
* `$filename`: file name; default '.\debug.log'

### Get-ObjLisFromCsv
```
Get-ObjLisFromCsv($csv, $delimiter)
```
Imports a csv file with headers into an array of objects; keys are the column headers, with cells as values, with parameters:

* `$csv`: csv file
* `$delimiter`: delimiter; default ','

### Get-Heading
```
Get-Heading($title, $indent)
```
Returns a 2-line heading with double underlining, from an input string, with parameters:

* `$title`: title
* `$indent`: indent level; default 0

### Get-ColHeaders
```
Get-ColHeaders($header2Lis, $indent)
```
Returns a list of strings as one line, input as list of (string, length) tuples, and indent spaces, with parameters:

* `$header2Lis`: list of (string, length) tuples; -ve length -> right-justify
* `$indent`: indent level; default 0

### Get-2LisAsLine
```
Get-2LisAsLine($line2Lis, $indent)
```
Returns a list of strings as one line, input as list of (string, length) tuples, and indent spaces, with parameters:

* `$line2Lis`: list of (string, length) tuples; -ve length -> right-justify
* `$indent`: indent level; default 0

### Get-StrLisFromObjLis
```
Get-StrLisFromObjLis($objLis, $delimiter)
```
Returns a list of name, value strings from a list of objects, with simple string properties, usinmg a delimiter. Property names from first object first, with parameters:

* `$objLis`: list of pscustomobjects
* `$delimiter`: $delimiter; default '|'

### Remove-ExtraLF
```
Remove-ExtraLF($fileName)
```
Removes the last two characters from a file, intended for the spurious extra line added by powershell functions like Out-File in Windows, with parameters:

* `$fileName`: file name

### Install-Module
```
Install-Module($srcFolder, $modName)
```
Installs a module in the first folder in psmodulepath environment variable, with parameters:

* `$srcFolder`: source folder for the module file
* `$modName`: module name (stem, without '.psm1' extension)

## Installation

To install Utils open a powershell window in the install folder below Utils, and execute as follows:
```
$ ./Install-Utils
```
This will create a folder Utils under the first folder in your `psmodulepath` environment variable, and copy Utils.psm1 to it.
