<#**************************************************************************************************
Name: Test-TimerSet.ps1                     Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module TimerSet. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

    GitHub: https://github.com/BrenPatF/powershell_utils

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There is an examples main script and a unit test script. The examples script makes calls to an
example class module, ColGroup.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

====================================================================================================
| Script (.ps1)      | Module (.psm1) |  Notes                                                     |
|==================================================================================================|
|                    |  ColGroup      |  Simple file-reading and group-counting class module       |
|  Show-ColGroup     |----------------|------------------------------------------------------------|
|--------------------|  TimerSet      |  TimerSet class module                                     |
|                    |----------------|------------------------------------------------------------|
| *Test-TimerSet*    |  TrapitUtils   |  Trapit unit testing utility functions                     |                                                                                                                                                                                                                                                                                                                                                                                               
|                    |----------------|------------------------------------------------------------|                                                                                                                                                                                                                                                                               -------------------------------------------------------------|
|--------------------|  Utils         |  General utility functions                                 |
|                    |-----------------------------------------------------------------------------|
|  Install-TimerSet  |                   Install script copies module to Powershell path           |
====================================================================================================

This file contains a wrapper script that calls the function Test-Format, passing in the test driver
script name and the parent folder of the JavaScript node_modules npm root folder. It creates a
subfolder containing the formatted unit test results files, and returns a summary of the results.

**************************************************************************************************#>
Using Module ..\..\TimerSet\TimerSet.psm1
Import-Module ..\..\Utils\Utils.psm1, ..\..\TrapitUtils\TrapitUtils.psm1

$DELIM = '|'
$CON,  $INC,  $INI,  $GET,  $GETF,  $SELF,  $SELFF,  $RES = 
"CON", "INC", "INI", "GET", "GETF", "SELF", "SELFF", "RES"
$EVENT_SEQUENCE, $SCALARS = "Event Sequence", "Scalars"
$TIMER_SET_1, $TIMER_SET_1_F,      $TIMER_SET_2, $TIMER_SET_2_F = 
"Set 1",      "Set 1 (formatted)", "Set 2",      "Set 2 (formatted)"
$SELF_GRP,         $SELF_GRP_F,                  $RES_GRP,  $EXCEPTION = 
"Self (unmocked)", "Self (unmocked, formatted)", "Results", "Exception"
[int]$counter_n = 0
[int]$counter_c = 0
function purelyWrap-Unit([PSCustomObject]$inpGroups) {# json object for a single scenario, with inputs

    $script:counter_n = 0
    $script:counter_c = 0
    $scalarsCsv = $inpGroups.$SCALARS[0]
    $scalars = @()
    foreach ($s in $scalarsCsv.split($DELIM)) {
        $scalars += $s
    }
    [string]$mock_yn, [int]$timeWidth, [int]$dpTotals, [int]$dpPerCall, [int]$callsWidth = $scalars
    $events = $inpGroups.$EVENT_SEQUENCE
    [string[][]]$times = @()
    foreach ($e in $events) {
        $times += ,@($e.split($DELIM))
    }
    $timerSet = @{}
    [ScriptBlock]$getEla = {
        [long]([double]$times[$script:counter_n++][3] * 10000000)
    }
    [ScriptBlock]$getCpu = {
        [long]([double]$times[$script:counter_c++][4] * 10000000)
    }
    $outArr, $outArrF, $exceptions, $selfTimer, $selfTimerF, $results = 
    @(@{$TIMER_SET_1 = @(); $TIMER_SET_2 = @()}, @{$TIMER_SET_1 = @(); $TIMER_SET_2 = @()}, @(), @(), @(), @())
    foreach ($eventCsv in $events) {
        [string]$setNm, [string]$timerNm, [string]$event, [double]$elaTime, [double]$cpuTime = $eventCsv.split($DELIM)
        if ($mock_yn -ne 'Y') { Start-MySleep $elaTime }
        if ($event -eq $CON) {
            $timerSet[$setNm] = $(if ($mock_yn -eq 'Y') {
                                    [TimerSet]::New($setNm, $getEla, $getCpu)
                                } else {
                                    [TimerSet]::New($setNm)
                                })
        } elseif ($event -eq $INC) {
            $timerSet[$setNm].incrementTime($timerNm)
        } elseif ($event -eq $INI) {
            $timerSet[$setNm].initTime()
        } elseif ($event -eq $GET) {
            foreach ($t in ($timerSet[$setNm]).getTimers()) {
                $outArr[$setNm] += ($t.timer + $DELIM + $t.ela + $DELIM + $t.cpu + $DELIM + $t.calls)
            }
        } elseif ($event -eq $GETF) {
            try {
                if ($timeWidth -eq 0) {
                    $outArrF[$setNm] = $timerSet[$setNm].formatTimers()
                } else {
                    $outArrF[$setNm] = $timerSet[$setNm].formatTimers($timeWidth, $dpTotals, $dpPerCall, $callsWidth)
                }
            } catch {
                $outArrF[$setNm] = @()
                $exceptions = @($_.Exception.Message, $_.ScriptStackTrace)
            }
        } elseif ($event -eq $SELF) {
            $st = [TimerSet]::getSelfTimer()
            [string[]]$selfTimer = @($st.ela.ToString() + $DELIM + $st.cpu.ToString())
        } elseif ($event -eq $SELFF) {
            [string[]]$selfTimerF = [TimerSet]::formatSelfTimer()
        } elseif ($event -eq $RES) {
            [string[]]$results = $timerSet[$setNm].formatResults()
        }
    }
    [PSCustomObject]@{
                $TIMER_SET_1    = $outArr[$TIMER_SET_1]
                $TIMER_SET_1_F  = $outArrF[$TIMER_SET_1]
                $TIMER_SET_2    = $outArr[$TIMER_SET_2]
                $TIMER_SET_2_F  = $outArrF[$TIMER_SET_2]
                $SELF_GRP       = $selfTimer
                $SELF_GRP_F     = $selfTimerF
                $RES_GRP        = $results
                $EXCEPTION      = $exceptions
    }
}
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'timerset_ps' ${function:purelyWrap-Unit}
