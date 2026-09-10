CLASS zcl_cs03_currency_conv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS convert
      IMPORTING
        iv_amount        TYPE p
        iv_from_currency TYPE zcurrencyt3
        iv_to_currency   TYPE zcurrency_targett3
        iv_date          TYPE zchange_rate_datet3 OPTIONAL
      EXPORTING
        ev_amount        TYPE p
        ev_rate_found    TYPE abap_bool.

ENDCLASS.


CLASS zcl_cs03_currency_conv IMPLEMENTATION.

  METHOD convert.

    CLEAR: ev_amount, ev_rate_found.

    DATA(lv_date) = iv_date.
    IF lv_date IS INITIAL.
      lv_date = cl_abap_context_info=>get_system_date( ).
    ENDIF.

    " Keine Zielwährung oder gleiche Währung -> keine Umrechnung nötig
    IF iv_to_currency IS INITIAL OR iv_to_currency = iv_from_currency.
      ev_amount     = iv_amount.
      ev_rate_found = abap_true.
      RETURN.
    ENDIF.

    " zeitlich zuletzt gültigen Kurs suchen (startdate <= Stichtag)
    SELECT exchangerate
      FROM zcs03_exchrate
      WHERE fromcurr   = @iv_from_currency
        AND tocurr     = @iv_to_currency
        AND startdate <= @lv_date
      ORDER BY startdate DESCENDING
      INTO @DATA(lv_rate)
      UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc = 0.
      ev_amount     = iv_amount * lv_rate.
      ev_rate_found = abap_true.
    ELSE.
      ev_amount     = iv_amount.   " Fallback: unkonvertiert
      ev_rate_found = abap_false.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
