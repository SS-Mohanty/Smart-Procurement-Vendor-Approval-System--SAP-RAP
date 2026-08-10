@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manager Window - PR Header Projection'
@Metadata.allowExtensions: true
/* --- ADD THESE 3 LINES TO HIDE STANDARD BUTTONS --- */
@UI.createHidden: true
@UI.updateHidden: true
@UI.deleteHidden: true
define root view entity ZC_PR_SU_MGR_HDR
  provider contract transactional_query
  as projection on ZI_PR_SU_HDR
{
  key PurchaseRequestUuid,
      RequestNumber,
      @ObjectModel.text.element: ['RequesterName']
      RequesterUuid,
      _Requester.FullName as RequesterName,
    
      VendorUuid,
      RequestTitle,
      RequestDescription,
      RequiredByDate,
      Status,
      RejectionReason,
      OverallAmount,
      CurrencyCode,
      PaymentQrUrl,
      ReceiptFile,
      ReceiptFilename,
      ReceiptMimetype,
      CreatedBy,
      CreatedOn,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Items : redirected to composition child ZC_PR_SU_MGR_ITEM,
      /* ADD THIS LINE: */
      _History : redirected to composition child ZC_PR_SU_MGR_HIST,
      _Requester,
      _Vendor
}
/* MANAGER FILTER: Only show submitted requests (Hide unsubmitted NEW / INITIAL drafts) */
where Status is not initial 
  and Status <> 'NEW'
