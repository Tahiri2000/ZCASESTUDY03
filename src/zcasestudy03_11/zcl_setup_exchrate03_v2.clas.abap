CLASS zcl_setup_exchrate03_v2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_setup_exchrate03_v2 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.



     MODIFY zcs03_exchrate FROM TABLE @( VALUE #(
   ( client = sy-mandt fromcurr = 'EUR' tocurr = 'AED' startdate = '20260101' exchangerate = '4.00000' )
( client = sy-mandt fromcurr = 'AED' tocurr = 'EUR' startdate = '20260101' exchangerate = '0.25000' )
    ) ).

    out->write( |{ sy-dbcnt } Kurs(e) eingefügt/aktualisiert.| ).


  ENDMETHOD.
ENDCLASS.
