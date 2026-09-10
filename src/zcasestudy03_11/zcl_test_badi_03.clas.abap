CLASS zcl_test_badi_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_test_badi_03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Testfall 1: ein Kunde mit VOLLSTÄNDIGER Adresse (sollte NICHT als Fehler zurückkommen)
    SELECT customerid FROM zcs03_customers
      WHERE company IS NOT INITIAL AND street IS NOT INITIAL
        AND city IS NOT INITIAL AND postcode IS NOT INITIAL
      INTO TABLE @DATA(lt_complete_ids)
      UP TO 1 ROWS.

    " Testfall 2: ein Kunde mit UNVOLLSTÄNDIGER Adresse (sollte als Fehler zurückkommen)
    SELECT customerid FROM zcs03_customers
      WHERE street IS INITIAL
      INTO TABLE @DATA(lt_incomplete_ids)
      UP TO 1 ROWS.

    DATA(lt_test_ids) = VALUE zif_custimport_03=>tt_customer_ids( ).
    LOOP AT lt_complete_ids INTO DATA(ls_complete).
      APPEND ls_complete-customerid TO lt_test_ids.
    ENDLOOP.
    LOOP AT lt_incomplete_ids INTO DATA(ls_incomplete).
      APPEND ls_incomplete-customerid TO lt_test_ids.
    ENDLOOP.

    out->write( |Teste mit { lines( lt_test_ids ) } Kundennummern (1x vollständig, 1x unvollständig)| ).

    " Testfall 3+4: eine gültige Rohzeile (>=4 Felder) und eine ungültige (<4 Felder)
    DATA(lt_test_raw) = VALUE zif_custimport_03=>tt_raw_data(
      ( |"Testfirma";"Teststr. 1";"12345";"Hamburg"| )
      ( |"Nur zwei Felder";"Rest fehlt"| )
    ).

    DATA lo_badi TYPE REF TO zbadi_custimport_03.
    GET BADI lo_badi.

    DATA lt_error_customers TYPE zif_custimport_03=>tt_error_customers.
    DATA lt_bad_raw         TYPE zif_custimport_03=>tt_raw_data.

    CALL BADI lo_badi->process_data
      EXPORTING
        it_customer_ids    = lt_test_ids
        it_raw_data        = lt_test_raw
      IMPORTING
        et_error_customers = lt_error_customers
        et_raw_data        = lt_bad_raw.

    out->write( |=== Ergebnis Kunden ===| ).
    out->write( |{ lines( lt_error_customers ) } von { lines( lt_test_ids ) } als unvollständig gemeldet (erwartet: 1)| ).
    LOOP AT lt_error_customers INTO DATA(ls_err).
      out->write( |  -> { ls_err-customerid }: '{ ls_err-company }'| ).
    ENDLOOP.

    out->write( |=== Ergebnis Rohzeilen ===| ).
    out->write( |{ lines( lt_bad_raw ) } von { lines( lt_test_raw ) } als fehlerhaft gemeldet (erwartet: 1)| ).
    LOOP AT lt_bad_raw INTO DATA(lv_raw).
      out->write( |  -> '{ lv_raw }'| ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
