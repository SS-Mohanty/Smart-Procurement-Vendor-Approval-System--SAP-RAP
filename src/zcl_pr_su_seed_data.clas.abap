CLASS zcl_pr_su_seed_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_pr_su_seed_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        " 1. Clear existing master data
        DELETE FROM zpr_su_employee.
        DELETE FROM zpr_su_vendor.

        " 2. Insert 5 Mock Employees with distinct Persona Roles
        DATA lt_employees TYPE TABLE OF zpr_su_employee.
        lt_employees = VALUE #(
          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP001'
            full_name     = 'Ananya Sharma'
            email_address = 'ananya.s@college.edu'
            department    = 'ECE Department'
            role          = 'EMPLOYEE'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP002'
            full_name     = 'Rohan Verma'
            email_address = 'rohan.v@college.edu'
            department    = 'VLSI Design Lab'
            role          = 'MANAGER'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP003'
            full_name     = 'Priyanka Dash'
            email_address = 'priyanka.d@college.edu'
            department    = 'Embedded Systems'
            role          = 'OFFICER'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP004'
            full_name     = 'Aditya Narayan'
            email_address = 'aditya.n@college.edu'
            department    = 'IoT Research Lab'
            role          = 'EMPLOYEE'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP005'
            full_name     = 'Siddharth Mohanty'
            email_address = 'siddharth.m@college.edu'
            department    = 'RF & Telecom Lab'
            role          = 'MANAGER'
            is_active     = 'Y' )
        ).
        INSERT zpr_su_employee FROM TABLE @lt_employees.

        " 3. Insert 5 Enterprise Vendors with Bank Accounts for QR / Receipts
        DATA lt_vendors TYPE TABLE OF zpr_su_vendor.
        lt_vendors = VALUE #(
          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN001'
            vendor_name   = 'Dell India Pvt Ltd'
            email_address = 'sales@dell.co.in'
            phone_number  = '1800-425-2067'
            country_code  = 'IN'
            bank_account  = 'IN89370400440532013000'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN002'
            vendor_name   = 'Texas Instruments India'
            email_address = 'support@ti.com'
            phone_number  = '1800-102-1433'
            country_code  = 'IN'
            bank_account  = 'IN33400100440532013000'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN003'
            vendor_name   = 'Keysight Technologies'
            email_address = 'contact@keysight.com'
            phone_number  = '1800-112-928'
            country_code  = 'IN'
            bank_account  = 'IN22800100440532013000'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN004'
            vendor_name   = 'National Instruments'
            email_address = 'ni.india@ni.com'
            phone_number  = '1800-425-7070'
            country_code  = 'IN'
            bank_account  = 'IN55400100440532013000'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN005'
            vendor_name   = 'Xilinx / AMD (FPGA Boards)'
            email_address = 'univ_support@amd.com'
            phone_number  = '1800-103-3600'
            country_code  = 'IN'
            bank_account  = 'IN99800100440532013000'
            is_active     = 'Y' )
        ).
        INSERT zpr_su_vendor FROM TABLE @lt_vendors.

        out->write( 'SUCCESS: Phase 1 Master Tables seeded with 5 Employees and 5 Vendors!' ).

      CATCH cx_uuid_error.
        out->write( 'ERROR: Could not generate UUIDs.' ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
