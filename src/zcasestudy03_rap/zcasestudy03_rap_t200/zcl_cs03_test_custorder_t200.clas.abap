CLASS zcl_cs03_test_custorder_t200 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_cs03_test_custorder_t200 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_orders TYPE TABLE OF zcs03_custorders.

    lt_orders = VALUE #(

      (
        client                = sy-mandt
        customerid            = '050438'
        orderid               = '900001'
        order_date            = sy-datum
        order_total           = '250.00'
        discount              = '10.00'
        info                  = 'TESTBESTELLUNG 1'
        status                = 'BA'
        currency              = 'EUR'
        target_currency       = 'EUR'
        change_rate_date      = sy-datum
        order_total_converted = '240.00'
      )

      (
        client                = sy-mandt
        customerid            = '050440'
        orderid               = '900002'
        order_date            = sy-datum
        order_total            = '500.00'
        discount              = '20.00'
        info                  = 'TESTBESTELLUNG 2'
        status                = 'BO'
        currency              = 'EUR'
        target_currency       = 'EUR'
        change_rate_date      = sy-datum
        order_total_converted = '480.00'
      )

      (
        client                = sy-mandt
        customerid            = '050443'
        orderid               = '900003'
        order_date            = sy-datum
        order_total            = '750.00'
        discount              = '15.00'
        info                  = 'TESTBESTELLUNG 3'
        status                = 'BB'
        currency              = 'EUR'
        target_currency       = 'EUR'
        change_rate_date      = sy-datum
        order_total_converted = '735.00'
      )

      (
        client                = sy-mandt
        customerid            = '050690'
        orderid               = '900004'
        order_date            = sy-datum
        order_total            = '1200.00'
        discount              = '50.00'
        info                  = 'TESTBESTELLUNG 4'
        status                = 'BA'
        currency              = 'EUR'
        target_currency       = 'EUR'
        change_rate_date      = sy-datum
        order_total_converted = '1150.00'
      )

      (
        client                = sy-mandt
        customerid            = '050439'
        orderid               = '900005'
        order_date             = sy-datum
        order_total            = '350.00'
        discount              = '5.00'
        info                  = 'TESTBESTELLUNG 5'
        status                = 'BO'
        currency              = 'EUR'
        target_currency       = 'EUR'
        change_rate_date       = sy-datum
        order_total_converted  = '345.00'
      )

    ).

    INSERT zcs03_custorders FROM TABLE @lt_orders.

    IF sy-subrc = 0.
      out->write( 'Testbestellungen wurden erfolgreich eingefügt.' ).
    ELSE.
      out->write( |Fehler beim Einfügen. SY-SUBRC: { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
