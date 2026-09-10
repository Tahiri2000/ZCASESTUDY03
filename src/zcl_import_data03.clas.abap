CLASS zcl_import_data03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Struktur für einen Hinweis zu einem übernommenen, aber auffälligen Datensatz.
    " Die Adressfelder werden benötigt, um am Ende von Abschnitt 4 die
    " TATSÄCHLICH gespeicherte customerid nachzutragen - die ID, die beim
    " Erkennen der Auffälligkeit in Abschnitt 2 gezogen wurde, kann bei
    " Mehrzeilen-Duplikaten verworfen worden sein und ist dann ungültig.
    TYPES: BEGIN OF ty_import_warning,
             customerid TYPE zcs03_customers-customerid,
             fieldname  TYPE string,
             message    TYPE string,
             company    TYPE zcs03_customers-company,
             street     TYPE zcs03_customers-street,
             city       TYPE zcs03_customers-city,
             postcode   TYPE zcs03_customers-postcode,
           END OF ty_import_warning.
    TYPES tt_import_warnings TYPE STANDARD TABLE OF ty_import_warning WITH EMPTY KEY.

    CONSTANTS gc_company_maxlen TYPE i VALUE 60.

    METHODS import_data
      EXPORTING et_warnings               TYPE tt_import_warnings
                ev_lookup_failed          TYPE i
                et_badi_success_customers TYPE zif_custimport_03=>tt_success_customers
                et_badi_error_customers   TYPE zif_custimport_03=>tt_error_customers
                et_badi_raw_data          TYPE zif_custimport_03=>tt_raw_data
      RETURNING VALUE(rv_duplicates)      TYPE i
      RAISING   cx_number_ranges.

    METHODS remove_quotes
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_import_data03 IMPLEMENTATION.

  METHOD import_data.

    DATA lt_new_customer_ids TYPE STANDARD TABLE OF zcustomeridt3 WITH EMPTY KEY.

    DATA lt_source TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA ls_source TYPE string.

    DATA lt_customers TYPE SORTED TABLE OF zcs03_customers
      WITH UNIQUE KEY last_name
                       first_name
                       company
                       street
                       city
                       postcode.

    DATA ls_customer TYPE zcs03_customers.

    DATA(lo_util) = NEW zcl_nr_util_03( ).

    DATA lv_duplicates TYPE i.


    "----------------------------------------------------------
    " 1. Importdaten lesen
    "----------------------------------------------------------

    SELECT import
      FROM ztl_00_casestudy
      INTO TABLE @lt_source.

    DATA lt_delta TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    SELECT import FROM ztl_00_cs_delta INTO TABLE @lt_delta.
    APPEND LINES OF lt_delta TO lt_source.


    "----------------------------------------------------------
    " 2. Kunden einlesen, Auffälligkeiten protokollieren, trotzdem übernehmen
    "----------------------------------------------------------

    LOOP AT lt_source INTO ls_source.

      DATA(lv_csv) = ls_source.
      DATA lt_fields TYPE TABLE OF string.

      SPLIT lv_csv AT ';' INTO TABLE lt_fields.

      LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<field>).
        <field> = remove_quotes( <field> ).
      ENDLOOP.

      IF lines( lt_fields ) < 4.
        CONTINUE.
      ENDIF.

      DATA(lv_company)  = lt_fields[ 1 ].
      DATA(lv_street)   = lt_fields[ 2 ].
      DATA(lv_postcode) = lt_fields[ 3 ].
      DATA(lv_city)     = lt_fields[ 4 ].


      CLEAR ls_customer.

      ls_customer-customerid = lo_util->get_next_customer_id( ).

      IF lv_company IS INITIAL
         OR lv_street IS INITIAL
         OR lv_city IS INITIAL
         OR lv_postcode IS INITIAL.

        DATA(lo_field_error) = NEW zcx_03_transfer(
          textid    = zcx_03_transfer=>missing_mandatory_field
          fieldname = COND #( WHEN lv_company  IS INITIAL THEN 'COMPANY'
                               WHEN lv_street   IS INITIAL THEN 'STREET'
                               WHEN lv_city     IS INITIAL THEN 'CITY'
                               ELSE 'POSTCODE' ) ).

        APPEND VALUE #( fieldname = lo_field_error->fieldname
                         message   = lo_field_error->get_text( )
                         company   = lv_company
                         street    = lv_street
                         city      = lv_city
                         postcode  = lv_postcode ) TO et_warnings.

      ENDIF.

      IF strlen( lv_company ) > gc_company_maxlen.

        DATA(lo_length_error) = NEW zcx_03_transfer(
          textid    = zcx_03_transfer=>value_too_long
          fieldname = 'COMPANY'
          maxlen    = gc_company_maxlen ).

        APPEND VALUE #( fieldname = lo_length_error->fieldname
                         message   = lo_length_error->get_text( )
                         company   = lv_company(gc_company_maxlen)
                         street    = lv_street
                         city      = lv_city
                         postcode  = lv_postcode ) TO et_warnings.

        lv_company = lv_company(gc_company_maxlen).

      ENDIF.


      ls_customer-client   = sy-mandt.
      ls_customer-company  = lv_company.
      ls_customer-street   = lv_street.
      ls_customer-postcode = lv_postcode.
      ls_customer-city     = lv_city.


      INSERT ls_customer INTO TABLE lt_customers.

      IF sy-subrc <> 0.
        lv_duplicates = lv_duplicates + 1.
      ENDIF.

    ENDLOOP.


    "----------------------------------------------------------
    " 3. Telefon / Fax / E-Mail zuordnen
    "----------------------------------------------------------

    LOOP AT lt_source INTO ls_source.

      DATA(lv_csv2) = ls_source.

      DATA lt_fields2 TYPE TABLE OF string.

      SPLIT lv_csv2 AT ';' INTO TABLE lt_fields2.

      LOOP AT lt_fields2 ASSIGNING FIELD-SYMBOL(<field2>).
        <field2> = remove_quotes( <field2> ).
      ENDLOOP.

      IF lines( lt_fields2 ) < 7.
        CONTINUE.
      ENDIF.

      DATA(lv_company2)  = lt_fields2[ 1 ].
      DATA(lv_street2)   = lt_fields2[ 2 ].
      DATA(lv_postcode2) = lt_fields2[ 3 ].
      DATA(lv_city2)     = lt_fields2[ 4 ].
      DATA(lv_type2)     = lt_fields2[ 5 ].
      DATA(lv_value1_2)  = lt_fields2[ 6 ].
      DATA(lv_value2_2)  = lt_fields2[ 7 ].

      READ TABLE lt_customers INTO ls_customer
        WITH TABLE KEY
          last_name  = ''
          first_name = ''
          company    = lv_company2
          street     = lv_street2
          city       = lv_city2
          postcode   = lv_postcode2.

      READ TABLE lt_customers INTO ls_customer
             WITH TABLE KEY
               last_name  = ''
               first_name = ''
               company    = lv_company2
               street     = lv_street2
               city       = lv_city2
               postcode   = lv_postcode2.

      IF sy-subrc <> 0.
        APPEND VALUE #( fieldname = 'DEBUG_NOMATCH'
                         message   = |Kein Treffer Abschnitt 3: '{ lv_company2 }' / '{ lv_street2 }' / '{ lv_postcode2 }'|
                         company   = lv_company2
                         street    = lv_street2
                         city      = lv_city2
                         postcode  = lv_postcode2 ) TO et_warnings.
      ENDIF.

      IF sy-subrc = 0.

        IF sy-subrc = 0.

          IF lv_type2 = 'Email'.

            IF zcl_email_vali03=>is_valid( lv_value1_2 ).
              ls_customer-email = lv_value1_2.
            ELSE.
              ls_customer-memo = |{ ls_customer-memo } Ungültige Email: { lv_value1_2 }|.

              APPEND VALUE #( fieldname = 'EMAIL'
                               message   = |Ungültige E-Mail-Adresse: { lv_value1_2 }|
                               company   = lv_company2
                               street    = lv_street2
                               city      = lv_city2
                               postcode  = lv_postcode2 ) TO et_warnings.
            ENDIF.

          ELSEIF lv_type2 = 'Telefax'.

            ls_customer-fax =
              |{ lv_value1_2 }{ lv_value2_2 }|.

          ELSE.

            ls_customer-phone =
              |{ lv_value1_2 }{ lv_value2_2 }|.

          ENDIF.

          MODIFY TABLE lt_customers FROM ls_customer.

        ENDIF.
      ENDIF.
    ENDLOOP.

    "----------------------------------------------------------
    " 4. Neue Kunden ergänzen
    "    Bestehende Kunden werden nicht überschrieben
    "----------------------------------------------------------

    LOOP AT lt_customers INTO ls_customer.

      SELECT SINGLE customerid
        FROM zcs03_customers
        WHERE company  = @ls_customer-company
          AND street   = @ls_customer-street
          AND city     = @ls_customer-city
          AND postcode = @ls_customer-postcode
        INTO @DATA(lv_existing_id).

      IF sy-subrc <> 0.
        INSERT zcs03_customers FROM @ls_customer.
        APPEND ls_customer-customerid TO lt_new_customer_ids.
      ELSE.
        lv_duplicates = lv_duplicates + 1.

        " Bestehenden Kunden holen, um alte vs. neue Werte vergleichen zu können
        SELECT SINGLE *
          FROM zcs03_customers
          WHERE customerid = @lv_existing_id
          INTO @DATA(ls_existing_customer).

        DATA(lv_data_changed) = abap_false.

        IF ls_customer-phone IS NOT INITIAL AND ls_customer-phone <> ls_existing_customer-phone.
          APPEND VALUE #( customerid = lv_existing_id
                           fieldname  = 'PHONE'
                           message    = |Telefonnummer aktualisiert: '{ ls_existing_customer-phone }' -> '{ ls_customer-phone }'|
                           company    = ls_customer-company ) TO et_warnings.
          ls_existing_customer-phone = ls_customer-phone.
          lv_data_changed = abap_true.
        ENDIF.

        IF ls_customer-fax IS NOT INITIAL AND ls_customer-fax <> ls_existing_customer-fax.
          APPEND VALUE #( customerid = lv_existing_id
                           fieldname  = 'FAX'
                           message    = |Fax aktualisiert: '{ ls_existing_customer-fax }' -> '{ ls_customer-fax }'|
                           company    = ls_customer-company ) TO et_warnings.
          ls_existing_customer-fax = ls_customer-fax.
          lv_data_changed = abap_true.
        ENDIF.

        IF ls_customer-email IS NOT INITIAL AND ls_customer-email <> ls_existing_customer-email.
          APPEND VALUE #( customerid = lv_existing_id
                           fieldname  = 'EMAIL'
                           message    = |E-Mail aktualisiert: '{ ls_existing_customer-email }' -> '{ ls_customer-email }'|
                           company    = ls_customer-company ) TO et_warnings.
          ls_existing_customer-email = ls_customer-email.
          lv_data_changed = abap_true.
        ENDIF.

        " memo-Hinweise aus Abschnitt 3 (z. B. ungültige Email) an bestehenden Kunden anhängen,
        " statt sie bei einem Duplikat stillschweigend zu verlieren
        IF ls_customer-memo IS NOT INITIAL.
          ls_existing_customer-memo = |{ ls_existing_customer-memo } { ls_customer-memo }|.
          lv_data_changed = abap_true.
        ENDIF.

        IF lv_data_changed = abap_true.
          MODIFY zcs03_customers FROM @ls_existing_customer.
          APPEND lv_existing_id TO lt_new_customer_ids.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " Warnungen aus Abschnitt 2 tragen noch keine gültige customerid -
    " jetzt anhand der Adresse die tatsächlich gespeicherte Nummer nachtragen
    LOOP AT et_warnings ASSIGNING FIELD-SYMBOL(<warning>).

      SELECT SINGLE customerid
        FROM zcs03_customers
        WHERE company  = @<warning>-company
          AND street   = @<warning>-street
          AND city     = @<warning>-city
          AND postcode = @<warning>-postcode
        INTO @<warning>-customerid.

      IF sy-subrc <> 0.
        ev_lookup_failed = ev_lookup_failed + 1.
      ENDIF.

    ENDLOOP.

    rv_duplicates = lv_duplicates.

    "----------------------------------------------------------
    " 5. BAdI aufrufen - liefert zusätzliche Informationen zu den
    "    neu angelegten Kunden (z. B. unvollständige Adressen)
    "----------------------------------------------------------

    DATA lo_badi TYPE REF TO zbadi_custimport_03.
    GET BADI lo_badi.

    DATA lt_badi_error_customers   TYPE zif_custimport_03=>tt_error_customers.
    DATA lt_badi_success_customers TYPE zif_custimport_03=>tt_success_customers.
    DATA lt_badi_bad_raw           TYPE zif_custimport_03=>tt_raw_data.

    CALL BADI lo_badi->process_data
      EXPORTING
        it_customer_ids      = lt_new_customer_ids
        it_raw_data          = lt_source
      IMPORTING
        et_error_customers   = lt_badi_error_customers
        et_success_customers = lt_badi_success_customers
        et_raw_data          = lt_badi_bad_raw.

    et_badi_success_customers = lt_badi_success_customers.
    et_badi_error_customers   = lt_badi_error_customers.
    et_badi_raw_data          = lt_badi_bad_raw.

    " Kunden mit gekürztem COMPANY-Feld nachträglich als fehlerhaft einstufen -
    " die BAdI selbst weiß nichts von der Kürzung (sieht nur den fertigen,
    " bereits gekürzten DB-Stand), deshalb Abgleich über et_warnings, wo die
    " Kürzung schon protokolliert und mit der echten customerid verknüpft ist.
    DATA(lt_truncated_ids) = VALUE string_table( ).

    LOOP AT et_warnings INTO DATA(ls_warn) WHERE fieldname = 'COMPANY' OR fieldname = 'EMAIL'.
      APPEND ls_warn-customerid TO lt_truncated_ids.
    ENDLOOP.

    DATA(lt_success_filtered) = VALUE zif_custimport_03=>tt_success_customers( ).

    LOOP AT et_badi_success_customers INTO DATA(ls_success_check).

      READ TABLE lt_truncated_ids WITH KEY table_line = ls_success_check-customerid
        TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        " Feld wurde gekürzt -> jetzt zu den fehlerhaften Datensätzen zählen
        APPEND ls_success_check TO et_badi_error_customers.

        " Auch als Rohdaten-Repräsentation aufnehmen, damit der Kunde
        " nachvollziehen kann, welcher Datensatz betroffen ist
        APPEND |{ ls_success_check-company };{ ls_success_check-street };| &&
               |{ ls_success_check-postcode };{ ls_success_check-city }| TO et_badi_raw_data.
      ELSE.
        " Wirklich unverändert übernommen -> bleibt erfolgreich
        APPEND ls_success_check TO lt_success_filtered.
      ENDIF.

    ENDLOOP.

    et_badi_success_customers = lt_success_filtered.


    LOOP AT lt_badi_error_customers INTO DATA(ls_badi_error).
      APPEND VALUE #( customerid = ls_badi_error-customerid
                       fieldname  = 'BADI'
                       message    = 'BAdI: Adresse unvollständig'
                       company    = ls_badi_error-company ) TO et_warnings.
    ENDLOOP.

    LOOP AT lt_badi_bad_raw INTO DATA(lv_bad_raw).
      APPEND VALUE #( fieldname = 'BADI'
                       message   = |BAdI: Rohzeile unvollständig: { lv_bad_raw }| ) TO et_warnings.
    ENDLOOP.

    COMMIT WORK.

  ENDMETHOD.


  METHOD remove_quotes.
    rv_value = iv_value.
    REPLACE ALL OCCURRENCES OF `"` IN rv_value WITH ``.
  ENDMETHOD.

ENDCLASS.
