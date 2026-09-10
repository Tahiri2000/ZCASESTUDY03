@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Wertehilfe Active'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZCS03_I_ACTIVEFLAG
  as select from zcs03_activeflag
{
  @ObjectModel.text.element: [ 'ActiveText' ]
  key value as ActiveValue,
      text  as ActiveText
}
