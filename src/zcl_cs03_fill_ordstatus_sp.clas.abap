CLASS zcl_cs03_fill_ordstatus_sp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_cs03_fill_ordstatus_sp IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_status TYPE TABLE OF zcs03_ordstatus.
    DATA ls_status TYPE zcs03_ordstatus.

    "Bestehende Statuswerte löschen
    DELETE FROM zcs03_ordstatus.


    "--------------------------------------------------
    "Deutsche Statuswerte
    "--------------------------------------------------

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BO'.
    ls_status-language = 'D'.
    ls_status-description = 'Bestellung nicht bezahlt'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BB'.
    ls_status-language = 'D'.
    ls_status-description = 'Bestellung bezahlt'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BA'.
    ls_status-language = 'D'.
    ls_status-description = 'Bestellung ausgeliefert'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BN'.
    ls_status-language = 'D'.
    ls_status-description = 'Neue Bestellung'.
    APPEND ls_status TO lt_status.


    "--------------------------------------------------
    "Deutsche Storno-Statuswerte
    "--------------------------------------------------

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SO'.
    ls_status-language = 'D'.
    ls_status-description = 'Stornierung nicht bezahlt'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SB'.
    ls_status-language = 'D'.
    ls_status-description = 'Stornierung bezahlt'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SA'.
    ls_status-language = 'D'.
    ls_status-description = 'Stornierung ausgeliefert'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SN'.
    ls_status-language = 'D'.
    ls_status-description = 'Stornierung neue Bestellung'.
    APPEND ls_status TO lt_status.


    "--------------------------------------------------
    "Englische Statuswerte
    "--------------------------------------------------

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BO'.
    ls_status-language = 'E'.
    ls_status-description = 'Order not paid'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BB'.
    ls_status-language = 'E'.
    ls_status-description = 'Order paid'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BA'.
    ls_status-language = 'E'.
    ls_status-description = 'Order delivered'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'BN'.
    ls_status-language = 'E'.
    ls_status-description = 'New order'.
    APPEND ls_status TO lt_status.


    "--------------------------------------------------
    "Englische Storno-Statuswerte
    "--------------------------------------------------

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SO'.
    ls_status-language = 'E'.
    ls_status-description = 'Cancelled order not paid'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SB'.
    ls_status-language = 'E'.
    ls_status-description = 'Cancelled order paid'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SA'.
    ls_status-language = 'E'.
    ls_status-description = 'Cancelled order delivered'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-client = sy-mandt.
    ls_status-status = 'SN'.
    ls_status-language = 'E'.
    ls_status-description = 'Cancelled new order'.
    APPEND ls_status TO lt_status.


    "Alle Statuswerte einfügen
    INSERT zcs03_ordstatus FROM TABLE @lt_status.

    COMMIT WORK.

    out->write( 'Statuswerte wurden erfolgreich eingefügt.' ).

  ENDMETHOD.

ENDCLASS.
