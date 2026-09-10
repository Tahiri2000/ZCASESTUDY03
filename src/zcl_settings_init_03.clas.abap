CLASS zcl_settings_init_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_settings_init_03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    INSERT zcs03_settings FROM @( VALUE #(
      client   = sy-mandt
      key_code = 'DEFAULT_CURRENCY_TARGET'
      value    = 'EUR'
      active   = 'X'
    ) ).

    IF sy-subrc = 0.
      out->write( 'Eintrag DEFAULT_CURRENCY_TARGET erfolgreich angelegt' ).
    ELSE.
      out->write( 'Eintrag DEFAULT_CURRENCY_TARGET bereits vorhanden oder Fehler' ).
    ENDIF.

    INSERT zcs03_settings FROM @( VALUE #(
      client   = sy-mandt
      key_code = 'FISCAL_YEAR_START'
      value    = '0701'
      active   = 'X'
    ) ).

    IF sy-subrc = 0.
      out->write( 'Eintrag FISCAL_YEAR_START erfolgreich angelegt' ).
    ELSE.
      out->write( 'Eintrag FISCAL_YEAR_START bereits vorhanden oder Fehler' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
