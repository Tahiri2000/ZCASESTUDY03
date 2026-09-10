CLASS zcl_nr_util_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Zentrale Methode: liefert die nächste freie Kundennummer.
    " Wird sowohl von T100 (CSV-Import) als auch von T120/AP16
    " (manuelle Kundenanlage) aufgerufen, damit die Logik nur
    " an einer Stelle gepflegt werden muss.
    " RAISING statt eigenem TRY/CATCH: der Aufrufer entscheidet,
    " wie er mit einem Fehler (z. B. Intervall erschöpft) umgeht.
    METHODS get_next_customer_id
      RETURNING VALUE(rv_customerid) TYPE zcs03_customers-customerid
      RAISING   cx_number_ranges.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_nr_util_03 IMPLEMENTATION.

  METHOD get_next_customer_id.

    " Zieht die nächste freie Nummer aus dem Intervall von ZCS03_CUST.
    " Kein eigenes TRY/CATCH hier - eine mögliche cx_number_ranges
    " wird bewusst an den Aufrufer weitergereicht (siehe RAISING oben).
    cl_numberrange_runtime=>number_get(
      EXPORTING
        nr_range_nr = '02'              " dieselbe Intervall-Nr. wie beim Anlegen
        object      = 'ZCS03_CUST'
      IMPORTING
        number      = DATA(lv_number)   " Ergebnis, kommt immer als NUMC(20) zurück
        returncode  = DATA(lv_rcode)    " Rückgabecode, z. B. bei Intervall-Engpass
    ).

    " NUMC(20) auf die 6-stellige CUSTOMERID zuschneiden:
    " die letzten 6 Zeichen enthalten die eigentliche Nummer,
    " die führenden Stellen sind Nullen/technische Füllzeichen.
    rv_customerid = lv_number+14(6).

  ENDMETHOD.

ENDCLASS.
