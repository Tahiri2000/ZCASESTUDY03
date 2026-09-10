CLASS zcl_nr_setup_t200 DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_nr_setup_t200 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Schritt 1: Falls schon ein Intervall existiert, erst löschen
    " (Fehler hier ignorieren, falls noch gar keins da ist)
    TRY.
        cl_numberrange_intervals=>delete(
          EXPORTING
            interval = VALUE #( ( nrrangenr = '01' ) )
            object   = 'ZT200ORD'
          IMPORTING
            error    = DATA(lv_error_del)
        ).
        IF lv_error_del = abap_true.
          out->write( |Loeschen fehlgeschlagen (evtl. nicht vorhanden).| ).
        ELSE.
          out->write( |Loeschen erfolgreich.| ).
        ENDIF.
      CATCH cx_root INTO DATA(lo_error_del).
        out->write( |Loeschen uebersprungen: { lo_error_del->get_text( ) }| ).
    ENDTRY.

    " Schritt 2: Intervall neu anlegen
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval = VALUE #( ( nrrangenr  = '01'
                                   fromnumber = '000001'
                                   tonumber   = '999999'
                                   procind    = 'I' ) )
            object   = 'ZT200ORD'
          IMPORTING
            error = DATA(lv_error)
        ).
        IF lv_error = abap_true.
          out->write( |Neuanlegen fehlgeschlagen.| ).
        ELSE.
          out->write( |Intervall erfolgreich neu angelegt, 000001-999999.| ).
        ENDIF.
        COMMIT WORK.
      CATCH cx_root INTO DATA(lo_error).
        out->write( |Fehler beim Neuanlegen: { lo_error->get_text( ) }| ).
    ENDTRY.

    " Diagnose: Bestehende Intervalle auslesen
    TRY.
        cl_numberrange_intervals=>read(
          EXPORTING
            object   = 'ZT200ORD'
          IMPORTING
            interval = DATA(lt_intervals)
        ).
        LOOP AT lt_intervals INTO DATA(ls_interval).
          out->write( |Gefunden: Range={ ls_interval-nrrangenr } von { ls_interval-fromnumber } bis { ls_interval-tonumber } aktuell={ ls_interval-nrlevel }| ).
        ENDLOOP.
        IF lt_intervals IS INITIAL.
          out->write( |Keine Intervalle gefunden fuer ZT200ORD!| ).
        ENDIF.
      CATCH cx_root INTO DATA(lo_error_read).
        out->write( |Fehler beim Lesen: { lo_error_read->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
