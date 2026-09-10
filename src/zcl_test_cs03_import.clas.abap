CLASS zcl_test_cs03_import DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_test_cs03_import IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

   DATA(lo_import) = NEW zcl_import_data03( ).

    DATA lt_warnings          TYPE zcl_import_data03=>tt_import_warnings.
    DATA lv_lookup_failed     TYPE i.
    DATA lt_success_customers TYPE zif_custimport_03=>tt_success_customers.
    DATA lt_error_customers   TYPE zif_custimport_03=>tt_error_customers.
    DATA lt_raw_data          TYPE zif_custimport_03=>tt_raw_data.

    DATA(lv_duplicates) = lo_import->import_data(
      IMPORTING
        et_warnings               = lt_warnings
        ev_lookup_failed          = lv_lookup_failed
        et_badi_success_customers = lt_success_customers
        et_badi_error_customers   = lt_error_customers
        et_badi_raw_data          = lt_raw_data
    ).

    out->write( 'Import wurde ausgeführt.' ).
    out->write( |Duplikate: { lv_duplicates }| ).
    out->write( |Lookup fehlgeschlagen: { lv_lookup_failed }| ).
    out->write( |Anzahl Warnungen/Hinweise: { lines( lt_warnings ) }| ).
    out->write( '---' ).

    out->write( |Erfolgreich übernommen folgende Datensätze ({ lines( lt_success_customers ) }):| ).
    LOOP AT lt_success_customers INTO DATA(ls_success).
      out->write( |{ ls_success-customerid } - { ls_success-company } - { ls_success-street } - | &&
                  |{ ls_success-postcode } { ls_success-city }| ).
    ENDLOOP.

    out->write( '---' ).
    out->write( |Fehlerhafte Datensätze ({ lines( lt_error_customers ) }):| ).
    LOOP AT lt_error_customers INTO DATA(ls_error).
      out->write( |{ ls_error-customerid } - { ls_error-company } - { ls_error-street } - | &&
                  |{ ls_error-postcode } { ls_error-city }| ).
    ENDLOOP.

    out->write( '---' ).
    out->write( |Raw Data ({ lines( lt_raw_data ) }):| ).
    LOOP AT lt_raw_data INTO DATA(lv_raw).
      out->write( lv_raw ).
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
