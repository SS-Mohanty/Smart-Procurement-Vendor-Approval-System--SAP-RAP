@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Employee Master'
define view entity ZI_PR_SU_EMPLOYEE
  as select from zpr_su_employee
{
  key employee_uuid as EmployeeUuid,
      employee_id   as EmployeeId,
      full_name     as FullName,
      email_address as EmailAddress,
      department    as Department,
      role          as Role,
      is_active     as IsActive
}
