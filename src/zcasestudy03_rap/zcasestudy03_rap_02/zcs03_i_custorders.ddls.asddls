@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZCS03_I_CUSTORDERS
  as select from zcs03_custorders

  association [0..1] to ZCS03_I_CUSTOMERS_CDS as _Customer
    on $projection.Customerid = _Customer.Customerid
    
  association [0..1] to ZCS03_I_ORDSTATUS as _Status
    on  $projection.Status = _Status.Status
    and _Status.Language = $session.system_language

{
  key customerid as Customerid,
  key orderid as Orderid,
  
  order_date as OrderDate,

  @Semantics.amount.currencyCode: 'Currency'
  order_total as OrderTotal,

  discount as Discount,
  info as Info,
  
  @ObjectModel.text.element: [ 'StatusDescription' ]
  status as Status,
  
  _Status.Description as StatusDescription,

  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH',
    entity.element: 'Currency',
    useForValidation: true
  } ]
  currency as Currency,

  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH',
    entity.element: 'Currency',
    useForValidation: true
  } ]
  target_currency as TargetCurrency,

  change_rate_date as ChangeRateDate,

  @Semantics.amount.currencyCode: 'TargetCurrency'
  order_total_converted as OrderTotalConverted,

  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,

  @Semantics.user.createdBy: true
  created_by as CreatedBy,

  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  
  _Customer,
  _Status
}
