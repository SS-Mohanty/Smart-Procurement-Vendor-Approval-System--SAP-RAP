@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Approval History'
define view entity ZI_PR_SU_HIST
  as select from zpr_su_hist
  association to parent ZI_PR_SU_HDR as _Header on $projection.PurchaseRequestUuid = _Header.PurchaseRequestUuid
{
  key approval_history_uuid as ApprovalHistoryUuid,
      
      @ObjectModel.foreignKey.association: '_Header'
      purchase_request_uuid as PurchaseRequestUuid,
      
      event_type            as EventType,
      old_status            as OldStatus,
      new_status            as NewStatus,
      @Semantics.user.createdBy: true
      performed_by          as PerformedBy,
      @Semantics.systemDateTime.createdAt: true
      performed_at          as PerformedAt,
      comments              as Comments,

      /* Association to Parent */
      _Header
}
