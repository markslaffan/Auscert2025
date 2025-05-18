### Connect to MS Graph
Connect-MgGraph -Scopes "Directory.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

### List Required Permissions for Entra
$EntraPermissions = @(
    "Directory.ReadWrite.All"
    "Group.ReadWrite.All"
    "User.ReadWrite.All"
)

### List Required Permissions for Exchange
$ExchangePermissions = @(
    "Exchange.ManageAsApp"
)

### Get the MS Graph Service Principal
$EntraGraphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

### Get the MS Exchange Service Principal
$ExchangeGraphApp = Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'"

### Get the Automation Account Service Principal ID
$SPID = (Get-MgServicePrincipal -Filter "displayName eq 'aaacuitinfosecautomation'").id

### Get the MS Entra Graph and Exchange Role IDs, then combine into a single array
[array]$EntraRoles = $EntraGraphApp.AppRoles | Where-Object {$EntraPermissions -contains $_.Value}
[array]$ExchangeRoles = $ExchangeGraphApp.AppRoles | Where-Object {$ExchangePermissions -contains $_.Value}
$Roles = $EntraRoles + $ExchangeRoles

### Assign each permission
foreach($Role in $Roles){
    $AppRoleAssignment = @{
        "PrincipalId" = $SPID
        "ResourceId" =  if ($EntraRoles.Id -contains $Role.Id) {$EntraGraphApp.Id}
                        elseif($ExchangeRoles.Id -contains $Role.Id) {$ExchangeGraphApp.Id}
                        else {""} 
        "AppRoleId" =   $Role.Id
    }
    
    ### Assign the Graph permission
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $SPID -BodyParameter $AppRoleAssignment
}