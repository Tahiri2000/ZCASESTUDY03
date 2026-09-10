CLASS zcl_cs03_calculate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_cs03_calculate IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF line_exists(
         it_requested_calc_elements[
           table_line = 'NUMBEROFORDERS'
         ] ).

      APPEND 'CUSTOMERID' TO et_requested_orig_elements.

    ENDIF.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    TYPES:
      BEGIN OF ty_original,
        customerid TYPE zcs03_customers-customerid,
      END OF ty_original.

    TYPES:
      BEGIN OF ty_calculated,
        customerid     TYPE zcs03_customers-customerid,
        numberoforders TYPE int4,
      END OF ty_calculated.

    DATA lt_original_data TYPE STANDARD TABLE OF ty_original
      WITH DEFAULT KEY.

    DATA lt_calculated_data TYPE STANDARD TABLE OF ty_calculated
      WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original>).

      DATA(lv_count) = 0.

      SELECT COUNT( * )
        FROM zcs03_custorders
        WHERE customerid = @<ls_original>-customerid
          AND status NOT LIKE 'S%'
        INTO @lv_count.

      APPEND VALUE #(
        customerid     = <ls_original>-customerid
        numberoforders = lv_count
      ) TO lt_calculated_data.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_calculated_data ).

  ENDMETHOD.

ENDCLASS.
