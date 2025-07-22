$report = [ordered]@{}

$report["Computer name"] = $env:COMPUTERNAME
$report["Username"] = $env:USERNAME

$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
$report["OS"] = "$($os.Caption) $($os.Version)"
$report["Uptime in days"] = [math]::Round($uptime.TotalDays, 1)

$defender = Get-MpComputerStatus
if($defender.AntivirusEnabled) {
	$report["Antivirus Enabled"] = "Yes"
} else {
	$report["Antivirus Enabled"] = "No"
}
if($defender.RealTimeProtectionEnabled) {
	$report["Real-time Protection Enabled"] = "Yes"
} else {
	$report["Real-time Protection Enabled"] = "No"
}
$report["Last scan"] = $defender.LastFullScanTime
$report["Threats detected"] = $defender.ThreatsDetected

$domainProfile = Get-NetFirewallProfile -Profile Domain
$privateProfile = Get-NetFirewallProfile -Profile Private
$publicProfile = Get-NetFirewallProfile -Profile Public

if($domainProfile.Enabled -or $privateProfile.Enabled -or $publicProfile.Enabled) {
	$report["Domain Firewall Enabled"] = "Yes"
} else {
	$report["Domain Firewall Enabled"] = "No"
}
$report["Firewall Domain"] = if($domainProfile.Enabled) { "Enabled" } else { "Disabled" }
$report["Firewall Private"] = if($privateProfile.Enabled) { "Enabled" } else { "Disabled" }
$report["Firewall Public"] = if($publicProfile.Enabled) { "Enabled" } else { "Disabled" }

$hotfixes = Get-HotFix
$report["Last Windows update"] = $hotfixes | Sort-Object InstalledOn -Descending | Select-Object -First 1 -ExpandProperty InstalledOn

Write-Host "`n===== System Report =====`n"
foreach($entry in $report.GetEnumerator()) {
	Write-Host "$($entry.Key): $($entry.Value)"
}

$desktopPath = "$env:USERPROFILE\Documents\Report.txt"
$report | Out-File -FilePath $desktopPath

Write-Host "`nReport saved to: $desktopPath`n"