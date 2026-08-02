CLASS lhc_PurchaseRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR PurchaseRequest RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR PurchaseRequest RESULT result.

    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Approve RESULT result.

    METHODS AssignVendor FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~AssignVendor RESULT result.

    METHODS Complete FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Complete RESULT result.

    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Reject RESULT result.

    METHODS Submit FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseRequest~Submit RESULT result.

    METHODS generateRequestNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseRequest~generateRequestNumber.

    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseRequest~setDefaultStatus.

    METHODS validateRequester FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateRequester.

    METHODS validateRequiredDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateRequiredDate.

    METHODS validateTitle FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseRequest~validateTitle.

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

  METHOD get_instance_features.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    result = VALUE #( FOR ls_hdr IN lt_headers (
      %tky = ls_hdr-%tky
      " Lock down Edit button (%update AND %action-Edit) for PENDING, APPROVED, and COMPLETED
      %update              = COND #( WHEN ls_hdr-status = 'NEW' OR ls_hdr-status = 'REJECTED' OR ls_hdr-status IS INITIAL
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-Edit         = COND #( WHEN ls_hdr-status = 'NEW' OR ls_hdr-status = 'REJECTED' OR ls_hdr-status IS INITIAL
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      " Lock down Delete button for PENDING and APPROVED; keep enabled for NEW, REJECTED, and COMPLETED
      %delete              = COND #( WHEN ls_hdr-status = 'NEW' OR ls_hdr-status = 'REJECTED' OR ls_hdr-status = 'COMPLETED' OR ls_hdr-status IS INITIAL
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-Submit       = COND #( WHEN ls_hdr-status = 'NEW' OR ls_hdr-status = 'REJECTED'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-Approve      = COND #( WHEN ls_hdr-status = 'PENDING'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-Reject       = COND #( WHEN ls_hdr-status = 'PENDING'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-AssignVendor = COND #( WHEN ls_hdr-status = 'APPROVED'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
      %action-Complete     = COND #( WHEN ls_hdr-status = 'APPROVED'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )
    ) ).
  ENDMETHOD.

