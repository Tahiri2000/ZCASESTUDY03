CLASS zcl_cs03_customer_import DEFINITION

  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS import_data.

ENDCLASS.


CLASS zcl_cs03_customer_import IMPLEMENTATION.

  METHOD import_data.

    DATA lt_source TYPE TABLE OF ztl_00_casestudy.
    DATA ls_source TYPE ztl_00_casestudy.

    " Tabelle für eindeutige Kunden
    DATA lt_customers TYPE SORTED TABLE OF zcs03_customers
      WITH UNIQUE KEY last_name
                      first_name
                      company
                      street
                      city
                      postcode.

    DATA ls_customer TYPE zcs03_customers.

    " Anzahl der Duplikate
    DATA lv_duplicates TYPE i.


    " 1. Importdaten lesen
    SELECT *
      FROM ztl_00_casestudy
      INTO TABLE @lt_source.


    " 2. Kunden einlesen und Duplikate erkennen
    LOOP AT lt_source INTO ls_source.

      DATA(lv_csv) = ls_source-import.

      DATA lt_fields TYPE TABLE OF string.

      SPLIT lv_csv AT ';' INTO TABLE lt_fields.

      DATA(lv_company)  = lt_fields[ 1 ].
      DATA(lv_street)   = lt_fields[ 2 ].
      DATA(lv_postcode) = lt_fields[ 3 ].
      DATA(lv_city)     = lt_fields[ 4 ].


      CLEAR ls_customer.

      ls_customer-company  = lv_company.
      ls_customer-street   = lv_street.
      ls_customer-postcode = lv_postcode.
      ls_customer-city     = lv_city.


      " Kunde einfügen
      INSERT ls_customer INTO TABLE lt_customers.


      " Duplikat erkennen
      IF sy-subrc <> 0.
        lv_duplicates = lv_duplicates + 1.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
