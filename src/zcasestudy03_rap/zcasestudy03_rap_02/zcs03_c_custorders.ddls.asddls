@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZCUSTORDERS'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZCS03_C_CUSTORDERS
  provider contract transactional_query
  
  as projection on ZCS03_I_CUSTORDERS
  association [1..1] to ZCS03_I_CUSTORDERS as _BaseEntity
  on  $projection.Customerid = _BaseEntity.Customerid
  and $projection.Orderid    = _BaseEntity.Orderid
{
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'ZCS03_C_CUSTOMERS',
            element: 'Customerid'
          },
          useForValidation: true
        }
      ]
  key Customerid,
  key Orderid,
      OrderDate,
      @Semantics: {
        amount.currencyCode: 'Currency'
      }
      OrderTotal,
      TargetCurrency,
      @Semantics: {
        amount.currencyCode: 'TargetCurrency'
      }
      OrderTotalConverted,
      Discount,
      Info,

      @ObjectModel.text.element: [ 'StatusDescription' ]
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: 'ZCS03_I_BESTELLSTATUS',
            element: 'Status'
          }
        }
      ]
      Status,
        
      StatusDescription,

      @Consumption: {
        valueHelpDefinition: [ {
          entity.element: 'Currency',
          entity.name: 'I_CurrencyStdVH',
          useForValidation: true
        } ]
      }
      Currency,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        user.lastChangedBy: true
      }
      LastChangedBy,
      _Customer
}
