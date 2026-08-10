@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Window - PR Header Projection'
@Metadata.allowExtensions: true
define root view entity ZC_PR_SU_EMP_HDR
  provider contract transactional_query
  as projection on ZI_PR_SU_HDR
{
  key PurchaseRequestUuid,
      RequestNumber,
     /* REQUIREMENT: Bind EmployeeName as text for RequesterUuid */
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
      _Items : redirected to composition child ZC_PR_SU_EMP_ITEM,
     _History : redirected to composition child ZC_PR_SU_EMP_HIST,
      _Requester,
      _Vendor
      
}
