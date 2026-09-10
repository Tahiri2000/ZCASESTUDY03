@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View auf ZCS03_ORDSTATUS'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZCS03_I_ORDSTATUS
  as select from zcs03_ordstatus
{
  key status      as Status,
  key language    as Language,
      description as Description
}
