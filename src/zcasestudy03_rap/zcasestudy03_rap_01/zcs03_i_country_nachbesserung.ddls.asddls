@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Value Help'

define view entity ZCS03_I_COUNTRY_NACHBESSERUNG
  as select from I_Country
    association [0..1] to I_CountryText as _Text
      on  $projection.Country = _Text.Country
      and _Text.Language = $session.system_language
{
  key Country,

      @Semantics.text: true
      _Text.CountryName as CountryName
}
