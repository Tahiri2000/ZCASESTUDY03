CLASS zcl_test_import_11 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS zcl_test_import_11 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA(lo_import) = NEW zcl_import_data03( ).

    DATA lt_warnings         TYPE zcl_import_data03=>tt_import_warnings.
    DATA lv_lookup_failed    TYPE i.
    DATA lv_duplicates       TYPE i.

    TRY.
        lv_duplicates = lo_import->import_data(
          IMPORTING
            et_warnings      = lt_warnings
            ev_lookup_failed = lv_lookup_failed
        ).
      CATCH cx_number_ranges INTO DATA(lx_nr).
        out->write( |Fehler Nummernkreis: { lx_nr->get_text( ) }| ).
        RETURN.
    ENDTRY.

    out->write( |Duplikate: { lv_duplicates }| ).
    out->write( |Lookup fehlgeschlagen: { lv_lookup_failed }| ).
    out->write( |Anzahl Warnungen/Hinweise: { lines( lt_warnings ) }| ).
    out->write( '---' ).

     LOOP AT lt_warnings INTO DATA(ls_warning).
      out->write( |{ ls_warning-customerid } - { ls_warning-fieldname } - { ls_warning-message }| ).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
