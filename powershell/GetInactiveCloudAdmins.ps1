# Set the date threshold for inactivity (90 days ago)
$InactivityThreshold = (Get-Date).AddDays(-90)

# Connect to Azure using MS Graph
Connect-MgGraph -Scopes User.Read.All -NoWelcome

# Get all users from your tenant with ".admin@" in their UPN
# UPDATE THE UPN FOR YOUR TENANT, If you name your accounts differently, then also update that!

$MyAdminUsers = Get-MgUser -Filter "endswith(userPrincipalName, '.admin@xxxxxx.onmicrosoft.com')" -Property UserPrincipalName, SignInActivity, AccountEnabled -ConsistencyLevel eventual -CountVariable count

# Filter users who have not signed in since the threshold date
$InactiveMyAdminUsers = $MyAdminUsers | Where-Object { 
    $_.SignInActivity.LastSignInDateTime -lt $InactivityThreshold -and $_.SignInActivity.LastSignInDateTime -ne $null 
}

# Output the users found
# $MyAdminUsers | Select-Object UserPrincipalName, LastSignInDateTime, AccountEnabled

# Export the list of inactive myacu.onmicrosoft.com admin users to a CSV file
$InactiveMyAdminUsers | Select-Object UserPrincipalName, @{Name='LastSignInDateTime';Expression={$_.SignInActivity.LastSignInDateTime}}, AccountEnabled | Export-Csv -Path InactiveMyAdminUsers.csv -NoTypeInformation
