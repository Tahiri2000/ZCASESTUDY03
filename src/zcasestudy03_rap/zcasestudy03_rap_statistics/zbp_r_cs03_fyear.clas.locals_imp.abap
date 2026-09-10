CLASS lhc_ZR_CS03_FYEAR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zr_cs03_fyear RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zr_cs03_fyear RESULT result.



    METHODS SetActiveYear FOR MODIFY
      IMPORTING keys FOR ACTION zr_cs03_fyear~SetActiveYear.

    METHODS deactivateOtherYears FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_cs03_fyear~deactivateOtherYears.

    METHODS validateActiveYearUnique FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_cs03_fyear~validateActiveYearUnique.

ENDCLASS.

CLASS lhc_ZR_CS03_FYEAR IMPLEMENTATION.

  METHOD get_instance_authorizations.

     result = VALUE #( FOR key IN keys (
      %tky    = key-%tky
      %update = if_abap_behv=>auth-allowed
      %delete = if_abap_behv=>auth-allowed
      %action-Edit          = if_abap_behv=>auth-allowed
      %action-SetActiveYear = if_abap_behv=>auth-allowed
    ) ).

  ENDMETHOD.

  METHOD get_global_authorizations.

    result-%create = if_abap_behv=>auth-allowed.

  ENDMETHOD.



  METHOD setactiveyear.

    IF lines( keys ) > 1.
      LOOP AT keys INTO DATA(ls_key_multi).
        APPEND VALUE #( %tky = ls_key_multi-%tky ) TO failed-zr_cs03_fyear.
        APPEND VALUE #(
          %tky = ls_key_multi-%tky
          %msg = new_message(
            id       = 'ZCS03_FYEAR_MSG'
            number   = '001'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zr_cs03_fyear.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA lt_update TYPE TABLE FOR UPDATE zr_cs03_fyear.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #(
        %tky            = ls_key-%tky
        Active          = abap_true
        %control-Active = if_abap_behv=>mk-on
      ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zr_cs03_fyear IN LOCAL MODE
      ENTITY zr_cs03_fyear
        UPDATE FIELDS ( Active )
        WITH lt_update.

  ENDMETHOD.

  METHOD deactivateotheryears.

    READ ENTITIES OF zr_cs03_fyear
          ENTITY zr_cs03_fyear
          FIELDS ( Active )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_rows).

    DATA lt_update TYPE TABLE FOR UPDATE zr_cs03_fyear.

    LOOP AT lt_rows INTO DATA(ls_row) WHERE Active = abap_true.

      SELECT fiscal_year_id
        FROM zcs03_fyear
        WHERE active = @abap_true
          AND fiscal_year_id <> @ls_row-FiscalYearId
        INTO TABLE @DATA(lt_others).

      LOOP AT lt_others INTO DATA(ls_other).
        APPEND VALUE #(
          FiscalYearId    = ls_other-fiscal_year_id
          Active          = abap_false
          %control-Active = if_abap_behv=>mk-on
        ) TO lt_update.
      ENDLOOP.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_cs03_fyear IN LOCAL MODE
        ENTITY zr_cs03_fyear
          UPDATE FIELDS ( Active )
          WITH lt_update.
    ENDIF.


  ENDMETHOD.

  METHOD validateactiveyearunique.

    SELECT COUNT( * )
         FROM zcs03_fyear
         WHERE active = @abap_true
         INTO @DATA(lv_count).

    IF lv_count > 1.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-zr_cs03_fyear.
        APPEND VALUE #(
          %tky = ls_key-%tky
          %msg = new_message(
            id       = 'ZCS03_FYEAR_MSG'
            number   = '001'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zr_cs03_fyear.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.



ENDCLASS.
