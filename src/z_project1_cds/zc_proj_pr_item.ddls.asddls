@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Request Item Projection'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PROJ_PR_ITEM
  as projection on ZI_PROJ_PR_ITEM
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

      /* Associations */
      _Header : redirected to parent ZC_PROJ_PR_HDR
}
