<#**************************************************************************************************
Name: TimerSet.psm1                     Author: Brendan Furey                      Date: 27-Aug-2023

Component package in the Powershell code timing module TimerSet. This module facilitates code timing
forinstrumentation and other purposes, with very small footprint in both code and resource usage.

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
|--------------------| *TimerSet*     |  TimerSet class module                                     |
|                    |----------------|------------------------------------------------------------|
|  Test-TimerSet     |  Trapit-Utils  |  Trapit unit testing utility functions                     |                                                                                                                                                                                                                                                                                                                                                                                               
|                    |----------------|------------------------------------------------------------|                                                                                                                                                                                                                                                                               -------------------------------------------------------------|
|--------------------|  Utils         |  General utility functions                                 |
|                    |-----------------------------------------------------------------------------|
|  Install-TimerSet  |                   Install script copies module to Powershell path           |
====================================================================================================

This file has the TimerSet class with methods called by Show-TimerSet and Test-TimerSet scripts

**************************************************************************************************#>
Import-Module Utils
$CALLS_WIDTH, $TIME_WIDTH, $TIME_DP, $TIME_RATIO_DP, $TOT_TIMER, $OTH_TIMER, $SELF_TIME, $TIME_FACTOR =
6,            8,           2,        5,              'Total',    '(Other)',  0.1,        1000
<#*************************************************************************************************

getTimes: Gets elapsed and CPU times using system calls (or mocks) and returns as tuple

*************************************************************************************************#>
[ScriptBlock]$getElaDef = {
    [long]$(Get-Date).ticks
}
[ScriptBlock]$getCpuDef = {
    [long]$(Get-Process -id $pid).TotalProcessorTime.ticks
}
function getTimes ([ScriptBlock]$getEla, [ScriptBlock]$getCpu) {# elapsed, CPU time functions (may be from time, or mocks)
    @{  
        ela = & $getEla
        cpu = & $getCpu
    }
}
<#*************************************************************************************************

valWidths: Handle parameter defaulting, and validate width parameters, int() where necessary
    Parameters: time width and decimal places, time ratio dp, calls width

*************************************************************************************************#>
function valWidths([int]$timeWidth, [int]$timeDP, [int]$timeRatioDP, [int]$callsWidth) {
    if ($timeWidth -lt 8) {
        throw ('Error, timeWidth must be > 7, actual: ' + $timeWidth)
    }
    elseif ($timeDP -gt $timeRatioDP) {
        throw ('Error, timeDP  must be <= timeRatioDP, actual: ' + $timeDP + ', ' + $timeRatioDP)
    }
    elseif ($($timeWidth - $timeDP) -lt 2) {
        throw ('Error, timeWidth - timeDP must be > 1 , actual: ' + $timeWidth + ', ' + $timeDP)
    }
    elseif ($callsWidth -lt 5) {
        throw ('Error, callsWidth must be > 4, actual: ' + $callsWidth)
    }
}
<#*************************************************************************************************

form*: Formatting methods that return formatted times and other values as strings

*************************************************************************************************#>
function formName([string]$name, [int]$maxName) {# timer name, column length as maximum timer name length
    "{0,-$($maxName)}" -f $name
}
function formTime([long]$ticks, [int]$dp, [int]$timeWidth) {# time, decimal places to print
    $t = $ticks / 10000000
    "{0,$($timeWidth):F$dp}" -f $t
}
function formTimeTrim ([long]$ticks, [int]$dp, [int]$timeWidth) { # time, decimal places to print
    (formTime $ticks $dp $timeWidth).Trim()
}
function formCalls([int]$calls, [int]$callsWidth) { # number of calls to timer
    "{0,$($callsWidth)}" -f $calls
}
function formDtTime([date]$dt = (Date)) { # datetime, defaulting to now
    $dt.ToString("yyyy-mm-dd hh:m:ss")
}
<#*************************************************************************************************

timerLine: Returns a formatted timing line
    Parameters: timer name, maximum timer name length, elapsed, cpu times, number of calls to timer,
                time width and decimal places, time ratio dp, calls width

