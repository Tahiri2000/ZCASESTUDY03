@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T200 Kundenbestellungen'

define view entity ZCS03_I_T200_CUSTORDERS
  as select from zcs03_custorders

  association to parent ZCS03_I_T200_CUSTOMERS as _Customer on $projection.CustomerId = _Customer.CustomerId
{
  key customerid            as CustomerId,
  key orderid               as OrderId,

      order_date            as OrderDate,
      order_total           as OrderTotal,
      discount              as Discount,
      info                  as Info,
      @Consumption.valueHelpDefinition: [ {
        entity.name: 'ZCS03_I_BESTELLSTATUS',
        entity.element: 'Status'
      } ]
      status                as Status,
      @Consumption.valueHelpDefinition: [ {
      entity.name: 'I_CurrencyStdVH',
      entity.element: 'Currency',
      useForValidation: true
      } ]
      currency              as Currency,
      @Consumption.valueHelpDefinition: [ {
      entity.name: 'I_CurrencyStdVH',
      entity.element: 'Currency',
      useForValidation: true
      } ]
      target_currency       as TargetCurrency,
      change_rate_date      as ChangeRateDate,
      order_total_converted as OrderTotalConverted,
      //local_last_changed_at as ChildLocalLastChangedAt,
      local_last_changed_at as ChildLocalLastChangedAt,
      created_by            as CreatedBy,
      last_changed_by       as LastChangedBy,

      _Customer
}
