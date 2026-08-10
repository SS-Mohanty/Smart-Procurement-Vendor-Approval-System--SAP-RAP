CLASS lhc_PurchaseRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR PurchaseRequest RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PurchaseRequest RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR PurchaseRequest RESULT result.

    METHODS Submit FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Submit RESULT result.

    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Approve RESULT result.

    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Reject RESULT result.

    METHODS AssignVendor FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~AssignVendor RESULT result.

    METHODS GenerateReceipt FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~GenerateReceipt RESULT result.

    METHODS Complete FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Complete RESULT result.

    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseRequest~setDefaultStatus.

    METHODS generateRequestNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseRequest~generateRequestNumber.

    METHODS generatePaymentQR FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseRequest~generatePaymentQR.

    METHODS validateRequester FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateRequester.

    METHODS validateTitle FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateTitle.

    METHODS validateRequiredDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateRequiredDate.

    METHODS validateVendorBeforeComplete FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateVendorBeforeComplete.

ENDCLASS.

CLASS lhc_PurchaseRequest IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      APPEND VALUE #( %tky    = <key>-%tky
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    result = VALUE #( FOR ls_hdr IN lt_headers (
      %tky                 = ls_hdr-%tky

      " 1. EDIT BUTTON: Enabled ONLY when NEW, REJECTED, or APPROVED
      %update              = COND #( WHEN ls_hdr-Status = 'NEW' OR ls_hdr-Status = 'REJECTED' OR
                                          ls_hdr-Status = 'APPROVED' OR ls_hdr-Status IS INITIAL
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      %action-Edit         = COND #( WHEN ls_hdr-Status = 'NEW' OR ls_hdr-Status = 'REJECTED' OR
                                          ls_hdr-Status = 'APPROVED' OR ls_hdr-Status IS INITIAL
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      %delete              = COND #( WHEN ls_hdr-Status = 'NEW' OR ls_hdr-Status = 'REJECTED' OR
                                          ls_hdr-Status = 'COMPLETED' OR ls_hdr-Status IS INITIAL
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      " 2. EMPLOYEE / MANAGER ACTIONS
      %action-Submit       = COND #( WHEN ls_hdr-Status = 'NEW' OR ls_hdr-Status = 'REJECTED'
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      %action-Approve      = COND #( WHEN ls_hdr-Status = 'PENDING'
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      %action-Reject       = COND #( WHEN ls_hdr-Status = 'PENDING'
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      " 3. PROCUREMENT OFFICER STEP 1: Assign Vendor (Enabled ONLY when APPROVED)
      %action-AssignVendor = COND #( WHEN ls_hdr-Status = 'APPROVED'
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      " 4. PROCUREMENT OFFICER STEP 2: Generate Receipt (Enabled ONLY when VENDOR_ASSIGNED)
      %action-GenerateReceipt = COND #( WHEN ls_hdr-Status = 'VENDOR_ASSIGNED'
                                        THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

      " 5. PROCUREMENT OFFICER STEP 3: Complete Order (Enabled ONLY when RECEIPT_READY)
      %action-Complete     = COND #( WHEN ls_hdr-Status = 'RECEIPT_READY'
                                     THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
    ) ).
  ENDMETHOD.

  METHOD setDefaultStatus.
    CLEAR reported.

    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    TRY.
        DATA lv_local_date TYPE d.
        GET TIME STAMP FIELD DATA(lv_ts).
        CONVERT TIME STAMP lv_ts TIME ZONE 'INDIA' INTO DATE lv_local_date.
        IF lv_local_date IS NOT INITIAL.
          lv_today = lv_local_date.
        ENDIF.
      CATCH cx_root ##NO_HANDLER. "#EC NO_HANDLER
    ENDTRY.

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE Status IS INITIAL.
      MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( Status CreatedBy CreatedOn )
          WITH VALUE #( ( %tky       = ls_hdr-%tky
                          Status     = 'NEW'
                          CreatedBy  = cl_abap_context_info=>get_user_technical_name( )
                          CreatedOn  = lv_today ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD generateRequestNumber.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( RequestNumber )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE RequestNumber IS INITIAL.
      TRY.
          DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
          DATA(lv_year)  = lv_today(4).
          DATA(lv_pattern) = |PR-{ lv_year }-%|.

          SELECT MAX( request_number ) FROM zpr_su_hdr
            WHERE request_number LIKE @lv_pattern
            INTO @DATA(lv_max_req).       "#EC CI_NOWHERE

          SELECT MAX( requestnumber ) FROM zpr_su_d_hdr
            WHERE requestnumber LIKE @lv_pattern
            INTO @DATA(lv_max_draft).     "#EC CI_NOWHERE

          IF lv_max_draft > lv_max_req.
            lv_max_req = lv_max_draft.
          ENDIF.

          DATA lv_next_seq TYPE i VALUE 1.
          IF lv_max_req IS NOT INITIAL AND strlen( lv_max_req ) >= 12.
            DATA(lv_last_num) = lv_max_req+8(4).
            lv_next_seq = CONV i( lv_last_num ) + 1.
          ENDIF.

          DATA(lv_req_number) = |PR-{ lv_year }-{ lv_next_seq WIDTH = 4 PAD = '0' ALIGN = RIGHT }|.

          MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
            ENTITY PurchaseRequest
              UPDATE FIELDS ( RequestNumber )
              WITH VALUE #( ( %tky          = ls_hdr-%tky
                              RequestNumber = CONV #( lv_req_number ) ) ).
        CATCH cx_root ##NO_HANDLER.       "#EC NO_HANDLER
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD Submit.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-RequestTitle IS INITIAL OR ls_hdr-RequesterUuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Cannot Submit: Please fill Request Title and Requester!' )
                      ) TO reported-purchaserequest.
        CONTINUE.
      ENDIF.

      READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest BY \_Items
          ALL FIELDS WITH VALUE #( ( %tky = ls_hdr-%tky ) )
        RESULT DATA(lt_items).

      IF lt_items IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Cannot Submit: Please add at least one Requested Item!' )
                      ) TO reported-purchaserequest.
        CONTINUE.
      ENDIF.

      " FIXED: Corrected EML Syntax to CREATE BY \_History
      MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( %tky   = ls_hdr-%tky
                          Status = 'PENDING' ) )
        ENTITY PurchaseRequest
          CREATE BY \_History FIELDS ( EventType OldStatus NewStatus Comments )
          WITH VALUE #( ( %tky = ls_hdr-%tky
                          %target = VALUE #( (
                            %cid      = 'HIST_SUBMIT'
                            EventType = 'SUBMIT'
                            OldStatus = ls_hdr-Status
                            NewStatus = 'PENDING'
                            Comments  = 'Request submitted for Manager review'
                          ) ) ) ).

      APPEND VALUE #( %tky = VALUE #( )
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = 'Purchase Request successfully submitted for Manager review!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.

    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD Approve.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      " FIXED: Corrected EML Syntax to CREATE BY \_History
      MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( Status RejectionReason )
          WITH VALUE #( ( %tky            = ls_hdr-%tky
                          Status          = 'APPROVED'
                          RejectionReason = '' ) )
        ENTITY PurchaseRequest
          CREATE BY \_History FIELDS ( EventType OldStatus NewStatus Comments )
          WITH VALUE #( ( %tky = ls_hdr-%tky
                          %target = VALUE #( (
                            %cid      = 'HIST_APP'
                            EventType = 'APPROVE'
                            OldStatus = ls_hdr-Status
                            NewStatus = 'APPROVED'
                            Comments  = 'Request approved by Manager'
                          ) ) ) ).
    ENDLOOP.

    result = VALUE #( FOR ls_res IN lt_headers ( %tky   = ls_res-%tky
                                                 %param = ls_res ) ).
  ENDMETHOD.

