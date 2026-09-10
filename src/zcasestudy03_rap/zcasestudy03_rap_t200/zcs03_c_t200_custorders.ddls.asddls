@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T200 Kundenbestellungen'
@Metadata.allowExtensions: true

define view entity ZCS03_C_T200_CUSTORDERS
    as projection on ZCS03_I_T200_CUSTORDERS
{
    key CustomerId,
    key OrderId,
    OrderDate,
    OrderTotal,
    Discount,
    Info,
    Status,
    Currency,
    TargetCurrency,
    ChangeRateDate,
    OrderTotalConverted,
    ChildLocalLastChangedAt,
    //LastChangedAt,
    CreatedBy,
    LastChangedBy,

    _Customer : redirected to parent ZCS03_C_T200_CUSTOMERS
}
