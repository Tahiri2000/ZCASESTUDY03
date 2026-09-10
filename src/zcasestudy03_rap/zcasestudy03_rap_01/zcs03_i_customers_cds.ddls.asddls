@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'View Entity for ZCS03_CUSTOMERS'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZCS03_I_CUSTOMERS_CDS
as select from zcs03_customers as _Customer

//association [0..1] to ZCS03_CUST_ORDER_COUNT as _OrderCount
 //on _Customer.customerid = _OrderCount.CustomerId

{
key _Customer.customerid            as Customerid,
    _Customer.salutation            as Salutation,
    _Customer.last_name             as LastName,
    _Customer.first_name            as FirstName,
    _Customer.company               as Company,
    _Customer.street                as Street,
    _Customer.city                  as City,
    _Customer.country               as Country,
    _Customer.postcode              as Postcode,
    _Customer.acc_lock              as AccLock,
    _Customer.last_date             as LastDate,

    @Semantics.amount.currencyCode : 'currency'
    _Customer.sales_volume          as SalesVolume,

    @Semantics.amount.currencyCode : 'currency'
    _Customer.sales_volume_target   as SalesVolumeTarget,

    _Customer.change_rate_date      as ChangeRateDate,
    _Customer.fax                   as Fax,
    _Customer.phone                 as Phone,
    _Customer.email                 as Email,
    _Customer.currency              as Currency,
    _Customer.currency_target       as CurrencyTarget,
    _Customer.language              as Language,
    _Customer.weblogin              as Weblogin,
    _Customer.webpw                 as Webpw,
    _Customer.memo                  as Memo,
    _Customer.url                   as Url,
    _Customer.log_id                as LogId,
    _Customer.created_by            as CreatedBy,
    _Customer.created_at            as CreatedAt,
    _Customer.last_changed_by       as LastChangedBy,
    _Customer.last_changed_at       as LastChangedAt,
    _Customer.local_last_changed_at as LocalLastChangedAt
    
    //_OrderCount.OrderCount          as OrderCount  // 
}
