CLASS zcl_test_statistics03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_statistics03 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    DATA(lv_customerid) = CONV zcustomeridt3( '029778' ). "<-- hier eine echte, bei euch existierende Kundennummer eintragen

    DATA(lo_stat) = NEW zcl_statistics03( iv_customerid = lv_customerid ).

    out->write( |Kunde: { lv_customerid }| ).
    out->write( |AverageSales: { lo_stat->zif_statistics03~average_sales( ) }| ).
    out->write( |MaxSales:     { lo_stat->zif_statistics03~max_sales( ) }| ).
    out->write( |DaySales:     { lo_stat->zif_statistics03~day_sales( ) }| ).


  ENDMETHOD.
ENDCLASS.
