@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: 'View Entity for ZCS03_FYEAR'
define root view entity ZR_CS03_FYEAR
  as select from zcs03_fyear
{
  key fiscal_year_id      as FiscalYearId,
  start_date              as StartDate,
  end_date                as EndDate,
  description             as Description,
  active                  as Active,
  @Semantics.user.createdBy: true
  created_by              as CreatedBy,
  created_at              as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by         as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at         as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at   as LocalLastChangedAt
}
