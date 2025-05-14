#This script dumps all email addresses of members for a given group
# Useful for Phishing simulations where you need to import users into a campaign.
#
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All" -NoWelcome

# Define the group ID
$groupId = "your group ID"

# Get members of the dynamic group
$members = Get-MgGroupMemberAsUser -GroupId $groupId -All

# Create an array to hold email addresses
$emailAddresses = @()

# Loop through each member and extract the email address
foreach ($member in $members) {
    if ($member.Mail) {
        $emailAddresses += [PSCustomObject]@{
            Email = $member.Mail
        }
    }
}

# Export the email addresses to a CSV file
$emailAddresses | Export-Csv -Path "email_addresses.csv" -NoTypeInformation
