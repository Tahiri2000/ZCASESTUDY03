CLASS zcl_nr_test_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_nr_test_03 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

 DATA(lo_util) = NEW zcl_nr_util_03( ).

    " Dreimal aufrufen, um zu sehen, dass die Nummer jedes Mal hochzählt
    out->write( lo_util->get_next_customer_id( ) ).
    out->write( lo_util->get_next_customer_id( ) ).
    out->write( lo_util->get_next_customer_id( ) ).

  ENDMETHOD.
ENDCLASS.