METHOD Reject.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    " Loop over 'keys' directly to access the Popup parameters naturally
    LOOP AT keys INTO DATA(ls_key).

      " 1. EXPLICIT KEY FIX: We explicitly tell the compiler to use the RAP secondary key 'id'
      DATA(ls_hdr) = VALUE #( lt_headers[ KEY id %tky = ls_key-%tky ] OPTIONAL ).
      IF ls_hdr IS INITIAL.
        CONTINUE.
      ENDIF.

      " 2. Extract the Rejection Reason entered in the Fiori Popup
      DATA(lv_reason) = ls_key-%param-RejectionReason.

      IF lv_reason IS INITIAL.
        lv_reason = 'Rejected by Manager Review'. " Fallback if they leave it blank
      ENDIF.

      " 3. Update Header Status and save the Rejection Reason
      MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( Status RejectionReason )
          WITH VALUE #( ( %tky            = ls_hdr-%tky
                          Status          = 'REJECTED'
                          RejectionReason = lv_reason ) )
        " 4. Push the exact Rejection Reason into the Audit History Log!
        ENTITY PurchaseRequest
          CREATE BY \_History FIELDS ( EventType OldStatus NewStatus Comments )
          WITH VALUE #( ( %tky = ls_hdr-%tky
                          %target = VALUE #( (
                            %cid      = 'HIST_REJ'
                            EventType = 'REJECT'
                            OldStatus = ls_hdr-Status
                            NewStatus = 'REJECTED'
                            Comments  = lv_reason
                          ) ) ) ).

      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = 'Request Rejected and returned to employee.' )
                    ) TO reported-purchaserequest.
    ENDLOOP.

    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD AssignVendor.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-VendorUuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Please select a Vendor from the dropdown first before clicking Assign Vendor!' )
                      ) TO reported-purchaserequest.
      ELSE.
        " FIXED: Corrected EML Syntax to CREATE BY \_History
        MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
          ENTITY PurchaseRequest
            UPDATE FIELDS ( Status )
            WITH VALUE #( ( %tky   = ls_hdr-%tky
                            Status = 'VENDOR_ASSIGNED' ) )
          ENTITY PurchaseRequest
            CREATE BY \_History FIELDS ( EventType OldStatus NewStatus Comments )
            WITH VALUE #( ( %tky = ls_hdr-%tky
                            %target = VALUE #( (
                              %cid      = 'HIST_VEND'
                              EventType = 'ASSIGN_VENDOR'
                              OldStatus = ls_hdr-Status
                              NewStatus = 'VENDOR_ASSIGNED'
                              Comments  = 'Vendor assigned and UPI QR Code generated'
                            ) ) ) ).

        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = 'Vendor assigned successfully! Scannable PhonePe QR Code generated.' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD GenerateReceipt.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      DATA lv_vendor_name TYPE string VALUE 'Not Assigned'.
      IF ls_hdr-VendorUuid IS NOT INITIAL.
        SELECT SINGLE vendor_name FROM zpr_su_vendor
        WHERE vendor_uuid = @ls_hdr-VendorUuid
        INTO @DATA(lv_vname).           "#EC CI_NOWHERE
        IF sy-subrc = 0 AND lv_vname IS NOT INITIAL.
          lv_vendor_name = lv_vname.
        ENDIF.
      ENDIF.

      DATA(lv_req_date) = |{ ls_hdr-RequiredByDate DATE = ISO }|.
      DATA(lv_today)    = |{ cl_abap_context_info=>get_system_date( ) DATE = ISO }|.

      DATA(lv_voucher_txt) =
        |=========================================================\r\n| &&
        |            OFFICIAL PROCUREMENT PAYMENT VOUCHER         \r\n| &&
        |=========================================================\r\n| &&
        | PR Number         : { ls_hdr-RequestNumber }\r\n| &&
        | Request Title     : { ls_hdr-RequestTitle }\r\n| &&
        | Current Status    : { ls_hdr-Status }\r\n| &&
        |---------------------------------------------------------\r\n| &&
        | SUPPLIER / VENDOR DETAILS\r\n| &&
        | Selected Vendor   : { lv_vendor_name }\r\n| &&
        | Vendor UUID       : { ls_hdr-VendorUuid }\r\n| &&
        |---------------------------------------------------------\r\n| &&
        | SCHEDULE & BUDGET DETAILS\r\n| &&
        | Required By Date  : { lv_req_date }\r\n| &&
        | Voucher Gen. Date : { lv_today }\r\n| &&
        | Approved Budget   : { ls_hdr-OverallAmount } { ls_hdr-CurrencyCode }\r\n| &&
        |---------------------------------------------------------\r\n| &&
        | Description       : { ls_hdr-RequestDescription }\r\n| &&
        |=========================================================\r\n| &&
        |  Authorized by SAP Procurement & Fintech Gateway Module \r\n| &&
        |=========================================================\r\n|.

      DATA(lv_xstring) = cl_abap_conv_codepage=>create_out( )->convert( lv_voucher_txt ).
      DATA(lv_filename) = |Voucher_{ ls_hdr-RequestNumber }.txt|.

      " FIXED: Corrected EML Syntax to CREATE BY \_History
      MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( ReceiptFile ReceiptFilename ReceiptMimetype Status )
          WITH VALUE #( ( %tky            = ls_hdr-%tky
                          ReceiptFile     = lv_xstring
                          ReceiptFilename = CONV #( lv_filename )
                          ReceiptMimetype = 'text/plain'
                          Status          = 'RECEIPT_READY' ) )
        ENTITY PurchaseRequest
          CREATE BY \_History FIELDS ( EventType OldStatus NewStatus Comments )
          WITH VALUE #( ( %tky = ls_hdr-%tky
                          %target = VALUE #( (
                            %cid      = 'HIST_REC'
                            EventType = 'GENERATE_RECEIPT'
                            OldStatus = ls_hdr-Status
                            NewStatus = 'RECEIPT_READY'
                            Comments  = 'Payment Voucher generated for Vendor'
                          ) ) ) ).

      APPEND VALUE #(
        %tky = VALUE #( )
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-success
                 text     = |Voucher generated successfully for { lv_vendor_name }!| )
      ) TO reported-purchaserequest.
    ENDLOOP.

    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_res IN lt_headers ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD Complete.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-VendorUuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Cannot complete request without an assigned Vendor!' )
                      ) TO reported-purchaserequest.
      ELSE.
        " FIXED: Corrected EML Syntax to CREATE BY \_History
        MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
          ENTITY PurchaseRequest
            UPDATE FIELDS ( Status )
            WITH VALUE #( ( %tky   = ls_hdr-%tky
                            Status = 'COMPLETED' ) )
          ENTITY PurchaseRequest
            CREATE BY \_History FIELDS ( EventType OldStatus NewStatus Comments )
            WITH VALUE #( ( %tky = ls_hdr-%tky
                            %target = VALUE #( (
                              %cid      = 'HIST_COMP'
                              EventType = 'COMPLETE'
                              OldStatus = ls_hdr-Status
                              NewStatus = 'COMPLETED'
                              Comments  = 'Purchase Request completed and permanently archived!'
                            ) ) ) ).

        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = 'Purchase Request completed and permanently archived!' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD generatePaymentQR.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( OverallAmount VendorUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_pr).

    LOOP AT lt_pr ASSIGNING FIELD-SYMBOL(<pr>).
      IF <pr>-VendorUuid IS NOT INITIAL AND <pr>-OverallAmount > 0.
        DATA(lv_upi_id) = 'mohanty2525@okaxis'.
        DATA(lv_amount) = CONV string( <pr>-OverallAmount ).
        CONDENSE lv_amount NO-GAPS.

        DATA(lv_upi_uri) = |upi://pay?pa={ lv_upi_id }&pn=EnterpriseVendor&am={ lv_amount }&cu=INR|.
        DATA(lv_qr_url)  = |https://api.qrserver.com/v1/create-qr-code/?size=450x450&data={ cl_web_http_utility=>escape_url( lv_upi_uri ) }|.
        MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
          ENTITY PurchaseRequest
            UPDATE FIELDS ( PaymentQrUrl )
            WITH VALUE #( ( %tky         = <pr>-%tky
                            PaymentQrUrl = CONV #( lv_qr_url ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateRequester.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( RequesterUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE RequesterUuid IS INITIAL.
      APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Requester Employee is mandatory!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateTitle.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( RequestTitle )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE RequestTitle IS INITIAL.
      APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Please enter a Request Title!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateRequiredDate.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( RequiredByDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-RequiredByDate IS INITIAL OR ls_hdr-RequiredByDate < lv_today.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Required Date must be today or a future date!' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateVendorBeforeComplete.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( Status VendorUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ( ls_hdr-Status = 'COMPLETED' ) AND ls_hdr-VendorUuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'A Vendor must be assigned before completion!' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_PurchaseRequestItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseRequestItem~calculateTotalAmount.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequestItem~validatePrice.

    METHODS validateQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequestItem~validateQuantity.

ENDCLASS.

CLASS lhc_PurchaseRequestItem IMPLEMENTATION.

  METHOD calculateTotalAmount.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequestItem BY \_Header
        FIELDS ( PurchaseRequestUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      SELECT purchaserequestuuid FROM zpr_su_d_hdr
        INTO TABLE @DATA(lt_draft_headers). "#EC CI_NOWHERE

      LOOP AT lt_draft_headers INTO DATA(ls_draft).
        APPEND VALUE #(
          %tky-PurchaseRequestUuid = ls_draft-purchaserequestuuid
          %tky-%is_draft           = if_abap_behv=>mk-on
        ) TO lt_headers.
      ENDLOOP.
    ENDIF.

    SORT lt_headers BY PurchaseRequestUuid %is_draft.
    DELETE ADJACENT DUPLICATES FROM lt_headers COMPARING PurchaseRequestUuid %is_draft.

    LOOP AT lt_headers INTO DATA(ls_hdr).
      READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest BY \_Items
          FIELDS ( Quantity UnitPrice LineTotal )
          WITH VALUE #( ( %tky = ls_hdr-%tky ) )
        RESULT DATA(lt_items).

      DATA lv_total      TYPE p LENGTH 15 DECIMALS 2 VALUE 0.
      DATA lv_line_total TYPE p LENGTH 15 DECIMALS 2.

      LOOP AT lt_items INTO DATA(ls_item).
        lv_line_total = ls_item-Quantity * ls_item-UnitPrice.
        lv_total      = lv_total + lv_line_total.

        IF ls_item-LineTotal <> lv_line_total.
          MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
            ENTITY PurchaseRequestItem
              UPDATE FIELDS ( LineTotal )
              WITH VALUE #( ( %tky      = ls_item-%tky
                              LineTotal = lv_line_total ) ).
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( OverallAmount )
          WITH VALUE #( ( %tky          = ls_hdr-%tky
                          OverallAmount = lv_total ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validateQuantity.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequestItem
        FIELDS ( Quantity )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item) WHERE Quantity <= 0.
      APPEND VALUE #( %tky = ls_item-%tky ) TO failed-purchaserequestitem.
      APPEND VALUE #( %tky = ls_item-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Item Quantity must be greater than zero!' )
                    ) TO reported-purchaserequestitem.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatePrice.
    READ ENTITIES OF ZI_PR_SU_HDR IN LOCAL MODE
      ENTITY PurchaseRequestItem
        FIELDS ( UnitPrice )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item) WHERE UnitPrice <= 0.
      APPEND VALUE #( %tky = ls_item-%tky ) TO failed-purchaserequestitem.
      APPEND VALUE #( %tky = ls_item-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Item Unit Price must be greater than zero!' )
                    ) TO reported-purchaserequestitem.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