*************************************************************************************************#>
function timerLine([string]$timer, [int]$maxName, [long]$ela, [long]$cpu, [int]$calls, [int]$timeWidth, [int]$timeDP, [int]$timeRatioDP, [int]$callsWidth) {
    [string[]]$arr = @((formName  $timer        $maxName),
                       (formTime  $ela          $timeDP      $timeWidth),
                       (formTime  $cpu          $timeDP      $timeWidth),
                       (formCalls $calls        $callsWidth),
                       (formTime  ($ela/$calls) $timeRatioDP ($timeWidth + $timeRatioDP - $timeDP)),
                       (formTime  ($cpu/$calls) $timeRatioDP ($timeWidth + $timeRatioDP - $timeDP)))
    $arr -join '  '
}
Class TimerSet {
    [string]$timerSetName
    [PSObject]$timBeg
    [PSObject]$timPri
    [System.Collections.Specialized.OrderedDictionary]$timerHash
    [string]$stime
    [PSObject[]]$results
    [ScriptBlock]$getEla
    [ScriptBlock]$getCpu
    <#**********************************************************************************************

    init: Hidden function called by the two versions of the constructor

    **********************************************************************************************#>
    hidden init([string]$timerSetName) {# timer set name
        $this.timerSetName = $timerSetName
        $this.timBeg = (getTimes $this.getEla $this.getCpu)
        $this.timPri = $this.timBeg
        $this.timerHash = @{}
        $this.stime = (Date).ToString("yyyy-MM-dd HH:mm:ss")
        $this.results = @()   
    }
    <#**********************************************************************************************

    TimerSet: Base constructor function and overloaded version passing mock script blocks

    **********************************************************************************************#>
    TimerSet([string]$timerSetName) { # timer set name
        $this.getEla = $script:getElaDef
        $this.getCpu = $script:getCpuDef
        $this.init($timerSetName)
    }
    TimerSet([string]$timerSetName,    # timer set name
             [ScriptBlock]$p_getEla,   # mock script block for elapsed time
             [ScriptBlock]$p_getCpu) { # mock script block for CPU time
        $this.getEla = $p_getEla
        $this.getCpu = $p_getCpu
        $this.init($timerSetName)
    }
    <#**********************************************************************************************

    initTime: Resets the prior time values, to current, for a timer set

    **********************************************************************************************#>
    [void]initTime() {
        $this.timPri = (getTimes $this.getEla $this.getCpu)
    }
    <#**********************************************************************************************

    incrementTime: Increments the timing accumulators for a timer

    **********************************************************************************************#>
    [void]incrementTime([string]$timerName) { # timer name

        $curTim = (getTimes $this.getEla $this.getCpu)

        if ($this.timerHash.$timerName -eq $null) {
            $curHash = @{ela = 0; cpu = 0; calls = 0}
        } else {
            $curHash = $this.timerHash.$timerName
        }
        $ela = $curHash.ela + $curTim.ela - $this.timPri.ela
        $cpu = $curHash.cpu + $curTim.cpu - $this.timPri.cpu
        $this.timerHash[$timerName] = @{ela      = $ela
                                        cpu      = $cpu
                                        calls    = [int]$curHash.calls + 1}
        $this.timPri = $curTim
    }
    <#**********************************************************************************************

    getTimers: Returns the results for timer set in a hashtable of objects

    **********************************************************************************************#>
    [hashtable[]]getTimers() {
        if ($this.results.length -eq 0) {

            $tim = (getTimes $this.getEla $this.getCpu)
            $totTim = @{ela = $tim.ela - $this.timBeg.ela
                        cpu = $tim.cpu - $this.timBeg.cpu}
            $sumTim = @{ela = 0; cpu = 0; calls = 0}
            foreach ($k in $this.timerHash.Keys) {
                $sumTim.ela += $this.timerHash.$k.ela
                $sumTim.cpu += $this.timerHash.$k.cpu
                $sumTim.calls += $this.timerHash.$k.calls
                $this.results += @{     timer = $k
                                        ela   = $this.timerHash.$k.ela
                                        cpu   = $this.timerHash.$k.cpu
                                        calls = $this.timerHash.$k.calls
                                  }
            }
            $this.results += @{ timer = $script:OTH_TIMER
                                ela   = $totTim.ela   - $sumTim.ela
                                cpu   = $totTim.cpu   - $sumTim.cpu
                                calls = 1
                              }
            $this.results += @{ timer = $script:TOT_TIMER
                                ela   = $totTim.ela
                                cpu   = $totTim.cpu
                                calls = $sumTim.calls + 1
                              }
        }
        return $this.results
    }
    <#**********************************************************************************************

    formatTimers: Writes the timers to an array of formatted strings for the timer set

    **********************************************************************************************#>
    [string[]]formatTimers([int]$timeWidth,    # width of base time fields
                           [int]$timeDP,       # number of decimal places for base times
                           [int]$timeRatioDP,  # number of decimal places for time ratios
                           [int]$callsWidth) { # width of calls field

        valWidths $timeWidth $timeDP $timeRatioDP $callsWidth

        $timerArr = $this.getTimers()
        $maxName = [math]::max(7, ($this.timerHash.keys | measure-object -property length -maximum).maximum)
        $lenTime, $lenTimeRatio = ($timeWidth + $timeDP), ($timeWidth + $timeRatioDP)

        [string[]]$fmtArr = @(Get-ColHeadersLis @( @('Timer',    -$maxName),
                                    @('Elapsed',  ($timeWidth)),
                                    @('CPU',      ($timeWidth)),
                                    @('Calls',    ($callsWidth)),
                                    @('Ela/Call', ($timeWidth + $timeRatioDP - $timeDP)),
                                    @('CPU/Call', ($timeWidth + $timeRatioDP - $timeDP))
                                 ))
        $i = 0
        foreach ($k in $timerArr) {
            $fmtArr += (timerLine $k.timer $maxName $k.ela $k.cpu $k.calls $timeWidth $timeDP $timeRatioDP $callsWidth)
            if ($i++ -gt $timerArr.length - 3) {$fmtArr += $fmtArr[1]}
        }
        return $fmtArr
    }
    <#**********************************************************************************************

    formatTimers: Writes the timers to an array of formatted strings for the timer set, defaulting
        widths and decimal places

    **********************************************************************************************#>
    [string[]]formatTimers() {
        return $this.formatTimers($script:TIME_WIDTH, $script:TIME_DP, $script:TIME_RATIO_DP, $script:CALLS_WIDTH)
    }
    <#**********************************************************************************************

    getSelfTimer: Static function returns 2-field object with timings per call for calling 
        incrementTime in a loop

    **********************************************************************************************#>
    static [PSObject]getSelfTimer() {
        $timerTimer = [TimerSet]::New('timer')
        $t, [int]$i = 0, 0
        while (($t -lt (10000000 * $script:SELF_TIME)) -and ($i -lt 100000)) {
            $timerTimer.incrementTime('x')
            if (++$i % 10 -eq 0) {
                $t = $timerTimer.timerHash['x'].ela
            }
        }
        $timerTimes = $timerTimer.timerHash['x']
        return @{ela = $timerTimes.ela/$i; cpu = $timerTimes.cpu/$i}
    }
    <#**********************************************************************************************

    formatSelfTimer: Static function returns formatted string with the results of getSelfTimer

    **********************************************************************************************#>
    static [string]formatSelfTimer( [int]$timeWidth,     # width of base time fields
                                    [int]$timeDP,        # number of decimal places for base times
                                    [int]$timeRatioDP) { # number of decimal places for time ratios
        valWidths $timeWidth $timeDP $timeRatioDP 5
        $t = [TimerSet]::getSelfTimer()
        return '[Timer timed (per call in ms): Elapsed: ' + 
                    (formTimeTrim ($script:TIME_FACTOR * $t.ela) $timeRatioDP $timeWidth) + 
                    ', CPU: ' + (formTimeTrim ($script:TIME_FACTOR * $t.cpu) $timeRatioDP $timeWidth) + ']'
    }
    <#**********************************************************************************************

    formatSelfTimer: Static function returns formatted string with the results of getSelfTimer,
        defaulting width and decimal places

    **********************************************************************************************#>
    static [string]formatSelfTimer() {
        return [TimerSet]::formatSelfTimer($script:TIME_WIDTH, $script:TIME_DP, $script:TIME_RATIO_DP)
    }
    <#**********************************************************************************************

    formatResults: Returns array of formatted strings with the complete results, using formatTimers;
        includes self timing results

    **********************************************************************************************#>
    [string]formatResults([int]$timeWidth,    # width of base time fields
                          [int]$timeDP,       # number of decimal places for base times
                          [int]$timeRatioDP,  # number of decimal places for time ratios
                          [int]$callsWidth) { # width of calls field
    
        valWidths $timeWidth $timeDP $timeRatioDP $callsWidth
        $retVal = Get-Heading("Timer set: " + $this.timerSetName + ", constructed at " + $this.stime + 
            ", written at " + (Date).ToString("yyyy-MM-dd HH:mm:ss"))
        $frmLis = $this.formatTimers($timeWidth, $timeDP, $timeRatioDP, $callsWidth)
        foreach ($l in $frmLis) {
            $retVal += ("`n" + $l)
        }
        $retVal += "`n" + [TimerSet]::formatSelfTimer($timeWidth, $timeDP, $timeRatioDP)
        return $retVal
    }
    <#**********************************************************************************************

    formatResults: Returns array of formatted strings with the complete results, using formatTimers,
        defaulting width and decimal places; includes self timing results

    **********************************************************************************************#>
    [string]formatResults() {
        return $this.formatResults($script:TIME_WIDTH, $script:TIME_DP, $script:TIME_RATIO_DP, $script:CALLS_WIDTH)    
    }
}