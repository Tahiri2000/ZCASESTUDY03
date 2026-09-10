@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZCS03_CUSTOMERS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCS03_I_CUSTOMERS
  as select from zcs03_customers
{
  key customerid            as Customerid,
      salutation            as Salutation,
      last_name             as LastName,
      first_name            as FirstName,
      company               as Company,
      street                as Street,
      city                  as City,
      country               as Country,
      postcode              as Postcode,
      acc_lock              as AccLock,
      last_date             as LastDate,
      @Semantics.amount.currencyCode : 'currency'
      sales_volume          as SalesVolume,
      @Semantics.amount.currencyCode : 'currency'
      sales_volume_target   as SalesVolumeTarget,
      change_rate_date      as ChangeRateDate,
      fax                   as Fax,
      phone                 as Phone,
      email                 as Email,
      currency              as Currency,
      currency_target       as CurrencyTarget,
      language              as Language,
      weblogin              as Weblogin,
      webpw                 as Webpw,
      memo                  as Memo,
      log_id                as LogId,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
