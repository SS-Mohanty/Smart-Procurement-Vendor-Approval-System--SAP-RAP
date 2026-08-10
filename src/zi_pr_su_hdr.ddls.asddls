@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View - PR Header'
define root view entity ZI_PR_SU_HDR
  as select from zpr_su_hdr
  composition [0..*] of ZI_PR_SU_ITEM     as _Items
  composition [0..*] of ZI_PR_SU_HIST     as _History
  association [0..1] to ZI_PR_SU_EMPLOYEE as _Requester on $projection.RequesterUuid = _Requester.EmployeeUuid
  association [0..1] to ZI_PR_SU_VENDOR   as _Vendor    on $projection.VendorUuid    = _Vendor.VendorUuid
{
  key purchase_request_uuid as PurchaseRequestUuid,
      request_number        as RequestNumber,
      
      @ObjectModel.foreignKey.association: '_Requester'
      requester_uuid        as RequesterUuid,
      
      @ObjectModel.foreignKey.association: '_Vendor'
      vendor_uuid           as VendorUuid,
      
      request_title         as RequestTitle,
      request_description   as RequestDescription,
      required_by_date      as RequiredByDate,
      status                as Status,
      rejection_reason      as RejectionReason,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      overall_amount        as OverallAmount,
      currency_code         as CurrencyCode,

      @Semantics.imageUrl: true
      payment_qr_url        as PaymentQrUrl,

      @Semantics.largeObject: {
        mimeType: 'ReceiptMimetype',
        fileName: 'ReceiptFilename',
        contentDispositionPreference: #ATTACHMENT
      }
      receipt_file          as ReceiptFile,
      receipt_filename      as ReceiptFilename,
      @Semantics.mimeType: true
      receipt_mimetype      as ReceiptMimetype,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      created_on            as CreatedOn,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Public Associations */
      _Items,
      _History,
      _Requester,
      _Vendor
}
