CLASS zcl_cs03_cancel_orders DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS cancel
      IMPORTING
        iv_customerid TYPE zcustomeridt3.

ENDCLASS.

CLASS zcl_cs03_cancel_orders IMPLEMENTATION.

  METHOD cancel.

    SELECT orderid, status
   FROM zcs03_custorders
   WHERE customerid = @iv_customerid
   INTO TABLE @DATA(lt_orders).

    CHECK lt_orders IS NOT INITIAL.

    DATA lt_updates TYPE TABLE FOR UPDATE zcs03_i_custorders.

    LOOP AT lt_orders INTO DATA(ls_order).

      DATA(lv_new_status) = COND zstatust3(
       WHEN ls_order-status IS INITIAL THEN 'SN'
        WHEN ls_order-status = 'BO' THEN 'SO'
        WHEN ls_order-status = 'BB' THEN 'SB'
        WHEN ls_order-status = 'BN' THEN 'SN'
        WHEN ls_order-status = 'BA' THEN 'SA'
        ELSE ls_order-status ).

      " Bestellungen, die schon storniert sind oder einen
      " unbekannten Status haben, unverändert lassen.
      CHECK lv_new_status <> ls_order-status.

      lt_updates = VALUE #( BASE lt_updates
        ( %tky = VALUE #( Customerid = iv_customerid
                           Orderid    = ls_order-orderid )
          Status = lv_new_status ) ).

    ENDLOOP.

    CHECK lt_updates IS NOT INITIAL.

    MODIFY ENTITIES OF zcs03_i_custorders
      ENTITY Zcs03ICustorders
        UPDATE FIELDS ( Status )
        WITH lt_updates.


  ENDMETHOD.

ENDCLASS.
