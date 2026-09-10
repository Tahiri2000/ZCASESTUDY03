CLASS zcl_delete_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

 INTERFACES if_oo_adt_classrun.

    CLASS-METHODS delete_draft_row
      IMPORTING iv_customerid TYPE string.

    CLASS-METHODS delete_all_draft.

    CLASS-METHODS delete_draft_row_t200_customer
      IMPORTING iv_customerid TYPE string.

    CLASS-METHODS delete_all_draft_t200_customer.

    CLASS-METHODS delete_draft_row_t200_order
      IMPORTING iv_customerid TYPE string.

    CLASS-METHODS delete_all_draft_t200_order.

    CLASS-METHODS delete_draft_row_custorders
      IMPORTING iv_customerid TYPE string.

    CLASS-METHODS delete_all_draft_custorders.

ENDCLASS.


CLASS zcl_delete_draft IMPLEMENTATION.

METHOD if_oo_adt_classrun~main.

    delete_all_draft( ).
    delete_all_draft_t200_customer( ).
    delete_all_draft_t200_order( ).
    delete_all_draft_custorders( ).

  ENDMETHOD.


  METHOD delete_draft_row.

    DELETE FROM zcs03_cust_d
      WHERE customerid = @iv_customerid.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_all_draft.

    DELETE FROM zcs03_cust_d.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_draft_row_t200_customer.

    DELETE FROM zcs03_t2_cust_d
      WHERE customerid = @iv_customerid.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_all_draft_t200_customer.

    DELETE FROM zcs03_t2_cust_d.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_draft_row_t200_order.

    DELETE FROM zcs03_t2_cusor_d
      WHERE customerid = @iv_customerid.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_all_draft_t200_order.

    DELETE FROM zcs03_t2_cusor_d.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_draft_row_custorders.

    DELETE FROM zcs03_cstrders_d
      WHERE customerid = @iv_customerid.

    COMMIT WORK.

  ENDMETHOD.


  METHOD delete_all_draft_custorders.

    DELETE FROM zcs03_cstrders_d.

    COMMIT WORK.

  ENDMETHOD.


ENDCLASS.
