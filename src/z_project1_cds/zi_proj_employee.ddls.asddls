@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PROJ_EMPLOYEE
  as select from zproj_employee
{

  key employee_uuid,

      employee_id,
      full_name,
      email_address,
      department,
      is_active

}
