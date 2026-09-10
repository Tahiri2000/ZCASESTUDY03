*"* use this source file for your ABAP unit test classes
CLASS ltc_email_validation DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS field_is_empty          FOR TESTING.
    METHODS missing_mandatory_field FOR TESTING.
    METHODS value_too_long          FOR TESTING.
    METHODS invalid_postcode        FOR TESTING.
    METHODS default_textid          FOR TESTING.
    METHODS attributes_are_stored   FOR TESTING.
    METHODS previous_exception      FOR TESTING.

ENDCLASS.


CLASS ltc_email_validation IMPLEMENTATION.

  METHOD field_is_empty.

    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer
          EXPORTING
            textid    = zcx_03_transfer=>field_is_empty
            fieldname = 'CITY'.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_equals(
          exp = 'Feld CITY ist leer'
          act = lx_transfer->get_text( )
          msg = 'field_is_empty: Nachrichtentext stimmt nicht'
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD missing_mandatory_field.

    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer
          EXPORTING
            textid    = zcx_03_transfer=>missing_mandatory_field
            fieldname = 'CUSTOMERID'.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_equals(
          exp = 'Pflichtfeld CUSTOMERID fehlt im Quelldatensatz'
          act = lx_transfer->get_text( )
          msg = 'missing_mandatory_field: Nachrichtentext stimmt nicht'
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD value_too_long.

    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer
          EXPORTING
            textid    = zcx_03_transfer=>value_too_long
            fieldname = 'COMPANY'
            maxlen    = 40.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_equals(
          exp = 'Wert für Feld COMPANY überschreitet die maximale Länge 40'
          act = lx_transfer->get_text( )
          msg = 'value_too_long: Nachrichtentext stimmt nicht'
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD invalid_postcode.

    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer
          EXPORTING
            textid   = zcx_03_transfer=>invalid_postcode
            postcode = '99999'.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_equals(
          exp = 'Postleitzahl 99999 konnte nicht aufgelöst werden'
          act = lx_transfer->get_text( )
          msg = 'invalid_postcode: Nachrichtentext stimmt nicht'
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD default_textid.

    " Kein textid übergeben -> Default-Textid soll greifen, kein Laufzeitfehler
    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_bound(
          act = lx_transfer
          msg = 'default_textid: Exception-Objekt nicht gebunden'
        ).
        " get_text darf nicht dumpen, auch ohne spezifisches textid
        DATA(lv_text) = lx_transfer->get_text( ).
        cl_abap_unit_assert=>assert_not_initial(
          act = lv_text
          msg = 'default_textid: get_text() liefert leeren String'
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD attributes_are_stored.

    " Prüft, dass die Instanzattribute unabhängig vom Nachrichtentext
    " korrekt befüllt werden (Datenhaltung, nicht nur Textausgabe)
    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer
          EXPORTING
            textid    = zcx_03_transfer=>value_too_long
            fieldname = 'STREET'
            maxlen    = 60.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_equals(
          exp = 'STREET'
          act = lx_transfer->fieldname
          msg = 'attributes_are_stored: fieldname falsch befüllt'
        ).
        cl_abap_unit_assert=>assert_equals(
          exp = 60
          act = lx_transfer->maxlen
          msg = 'attributes_are_stored: maxlen falsch befüllt'
        ).
    ENDTRY.

  ENDMETHOD.


  METHOD previous_exception.

    " Prüft das Exception-Chaining über 'previous'
    DATA(lx_previous) = NEW zcx_03_transfer(
                             textid    = zcx_03_transfer=>field_is_empty
                             fieldname = 'CITY' ).

    TRY.
        RAISE EXCEPTION TYPE zcx_03_transfer
          EXPORTING
            textid    = zcx_03_transfer=>missing_mandatory_field
            fieldname = 'CUSTOMERID'
            previous  = lx_previous.

        cl_abap_unit_assert=>fail( msg = 'Exception wurde nicht geworfen' ).

      CATCH zcx_03_transfer INTO DATA(lx_transfer).
        cl_abap_unit_assert=>assert_bound(
          act = lx_transfer->previous
          msg = 'previous_exception: previous wurde nicht gesetzt'
        ).
        cl_abap_unit_assert=>assert_equals(
          exp = 'Feld CITY ist leer'
          act = lx_transfer->previous->get_text( )
          msg = 'previous_exception: Text der previous-Exception stimmt nicht'
        ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
