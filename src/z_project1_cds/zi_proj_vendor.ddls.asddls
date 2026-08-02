@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PROJ_VENDOR
  as select from zproj_vendor
{

  key vendor_uuid,

      vendor_code,
      vendor_name,
      email_address,
      phone_number,
      country_code,
      is_active

}
