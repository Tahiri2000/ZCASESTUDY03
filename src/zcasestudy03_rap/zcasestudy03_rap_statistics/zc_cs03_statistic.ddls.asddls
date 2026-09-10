@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
} 
@ObjectModel: {
  sapObjectNodeType.name: 'ZCS03_STATISTIC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CS03_STATISTIC
  provider contract transactional_query
  as projection on ZR_CS03_STATISTIC
  association [1..1] to ZR_CS03_STATISTIC as _BaseEntity on $projection.Classname = _BaseEntity.Classname
{
  key Classname,
  Interface,
  @Consumption.valueHelpDefinition: [ {
    entity: { name: 'ZCS03_I_ACTIVEFLAG', element: 'ActiveValue' },
    useForValidation: true
  } ]
  Active    as Active,
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
  _BaseEntity
}
