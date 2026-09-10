CLASS zcl_refresh_salesvol03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_refresh_salesvol03 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

      SELECT customerid,
           SUM( order_total )           AS sales_volume,
           SUM( order_total_converted ) AS sales_volume_target
      FROM zcs03_custorders
      GROUP BY customerid
      INTO TABLE @DATA(lt_sums).

    DATA lv_count TYPE i.

    LOOP AT lt_sums INTO DATA(ls_sum).

      UPDATE zcs03_customers
        SET sales_volume        = @ls_sum-sales_volume,
            sales_volume_target = @ls_sum-sales_volume_target
        WHERE customerid = @ls_sum-customerid.

      lv_count = lv_count + sy-dbcnt.

    ENDLOOP.

    out->write( |{ lv_count } Kunde(n) aktualisiert.| ).

  ENDMETHOD.
ENDCLASS.
