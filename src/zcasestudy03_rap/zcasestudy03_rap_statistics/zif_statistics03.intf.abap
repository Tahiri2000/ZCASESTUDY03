INTERFACE zif_statistics03
  PUBLIC .

TYPES ty_sales_amount TYPE p LENGTH 15 DECIMALS 2.

  METHODS average_sales
    RETURNING VALUE(rv_average_sales) TYPE ty_sales_amount.

  METHODS max_sales
    RETURNING VALUE(rv_max_sales) TYPE ty_sales_amount.

  METHODS day_sales
    RETURNING VALUE(rv_day_sales) TYPE ty_sales_amount.

ENDINTERFACE.
