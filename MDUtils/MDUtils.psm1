<#**************************************************************************************************
Name: MDUtils.psm1                      Author: Brendan Furey                      Date: 17-Nov-2024

Component package in the Powershell Markdown Utilities module MDUtils. The module has a utility to
create a combined markdown (MD) file from a set of constituent MD files listed in an input file. 
After merging the constituent files in order, the utility adds, after each heading, a link to any
parent heading and a list of links to any child headings. These internal links form a tree structure
that enables easy navigation for longer documents.

    GitHub: https://github.com/BrenPatF/powershell_utils

As well as the module file, there is an install script, an example script, and a unit test script.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

====================================================================================================
| Script (.ps1)           | Module (.psm1) |  Notes                                                |
|==================================================================================================|
|  Install-MDUtils        |                   Installer copies module to Powershell path           |
|-------------------------|------------------------------------------------------------------------|
|  Small-Multilevel       |                   Example script                                       |
|                         |------------------------------------------------------------------------|
|-------------------------| *MDUtils*      |  Markdown utility functions                           |
|                         |--------------- |-------------------------------------------------------|
|                         |  TrapitUtils   |  Trapit unit testing utility functions                |
|                         |------------------------------------------------------------------------|
|  Test-MergeLinkMDFiles  |                   Unit test script                                     |
====================================================================================================

MDUtils package with entry point function called by example and unit test scripts.

**************************************************************************************************#>
function link([String]$ud, [String]$text, [String]$anchorId){
    ('[&' + $ud + 'arr; ' + $text + '](#' + $anchorId + ')<br />')
}
function popHeadingIndexes([Int]$parentInd, [Int]$lev) {
    $childs = @()
    For ($i = $parentInd + 1; $i -lt $headings.length; $i++) {
        [Int]$newLev = $headings[$i].lev
        If ($newLev -eq $lev + 1) {
            $childs += $i
            $Script:headings[$i].parent = $parentInd
            popHeadingIndexes $i $newLev
        } ElseIf ($newLev -le $lev) {
            $Script:headings[$parentInd].childs = $childs
            break
        }
    }
    If ($parentInd -ne -1) {$Script:headings[$parentInd].childs = $childs}
}
function getSrcLines([String]$inputFilesFile) {
    [String[]]$sections = Get-Content $inputFilesFile
    [String[]]$srcLines = @()
    Foreach($s in $sections) {
        $srcLines += (Get-Content -path $s)
    }
    $srcLines | %{$_.TrimEnd()}
}
function getTgtLines([String[]]$srcLines, [PSObject[]]$headings) {
    [String[]]$tgtLines = @()
    $startLineNo = 0
    Foreach($h in $headings){
        $tgtLines += $srcLines[$startLineNo..$h.srcInd]
        $startLineNo = $h.srcInd + 1
        $links = @()
        If ($h.parent -ne -1) {
            $links += (link 'u' $headings[$h.parent].text $headings[$h.parent].anchorId)
        }
        Foreach($c in $h.childs){
            $links += (link 'd'  $headings[$c].text $headings[$c].anchorId)
        }
        $tgtLines += $links
    }
    If ($startLineNo -lt $srcLines.count) {
        $tgtLines += $srcLines[$startLineNo..($srcLines.count - 1)]
    }
    $tgtLines | %{$_ -Replace "^!#", "#"}
}
function findParent([Int]$hashLev, [PSObject[]]$headings) {
    If ($headings.count -gt 0) {
        For ($i = $headings.count-1; $i -ge 0; $i--) {
            If ($headings[$i].hashLev -lt $hashLev) {
                $retLev = $headings[$i].lev + 1
                break
            }
        }
    }
    If ($retLev -eq $null) {$retLev = 1}
    $retLev
}
function popHeadings([PSObject[]]$tree) {
    If ($tree.count -gt 0) {
        $anchorCount = @{}
        Foreach ($t in $tree) {
            $hashLev = $t.line.IndexOf(' ')
            $text = $t.line.SubString($hashLev + 1)
            $anchorId = (($text.ToLower() -Replace ' ', '-') -Replace "[^a-z0-9-_]", '') 
            $anchorCount[$anchorId] += 1
            If ($anchorCount[$anchorId] -gt 1) {$suffix = '-' + ($anchorCount[$anchorId] - 1).ToString()}
            Else {$suffix = ''}

            if ($t.line.SubString(0, 1) -ne '!') {
                $lev = findParent $hashLev $headings

                $Script:headings += @{  lev      = $lev
                                        hashLev  = $hashLev
                                        text     = $text
                                        anchorId = $anchorId + $suffix
                                        srcInd   = $t.linenumber - 1
                                        parent   = $null
                                        childs   = @()
                                    }
            }
        }
        popHeadingIndexes -1 0
    }
}
function Merge-LinkMDFiles { 
    Param(  [String]$inputFilesFile, 
            [String]$mergedOutFile,
            [ValidateRange(0,6)][Int]$maxLev = 6
    ) 
    Process {
        $Script:headings = @()
        [String[]]$srcLines = getSrcLines $inputFilesFile
        [PSObject[]]$tree = @()
        If ($maxLev -gt 0) {
            $tree = $srcLines | Select-String ("^!?#{1," + $maxLev.ToString() + "} .*")
        }
        popHeadings $tree
        getTgtLines $srcLines $headings | Out-File -FilePath $mergedOutFile -encoding utf8
        $tree | Select-String ("^#")
    }
}
Export-ModuleMember -Function Merge-LinkMDFiles