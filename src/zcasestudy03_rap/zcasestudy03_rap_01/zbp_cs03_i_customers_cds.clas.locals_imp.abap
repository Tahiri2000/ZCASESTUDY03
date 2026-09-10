CLASS lhc_ZCS03_I_CUSTOMERS_CDS DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations
      FOR zcs03_i_customers_cds
      RESULT result.

    METHODS validateEmailAddress
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR zcs03_i_customers_cds~validateEmailAddress.

    METHODS determineCity
      FOR DETERMINE ON SAVE
      IMPORTING keys FOR zcs03_i_customers_cds~determineCity.

    METHODS earlynumbering_create
      FOR NUMBERING
      IMPORTING entities FOR CREATE zcs03_i_customers_cds.

    METHODS showstatistic
      FOR MODIFY
      IMPORTING keys FOR ACTION zcs03_i_customers_cds~ShowStatistic.

    METHODS cancelOrders
      FOR MODIFY
      IMPORTING keys FOR ACTION zcs03_i_customers_cds~cancelOrders.

    METHODS normalizeUrl
      FOR DETERMINE ON SAVE
      IMPORTING keys FOR zcs03_i_customers_cds~normalizeUrl.

ENDCLASS.


CLASS lhc_ZCS03_I_CUSTOMERS_CDS IMPLEMENTATION.


  METHOD get_global_authorizations.

    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.

    IF requested_authorizations-%action-ShowStatistic = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT 'ZCS03_STAT'
        ID 'ACTVT' FIELD '03'.

      IF sy-subrc = 0.
        result-%action-ShowStatistic = if_abap_behv=>auth-allowed.
      ELSE.
        result-%action-ShowStatistic = if_abap_behv=>auth-unauthorized.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD validateEmailAddress.

    READ ENTITIES OF zcs03_i_customers_cds IN LOCAL MODE
      ENTITY zcs03_i_customers_cds
        FIELDS ( Email )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_customers).

    LOOP AT lt_customers INTO DATA(ls_customer).

      " Email ist kein Pflichtfeld.
      " Ein leeres Feld ist kein Fehler.
      CHECK ls_customer-Email IS NOT INITIAL.

      DATA(lv_email) = CONV string( ls_customer-Email ).

      DATA(lv_valid) = zcl_email_vali03=>is_valid(
        iv_email = lv_email
      ).

      IF lv_valid = abap_false.

        APPEND VALUE #(
          %tky = ls_customer-%tky
        ) TO failed-zcs03_i_customers_cds.

        APPEND VALUE #(
          %tky = ls_customer-%tky
          %msg = new_message(
            id       = 'ZCS03_TRANSFER'
            number   = '005'
            severity = if_abap_behv_message=>severity-error
            v1       = CONV string( ls_customer-email )
          )
        ) TO reported-zcs03_i_customers_cds.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD determineCity.

    READ ENTITIES OF zcs03_i_customers_cds IN LOCAL MODE
      ENTITY zcs03_i_customers_cds
        FIELDS ( Postcode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_customers).

    DELETE lt_customers WHERE Postcode IS INITIAL.

    CHECK lt_customers IS NOT INITIAL.

    DATA lt_update TYPE TABLE FOR UPDATE zcs03_i_customers_cds.

    LOOP AT lt_customers INTO DATA(ls_customer).

      SELECT SINGLE city
        FROM zcs03_plz_city
        WHERE postcode = @ls_customer-Postcode
        INTO @DATA(lv_city).

      IF sy-subrc = 0.

        APPEND VALUE #(
          %tky          = ls_customer-%tky
          City          = lv_city
          %control-City = if_abap_behv=>mk-on
        ) TO lt_update.

      ENDIF.

    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zcs03_i_customers_cds IN LOCAL MODE
      ENTITY zcs03_i_customers_cds
        UPDATE FIELDS ( City )
        WITH lt_update.

  ENDMETHOD.


  METHOD earlynumbering_create.

    DATA(lo_util) = NEW zcl_nr_util_03( ).

    LOOP AT entities INTO DATA(ls_entity).

      DATA(lv_id) = ls_entity-Customerid.

      IF lv_id IS INITIAL.

        TRY.

            lv_id = lo_util->get_next_customer_id( ).

          CATCH cx_number_ranges INTO DATA(lx_nr).

            APPEND VALUE #(
              %cid = ls_entity-%cid
            ) TO failed-zcs03_i_customers_cds.

            APPEND VALUE #(
              %cid = ls_entity-%cid
              %msg = new_message(
                id       = 'ZCS03_TRANSFER'
                number   = '005'
                severity = if_abap_behv_message=>severity-error
                v1       = CONV #( lx_nr->get_text( ) )
              )
            ) TO reported-zcs03_i_customers_cds.

            CONTINUE.

        ENDTRY.

      ENDIF.

      APPEND VALUE #(
        %cid        = ls_entity-%cid
        %is_draft   = ls_entity-%is_draft
        Customerid  = lv_id
      ) TO mapped-zcs03_i_customers_cds.

    ENDLOOP.

  ENDMETHOD.


  METHOD showstatistic.

    DATA lv_reason TYPE i.

    LOOP AT keys INTO DATA(ls_key).

      " Berechtigung für Statistik anzeigen
      " AUTHORITY-CHECK OBJECT 'Z00_STAT'

      AUTHORITY-CHECK OBJECT 'ZCS03_STA2'
        ID 'ACTVT' FIELD '03'.

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = ls_key-%tky
        ) TO failed-zcs03_i_customers_cds.

        APPEND VALUE #(
          %tky = ls_key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Keine Berechtigung für Statistik anzeigen'
          )
        ) TO reported-zcs03_i_customers_cds.

        CONTINUE.

      ENDIF.


      DATA(lo_stat) = zcl_statistics_factory=>get_statistics_instance(
        EXPORTING
          iv_customerid = ls_key-Customerid
        IMPORTING
          ev_reason     = lv_reason
      ).

      IF lo_stat IS NOT BOUND.

        DATA(lv_msgno) = COND symsgno(
          WHEN lv_reason =
               zcl_statistics_factory=>gc_reason-interface_not_implemented
          THEN '003'
          ELSE '002'
        ).

        APPEND VALUE #(
          %tky = ls_key-%tky
          %msg = new_message(
            id       = 'ZCS03_STATISTIC_MSG'
            number   = lv_msgno
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-zcs03_i_customers_cds.

        CONTINUE.

      ENDIF.


      DATA(lv_country) = COND land1(
        WHEN sy-langu = 'D' THEN 'DE'
        ELSE 'US'
      ).

      APPEND VALUE #(
        %tky = ls_key-%tky
        %msg = new_message(
          id       = 'ZCS03_TRANSFER'
          number   = '006'
          severity = if_abap_behv_message=>severity-information
          v1       = |{ lo_stat->average_sales( ) COUNTRY = lv_country }|
          v2       = |{ lo_stat->max_sales( ) COUNTRY = lv_country }|
          v3       = |{ lo_stat->day_sales( ) COUNTRY = lv_country }|
        )
      ) TO reported-zcs03_i_customers_cds.

    ENDLOOP.

  ENDMETHOD.


  METHOD cancelOrders.

    LOOP AT keys INTO DATA(ls_key).

      zcl_cs03_cancel_orders=>cancel(
        iv_customerid = ls_key-%param-req_customerid
      ).

      APPEND VALUE #(
        %cid = ls_key-%cid
        %msg = new_message(
          id       = 'ZCS03_TRANSFER2'
          number   = '001'
          severity = if_abap_behv_message=>severity-information
          v1       = CONV #( ls_key-%param-req_customerid )
        )
      ) TO reported-zcs03_i_customers_cds.

    ENDLOOP.

  ENDMETHOD.


  METHOD normalizeurl.

    READ ENTITIES OF zcs03_i_customers_cds
         ENTITY zcs03_i_customers_cds
         FIELDS ( Url )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_rows).

    DATA lt_update TYPE TABLE FOR UPDATE zcs03_i_customers_cds.

    LOOP AT lt_rows INTO DATA(ls_row).

      CHECK ls_row-Url IS NOT INITIAL.

      IF NOT ( ls_row-Url CP 'http://*' OR ls_row-Url CP 'https://*' ).

        APPEND VALUE #(
          %tky            = ls_row-%tky
          Url             = |https://{ ls_row-Url }|
          %control-Url    = if_abap_behv=>mk-on
        ) TO lt_update.

      ENDIF.

    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zcs03_i_customers_cds IN LOCAL MODE
      ENTITY zcs03_i_customers_cds
      UPDATE FIELDS ( Url )
      WITH lt_update.

  ENDMETHOD.

ENDCLASS.
