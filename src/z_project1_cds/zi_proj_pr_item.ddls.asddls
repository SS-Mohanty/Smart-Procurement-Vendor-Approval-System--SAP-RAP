@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Request Item Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PROJ_PR_ITEM
  as select from zproj_pr_item

  association to parent ZI_PROJ_PR_HDR as _Header
    on $projection.purchase_request_uuid = _Header.purchase_request_uuid

{
  key purchase_request_item_uuid,

      purchase_request_uuid,

      item_number,

      item_description,

      quantity,

      unit_of_measure,

      @Semantics.amount.currencyCode: 'currency_code'
      unit_price,

      currency_code,

      local_last_changed_at,

      _Header
}
