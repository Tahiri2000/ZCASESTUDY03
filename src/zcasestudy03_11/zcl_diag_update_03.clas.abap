CLASS zcl_diag_update_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_diag_update_03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

  " Einen beliebigen, existierenden Kunden holen
  SELECT customerid, log_id FROM zcs03_customers
    ORDER BY customerid
    INTO TABLE @DATA(lt_before)
    UP TO 1 ROWS.

  DATA(ls_before) = lt_before[ 1 ].

  out->write( |VORHER: customerid={ ls_before-customerid }, log_id='{ ls_before-log_id }'| ).

  " Direktes, isoliertes UPDATE - Testwert
  UPDATE zcs03_customers
    SET log_id = '9999999999'
    WHERE customerid = @ls_before-customerid.

  out->write( |UPDATE sy-subrc: { sy-subrc }| ).

  COMMIT WORK.

  " Nachher nochmal lesen
  SELECT SINGLE log_id FROM zcs03_customers
    WHERE customerid = @ls_before-customerid
    INTO @DATA(lv_after).

  out->write( |NACHHER: log_id='{ lv_after }'| ).

  ENDMETHOD.

ENDCLASS.
