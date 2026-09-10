CLASS zcl_statistics03_quatsch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  INTERFACES zif_statistics03.

    METHODS constructor
      IMPORTING
        iv_customerid TYPE zcustomeridt3 OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_statistics03_quatsch IMPLEMENTATION.
   METHOD constructor.
    " Testklasse - iv_customerid wird bewusst ignoriert,
    " liefert unabhängig vom Kunden immer denselben Quatschwert.
  ENDMETHOD.

  METHOD zif_statistics03~average_sales.
    rv_average_sales = '-99999.99'.
  ENDMETHOD.

  METHOD zif_statistics03~max_sales.
    rv_max_sales = '+99999.99'.
  ENDMETHOD.

  METHOD zif_statistics03~day_sales.
    rv_day_sales = '99999.99'.
  ENDMETHOD.

ENDCLASS.
