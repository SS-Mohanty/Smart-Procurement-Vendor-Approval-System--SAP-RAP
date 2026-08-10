@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Officer Audit History Projection'
@Metadata.ignorePropagatedAnnotations: true
@UI: {
  headerInfo: { typeName: 'Audit Log', typeNamePlural: 'Audit Logs', title: { type: #STANDARD, value: 'EventType' } }
}
define view entity ZC_PR_SU_OFF_HIST
  as projection on ZI_PR_SU_HIST
{
  @UI.lineItem: [ { position: 10, label: 'Action Taken' } ]
  key ApprovalHistoryUuid,
  
  PurchaseRequestUuid,
  
  @UI.lineItem: [ { position: 20, label: 'Event' } ]
  EventType,
  
  @UI.lineItem: [ { position: 30, label: 'Old Status' } ]
  OldStatus,
  
  @UI.lineItem: [ { position: 40, label: 'New Status' } ]
  NewStatus,
  
  @UI.lineItem: [ { position: 50, label: 'Performed By' } ]
  PerformedBy,
  
  @UI.lineItem: [ { position: 60, label: 'Timestamp' } ]
  PerformedAt,
  
  @UI.lineItem: [ { position: 70, label: 'Comments' } ]
  Comments,

  /* Association back to Officer Header Projection */
  _Header : redirected to parent ZC_PR_SU_OFF_HDR
}
