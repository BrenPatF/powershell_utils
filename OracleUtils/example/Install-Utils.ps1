<#**************************************************************************************************
Name: Install-Utils.ps1                 Author: Brendan Furey                      Date: 03-Jan-2025

Component script in the Powershell Oracle Utility module OracleUtils. The module has a utility that
facilitates installation of an Oracle database module comprising components such as tables, views,
packages etc. by means of a set of SQL*Plus scripts. These scripts have to be created separately for
the particular Oracle module, while the Powershell utility coordinates their execution. The utility
also allows for copying of files to a folder, such as a folder used for data loading via external
tables.

    GitHub: https://github.com/BrenPatF/powershell_utils

As well as the module file, there is an install script, an example script, and a unit test script.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

It uses unit testing utility functions from the separate Powershell module, TrapitUtils.

====================================================================================================
| Script (.ps1)           | Module (.psm1) |  Notes                                                |
|==================================================================================================|
|  Install-OracleUtils    |     Installer copies module to Powershell path                         |
|-------------------------|------------------------------------------------------------------------|
| *Install-Utils*         |     Example script installs Oracle PL/SQL General Utilities Module     |
|                         |------------------------------------------------------------------------|
|-------------------------|  OracleUtils   |  Powershell Oracle utility functions                  |
|                         |----------------|-------------------------------------------------------|
|                         |  TrapitUtils   |  Trapit unit testing utility functions                |
|                         |------------------------------------------------------------------------|
|  Test-InstallOracleApp  |     Unit test script                                                   |
====================================================================================================

Example script installs Oracle PL/SQL General Utilities Module.

**************************************************************************************************#>
Import-Module OracleUtils
$inputPath = 'c:/input'
$fileLis = @('./unit_test/tt_utils.purely_wrap_utils_inp.json',
             './fantasy_premier_league_player_stats.csv')

$sysSchema = 'sys'
$libSchema = 'lib'
$appSchema = 'app'

$sqlInstalls = @(@{folder = '.';                   script = 'drop_utils_users.sql';  schema = $sysSchema; prmLis = @($libSchema, $appSchema)},
               @{folder = '.';                     script = 'install_sys.sql';       schema = $sysSchema; prmLis = @($libSchema, $appSchema, $inputPath)},
               @{folder = 'lib';                   script = 'install_utils.sql';     schema = $libSchema; prmLis = @($appSchema)},
               @{folder = 'install_ut_prereq\lib'; script = 'install_lib_all.sql';   schema = $libSchema; prmLis = @($appSchema)},
               @{folder = 'install_ut_prereq\app'; script = 'c_syns_all.sql';        schema = $appSchema; prmLis = @($libSchema)},
               @{folder = 'lib';                   script = 'install_utils_tt.sql';  schema = $libSchema; prmLis = @()},
               @{folder = 'app';                   script = 'install_col_group.sql'; schema = $appSchema; prmLis = @($libSchema)},
               @{folder = '.';                     script = 'l_objects.sql';         schema = $sysSchema; prmLis = @($sysSchema)},
               @{folder = '.';                     script = 'l_objects.sql';         schema = $libSchema; prmLis = @($libSchema)},
               @{folder = '.';                     script = 'l_objects.sql';         schema = $appSchema; prmLis = @($appSchema)})

$fileCopies = [PSCustomObject]@{inputPath = $inputPath
                                fileLis = $fileLis}
$ret = Install-OracleApp -fileCopies $fileCopies -sqlInstalls $sqlInstalls -testMode $false
Write-OracleApp $ret
