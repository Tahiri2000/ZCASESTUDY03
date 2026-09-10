CLASS lhc_zr_cs03_statistic DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrCs03Statistic
        RESULT result,

      SetActiveClass FOR MODIFY
        IMPORTING keys FOR ACTION ZrCs03Statistic~SetActiveClass,

      validateActiveUnique FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrCs03Statistic~validateActiveUnique,

      deactivateOtherClasses FOR DETERMINE ON SAVE
        IMPORTING keys FOR ZrCs03Statistic~deactivateOtherClasses,

      determineInterface FOR DETERMINE ON SAVE
        IMPORTING keys FOR ZrCs03Statistic~determineInterface,

    validateClassnameValid for validate on save
            importing keys for ZrCs03Statistic~validateClassnameValid.

ENDCLASS.

CLASS lhc_zr_cs03_statistic IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD SetActiveClass.

    IF lines( keys ) > 1.
      LOOP AT keys INTO DATA(ls_key_multi).
        APPEND VALUE #( %tky = ls_key_multi-%tky ) TO failed-zrcs03statistic.
        APPEND VALUE #(
          %tky = ls_key_multi-%tky
          %msg = new_message(
            id       = 'ZCS03_STATISTIC_MSG'
            number   = '001'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zrcs03statistic.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA lt_update TYPE TABLE FOR UPDATE zr_cs03_statistic.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #(
        %tky            = ls_key-%tky
        Active          = abap_true
        %control-Active = if_abap_behv=>mk-on
      ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zr_cs03_statistic IN LOCAL MODE
      ENTITY ZrCs03Statistic
        UPDATE FIELDS ( Active )
        WITH lt_update.

  ENDMETHOD.

  METHOD deactivateOtherClasses.

    READ ENTITIES OF zr_cs03_statistic
      ENTITY ZrCs03Statistic
      FIELDS ( Active )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    DATA lt_update TYPE TABLE FOR UPDATE zr_cs03_statistic.

    LOOP AT lt_rows INTO DATA(ls_row) WHERE Active = abap_true.

      SELECT classname
        FROM zcs03_statistic
        WHERE active = @abap_true
          AND classname <> @ls_row-Classname
        INTO TABLE @DATA(lt_others).

      LOOP AT lt_others INTO DATA(ls_other).
        APPEND VALUE #(
          Classname       = ls_other-classname
          Active          = abap_false
          %control-Active = if_abap_behv=>mk-on
        ) TO lt_update.
      ENDLOOP.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_cs03_statistic IN LOCAL MODE
        ENTITY ZrCs03Statistic
          UPDATE FIELDS ( Active )
          WITH lt_update.
    ENDIF.

  ENDMETHOD.

  METHOD validateActiveUnique.

    " count how many rows are active in the database right now
    SELECT COUNT( * )
      FROM zcs03_statistic
      WHERE active = @abap_true
      INTO @DATA(lv_count).

    IF lv_count > 1.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-zrcs03statistic.
        APPEND VALUE #(
          %tky = ls_key-%tky
          %msg = new_message(
            id       = 'ZCS03_STATISTIC_MSG'
            number   = '001'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zrcs03statistic.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD determineinterface.

    READ ENTITIES OF zr_cs03_statistic
          ENTITY ZrCs03Statistic
          FIELDS ( Classname )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_rows).

    CHECK lt_rows IS NOT INITIAL.

    DATA lt_update TYPE TABLE FOR UPDATE zr_cs03_statistic.
    DATA lv_interface TYPE c LENGTH 30.

    LOOP AT lt_rows INTO DATA(ls_row).

      CLEAR lv_interface.

      DATA lo_typedescr TYPE REF TO cl_abap_typedescr.

      cl_abap_typedescr=>describe_by_name(
        EXPORTING
          p_name         = ls_row-Classname
        RECEIVING
          p_descr_ref    = lo_typedescr
        EXCEPTIONS
          type_not_found = 1
          OTHERS         = 2 ).

      IF sy-subrc = 0.
        TRY.
            DATA(lo_classdescr) = CAST cl_abap_classdescr( lo_typedescr ).
            LOOP AT lo_classdescr->interfaces INTO DATA(ls_interface).
              IF ls_interface-name = 'ZIF_STATISTICS03'.
                lv_interface = 'ZIF_STATISTICS03'.
                EXIT.
              ENDIF.
            ENDLOOP.
          CATCH cx_sy_move_cast_error.
        ENDTRY.
      ENDIF.

      APPEND VALUE #(
        %tky                = ls_row-%tky
        Interface           = lv_interface
        %control-Interface  = if_abap_behv=>mk-on
      ) TO lt_update.

    ENDLOOP.

    MODIFY ENTITIES OF zr_cs03_statistic IN LOCAL MODE
      ENTITY ZrCs03Statistic
        UPDATE FIELDS ( Interface )
        WITH lt_update.


  ENDMETHOD.

  METHOD validateclassnamevalid.

 READ ENTITIES OF zr_cs03_statistic
      ENTITY ZrCs03Statistic
      FIELDS ( Classname )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    LOOP AT lt_rows INTO DATA(ls_row).

      DATA(lv_valid) = abap_false.
      DATA(lv_interface_implemented) = abap_false.

      DATA lo_typedescr TYPE REF TO cl_abap_typedescr.

      cl_abap_typedescr=>describe_by_name(
        EXPORTING
          p_name         = ls_row-Classname
        RECEIVING
          p_descr_ref    = lo_typedescr
        EXCEPTIONS
          type_not_found = 1
          OTHERS         = 2 ).

      IF sy-subrc = 0.
        lv_valid = abap_true.
        TRY.
            DATA(lo_classdescr) = CAST cl_abap_classdescr( lo_typedescr ).
            LOOP AT lo_classdescr->interfaces INTO DATA(ls_interface).
              IF ls_interface-name = 'ZIF_STATISTICS03'.
                lv_interface_implemented = abap_true.
                EXIT.
              ENDIF.
            ENDLOOP.
          CATCH cx_sy_move_cast_error.
            lv_valid = abap_false.
        ENDTRY.
      ENDIF.

      IF lv_valid = abap_false.
        APPEND VALUE #( %tky = ls_row-%tky ) TO failed-zrcs03statistic.
        APPEND VALUE #(
          %tky = ls_row-%tky
          %msg = new_message(
            id       = 'ZCS03_STATISTIC_MSG'
            number   = '002'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zrcs03statistic.
      ELSEIF lv_interface_implemented = abap_false.
        APPEND VALUE #( %tky = ls_row-%tky ) TO failed-zrcs03statistic.
        APPEND VALUE #(
          %tky = ls_row-%tky
          %msg = new_message(
            id       = 'ZCS03_STATISTIC_MSG'
            number   = '003'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zrcs03statistic.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
