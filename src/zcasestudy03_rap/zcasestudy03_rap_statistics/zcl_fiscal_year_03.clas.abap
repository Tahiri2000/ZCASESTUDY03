CLASS zcl_fiscal_year_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Liefert das Geschaeftsjahr fuer ein gegebenes Datum,
    "! basierend auf dem in ZCS03_SETTINGS gepflegten
    "! Geschaeftsjahresbeginn (Key FISCAL_YEAR_START, Format MMTT).
    CLASS-METHODS get_fiscal_year_for_date
      IMPORTING
        iv_date       TYPE d
      RETURNING
        VALUE(rv_year) TYPE gjahr.

    "! Liefert das Geschaeftsjahr fuer das heutige Datum.
    CLASS-METHODS get_current_fiscal_year
      RETURNING
        VALUE(rv_year) TYPE gjahr.

    "! Liefert das Startdatum des Geschaeftsjahres, in dem iv_date liegt.
    CLASS-METHODS get_fiscal_year_start_date
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_date) TYPE d.

    "! Liefert das Enddatum des Geschaeftsjahres, in dem iv_date liegt
    "! (letzter Tag vor dem naechsten Geschaeftsjahresbeginn).
    CLASS-METHODS get_fiscal_year_end_date
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_date) TYPE d.

  PROTECTED SECTION.
  PRIVATE SECTION.

    "! Liest den Geschaeftsjahresbeginn (MMTT) aus der Settings-Tabelle.
    "! Liefert '0101' (Kalenderjahr), falls kein aktiver Eintrag existiert.
    CLASS-METHODS get_fiscal_year_start_mmdd
      RETURNING
        VALUE(rv_mmdd) TYPE char4.

ENDCLASS.

CLASS zcl_fiscal_year_03 IMPLEMENTATION.

  METHOD get_fiscal_year_start_mmdd.
    " Nicht mehr verwendet (altes Settings-Modell) - bleibt aus Kompatibilitaetsgruenden leer.
    CLEAR rv_mmdd.
  ENDMETHOD.

  METHOD get_fiscal_year_start_date.

    SELECT SINGLE start_date
      FROM zcs03_fyear
      WHERE active = @abap_true
      INTO @rv_date.

    IF sy-subrc <> 0.
      " Fallback: 01.01. des Kalenderjahres von iv_date, falls kein aktives Geschaeftsjahr gepflegt ist.
      rv_date = |{ iv_date(4) }0101|.
    ENDIF.

  ENDMETHOD.

  METHOD get_fiscal_year_end_date.

    SELECT SINGLE end_date
      FROM zcs03_fyear
      WHERE active = @abap_true
      INTO @rv_date.

    IF sy-subrc <> 0.
      " Fallback: 31.12. des Kalenderjahres von iv_date, falls kein aktives Geschaeftsjahr gepflegt ist.
      rv_date = |{ iv_date(4) }1231|.
    ENDIF.

  ENDMETHOD.

  METHOD get_fiscal_year_for_date.
     DATA(lv_start_date) = get_fiscal_year_start_date( iv_date ).
    rv_year = lv_start_date(4).
  ENDMETHOD.

  METHOD get_current_fiscal_year.
    rv_year = get_fiscal_year_for_date( sy-datum ).
  ENDMETHOD.

ENDCLASS.
