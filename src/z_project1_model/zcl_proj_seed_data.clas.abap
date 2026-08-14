CLASS zcl_proj_seed_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_proj_seed_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        " 1. Clear old seed data to prevent duplicates
        DELETE FROM zproj_employee.
        DELETE FROM zproj_vendor.

        " 2. Insert 5 Mock Employees (Requesters)
        DATA lt_employees TYPE TABLE OF zproj_employee.
        lt_employees = VALUE #(
          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP001'
            full_name     = 'Ananya Sharma'
            email_address = 'ananya.s@college.edu'
            department    = 'ECE Department'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP002'
            full_name     = 'Rohan Verma'
            email_address = 'rohan.v@college.edu'
            department    = 'VLSI Design Lab'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP003'
            full_name     = 'Priyanka Dash'
            email_address = 'priyanka.d@college.edu'
            department    = 'Embedded Systems'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP004'
            full_name     = 'Aditya Narayan'
            email_address = 'aditya.n@college.edu'
            department    = 'IoT Research Lab'
            is_active     = 'Y' )

          ( client        = sy-mandt
            employee_uuid = cl_system_uuid=>create_uuid_x16_static( )
            employee_id   = 'EMP005'
            full_name     = 'Siddharth Mohanty'
            email_address = 'siddharth.m@college.edu'
            department    = 'RF & Telecom Lab'
            is_active     = 'Y' )
        ).
        INSERT zproj_employee FROM TABLE @lt_employees.

        " 3. Insert 5 Mock Enterprise Vendors (Suppliers)
        DATA lt_vendors TYPE TABLE OF zproj_vendor.
        lt_vendors = VALUE #(
          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN001'
            vendor_name   = 'Dell India Pvt Ltd'
            email_address = 'sales@dell.co.in'
            phone_number  = '1800-425-2067'
            country_code  = 'IN'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN002'
            vendor_name   = 'Texas Instruments India'
            email_address = 'support@ti.com'
            phone_number  = '1800-102-1433'
            country_code  = 'IN'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN003'
            vendor_name   = 'Keysight Technologies'
            email_address = 'contact@keysight.com'
            phone_number  = '1800-112-928'
            country_code  = 'IN'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN004'
            vendor_name   = 'National Instruments'
            email_address = 'ni.india@ni.com'
            phone_number  = '1800-425-7070'
            country_code  = 'IN'
            is_active     = 'Y' )

          ( client        = sy-mandt
            vendor_uuid   = cl_system_uuid=>create_uuid_x16_static( )
            vendor_code   = 'VEN005'
            vendor_name   = 'Xilinx / AMD (FPGA Boards)'
            email_address = 'univ_support@amd.com'
            phone_number  = '1800-103-3600'
            country_code  = 'IN'
            is_active     = 'Y' )
        ).
        INSERT zproj_vendor FROM TABLE @lt_vendors.

        out->write( 'SUCCESS: 5 Employees and 5 Enterprise Vendors inserted into Master Tables!' ).

      CATCH cx_uuid_error.
        out->write( 'ERROR: Could not generate UUIDs.' ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
