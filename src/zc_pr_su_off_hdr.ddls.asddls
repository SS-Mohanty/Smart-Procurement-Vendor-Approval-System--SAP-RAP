@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Officer Window - PR Header Projection'
@Metadata.allowExtensions: true

define root view entity ZC_PR_SU_OFF_HDR
  provider contract transactional_query
  as projection on ZI_PR_SU_HDR
{
  key PurchaseRequestUuid,
      RequestNumber,
      @ObjectModel.text.element: ['RequesterName']
      RequesterUuid,
      _Requester.FullName as RequesterName,
      /* Bind VendorName as clean readable text for VendorUuid */
      @ObjectModel.text.element: ['VendorName']
      VendorUuid,
      _Vendor.VendorName as VendorName,
      RequestTitle,
      RequestDescription,
      RequiredByDate,
      Status,
      RejectionReason,
      OverallAmount,
      CurrencyCode,
     @Semantics.imageUrl: true
      PaymentQrUrl,

      /* FIXED: Clean alias without unreleased Semantics.url annotation */
     // PaymentQrUrl as QrCodeFullUrl,
      ReceiptFile,
      ReceiptFilename,
      ReceiptMimetype,
      CreatedBy,
      CreatedOn,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Items : redirected to composition child ZC_PR_SU_OFF_ITEM,
      _History : redirected to composition child ZC_PR_SU_OFF_HIST,
      _Requester,
      _Vendor
}
/* OFFICER FILTER: Only show Manager-Approved requisitions and downstream procurement steps */
where Status = 'APPROVED'
   or Status = 'VENDOR_ASSIGNED'
   or Status = 'RECEIPT_READY'
   or Status = 'COMPLETED'
