CLASS zcl_emailsuche DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_emailsuche IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

 DATA lt_case  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_delta TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  SELECT import FROM ztl_00_casestudy INTO TABLE @lt_case.
  SELECT import FROM ztl_00_cs_delta  INTO TABLE @lt_delta.

  LOOP AT lt_case INTO DATA(lv_line).
    IF lv_line CS 'autohausklein'.
      out->write( |CASESTUDY: { lv_line }| ).
    ENDIF.
  ENDLOOP.

  LOOP AT lt_delta INTO lv_line.
    IF lv_line CS 'autohausklein'.
      out->write( |DELTA: { lv_line }| ).
    ENDIF.
  ENDLOOP.

  out->write( |Zeilen CASESTUDY gesamt: { lines( lt_case ) }| ).
  out->write( |Zeilen DELTA gesamt: { lines( lt_delta ) }| ).

  ENDMETHOD.
ENDCLASS.
