CLASS zcl_cleanup_draft_12 DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_cleanup_draft_12 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    SELECT * FROM zcs03_cust_d INTO TABLE @DATA(lt_drafts).

    out->write( |Gefundene Draft-Einträge: { lines( lt_drafts ) }| ).

    IF lt_drafts IS NOT INITIAL.
      DELETE FROM zcs03_cust_d.
      out->write( |Draft-Tabelle bereinigt.| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
