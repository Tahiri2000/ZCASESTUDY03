CLASS zcl_test_exchrate_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_exchrate_03 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA lt_rates TYPE STANDARD TABLE OF zcs03_exchrate WITH EMPTY KEY.

  lt_rates = VALUE #(
    ( client = sy-mandt fromcurr = 'USD' tocurr = 'EUR' startdate = '20260101' exchangerate = '0.80000' )
    ( client = sy-mandt fromcurr = 'USD' tocurr = 'EUR' startdate = '20260824' exchangerate = '0.81000' )
  ).
    MODIFY zcs03_exchrate FROM TABLE @lt_rates.

  out->write( |{ sy-dbcnt } Zeilen verarbeitet (insert/update)| ).


*  INSERT zcs03_exchrate FROM TABLE @lt_rates.
*
*  out->write( |{ sy-dbcnt } Zeilen eingefügt| ).

  ENDMETHOD.
ENDCLASS.
