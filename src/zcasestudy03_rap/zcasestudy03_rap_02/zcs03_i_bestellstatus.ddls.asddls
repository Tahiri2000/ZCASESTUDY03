@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help Bestellstatus'

define view entity ZCS03_I_BESTELLSTATUS
  as select from zcs03_ordstatus
{
  key status as Status,
  description as Description
}
//Nachbesserung auf Wunsch von Herrn Buhl 
where language = $session.system_language
