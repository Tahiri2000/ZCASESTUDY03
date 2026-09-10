@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZCS03_STATISTIC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CS03_STATISTIC
  as select from zcs03_statistic
{
  key classname as Classname,
  active as Active,
  interface as Interface,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy

}
