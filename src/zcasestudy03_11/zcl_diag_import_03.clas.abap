CLASS zcl_diag_import_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_diag_import_03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

*
*DELETE FROM zcs03_customers WHERE customerid IS NOT INITIAL.
*    COMMIT WORK.
*
*    out->write( 'Customers-Tabelle geleert' ).

*DELETE FROM zcs03_import_log WHERE log_id IS NOT INITIAL.
*
*COMMIT WORK.
*
*out->write( 'LOG-Tabelle geleert' ).

out->write( 'Nix passiert' ).

  ENDMETHOD.

ENDCLASS.