METHOD setDefaultStatus.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    " Fixed: Force Indian Standard Time ('INDIA', UTC+5:30) directly, bypassing BTP Trial UTC profile
    DATA lv_local_date TYPE d.
    GET TIME STAMP FIELD DATA(lv_ts).
    CONVERT TIME STAMP lv_ts TIME ZONE 'INDIA' INTO DATE lv_local_date.
    IF lv_local_date IS INITIAL.
      CONVERT TIME STAMP lv_ts TIME ZONE 'UTC+5:30' INTO DATE lv_local_date.
    ENDIF.
    IF lv_local_date IS INITIAL.
      lv_local_date = cl_abap_context_info=>get_system_date( ).
    ENDIF.

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE status IS INITIAL.
      MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( status created_by created_on )
          WITH VALUE #( ( %tky       = ls_hdr-%tky
                          status     = 'NEW'
                          created_by = cl_abap_context_info=>get_user_technical_name( )
                          created_on = lv_local_date ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD generateRequestNumber.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( request_number )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE request_number IS INITIAL.
      SELECT COUNT( * ) FROM zproj_pr_hdr   INTO @DATA(lv_active_cnt).
      SELECT COUNT( * ) FROM zproj_pr_hdr_d INTO @DATA(lv_draft_cnt).
      DATA(lv_total_cnt) = lv_active_cnt + lv_draft_cnt + 1.

      DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
      DATA(lv_year)  = lv_today(4).
      DATA(lv_req_number) = |PR-{ lv_year }-{ lv_total_cnt WIDTH = 6 PAD = '0' ALIGN = RIGHT }|.

      MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( request_number )
          WITH VALUE #( ( %tky = ls_hdr-%tky request_number = lv_req_number ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD Submit.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-request_title IS INITIAL OR ls_hdr-requester_uuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Cannot Submit: Please fill Request Title and Requester!' )
                      ) TO reported-purchaserequest.
        CONTINUE.
      ENDIF.

      READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
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

      MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( status )
          WITH VALUE #( ( %tky = ls_hdr-%tky status = 'PENDING' ) ).

      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = 'Purchase Request successfully submitted for Manager review!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.

    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD Approve.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( status )
          WITH VALUE #( ( %tky = ls_hdr-%tky status = 'APPROVED' ) ).

      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = 'Request Approved successfully by Manager!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.

    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD Reject.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( status )
          WITH VALUE #( ( %tky = ls_hdr-%tky status = 'REJECTED' ) ).

      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = 'Request Rejected and returned to employee.' )
                    ) TO reported-purchaserequest.
    ENDLOOP.

    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD AssignVendor.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-vendor_uuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Please select a Vendor from the dropdown first before clicking Assign Vendor!' )
                      ) TO reported-purchaserequest.
      ELSE.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = 'Vendor successfully assigned to this Purchase Request!' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD Complete.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-vendor_uuid IS INITIAL.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Cannot complete request without an assigned Vendor!' )
                      ) TO reported-purchaserequest.
      ELSE.
        MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
          ENTITY PurchaseRequest
            UPDATE FIELDS ( status )
            WITH VALUE #( ( %tky = ls_hdr-%tky status = 'COMPLETED' ) ).

        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = 'Purchase Request completed and permanently archived!' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_headers.

    result = VALUE #( FOR ls_result IN lt_headers ( %tky = ls_result-%tky %param = ls_result ) ).
  ENDMETHOD.

  METHOD validateRequester.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( requester_uuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE requester_uuid IS INITIAL.
      APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Requester Employee is mandatory!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateTitle.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( request_title )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr) WHERE request_title IS INITIAL.
      APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
      APPEND VALUE #( %tky = ls_hdr-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Please enter a Request Title!' )
                    ) TO reported-purchaserequest.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateRequiredDate.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( required_by_date )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ls_hdr-required_by_date IS INITIAL OR ls_hdr-required_by_date < lv_today.
        APPEND VALUE #( %tky = ls_hdr-%tky ) TO failed-purchaserequest.
        APPEND VALUE #( %tky = ls_hdr-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Required Date must be a valid today or future date!' )
                      ) TO reported-purchaserequest.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateVendorBeforeComplete.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequest
        FIELDS ( status vendor_uuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_hdr).
      IF ( ls_hdr-status = 'COMPLETED' ) AND ls_hdr-vendor_uuid IS INITIAL.
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
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequestItem BY \_Header
        FIELDS ( purchase_request_uuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      SELECT purchase_request_uuid FROM zproj_pr_hdr_d
        INTO TABLE @DATA(lt_draft_headers).
      LOOP AT lt_draft_headers INTO DATA(ls_draft).
        APPEND VALUE #(
          %tky-purchase_request_uuid = ls_draft-purchase_request_uuid
          %tky-%is_draft             = if_abap_behv=>mk-on
        ) TO lt_headers.
      ENDLOOP.
    ENDIF.

    SORT lt_headers BY purchase_request_uuid %is_draft.
    DELETE ADJACENT DUPLICATES FROM lt_headers COMPARING purchase_request_uuid %is_draft.

    LOOP AT lt_headers INTO DATA(ls_hdr).
      READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest BY \_Items
          FIELDS ( quantity unit_price )
          WITH VALUE #( ( %tky = ls_hdr-%tky ) )
        RESULT DATA(lt_items).

      DATA lv_total TYPE p LENGTH 15 DECIMALS 2 VALUE 0.
      LOOP AT lt_items INTO DATA(ls_item).
        lv_total = lv_total + ( ls_item-quantity * ls_item-unit_price ).
      ENDLOOP.

      MODIFY ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
        ENTITY PurchaseRequest
          UPDATE FIELDS ( overall_amount )
          WITH VALUE #( ( %tky           = ls_hdr-%tky
                          overall_amount = lv_total ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validateQuantity.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequestItem
        FIELDS ( quantity )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item) WHERE quantity <= 0.
      APPEND VALUE #( %tky = ls_item-%tky ) TO failed-purchaserequestitem.
      APPEND VALUE #( %tky = ls_item-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Item Quantity must be greater than zero!' )
                    ) TO reported-purchaserequestitem.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatePrice.
    READ ENTITIES OF zi_proj_pr_hdr IN LOCAL MODE
      ENTITY PurchaseRequestItem
        FIELDS ( unit_price )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item) WHERE unit_price <= 0.
      APPEND VALUE #( %tky = ls_item-%tky ) TO failed-purchaserequestitem.
      APPEND VALUE #( %tky = ls_item-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Item Unit Price must be greater than zero!' )
                    ) TO reported-purchaserequestitem.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_PurchaseRequest DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_PurchaseRequest IMPLEMENTATION.

  METHOD save_modified.
    DATA lt_history TYPE TABLE OF zproj_appr_hist.
    GET TIME STAMP FIELD DATA(lv_ts).

    LOOP AT update-purchaserequest INTO DATA(ls_hdr).
      DATA(lv_event) = COND string(
        WHEN ls_hdr-status = 'PENDING'   THEN 'SUBMIT'
        WHEN ls_hdr-status = 'APPROVED'  THEN 'APPROVE'
        WHEN ls_hdr-status = 'REJECTED'  THEN 'REJECT'
        WHEN ls_hdr-status = 'COMPLETED' THEN 'COMPLETE'
        ELSE 'UPDATE' ).

      DATA(lv_comment) = COND string(
        WHEN ls_hdr-status = 'PENDING'   THEN 'Request submitted for manager review'
        WHEN ls_hdr-status = 'APPROVED'  THEN 'Request approved by Manager'
        WHEN ls_hdr-status = 'REJECTED'  THEN 'Request rejected by Manager'
        WHEN ls_hdr-status = 'COMPLETED' THEN 'Purchase request completed and archived'
        ELSE 'Request updated' ).

      IF ls_hdr-status = 'PENDING' OR ls_hdr-status = 'APPROVED' OR
         ls_hdr-status = 'REJECTED' OR ls_hdr-status = 'COMPLETED'.
        TRY.
            APPEND VALUE #(
              client                = sy-mandt
              approval_history_uuid = cl_system_uuid=>create_uuid_x16_static( )
              purchase_request_uuid = ls_hdr-purchase_request_uuid
              event_type            = CONV #( lv_event )
              old_status            = 'PREVIOUS_STAGE'
              new_status            = CONV #( ls_hdr-status )
              performed_by          = cl_abap_context_info=>get_user_technical_name( )
              performed_at          = lv_ts
              comments              = CONV #( lv_comment )
            ) TO lt_history.
          CATCH cx_uuid_error.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    IF lt_history IS NOT INITIAL.
      INSERT zproj_appr_hist FROM TABLE @lt_history.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
