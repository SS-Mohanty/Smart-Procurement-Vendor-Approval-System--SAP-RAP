@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - PR Item'
define view entity ZI_PR_SU_ITEM
  as select from zpr_su_item
  association to parent ZI_PR_SU_HDR as _Header on $projection.PurchaseRequestUuid = _Header.PurchaseRequestUuid
{
  key purchase_request_item_uuid as PurchaseRequestItemUuid,
      
      @ObjectModel.foreignKey.association: '_Header'
      purchase_request_uuid      as PurchaseRequestUuid,
      
      item_number                as ItemNumber,
      item_description           as ItemDescription,
      quantity                   as Quantity,
      unit_of_measure            as UnitOfMeasure,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      unit_price                 as UnitPrice,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      line_total                 as LineTotal,
      currency_code              as CurrencyCode,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt,

      /* Association to Parent */
      _Header
}
