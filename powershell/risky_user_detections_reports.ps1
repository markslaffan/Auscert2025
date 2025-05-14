# Connect to Azure using MS Graph
Connect-MgGraph -Scopes IdentityRiskEvent.Read.All -NoWelcome

# This script gets risky users for monthly reporting - this data is stored in most tenants for 90 days. You can use this script to automate the reports, but some changes will need to be made to dump to a sharepoint site

# Calculate the start and end dates for the previous month - note only run this in the next month!

$endDate = (Get-Date -Day 1).AddSeconds(-1) # Last second of the last day of the previous month
$startDate = $endDate.AddMonths(-1).AddDays(1 - $endDate.Day) # First day of the previous month

# Define the output CSV file paths with unique month and year - rename the files if required
$outputFolder = "C:$($env:HOMEPATH)\Documents\output"
$outputCsvPath = "$outputFolder\riskyusers_$($startDate.ToString('yyyy_MM-dd')).csv"
$outputCsvPathDomain1 = "$outputFolder\riskyusers_Domain1_$($startDate.ToString('yyyy_MM-dd')).csv"
$outputCsvPathDomain2 = "$outputFolder\riskyusers_Domain2_$($startDate.ToString('yyyy_MM-dd')).csv"

# Create the output folder if it doesn't exist
if (-not (Test-Path -Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory
}


# Filter information to grab
$filter = "riskState eq 'atRisk' and (riskLevel eq 'high' or riskLevel eq 'medium' or riskLevel eq 'low') and detectedDateTime ge $($startDate.ToString('yyyy-MM-ddTHH:mm:ssZ')) and detectedDateTime le $($endDate.ToString('yyyy-MM-ddTHH:mm:ssZ'))"


$riskDetections = @()
$page = Get-MgRiskDetection -Filter $filter -All

while ($page) {
    $riskDetections += $page
    if ($page.NextPageRequest) {
        $page = $page.NextPageRequest.Invoke()
    } else {
        $page = $null
    }
}

# Output to main file
$riskDetections | Export-Csv -Path $outputCsvPath -NoTypeInformation

# Filter and output to additional files example, change the UPN for different account types! like students or staff
#
#$riskDetectionsDomain1 = $riskDetections | Where-Object { $_.UserPrincipalName -like "*@xxx.xxx.au" }
#$riskDetectionsDomain2 = $riskDetections | Where-Object { $_.UserPrincipalName -like "*@xxx.xxx.au" }

#$riskDetectionsDomain1 | Export-Csv -Path $outputCsvPathDomain1 -NoTypeInformation
#$riskDetectionsDomain2 | Export-Csv -Path $outputCsvPathDomain2 -NoTypeInformation

# Count 'high' risk levels
#$highRiskCountDomain1 = ($riskDetectionsDomain1 | Where-Object { $_.RiskLevel -eq 'high' }).Count
#$highRiskCountDomain2 = ($riskDetectionsDomain2 | Where-Object { $_.RiskLevel -eq 'high' }).Count

# Output the counts
#Write-Output "================================================================="
#Write-Output "Number of 'high' risk levels for STAFF: $highRiskCountDomain1"
#Write-Output "================================================================="
#Write-Output "Number of 'high' risk levels for Students: $highRiskCountDomain2"
#Write-Output "================================================================="
