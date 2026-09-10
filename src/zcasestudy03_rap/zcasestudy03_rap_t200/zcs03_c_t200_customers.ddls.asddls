@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T200 Kunden'
@Metadata.allowExtensions: true

define root view entity ZCS03_C_T200_CUSTOMERS
    as projection on ZCS03_I_T200_CUSTOMERS
{
    key CustomerId,
    Salutation,
    LastName,
    FirstName,
    Company,
    Street,
    City,
    Country,
    Postcode,
    AccLock,
    LastDate,
    SalesVolume,
    SalesVolumeTarget,
    ChangeRateDate,
    Fax,
    Phone,
    Email,
    Currency,
    CurrencyTarget,
    Language,
    Weblogin,
    Webpw,
    Memo,
    Url,

    _Orders : redirected to composition child ZCS03_C_T200_CUSTORDERS
}
