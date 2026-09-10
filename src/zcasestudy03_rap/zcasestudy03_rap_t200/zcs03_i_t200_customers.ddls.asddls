define root view entity ZCS03_I_T200_CUSTOMERS
  as select from zcs03_customers

  composition [0..*] of ZCS03_I_T200_CUSTORDERS as _Orders
{
// @UI.hidden
  key customerid as CustomerId,
      salutation as Salutation,
      last_name as LastName,
      first_name as FirstName,
      company as Company,
      street as Street,
      city as City,
      country as Country,
      postcode as Postcode,
      acc_lock as AccLock,
      last_date as LastDate,
      sales_volume as SalesVolume,
      sales_volume_target as SalesVolumeTarget,
      change_rate_date as ChangeRateDate,
      fax as Fax,
      phone as Phone,
      email as Email,
      currency as Currency,
      currency_target as CurrencyTarget,
      language as Language,
      weblogin as Weblogin,
      webpw as Webpw,
      memo as Memo,
      url as Url,
  log_id as LogId,
local_last_changed_at as LocalLastChangedAt,
last_changed_at as LastChangedAt,
_Orders
}
