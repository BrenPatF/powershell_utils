Import-Module Utils
Get-Heading 'Many input groups - 20'
Get-Heading 'Input' 10
$spaces = ' '*73
foreach ($i in 1..20) {

	$spaces + '"Inp Group ' + $i + ';Field 1",'
	$spaces + '"Inp Group ' + $i + ';Field 2",'
}

Get-Heading 'Output' 10
foreach ($i in 1..20) {

	$spaces + '"Inp Group ' + $i + ';|",'
}
$spaces = ' '*73

Get-Heading 'Many input fields - 100'
Get-Heading 'Input' 10
foreach ($i in 1..100) {

	$spaces + '"Inp Group 1;Field ' + $i + '",'
}
Get-Heading 'Output' 10
$spaces + '"Inp Group 1;' + ('|' * 100) + '",'

Get-Heading 'Many output groups - 20'
Get-Heading 'Input' 10
$spaces = ' '*73
foreach ($i in 1..20) {

	$spaces + '"Out Group ' + $i + ';Field 1",'
	$spaces + '"Out Group ' + $i + ';Field 2",'
}

Get-Heading 'Output' 10
foreach ($i in 1..20) {

	$spaces + '"Out Group ' + $i + ';|",'
}

Get-Heading 'Many output fields - 100'
Get-Heading 'Input' 10
$spaces = ' '*73
foreach ($i in 1..100) {

	$spaces + '"Out Group 2;Field ' + $i + '",'
}
Get-Heading 'Output' 10
$spaces + '"Inp Group 2;' + ('|' * 100) + '",'
