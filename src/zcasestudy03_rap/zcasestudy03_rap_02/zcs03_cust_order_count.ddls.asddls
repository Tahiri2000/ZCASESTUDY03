@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Berechnetes Feld für die Anzahl der Bestellungen pro Kunde'

define view entity ZCS03_CUST_ORDER_COUNT
  as select from zcs03_custorders
{
  key customerid as CustomerId,
    count( * ) as OrderCount
}
where status not like 'S%'
group by customerid
