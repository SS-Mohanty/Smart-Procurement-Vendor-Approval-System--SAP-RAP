@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Officer Window - PR Item Projection'
@Metadata.allowExtensions: true
define view entity ZC_PR_SU_OFF_ITEM
  as projection on ZI_PR_SU_ITEM
{
  key PurchaseRequestItemUuid,
      PurchaseRequestUuid,
      ItemNumber,
      ItemDescription,
      Quantity,
      UnitOfMeasure,
      UnitPrice,
      LineTotal,
      CurrencyCode,
      LocalLastChangedAt,

      /* Association to Parent */
      _Header : redirected to parent ZC_PR_SU_OFF_HDR
}
