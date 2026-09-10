@EndUserText.label: 'Umsatzliste pro Kunde'
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view entity zcs03_c_salesbycust_r
  as select from zcs03_custorders
{
  key customerid                     as CustomerId,

      @Semantics.amount.currencyCode: 'Currency'
      sum( order_total )             as TotalSales,

      currency                       as Currency

}
group by
  customerid,
  currency
