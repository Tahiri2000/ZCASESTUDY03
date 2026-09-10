@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity zcs03exchrate_r
  as select from zcs03_exchrate
{
  key fromcurr     as FromCurr,
  key tocurr       as ToCurr,
  key startdate    as StartDate,
      exchangerate as ExchangeRate
}
