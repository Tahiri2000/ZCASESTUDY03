@EndUserText.label: 'Customer Projection'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@Metadata.allowExtensions: true

define root view entity ZCS03_C_CUSTOMERS
  provider contract transactional_query
  as projection on ZCS03_I_CUSTOMERS_CDS
 
{
  key Customerid,
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
      LogId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CS03_CALCULATE'
virtual NumberOfOrders : abap.int4
}
