@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Vendor Master'
define view entity ZI_PR_SU_VENDOR
  as select from zpr_su_vendor
{
  key vendor_uuid   as VendorUuid,
      vendor_code   as VendorCode,
      vendor_name   as VendorName,
      email_address as EmailAddress,
      phone_number  as PhoneNumber,
      country_code  as CountryCode,
      bank_account  as BankAccount,
      is_active     as IsActive
}
