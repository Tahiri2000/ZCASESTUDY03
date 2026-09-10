CLASS zcl_delete_customers03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_delete_customers03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DELETE FROM zcs03_customers.

    out->write( |Tabelle wurde geleert.| ).

  ENDMETHOD.

ENDCLASS.
