CLASS zcl_nr_setup_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Macht die Klasse über F9 direkt ausführbar (Konsolen-Tool)
    INTERFACES if_oo_adt_classrun.

    " Legt einmalig das Nummernintervall für ZCS03_CUST an
    METHODS create_interval
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_nr_setup_03 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Einstiegspunkt beim Ausführen der Klasse (F9)
    create_interval( out ).
  ENDMETHOD.

  METHOD create_interval.

    TRY.
        " Legt das Intervall 000001-999999 für das Nummernkreisobjekt
        " ZCS03_CUST an. procind = 'I' = interne (automatische) Vergabe
        " durch das System, nicht manuell durch den Anwender.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = VALUE #( ( nrrangenr  = '01'         " Intervall-Nr., frei wählbar
                                    fromnumber = '000001'     " untere Grenze
                                    tonumber   = '999999'     " obere Grenze
                                    procind    = 'I' ) )       " I = intern
            object    = 'ZCS03_CUST'                          " unser Nummernkreisobjekt
          IMPORTING
            error     = DATA(lv_error)      " 'X', falls ein Fehler auftrat
            error_inf = DATA(ls_error_inf)  " Detailinfos zum Fehler
            error_iv  = DATA(lt_error_iv)   " fehlerhafte Intervalle (falls mehrere übergeben wurden)
            warning   = DATA(lv_warning)    " 'X', falls nur eine Warnung vorliegt
        ).
      CATCH cx_root INTO DATA(lo_error).
        " Fängt unerwartete technische Fehler ab (z. B. Berechtigung)
        io_out->write( lo_error->get_text( ) ).
    ENDTRY.

    " Ausgabe in der Konsole, damit man den Erfolg/Misserfolg direkt sieht
    io_out->write( |Error: { lv_error }, Warning: { lv_warning }| ).

    " WICHTIG: Ohne COMMIT WORK bleibt die Intervall-Anlage nur im aktuellen
    " Programmlauf bestehen und wird danach wieder verworfen - das war
    " die Ursache für "Interval does not exist" beim ersten Versuch.
    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.
