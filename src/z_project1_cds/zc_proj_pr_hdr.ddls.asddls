@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Request Header Projection'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_PROJ_PR_HDR
  provider contract transactional_query
  as projection on ZI_PROJ_PR_HDR
{
  key purchase_request_uuid,
      request_number,

      @ObjectModel.text.element: ['RequesterName']
      requester_uuid,
      _Requester.full_name as RequesterName,

      @ObjectModel.text.element: ['VendorName']
      vendor_uuid,
      _Vendor.vendor_name  as VendorName,

      request_title,
      request_description,
      required_by_date,
      status,
      @Semantics.amount.currencyCode: 'currency_code'
      overall_amount,
      currency_code,
      created_by,
      created_on,
      local_last_changed_at,
      last_changed_at,

      /* Associations */
      _Requester,
      _Vendor,
      _History ,
      _Items : redirected to composition child ZC_PROJ_PR_ITEM
}
