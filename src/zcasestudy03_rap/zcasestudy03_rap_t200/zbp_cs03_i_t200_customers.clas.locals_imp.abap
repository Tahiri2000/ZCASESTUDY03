CLASS lhc_ZCS03_I_T200_CUSTOMERS DEFINITION
 INHERITING FROM cl_abap_behavior_handler.
 PRIVATE SECTION.

   METHODS get_global_authorizations
     FOR GLOBAL AUTHORIZATION
     IMPORTING REQUEST requested_authorizations
     FOR zcs03_i_t200_customers
     RESULT result.

   METHODS earlynumbering_create
     FOR NUMBERING
     IMPORTING entities FOR CREATE zcs03_i_t200_customers.

    METHODS convert_currency FOR DETERMINE ON SAVE
  IMPORTING keys FOR ZCS03_I_T200_CUSTORDERS~convert_currency.
    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
      keys FOR ZCS03_I_T200_CUSTORDERS~setDefaultStatus.

  METHODS earlynumbering_cba_orders
  FOR NUMBERING
  IMPORTING entities_cba FOR CREATE ZCS03_I_T200_CUSTOMERS\_Orders.

ENDCLASS.

CLASS lhc_ZCS03_I_T200_CUSTOMERS IMPLEMENTATION.
 METHOD get_global_authorizations.
   result-%create = if_abap_behv=>auth-allowed.
   result-%update = if_abap_behv=>auth-allowed.
   result-%delete = if_abap_behv=>auth-allowed.
 ENDMETHOD.

 METHOD earlynumbering_create.
*   DATA lv_max_id TYPE zcustomeridt3.
*
*   SELECT MAX( customerid )
*     FROM zcs03_customers
*     INTO @lv_max_id.
*
*   IF lv_max_id IS INITIAL.
*     lv_max_id = '000000'.
*   ENDIF.
*
*   LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*     lv_max_id = lv_max_id + 1.
*
*     APPEND VALUE #(
*       %cid      = <entity>-%cid
*       %key      = VALUE #( customerid = lv_max_id )
*       %is_draft = <entity>-%is_draft
*     ) TO mapped-zcs03_i_t200_customers.
*
*   ENDLOOP.


DATA(lo_util) = NEW zcl_nr_util_03( ).

  LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

    TRY.
        DATA(lv_id) = lo_util->get_next_customer_id( ).
      CATCH cx_number_ranges INTO DATA(lx_nr).
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-zcs03_i_t200_customers.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message(
            id       = 'ZCS03_TRANSFER'
            number   = '005'
            severity = if_abap_behv_message=>severity-error
            v1       = CONV #( lx_nr->get_text( ) )
          )
        ) TO reported-zcs03_i_t200_customers.
        CONTINUE.
    ENDTRY.

    APPEND VALUE #( %cid       = <entity>-%cid
                     %is_draft  = <entity>-%is_draft
                     CustomerId = lv_id ) TO mapped-zcs03_i_t200_customers.

  ENDLOOP.

 ENDMETHOD.

  METHOD convert_currency.

 READ ENTITIES OF ZCS03_I_T200_CUSTOMERS IN LOCAL MODE
  ENTITY ZCS03_I_T200_CUSTORDERS
  FIELDS ( OrderTotal Currency TargetCurrency )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_orders).

  CHECK lt_orders IS NOT INITIAL.

  DATA lt_update TYPE TABLE FOR UPDATE ZCS03_I_T200_CUSTORDERS.

  LOOP AT lt_orders INTO DATA(ls_order).

    zcl_cs03_currency_conv=>convert(
      EXPORTING
        iv_amount        = ls_order-OrderTotal
        iv_from_currency = ls_order-Currency
        iv_to_currency   = ls_order-TargetCurrency
      IMPORTING
        ev_amount        = DATA(lv_converted)
        ev_rate_found    = DATA(lv_rate_found)
    ).

    APPEND VALUE #(
      %tky                          = ls_order-%tky
      OrderTotalConverted           = lv_converted
      ChangeRateDate                = sy-datum
      %control-OrderTotalConverted  = if_abap_behv=>mk-on
      %control-ChangeRateDate       = if_abap_behv=>mk-on
    ) TO lt_update.

  ENDLOOP.

  CHECK lt_update IS NOT INITIAL.

  MODIFY ENTITIES OF ZCS03_I_T200_CUSTOMERS IN LOCAL MODE
  ENTITY ZCS03_I_T200_CUSTORDERS
    UPDATE FIELDS ( OrderTotalConverted ChangeRateDate )
    WITH lt_update.


  ENDMETHOD.

  METHOD earlynumbering_cba_orders.

 LOOP AT entities_cba INTO DATA(ls_parent).
    LOOP AT ls_parent-%target INTO DATA(ls_child).

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZT200ORD'
            IMPORTING
              number      = DATA(lv_number)
              returncode  = DATA(lv_rcode)
          ).
        CATCH cx_number_ranges INTO DATA(lx_nr).
          APPEND VALUE #( %cid = ls_child-%cid ) TO failed-ZCS03_I_T200_CUSTORDERS.
          APPEND VALUE #(
            %cid = ls_child-%cid
            %msg = new_message(
              id       = 'ZCS03_TRANSFER'
              number   = '005'
              severity = if_abap_behv_message=>severity-error
              v1       = CONV #( lx_nr->get_text( ) )
            )
          ) TO reported-ZCS03_I_T200_CUSTORDERS.
          CONTINUE.
      ENDTRY.

      APPEND VALUE #( %cid       = ls_child-%cid
                       %is_draft  = ls_child-%is_draft
                       CustomerId = ls_child-CustomerId
                       OrderId    = lv_number+14(6) ) TO mapped-ZCS03_I_T200_CUSTORDERS.

    ENDLOOP.
  ENDLOOP.

  ENDMETHOD.

  METHOD setDefaultStatus.

   MODIFY ENTITIES OF ZCS03_I_T200_CUSTOMERS IN LOCAL MODE
      ENTITY ZCS03_I_T200_CUSTORDERS
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR ls_key IN keys (
          %tky            = ls_key-%tky
          Status          = 'BN'
          %control-Status = if_abap_behv=>mk-on
        ) ).



  ENDMETHOD.

ENDCLASS.

