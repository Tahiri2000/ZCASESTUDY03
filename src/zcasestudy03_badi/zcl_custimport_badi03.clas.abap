CLASS zcl_custimport_badi03 DEFINITION

  PUBLIC

  FINAL

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_badi_interface.
    INTERFACES zif_custimport_03.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_custimport_badi03 IMPLEMENTATION.

  METHOD zif_custimport_03~process_data.

  CLEAR et_error_customers.
  CLEAR et_success_customers.
  CLEAR et_raw_data.

  LOOP AT it_raw_data INTO DATA(lv_raw_data).

    DATA(lt_fields) = VALUE string_table( ).
    SPLIT lv_raw_data AT ';' INTO TABLE lt_fields.

    IF lines( lt_fields ) < 4.
      APPEND lv_raw_data TO et_raw_data.
    ENDIF.

  ENDLOOP.

  LOOP AT it_customer_ids INTO DATA(lv_customer_id).

    SELECT SINGLE *
      FROM zcs03_customers
      WHERE customerid = @lv_customer_id
      INTO @DATA(ls_customer).

    IF sy-subrc = 0.

      IF ls_customer-company IS INITIAL
         OR ls_customer-street IS INITIAL
         OR ls_customer-city IS INITIAL
         OR ls_customer-postcode IS INITIAL
         OR strlen( ls_customer-company ) >= 60.

        APPEND ls_customer TO et_error_customers.

        " Passende Original-Rohzeile über Adressabgleich finden
        " (Index passt nicht, da it_raw_data alle 490 Zeilen enthält,
        " it_customer_ids aber nur die neuen Kunden)
        LOOP AT it_raw_data INTO DATA(lv_candidate).

          DATA(lt_candidate_fields) = VALUE string_table( ).
          SPLIT lv_candidate AT ';' INTO TABLE lt_candidate_fields.

          LOOP AT lt_candidate_fields ASSIGNING FIELD-SYMBOL(<f>).
            REPLACE ALL OCCURRENCES OF `"` IN <f> WITH ``.
          ENDLOOP.

          IF lines( lt_candidate_fields ) >= 4.

            DATA(lv_candidate_company) = lt_candidate_fields[ 1 ].
            IF strlen( lv_candidate_company ) > 60.
              lv_candidate_company = lv_candidate_company(60).
            ENDIF.

            IF lv_candidate_company    = ls_customer-company
               AND lt_candidate_fields[ 2 ] = ls_customer-street
               AND lt_candidate_fields[ 3 ] = ls_customer-postcode
               AND lt_candidate_fields[ 4 ] = ls_customer-city.

              APPEND lv_candidate TO et_raw_data.
              EXIT.

            ENDIF.
          ENDIF.
        ENDLOOP.

      ELSE.
        APPEND ls_customer TO et_success_customers.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDMETHOD.
ENDCLASS.
