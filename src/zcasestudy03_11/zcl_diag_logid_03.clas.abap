CLASS zcl_diag_logid_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_diag_logid_03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. Wie viele Log-Einträge haben überhaupt eine customerid?
    SELECT COUNT(*) FROM zcs03_import_log
      WHERE customerid IS NOT INITIAL
      INTO @DATA(lv_log_with_cust).

    out->write( |Log-Einträge MIT customerid: { lv_log_with_cust }| ).

    " 2. Wie viele Kunden haben überhaupt eine gefüllte log_id?
    SELECT COUNT(*) FROM zcs03_customers
      WHERE log_id IS NOT INITIAL
      INTO @DATA(lv_cust_with_log).

    out->write( |Kunden MIT log_id: { lv_cust_with_log }| ).

    " 3. Stichprobe: die ersten 20 Log-Einträge mit customerid,
    "    aufgeschlüsselt nach BAdI- vs. anderen Warnungen
    SELECT customerid, log_id, fieldname, message FROM zcs03_import_log
      WHERE customerid IS NOT INITIAL
      INTO TABLE @DATA(lt_log_sample)
      UP TO 20 ROWS.

    DATA(lv_badi_broken)  = 0.
    DATA(lv_badi_ok)      = 0.
    DATA(lv_other_broken) = 0.
    DATA(lv_other_ok)     = 0.

    LOOP AT lt_log_sample INTO DATA(ls_log_sample).

      SELECT SINGLE customerid FROM zcs03_customers
        WHERE customerid = @ls_log_sample-customerid
        INTO @DATA(lv_found).

      IF ls_log_sample-fieldname = 'BADI'.
        IF sy-subrc = 0.
          lv_badi_ok = lv_badi_ok + 1.
        ELSE.
          lv_badi_broken = lv_badi_broken + 1.
        ENDIF.
      ELSE.
        IF sy-subrc = 0.
          lv_other_ok = lv_other_ok + 1.
        ELSE.
          lv_other_broken = lv_other_broken + 1.
        ENDIF.
      ENDIF.

    ENDLOOP.

    out->write( |BAdI-Warnungen: { lv_badi_ok } ok, { lv_badi_broken } fehlerhaft| ).
    out->write( |Andere Warnungen: { lv_other_ok } ok, { lv_other_broken } fehlerhaft| ).

  ENDMETHOD.

ENDCLASS.
