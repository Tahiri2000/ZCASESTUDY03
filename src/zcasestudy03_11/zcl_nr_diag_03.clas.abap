CLASS zcl_nr_diag_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_nr_diag_03 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
      cl_numberrange_intervals=>delete(
        interval = VALUE #( ( nrrangenr = '02' ) )
        object   = 'ZCS03_CUST'
      ).
      COMMIT WORK.
      out->write( |Altes Intervall 02 gelöscht.| ).
    CATCH cx_root INTO DATA(lx_del).
      out->write( |Löschen übersprungen: { lx_del->get_text( ) }| ).
  ENDTRY.

  TRY.
      cl_numberrange_intervals=>create(
        interval = VALUE #( ( nrrangenr  = '02'
                               fromnumber = '030300'
                               tonumber   = '599999'
                               procind    = 'I' ) )
        object   = 'ZCS03_CUST'
      ).
      COMMIT WORK.
      out->write( |Intervall 02 neu angelegt, Start bei 030300.| ).
    CATCH cx_root INTO DATA(lx_create).
      out->write( |Fehler beim Neuanlegen: { lx_create->get_text( ) }| ).
  ENDTRY.

  TRY.
      cl_numberrange_intervals=>read(
        EXPORTING object   = 'ZCS03_CUST'
        IMPORTING interval = DATA(lt_interval)
      ).
      LOOP AT lt_interval INTO DATA(ls_iv).
        out->write( |NrRangeNr: '{ ls_iv-nrrangenr }' From: { ls_iv-fromnumber } To: { ls_iv-tonumber } Aktuell: { ls_iv-nrlevel }| ).
      ENDLOOP.
    CATCH cx_root INTO DATA(lx_read).
      out->write( |Fehler beim Lesen: { lx_read->get_text( ) }| ).
  ENDTRY.


  ENDMETHOD.
ENDCLASS.
