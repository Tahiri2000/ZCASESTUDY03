CLASS zcl_import_job_03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

    METHODS write_log
      IMPORTING
        iv_customerid       TYPE zcs03_customers-customerid OPTIONAL
        iv_fieldname        TYPE string OPTIONAL
        iv_message          TYPE string
      RETURNING VALUE(rv_log_id) TYPE zcs03_import_log-log_id.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_log_counter TYPE i.

ENDCLASS.


CLASS zcl_import_job_03 IMPLEMENTATION.

  METHOD if_apj_rt_exec_object~execute.

    SELECT SINGLE MAX( log_id ) FROM zcs03_import_log INTO @DATA(lv_max_id).

    TRY.
        gv_log_counter = lv_max_id.
      CATCH cx_sy_conversion_no_number.
        gv_log_counter = 0.
    ENDTRY.

    TRY.

        DATA(lo_import) = NEW zcl_import_data03( ).
        DATA lt_warnings TYPE zcl_import_data03=>tt_import_warnings.
        DATA lv_lookup_failed TYPE i.

        DATA(lv_duplicates) = lo_import->import_data(
          IMPORTING et_warnings      = lt_warnings
                    ev_lookup_failed = lv_lookup_failed ).

        write_log( iv_message = |Import erfolgreich, { lv_duplicates } Duplikate, { lines( lt_warnings ) } Warnungen, { lv_lookup_failed } Lookups fehlgeschlagen| ).

        LOOP AT lt_warnings INTO DATA(ls_warning).

          write_log( iv_customerid = ls_warning-customerid
                     iv_fieldname  = ls_warning-fieldname
                     iv_message    = |{ ls_warning-company }: { ls_warning-message }| ).

        ENDLOOP.

      CATCH cx_root INTO DATA(lo_error).
        write_log( iv_message = |Fehler: { lo_error->get_text( ) } ({ cl_abap_classdescr=>describe_by_object_ref( lo_error )->get_relative_name( ) })| ).
    ENDTRY.

  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Wir haben keine Parameter
  ENDMETHOD.


  METHOD write_log.

    gv_log_counter = gv_log_counter + 1.
    DATA(lv_log_id) = |{ gv_log_counter WIDTH = 10 PAD = '0' ALIGN = RIGHT }|.

    DATA(ls_log) = VALUE zcs03_import_log(
      client     = sy-mandt
      log_id     = lv_log_id
      timestamp  = utclong_current( )
      fieldname  = iv_fieldname
      message    = iv_message
      customerid = iv_customerid
    ).

    INSERT zcs03_import_log FROM @ls_log.
    COMMIT WORK.

    rv_log_id = lv_log_id.

  ENDMETHOD.

ENDCLASS.
