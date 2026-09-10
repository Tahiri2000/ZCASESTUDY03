INTERFACE zif_custimport_03
  PUBLIC.

  INTERFACES if_badi_interface.

   TYPES:
      "neue Adressen, nur Customer-ID
    tt_customer_ids TYPE STANDARD TABLE OF zcustomeridt3 WITH EMPTY KEY,
   "fehlerhafte Adressen
     tt_error_customers TYPE STANDARD TABLE OF zcs03_customers WITH EMPTY KEY,
     "erfolgreich hinzugefügte oder geänderte Adressen
     tt_success_customers TYPE STANDARD TABLE OF zcs03_customers WITH EMPTY KEY,
     "fehlerhafte CSV-Rohdaten
    tt_raw_data     TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS process_data
  IMPORTING
    it_customer_ids TYPE tt_customer_ids
     it_raw_data     TYPE tt_raw_data
  EXPORTING
    et_error_customers   TYPE tt_error_customers
    et_success_customers TYPE tt_success_customers
    et_raw_data          TYPE tt_raw_data.

ENDINTERFACE.
