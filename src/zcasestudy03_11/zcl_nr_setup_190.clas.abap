CLASS zcl_nr_setup_190 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_nr_setup_190 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


  DATA lt_data TYPE TABLE OF zcs03_activeflag.

    lt_data = VALUE #(
      ( client = sy-mandt value = 'X' text = 'Aktiv' )
      ( client = sy-mandt value = ''  text = 'Inaktiv' )
    ).

    MODIFY zcs03_activeflag FROM TABLE @lt_data.

    IF sy-subrc = 0.
      out->write( 'Wertehilfe-Stammdaten angelegt.' ).
    ELSE.
      out->write( 'Fehler beim Anlegen.' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
