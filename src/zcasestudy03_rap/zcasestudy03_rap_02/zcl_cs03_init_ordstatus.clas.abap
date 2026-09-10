CLASS zcl_cs03_init_ordstatus DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs03_init_ordstatus IMPLEMENTATION.

METHOD if_oo_adt_classrun~main.

  DATA ls_status TYPE zcs03_ordstatus.

  DELETE FROM zcs03_ordstatus.

  ls_status-client = sy-mandt.
  ls_status-status = 'BO'.
  ls_status-description = 'Bestellung nicht bezahlt'.
  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'BB'.
  ls_status-description = 'Bestellung bezahlt'.
  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'BA'.
  ls_status-description = 'Bestellung ausgeliefert'.
  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'BN'.
  ls_status-description = 'Neue Bestellung'.
  INSERT zcs03_ordstatus FROM @ls_status.

*  ls_status-status = 'BS'.
*  ls_status-description = 'Bestellung storniert'.
*  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'SO'.
  ls_status-description = 'Bestellung nicht bezahlt (storniert)'.
  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'SB'.
  ls_status-description = 'Bestellung bezahlt (storniert)'.
  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'SA'.
  ls_status-description = 'Bestellung ausgeliefert (storniert)'.
  INSERT zcs03_ordstatus FROM @ls_status.

  ls_status-status = 'SN'.
  ls_status-description = 'Neue Bestellung (storniert)'.
  INSERT zcs03_ordstatus FROM @ls_status.

  out->write( 'Bestellstatus wurden angelegt.' ).

ENDMETHOD.

ENDCLASS.
