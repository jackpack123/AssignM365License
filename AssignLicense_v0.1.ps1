
$Outputtimestamp = (get-date).tostring("yyyyMMdd_HHmmss")

#Connect MgGraph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

Start-Transcript "Log-$($env:COMPUTERNAME)-$Outputtimestamp.txt"

#$AllUsers = get-msoluser -all  | where-object {$_.isLicensed -eq $false}
$AllUsers = Get-MgUser -Filter 'assignedLicenses/$count eq 0' -ConsistencyLevel eventual -CountVariable unlicensedUserCount -All

#Define Variables
# User the command get the SkuID: Get-MgSubscribedSku | Select -Property Sku*, ConsumedUnits -ExpandProperty PrepaidUnits | Format-List
#Replace the below variable with the actual SkuID

#$StaffSkuId = "XXXX"
#$StuSkuId = "XXXX"


$StaffSkuId = "STANDARDWOFFPACK_FACULTY"
$StuSkuId = "STANDARDWOFFPACK_STUDENT"


#$StaffSkuId = "xxxxx"
$StaffLicenses = Get-MgSubscribedSku -all | Where-Object -FilterScript {$_.SkuPartNumber -eq $StaffSkuId}
$StaffDisabledPlans = $StaffLicenses.ServicePlans | Where-Object -Property ServicePlanName -in ("EXCHANGE_S_STANDARD") | Select-Object -ExpandProperty ServicePlanId
$Staffaddlicense = @(
    @{SkuId = $StaffLicenses.SkuId
      DisabledPlans = $StaffDisabledPlans
    } #Licnese one
)

#$StuSkuId = "ENTERPRISEPACK"
$StuLicenses = Get-MgSubscribedSku -all | Where-Object -FilterScript {$_.SkuPartNumber -eq $StuSkuId}
$StuDisabledPlans = $StuLicenses.ServicePlans | Where-Object -Property ServicePlanName -in ("EXCHANGE_S_STANDARD") | Select-Object -ExpandProperty ServicePlanId
$Stuaddlicense = @(
    @{SkuId = $StuLicenses.SkuId
      DisabledPlans = $StuDisabledPlans
    } #Licnese one
)



<#
$StaffSkuId = "XXXXX"
$StuSkuId = "XXXX"
$StaffLicense = New-MsolLicenseOptions -AccountSkuId $StaffSkuId -DisabledPlans EXCHANGE_S_STANDARD
$StuLicense = New-MsolLicenseOptions -AccountSkuId $StuSkuId -DisabledPlans EXCHANGE_S_STANDARD
#>

#Foreach for assigning User license except exchange Online Service plan
foreach ($user in $AllUsers)
{

<#$StaffSkuId = "XXXXX"
$StuSkuId = "XXXXX"
$StaffLicense = New-MsolLicenseOptions -AccountSkuId $StaffSkuId -DisabledPlans EXCHANGE_S_STANDARD
$StuLicense = New-MsolLicenseOptions -AccountSkuId $StuSkuId -DisabledPlans EXCHANGE_S_STANDARD
#$waplicenseSKU = $msoluser.Licenses
#>

$upnDomain = $user.UserPrincipalName -split '@'

if ($upnDomain[1] -eq "XXXX")

{
#Update-MgUser -UserId $user.UserPrincipalName -PreferredDataLocation CN
Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses $Staffaddlicense -RemoveLicenses @()
#Set-msoluser -UserPrincipalName $user.UserPrincipalName  -UsageLocation CN
#Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses $StaffSkuId -LicenseOptions $StaffLicense
Write-Host $user.userPrincipalName Licensed OK !

}

if ($upnDomain[1] -eq "XXXX")

{

#Set-msoluser -UserPrincipalName $user.UserPrincipalName  -UsageLocation CN
#Update-MgUser -UserId $user.UserPrincipalName -PreferredDataLocation CN
Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses $Stuaddlicense -RemoveLicenses @()

#Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses $StuSkuId -LicenseOptions $StuLicense

Write-Host $user.userPrincipalName Licensed OK !

}


}

#EXCHANGE_S_STANDARD
Stop-Transcript