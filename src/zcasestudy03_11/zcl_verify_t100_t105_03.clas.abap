CLASS zcl_verify_t100_t105_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_verify_t100_t105_03 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( '=== T100: Kundendaten ===' ).

    SELECT COUNT(*) FROM zcs03_customers INTO @DATA(lv_cust_count).
    out->write( |Anzahl Kunden gesamt: { lv_cust_count }| ).

    SELECT COUNT(*) FROM zcs03_customers WHERE email IS NOT INITIAL INTO @DATA(lv_email_count).
    out->write( |Kunden mit Email: { lv_email_count }| ).

    SELECT COUNT(*) FROM zcs03_customers WHERE street IS INITIAL INTO @DATA(lv_no_street).
    out->write( |Kunden mit fehlender Straße (bewusst übernommen, mit Hinweis): { lv_no_street }| ).

    SELECT COUNT(*) FROM zcs03_import_log INTO @DATA(lv_log_count).
    out->write( |Protokolleinträge gesamt: { lv_log_count }| ).


    out->write( '' ).
    out->write( '=== T105: Fremdschlüssel-Test CUSTORDERS -> CUSTOMERS ===' ).

    " Testfall 1: gültige Bestellung für einen echten Kunden
    SELECT SINGLE customerid FROM zcs03_customers INTO @DATA(lv_valid_cust).

    TRY.
        INSERT zcs03_custorders FROM @( VALUE #(
          client       = sy-mandt
          customerid   = lv_valid_cust
          orderid      = 'TST001'
          order_date   = sy-datum
          order_total  = '100.00'
          currency     = 'EUR'
          status       = 'BN'
        ) ).
        out->write( |Test 1 (gültiger Kunde { lv_valid_cust }): sy-subrc={ sy-subrc } - erwartet: 0 (erfolgreich)| ).
      CATCH cx_root INTO DATA(lo_err1).
        out->write( |Test 1: Exception { lo_err1->get_text( ) }| ).
    ENDTRY.

    " Testfall 2: Bestellung für eine NICHT existierende Kundennummer
    TRY.
        INSERT zcs03_custorders FROM @( VALUE #(
          client       = sy-mandt
          customerid   = '999999'
          orderid      = 'TST002'
          order_date   = sy-datum
          order_total  = '50.00'
          currency     = 'EUR'
          status       = 'BN'
        ) ).
        out->write( |Test 2 (ungültige Kundennummer 999999): sy-subrc={ sy-subrc } - erwartet: FEHLER (Fremdschlüssel sollte ablehnen!)| ).
      CATCH cx_root INTO DATA(lo_err2).
        out->write( |Test 2: korrekt abgelehnt - Exception { lo_err2->get_text( ) }| ).
    ENDTRY.


    out->write( '' ).
    out->write( '=== T105: Fremdschlüssel-Test ORDERITEMS -> CUSTORDERS ===' ).

    " Testfall 3: gültige Position zur eben angelegten Testbestellung
    TRY.
        INSERT zcs03_orderitems FROM @( VALUE #(
          client          = sy-mandt
          customerid      = lv_valid_cust
          orderid         = 'TST001'
          orderitem       = '001'
          itemid          = 'ART001'
          itemdescription = 'Testartikel 1'
          quantity        = '1'
          price           = '10.00'
          item_total      = '10.00'
          currency        = 'EUR'
        ) ).
        out->write( |Test 3 (gültige Position 001): sy-subrc={ sy-subrc } - erwartet: 0| ).
      CATCH cx_root INTO DATA(lo_err3).
        out->write( |Test 3: Exception { lo_err3->get_text( ) }| ).
    ENDTRY.

    " Testfall 4: zweite Position zur SELBEN Bestellung (prüft ORDERITEM als Schlüssel)
    TRY.
        INSERT zcs03_orderitems FROM @( VALUE #(
          client          = sy-mandt
          customerid      = lv_valid_cust
          orderid         = 'TST001'
          orderitem       = '002'
          itemid          = 'ART002'
          itemdescription = 'Testartikel 2'
          quantity        = '2'
          price           = '20.00'
          item_total      = '40.00'
          currency        = 'EUR'
        ) ).
        out->write( |Test 4 (zweite Position 002, gleiche Bestellung): sy-subrc={ sy-subrc } - erwartet: 0 (beide Positionen sollen nebeneinander existieren)| ).
      CATCH cx_root INTO DATA(lo_err4).
        out->write( |Test 4: Exception { lo_err4->get_text( ) }| ).
    ENDTRY.

    " Testfall 5: Position zu einer NICHT existierenden Bestellnummer
    TRY.
        INSERT zcs03_orderitems FROM @( VALUE #(
          client          = sy-mandt
          customerid      = lv_valid_cust
          orderid         = 'NOTEXIST'
          orderitem       = '001'
          itemid          = 'ART003'
          itemdescription = 'Testartikel 3'
          quantity        = '1'
          price           = '5.00'
          item_total      = '5.00'
          currency        = 'EUR'
        ) ).
        out->write( |Test 5 (ungültige Bestellnummer): sy-subrc={ sy-subrc } - erwartet: FEHLER| ).
      CATCH cx_root INTO DATA(lo_err5).
        out->write( |Test 5: korrekt abgelehnt - Exception { lo_err5->get_text( ) }| ).
    ENDTRY.

    COMMIT WORK.

    out->write( '' ).
    out->write( '=== Testdaten wieder aufräumen ===' ).
    DELETE FROM zcs03_orderitems WHERE orderid = 'TST001'.
    DELETE FROM zcs03_custorders WHERE orderid = 'TST001'.
    COMMIT WORK.
    out->write( 'Testbestellung TST001 und ihre Positionen wieder entfernt.' ).

  ENDMETHOD.
ENDCLASS.
