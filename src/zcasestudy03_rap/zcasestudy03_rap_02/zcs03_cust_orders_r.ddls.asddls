@EndUserText.label: 'CDS View Bestellungen'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity zcs03_cust_orders_r
  with parameters p_customerid : zcustomeridt3
  as select from zcs03_custorders

  association [0..1] to zcs03customers_r as _Customer
    on $projection.CustomerId = _Customer.CustomerId

{
    key customerid  as CustomerId,
    key orderid     as OrderId,
        order_date  as OrderDate,

        @Semantics.amount.currencyCode: 'Currency'
        order_total as OrderTotal,

        discount    as Discount,
        info        as Info,
        status      as Status,
        currency as Currency,
_Customer
}

where customerid = $parameters.p_customerid
