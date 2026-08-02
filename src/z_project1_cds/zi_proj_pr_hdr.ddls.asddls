@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Request Header Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PROJ_PR_HDR
  as select from zproj_pr_hdr

  composition [0..*] of ZI_PROJ_PR_ITEM as _Items

  association [0..*] to ZI_PROJ_APPR_HIST as _History
      on _History.purchase_request_uuid = $projection.purchase_request_uuid

  association [1..1] to ZI_PROJ_EMPLOYEE as _Requester
      on _Requester.employee_uuid = $projection.requester_uuid

  association [0..1] to ZI_PROJ_VENDOR as _Vendor
      on _Vendor.vendor_uuid = $projection.vendor_uuid

{
  key purchase_request_uuid,

      request_number,
      requester_uuid,
      vendor_uuid,

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

      _Requester,
      _Vendor,
      _Items,
      _History
}
