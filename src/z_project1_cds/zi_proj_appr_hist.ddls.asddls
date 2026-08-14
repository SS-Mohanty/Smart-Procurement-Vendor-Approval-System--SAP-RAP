@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approval History Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PROJ_APPR_HIST
  as select from zproj_appr_hist

  association to ZI_PROJ_PR_HDR as _Header
    on $projection.purchase_request_uuid = _Header.purchase_request_uuid

{
  key approval_history_uuid,

      purchase_request_uuid,

      event_type,

      old_status,

      new_status,

      performed_by,

      performed_at,

      comments,

      _Header
}
