
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome

# Path to the CSV file
$csvPath = "groups.csv"

# Import the CSV file
$groups = Import-Csv -Path $csvPath

# Define the owner object ID (replace with the actual owner object ID)
$ownerObjectId = "owner ID"


# Loop through each group and add the owner
foreach ($group in $groups) {
    $groupId = $group.GroupId
    $bodyParameter = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ownerObjectId"
    }
    try {
        New-MgGroupOwnerByRef -GroupId $groupId -BodyParameter $bodyParameter
        Write-Output "Added owner to group: $groupId"
    } catch {
        Write-Output "Failed to add owner to group: $groupId. Error: $_"
    }
}
