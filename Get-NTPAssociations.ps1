<#
.SYNOPSIS
Retrieves NTP associations from networking devices

.NOTES
File Name		: Get-NTPAssociations.ps1
Author			: Cadence James
Prerequisite	: Powershell Version 2.0 or newer
				: PuTTY Release 0.72 or newer
				: 'sites.csv' file
				: Network Device Credentials
				
.HISTORY
	1.0 - 10/05/2023 - Initial Script
#>
$username = Read-Host -Prompt " Username"
$password = Read-Host -Prompt " Password" -AsSecureString
$temppass = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($password)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($temppass)
if (! (Test-Path ".\sites.csv") ) { Write-Host " No 'sites.csv' file found. Please verify" -foreground red; quit }
else { $sites = Import-Csv ".\sites.csv" }
$outfile = ".\NTPAssociations.txt"
New-Item -Path $outfile -Type file -Force | Out-Null
foreach ($site in $sites) {
	$counter = 0
	$testconnection = Test-Connection $( $site.IP ) -Count 1 -Quiet
	if ($testconnection -eq $True) {
		echo y | plink $( $site.IP ) -ssh
		$ntp = $( plink $( $site.IP ) -l $username -pw $password -batch "show ntp associations" )
		Add-Content $outfile ""
		Add-Content $outfile "$($site.IP) - $($site.sitename)"
		Add-Content $outfile "--------------------------"
		foreach ($line in $ntp) {
			if ($counter -lt 4) { $counter++; continue }
			Add-Content $outfile $line
		}
		Add-Content $outfile "=============================================================="
	}
 	else {
  		Add-Content $outfile ""
		Add-Content $outfile "$($site.IP) - $($site.sitename)"
		Add-Content $outfile "--------------------------"
  		Add-Content $outfile "Unable to reach"
    		Add-Content $outfile "=============================================================="
  	}
}
