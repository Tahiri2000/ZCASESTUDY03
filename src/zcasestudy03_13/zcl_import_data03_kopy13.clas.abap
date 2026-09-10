CLASS zcl_import_data03_kopy13 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Struktur für einen Hinweis zu einem übernommenen, aber auffälligen Datensatz.
    " customerid verweist auf den betroffenen, trotzdem angelegten Kunden.
    TYPES: BEGIN OF ty_import_warning,
             customerid TYPE zcs03_customers-customerid,
             fieldname  TYPE string,
             message    TYPE string,
             company    TYPE zcs03_customers-company,
           END OF ty_import_warning.
    TYPES tt_import_warnings TYPE STANDARD TABLE OF ty_import_warning WITH EMPTY KEY.

    " Maximale Länge für COMPANY, passend zur Feldvorgabe CHAR(60)
    CONSTANTS gc_company_maxlen TYPE i VALUE 60.

    " Führt den kompletten Kundenimport durch (Basis- und Delta-Quelle).
    " et_warnings liefert Hinweise zu Datensätzen, die trotz Auffälligkeit
    " (fehlendes Pflichtfeld, zu langer Firmenname) übernommen wurden.
    " rv_duplicates zählt jede Zeile, die NICHT zu einem neuen Kunden führt
    " (Mehrzeilen-Duplikat innerhalb der Quelle ODER bereits in der DB vorhanden).
    METHODS import_data
      EXPORTING et_warnings          TYPE tt_import_warnings
      RETURNING VALUE(rv_duplicates) TYPE i
      RAISING   cx_number_ranges.

    " Entfernt umschließende Anführungszeichen aus einem CSV-Feldwert
    METHODS remove_quotes
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_import_data03_kopy13 IMPLEMENTATION.

  METHOD import_data.

    " Rohdaten aus beiden Quelltabellen, jeweils eine CSV-Zeile als String
    DATA lt_source TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA ls_source TYPE string.

    " Zwischenspeicher für die in diesem Lauf eingelesenen, eindeutigen Kunden.
    " Der UNIQUE KEY sorgt dafür, dass ein INSERT fehlschlägt (sy-subrc <> 0),
    " sobald derselbe Kunde (Name/Firma/Adresse) ein zweites Mal vorkommt.
    DATA lt_customers TYPE SORTED TABLE OF zcs03_customers
      WITH UNIQUE KEY last_name
                       first_name
                       company
                       street
                       city
                       postcode.

    DATA ls_customer TYPE zcs03_customers.

    " Utility-Klasse zur Vergabe der nächsten freien Kundennummer (AP6)
    DATA(lo_util) = NEW zcl_nr_util_03( ).

    " Zählt jede Zeile, die zu keinem neuen Kunden führt
    DATA lv_duplicates TYPE i.


    "----------------------------------------------------------
    " 1. Importdaten lesen
    "----------------------------------------------------------

    " Basisdaten (vom Trainer bereitgestellt)
    SELECT import
      FROM ztl_00_casestudy
      INTO TABLE @lt_source.

    " Delta-Daten ergänzen (zusätzliche, nachträglich bereitgestellte Testzeilen)
    DATA lt_delta TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    SELECT import FROM ztl_00_cs_delta INTO TABLE @lt_delta.
    APPEND LINES OF lt_delta TO lt_source.


    "----------------------------------------------------------
    " 2. Kunden einlesen, Auffälligkeiten protokollieren, trotzdem übernehmen
    "----------------------------------------------------------

    LOOP AT lt_source INTO ls_source.

      DATA(lv_csv) = ls_source.
      DATA lt_fields TYPE TABLE OF string.

      SPLIT lv_csv AT ';' INTO TABLE lt_fields.

      " Anführungszeichen aus jedem Feld entfernen
      LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<field>).
        <field> = remove_quotes( <field> ).
      ENDLOOP.

      " Nur verarbeiten, wenn genügend Felder vorhanden sind (mind. Adresse)
      IF lines( lt_fields ) < 4.
        CONTINUE.
      ENDIF.

      DATA(lv_company)  = lt_fields[ 1 ].
      DATA(lv_street)   = lt_fields[ 2 ].
      DATA(lv_postcode) = lt_fields[ 3 ].
      DATA(lv_city)     = lt_fields[ 4 ].


      CLEAR ls_customer.

      " Kundennummer wird jetzt VOR den Prüfungen vergeben, damit sie beim
      " Protokollieren von Hinweisen bereits zur Verfügung steht - anders
      " als bei der früheren "überspringen"-Logik ist das jetzt sinnvoll,
      " da jeder verarbeitete Datensatz tatsächlich angelegt wird.
      ls_customer-customerid = lo_util->get_next_customer_id( ).

      " Pflichtfeld-Prüfung - Datensatz wird trotzdem übernommen,
      " nur ein Hinweis wird protokolliert (kein CONTINUE mehr, anders
      " als in der ursprünglichen Fassung)
      IF lv_company IS INITIAL
         OR lv_street IS INITIAL
         OR lv_city IS INITIAL
         OR lv_postcode IS INITIAL.

        DATA(lo_field_error) = NEW zcx_03_transfer(
          textid    = zcx_03_transfer=>missing_mandatory_field
          fieldname = COND #( WHEN lv_company  IS INITIAL THEN 'COMPANY'
                               WHEN lv_street   IS INITIAL THEN 'STREET'
                               WHEN lv_city     IS INITIAL THEN 'CITY'
                               ELSE 'POSTCODE' ) ).

        APPEND VALUE #( customerid = ls_customer-customerid
                         fieldname  = lo_field_error->fieldname
                         message    = lo_field_error->get_text( )
                         company    = lv_company ) TO et_warnings.

      ENDIF.

      " Längen-Prüfung COMPANY - bei Überlänge kürzen und Hinweis protokollieren,
      " damit das INSERT später nicht wegen Feldüberlänge technisch scheitert
      IF strlen( lv_company ) > gc_company_maxlen.

        DATA(lo_length_error) = NEW zcx_03_transfer(
          textid    = zcx_03_transfer=>value_too_long
          fieldname = 'COMPANY'
          maxlen    = gc_company_maxlen ).

        APPEND VALUE #( customerid = ls_customer-customerid
                         fieldname  = lo_length_error->fieldname
                         message    = lo_length_error->get_text( )
                         company    = lv_company(gc_company_maxlen) ) TO et_warnings.

        " Wert auf die zulässige Länge kürzen, damit der INSERT unten gelingt
        lv_company = lv_company(gc_company_maxlen).

      ENDIF.


      ls_customer-client   = sy-mandt.
      ls_customer-company  = lv_company.
      ls_customer-street   = lv_street.
      ls_customer-postcode = lv_postcode.
      ls_customer-city     = lv_city.


      " Kunde einfügen
      INSERT ls_customer INTO TABLE lt_customers.

      " Duplikat erkennen: schlägt der INSERT fehl, gab es diesen Kunden
      " (nach Name/Firma/Adresse) in dieser Quelle bereits
      IF sy-subrc <> 0.
        lv_duplicates = lv_duplicates + 1.
      ENDIF.

    ENDLOOP.


    "----------------------------------------------------------
    " 3. Telefon / Fax / E-Mail zuordnen
    "----------------------------------------------------------

    LOOP AT lt_source INTO ls_source.

      DATA(lv_csv2) = ls_source.

      DATA lt_fields2 TYPE TABLE OF string.

      SPLIT lv_csv2 AT ';' INTO TABLE lt_fields2.

      LOOP AT lt_fields2 ASSIGNING FIELD-SYMBOL(<field2>).
        <field2> = remove_quotes( <field2> ).
      ENDLOOP.

      " Nur Zeilen mit Kontaktdaten (Medium/Value1/Value2) verarbeiten
      IF lines( lt_fields2 ) < 7.
        CONTINUE.
      ENDIF.

      DATA(lv_company2)  = lt_fields2[ 1 ].
      DATA(lv_street2)   = lt_fields2[ 2 ].
      DATA(lv_postcode2) = lt_fields2[ 3 ].
      DATA(lv_city2)     = lt_fields2[ 4 ].
      DATA(lv_type2)     = lt_fields2[ 5 ].
      DATA(lv_value1_2)  = lt_fields2[ 6 ].
      DATA(lv_value2_2)  = lt_fields2[ 7 ].

      " Passenden, bereits in Abschnitt 2 angelegten Kunden anhand der
      " Adresse suchen - MODIFY unten führt Kontaktdaten mehrerer Zeilen
      " (z. B. Telefon + separate Email-Zeile) in einem Datensatz zusammen
      READ TABLE lt_customers INTO ls_customer
        WITH TABLE KEY
          last_name  = ''
          first_name = ''
          company    = lv_company2
          street     = lv_street2
          city       = lv_city2
          postcode   = lv_postcode2.

      IF sy-subrc = 0.

        " E-Mail: nur bei syntaktisch gültiger Adresse übernehmen,
        " sonst als Hinweis im Memo-Feld dokumentieren
        IF lv_type2 = 'Email'.

          IF zcl_email_vali03=>is_valid( lv_value1_2 ).
            ls_customer-email = lv_value1_2.
          ELSE.
            ls_customer-memo = |{ ls_customer-memo } Ungültige Email: { lv_value1_2 }|.
          ENDIF.

          " Fax
        ELSEIF lv_type2 = 'Telefax'.

          ls_customer-fax =
            |{ lv_value1_2 }{ lv_value2_2 }|.

          " Telefon
        ELSE.

          ls_customer-phone =
            |{ lv_value1_2 }{ lv_value2_2 }|.

        ENDIF.

        " Geänderten Kunden zurückschreiben (MODIFY, kein INSERT -
        " es entsteht kein zusätzlicher Datensatz)
        MODIFY TABLE lt_customers FROM ls_customer.

      ENDIF.

    ENDLOOP.

    "----------------------------------------------------------
    " 4. Neue Kunden ergänzen
    "    Bestehende Kunden werden nicht überschrieben
    "----------------------------------------------------------

    LOOP AT lt_customers INTO ls_customer.

      " Prüfen, ob dieser Kunde (nach Adresse) schon aus einem früheren
      " Lauf in der Datenbank steht
      SELECT SINGLE customerid
        FROM zcs03_customers
        WHERE company  = @ls_customer-company
          AND street   = @ls_customer-street
          AND city     = @ls_customer-city
          AND postcode = @ls_customer-postcode
        INTO @DATA(lv_existing_id).

      IF sy-subrc <> 0.

        " Kunde ist neu -> einfügen
        INSERT zcs03_customers FROM @ls_customer.

      ELSE.

        " Kunde existiert bereits -> als Duplikat zählen, nicht überschreiben
        lv_duplicates = lv_duplicates + 1.

      ENDIF.

    ENDLOOP.

    " Gesamtzahl der Duplikate zurückgeben
    rv_duplicates = lv_duplicates.

  ENDMETHOD.


  METHOD remove_quotes.
    rv_value = iv_value.
    REPLACE ALL OCCURRENCES OF `"` IN rv_value WITH ``.
  ENDMETHOD.

ENDCLASS.
