CLASS lhc_zcs03_i_custorders DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR Zcs03ICustorders
      RESULT result.

    METHODS convert_currency
      FOR DETERMINE ON SAVE
      IMPORTING
        keys FOR Zcs03ICustorders~convert_currency.
    METHODS updateCustomerSalesVolume FOR DETERMINE ON SAVE
      IMPORTING keys FOR Zcs03ICustorders~updateCustomerSalesVolume.
    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
       keys FOR Zcs03ICustorders~setDefaultStatus.

ENDCLASS.
CLASS lhc_zcs03_i_custorders IMPLEMENTATION.

  METHOD get_global_authorizations.

    result = VALUE #(
      %create = if_abap_behv=>auth-allowed
      %update = if_abap_behv=>auth-allowed
      %delete = if_abap_behv=>auth-allowed
    ).

  ENDMETHOD.


  METHOD convert_currency.

  " betroffene Bestellungen (mit Betrag, Ausgangs- und Zielwährung) anhand
  " der übergebenen Keys aus dem RAP-Puffer lesen
  READ ENTITIES OF ZCS03_I_CUSTORDERS IN LOCAL MODE
    ENTITY Zcs03ICustorders
    FIELDS ( OrderTotal Currency TargetCurrency )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

  " Determination sofort verlassen, falls keine passenden Bestellungen
  " gefunden wurden (z. B. bei Löschung o. ä.)
  CHECK lt_orders IS NOT INITIAL.

  DATA lt_update TYPE TABLE FOR UPDATE ZCS03_I_CUSTORDERS.

  " für jede betroffene Bestellung den Betrag von der Ausgangs- in die
  " Zielwährung umrechnen
  LOOP AT lt_orders INTO DATA(ls_order).

    " Umrechnung an zentrale Konvertierungsklasse delegieren; liefert den
    " umgerechneten Betrag sowie ein Flag, ob ein Wechselkurs gefunden wurde
    zcl_cs03_currency_conv=>convert(
      EXPORTING
        iv_amount        = ls_order-OrderTotal
        iv_from_currency = ls_order-Currency
        iv_to_currency   = ls_order-TargetCurrency
      IMPORTING
        ev_amount        = DATA(lv_converted)
        ev_rate_found    = DATA(lv_rate_found)
    ).

    " umgerechneten Betrag und Umrechnungsdatum für das anschließende
    " Sammel-Update vormerken
    APPEND VALUE #(
      %tky                         = ls_order-%tky
      OrderTotalConverted          = lv_converted
      ChangeRateDate               = sy-datum
      %control-OrderTotalConverted = if_abap_behv=>mk-on
      %control-ChangeRateDate      = if_abap_behv=>mk-on
    ) TO lt_update.

  ENDLOOP.

  " Determination verlassen, falls sich aus der Schleife keine Updates
  " ergeben haben (z. B. wenn lt_orders zwar gefüllt, aber alle Zeilen
  " übersprungen wurden)
  CHECK lt_update IS NOT INITIAL.

  " berechnete Werte gesammelt in einem Schritt auf die Bestellungen
  " zurückschreiben
  MODIFY ENTITIES OF ZCS03_I_CUSTORDERS IN LOCAL MODE
    ENTITY Zcs03ICustorders
    UPDATE FIELDS ( OrderTotalConverted ChangeRateDate )
    WITH lt_update.

ENDMETHOD.



METHOD updateCustomerSalesVolume.
  " betroffene Kunden + betroffene Bestellungen (mit aktuellem Puffer-Stand) ermitteln
  READ ENTITIES OF ZCS03_I_CUSTORDERS IN LOCAL MODE
    ENTITY Zcs03ICustorders
    FIELDS ( Customerid OrderTotal OrderTotalConverted Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_touched_orders).

  DATA lt_customerids TYPE SORTED TABLE OF zcustomeridt3 WITH UNIQUE KEY table_line.
  LOOP AT lt_touched_orders INTO DATA(ls_touched).
    INSERT ls_touched-Customerid INTO TABLE lt_customerids.
  ENDLOOP.
  CHECK lt_customerids IS NOT INITIAL.

  DATA lt_updates TYPE TABLE FOR UPDATE zcs03_i_customers_cds.

  LOOP AT lt_customerids INTO DATA(lv_customerid).
    " Summe der bereits gespeicherten (unveraenderten), NICHT stornierten
    " Bestellungen aus der DB, OHNE die gerade in diesem Save-Vorgang
    " geaenderten Bestellungen
    SELECT SUM( order_total ) AS sales_volume,
           SUM( order_total_converted ) AS sales_volume_target
      FROM zcs03_custorders
      WHERE customerid = @lv_customerid
        AND status NOT IN ( 'SO', 'SB', 'SA', 'SN' )
        AND orderid NOT IN ( SELECT orderid FROM @lt_touched_orders AS t
                              WHERE t~Customerid = @lv_customerid )
      INTO @DATA(ls_sum_db).

    DATA(lv_sales_volume)        = CONV zsales_volumet3( ls_sum_db-sales_volume ).
    DATA(lv_sales_volume_target) = CONV zsales_volume_targett3( ls_sum_db-sales_volume_target ).

    " die gerade geaenderten, NICHT stornierten Bestellungen (Puffer-aktuell) addieren
    LOOP AT lt_touched_orders INTO ls_touched
      WHERE Customerid = lv_customerid
        AND Status <> 'SO' AND Status <> 'SB' AND Status <> 'SA' AND Status <> 'SN'.
      lv_sales_volume        += ls_touched-OrderTotal.
      lv_sales_volume_target += ls_touched-OrderTotalConverted.
    ENDLOOP.

    lt_updates = VALUE #( BASE lt_updates
      ( %tky = VALUE #( Customerid = lv_customerid )
        SalesVolume = lv_sales_volume
        SalesVolumeTarget = lv_sales_volume_target
        %control-SalesVolume = if_abap_behv=>mk-on
        %control-SalesVolumeTarget = if_abap_behv=>mk-on ) ).
  ENDLOOP.

  MODIFY ENTITIES OF zcs03_i_customers_cds
    ENTITY zcs03_i_customers_cds
    UPDATE FIELDS ( SalesVolume SalesVolumeTarget )
    WITH lt_updates
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

ENDMETHOD.

  METHOD setDefaultStatus.

    MODIFY ENTITIES OF zcs03_i_custorders IN LOCAL MODE
      ENTITY Zcs03ICustorders
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR ls_key IN keys (
          %tky            = ls_key-%tky
          Status          = 'BN'
          %control-Status = if_abap_behv=>mk-on
        ) ).

  ENDMETHOD.

ENDCLASS.

