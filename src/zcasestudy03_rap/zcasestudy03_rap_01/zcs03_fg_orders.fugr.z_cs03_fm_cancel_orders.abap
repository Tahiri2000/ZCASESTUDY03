FUNCTION z_cs03_fm_cancel_orders.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_CUSTOMERID) TYPE  ZCUSTOMERIDT3
*"----------------------------------------------------------------------
UPDATE zcs03_custorders
    SET status = 'BS'
    WHERE customerid = @iv_customerid.


ENDFUNCTION.
