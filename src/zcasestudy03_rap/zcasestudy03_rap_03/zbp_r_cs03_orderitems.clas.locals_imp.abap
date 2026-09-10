CLASS LHC_ORDERITEMS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.

  PRIVATE SECTION.

    METHODS GET_GLOBAL_AUTHORIZATIONS
      FOR GLOBAL AUTHORIZATION
      IMPORTING
        REQUEST requested_authorizations FOR OrderItems
      RESULT result.

    METHODS CalculateItemTotal
      FOR DETERMINE ON SAVE
      IMPORTING keys FOR OrderItems~CalculateItemTotal.

ENDCLASS.


CLASS LHC_ORDERITEMS IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.

    result = VALUE #(
      %create = if_abap_behv=>auth-allowed
      %update = if_abap_behv=>auth-allowed
      %delete = if_abap_behv=>auth-allowed
    ).

  ENDMETHOD.


 METHOD CalculateItemTotal.

  READ ENTITIES OF ZZR_CS03_ORDERITEMS IN LOCAL MODE
    ENTITY OrderItems
    FIELDS ( Customerid Orderid Quantity Price )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

  CHECK lt_items IS NOT INITIAL.

  DATA lt_update TYPE TABLE FOR UPDATE ZZR_CS03_ORDERITEMS.

  LOOP AT lt_items INTO DATA(ls_item).

    SELECT SINGLE discount
      FROM zcs03_custorders
      WHERE customerid = @ls_item-Customerid
        AND orderid    = @ls_item-Orderid
      INTO @DATA(lv_discount).

    DATA(lv_factor) = CONV decfloat34( 1 ) -
                      CONV decfloat34( lv_discount ) / 100.

    DATA(lv_item_total) =
      CONV decfloat34( ls_item-Quantity ) *
      CONV decfloat34( ls_item-Price ) *
      lv_factor.

    APPEND VALUE #(
      %tky = ls_item-%tky
      ItemTotal = lv_item_total
      %control-ItemTotal = if_abap_behv=>mk-on
    ) TO lt_update.

  ENDLOOP.

  CHECK lt_update IS NOT INITIAL.

  MODIFY ENTITIES OF ZZR_CS03_ORDERITEMS IN LOCAL MODE
    ENTITY OrderItems
    UPDATE FIELDS ( ItemTotal )
    WITH lt_update.

ENDMETHOD.

ENDCLASS.
