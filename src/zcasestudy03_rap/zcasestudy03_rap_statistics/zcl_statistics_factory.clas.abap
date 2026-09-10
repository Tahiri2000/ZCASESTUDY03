CLASS zcl_statistics_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF gc_reason,
        ok                        TYPE i VALUE 0,
        class_not_found           TYPE i VALUE 1,
        interface_not_implemented TYPE i VALUE 2,
      END OF gc_reason.

    CLASS-METHODS get_statistics_instance
      IMPORTING
        iv_customerid        TYPE zcustomeridt3
      EXPORTING
        ev_reason            TYPE i
      RETURNING
        VALUE(ro_statistics) TYPE REF TO zif_statistics03.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_statistics_factory IMPLEMENTATION.

  METHOD get_statistics_instance.

    CLEAR ro_statistics.
    ev_reason = gc_reason-ok.

    DATA lv_classname TYPE zcs03_statistic-classname.

    SELECT SINGLE classname
      FROM zcs03_statistic
      WHERE active = @abap_true
      INTO @lv_classname.

    IF sy-subrc <> 0.
      ev_reason = gc_reason-class_not_found.
      RETURN.
    ENDIF.

    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = lv_classname
      RECEIVING
        p_descr_ref    = lo_typedescr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2 ).

    IF sy-subrc <> 0.
      ev_reason = gc_reason-class_not_found.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_classdescr) = CAST cl_abap_classdescr( lo_typedescr ).
      CATCH cx_sy_move_cast_error.
        " lv_classname existiert als Typ, ist aber keine Klasse (z. B. Interface)
        ev_reason = gc_reason-class_not_found.
        RETURN.
    ENDTRY.

    DATA(lv_implements) = abap_false.
    LOOP AT lo_classdescr->interfaces INTO DATA(ls_interface).
      IF ls_interface-name = 'ZIF_STATISTICS03'.
        lv_implements = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_implements = abap_false.
      ev_reason = gc_reason-interface_not_implemented.
      RETURN.
    ENDIF.

    CREATE OBJECT ro_statistics TYPE (lv_classname)
      EXPORTING
        iv_customerid = iv_customerid.

  ENDMETHOD.


ENDCLASS.
