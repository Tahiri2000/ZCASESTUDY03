CLASS zcl_statistics03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_statistics03.

    METHODS constructor
      IMPORTING
        iv_customerid TYPE zcustomeridt3 OPTIONAL.

  PRIVATE SECTION.
    DATA mv_customerid TYPE zcustomeridt3.

ENDCLASS.

CLASS zcl_statistics03 IMPLEMENTATION.

  METHOD constructor.
    mv_customerid = iv_customerid.
  ENDMETHOD.

  METHOD zif_statistics03~average_sales.

    DATA(lv_year_start) = zcl_fiscal_year_03=>get_fiscal_year_start_date( sy-datum ).
    DATA(lv_year_end)   = zcl_fiscal_year_03=>get_fiscal_year_end_date( sy-datum ).

    SELECT SUM( OrderTotalConverted ), COUNT(*)
    FROM zcs03_c_custorders
    WHERE Customerid = @mv_customerid
      AND OrderDate BETWEEN @lv_year_start AND @lv_year_end
      AND Status NOT IN ( 'SA', 'SB', 'SN', 'SO' )
    INTO ( @DATA(lv_sum), @DATA(lv_count) ).

    IF lv_count > 0.
      rv_average_sales = lv_sum / lv_count.
    ENDIF.

  ENDMETHOD.

  METHOD zif_statistics03~max_sales.

    SELECT MAX( OrderTotalConverted )
    FROM zcs03_c_custorders
    WHERE Customerid = @mv_customerid
      AND Status NOT IN ( 'SA', 'SB', 'SN', 'SO' )
    INTO @DATA(lv_max).

    rv_max_sales = lv_max.

  ENDMETHOD.

  METHOD zif_statistics03~day_sales.

    " Kundenunabhaengig laut T191 - kein Customerid-Filter
    DATA(lv_year_start)   = zcl_fiscal_year_03=>get_fiscal_year_start_date( sy-datum ).
    DATA(lv_days_elapsed) = sy-datum - lv_year_start + 1.

    SELECT SUM( OrderTotalConverted )
    FROM zcs03_c_custorders
    WHERE OrderDate BETWEEN @lv_year_start AND @sy-datum
      AND Status NOT IN ( 'SA', 'SB', 'SN', 'SO' )
    INTO @DATA(lv_total).

    IF lv_days_elapsed > 0.
      rv_day_sales = lv_total / lv_days_elapsed.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
