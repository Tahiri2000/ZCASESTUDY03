@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Language Value Help'

define view entity ZCS03_I_LANGUAGE_NACHBESSERUNG
  as select from I_Language
    association [0..1] to I_LanguageText as _Text
      on  $projection.Language = _Text.LanguageCode
      and _Text.Language = $session.system_language
{
  key Language,

      @Semantics.text: true
      _Text.LanguageName as LanguageName
}
