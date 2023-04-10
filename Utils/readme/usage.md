## Usage

There is a script with examples of use of all the utilities, some used directly and some via a demo class ColGroup. We show first an extract from the script, including use of a debugging utility and the calls to the demo class. 

Secondly, we show extracts from the demo class, with the utlity calls it makes, and the 'pretty-printed' output from one of its methods.

The full scripts and output logs can be found in the `examples` folder.

### Show-Examples.ps1 (extract)

```powershell
Using Module './ColGroup.psm1'
Import-Module Utils
$INPUT_FILE, $DELIM, $COL = ($PSScriptRoot + './fantasy_premier_league_player_stats.csv'), ',', 'team_name'

Get-Heading 'Demonstrate initial call to Write-Debug...'
Write-Debug 'Debug' $true

Get-Heading 'ColGroup constructor uses Get-ObjLisFromCsv...'
$grp = [ColGroup]::New($INPUT_FILE, $DELIM, $COL)

$meas = $grp.ListAsIs() | measure-object -property value -sum
Get-Heading 'Demonstrate subsequent call to Write-Debug...'
Write-Debug ('Counted ' + $meas.count + ' teams, with ' + $meas.sum + ' appearances')

Get-Heading 'ColGroup.WriteList uses the pretty-printing functions...'
$grp.WriteList('(as is)', $grp.ListAsIs())
...
```

The extract above from the script demonstrates usage of:

- Write-Debug
- Get-Heading

The debug file would then have lines such as the following:

```
Debug starting, 04/09/2023 15:44:33: Debug
Counted 23 teams, with 22831 appearances
```
The full script also demonstrates usage of:

- Get-StrLisFromObjLis
- Remove-ExtraLF
- Install-Module

### ColGroup.psm1 (extracts)

The constructor function reads a csv file into a list of objects, and demonstrates the usage of:

- Get-ObjLisFromCsv

```powershell
    $objLis = Get-ObjLisFromCsv $file $delim
```

The method WriteList demonstrates the usage of:

- Get-Heading
- Get-ColHeaders
- Get-2LisAsLine

```powershell
    [String[]]WriteList($sortBy,                # sort by descriptor
                        [Object[]]$keyValues) { # list of key/value objects

        $strLis = Get-Heading ('Counts sorted by ' + $sortBy)
        $strLis += Get-ColHeaders @(@('Team', -$this.maxLen), @('#apps', 5))
        foreach ($kv in $keyValues) {
            $strLis += Get-2LisAsLine @(@($kv.name, -$this.maxLen), @($kv.value, 5))
        }
        return $strLis
    }
```
The method returns a list of strings, which the script then outputs such as the following (first call):

```
Counts sorted by (as is)
========================
Team         #apps
-----------  -----
Bolton          37
Southampton   1110
QPR           1517
...
```
To run the examples script, open a powershell window in the examples folder and execute as follows:

```
$ ./Show-Examples
```
