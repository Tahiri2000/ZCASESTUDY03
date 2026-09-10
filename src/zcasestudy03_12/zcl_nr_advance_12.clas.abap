CLASS zcl_nr_advance_12 DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_nr_advance_12 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Schritt 1: Bestehendes Intervall löschen (Fehler hier ignorieren,
    " falls es gar nicht existiert)
    TRY.
        cl_numberrange_intervals=>delete(
          EXPORTING
            interval = VALUE #( ( nrrangenr = '01' ) )
            object   = 'ZCS03_CUST'
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

    " Schritt 2: Intervall neu anlegen, Start oberhalb der importierten Nummern
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval = VALUE #( ( nrrangenr  = '01'
                                   fromnumber = '040000'
                                   tonumber   = '999999'
                                   procind    = 'I' ) )
            object   = 'ZCS03_CUST'
          IMPORTING
            error = DATA(lv_error)
        ).
        IF lv_error = abap_true.
          out->write( |Neuanlegen fehlgeschlagen.| ).
        ELSE.
          out->write( |Intervall erfolgreich neu angelegt, Start bei 040000.| ).
        ENDIF.
        COMMIT WORK.
      CATCH cx_root INTO DATA(lo_error).
        out->write( |Fehler beim Neuanlegen: { lo_error->get_text( ) }| ).
    ENDTRY.

    " Diagnose: Bestehende Intervalle auslesen
    TRY.
        cl_numberrange_intervals=>read(
          EXPORTING
            object   = 'ZCS03_CUST'
          IMPORTING
            interval = DATA(lt_intervals)
        ).
        LOOP AT lt_intervals INTO DATA(ls_interval).
          out->write( |Gefunden: Range={ ls_interval-nrrangenr } von { ls_interval-fromnumber } bis { ls_interval-tonumber } aktuell={ ls_interval-nrlevel }| ).
        ENDLOOP.
        IF lt_intervals IS INITIAL.
          out->write( |Keine Intervalle gefunden fuer ZCS03_CUST!| ).
        ENDIF.
      CATCH cx_root INTO DATA(lo_error_read).
        out->write( |Fehler beim Lesen: { lo_error_read->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
