@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maximalumsatz pro Kunde'
@Metadata.ignorePropagatedAnnotations: true

define view entity zcs03_c_maxsales_r
  as select from zcs03_custorders
{
  key customerid                     as CustomerId,

      @Semantics.amount.currencyCode: 'Currency'
      max( order_total )             as MaxSales,

      currency                       as Currency

}
group by
  customerid,
  currency
