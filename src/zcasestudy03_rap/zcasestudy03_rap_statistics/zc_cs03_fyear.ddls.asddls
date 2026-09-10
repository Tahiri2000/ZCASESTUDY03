@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View für ZC_CS03_FYEAR'
@Metadata.allowExtensions: true
@UI.headerInfo: {
  typeName: 'Geschäftsjahr',
  typeNamePlural: 'Geschäftsjahre'
}
define root view entity ZC_CS03_FYEAR
  provider contract transactional_query
  as projection on ZR_CS03_FYEAR
{
    @UI.facet: [{ id: 'GeneralInfo', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Geschäftsjahr', position: 10 }]
  @UI.hidden: true
  key FiscalYearId,
 

 @UI.lineItem: [{ position: 10, label: 'Von' }]
  @UI.identification: [{ position: 10, label: 'Von' }]
  StartDate,

  @UI.lineItem: [{ position: 20, label: 'Bis' }]
  @UI.identification: [{ position: 20, label: 'Bis' }]
  EndDate,

  @UI.lineItem: [{ position: 30, label: 'Beschreibung' }]
  @UI.identification: [{ position: 30, label: 'Beschreibung' }]
  Description,

  @UI.lineItem: [{ position: 40, label: 'Aktiv' }]
  @UI.identification: [{ position: 40, label: 'Aktiv' }]
  @Consumption.valueHelpDefinition: [ {
    entity: { name: 'ZCS03_I_ACTIVEFLAG', element: 'ActiveValue' },
    useForValidation: true
  } ]
  Active,

  CreatedBy,
  CreatedAt,
  LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LocalLastChangedAt
}
