*"* use this source file for your ABAP unit test classes
CLASS ltc_email_validation DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS valid_simple_email       FOR TESTING.
    METHODS valid_email_with_umlaut  FOR TESTING.
    METHODS invalid_missing_at       FOR TESTING.
    METHODS invalid_double_dot       FOR TESTING.
    METHODS invalid_tld_too_long     FOR TESTING.
    METHODS invalid_empty_email      FOR TESTING.

ENDCLASS.


CLASS ltc_email_validation IMPLEMENTATION.

  METHOD valid_simple_email.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_email_vali03=>is_valid( 'max.mustermann@firma.de' )
      msg = 'Gültige E-Mail wurde fälschlich abgelehnt'
    ).
  ENDMETHOD.

  METHOD valid_email_with_umlaut.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_email_vali03=>is_valid( 'müller@köln-post.de' )
      msg = 'Gültige E-Mail mit Umlaut wurde fälschlich abgelehnt'
    ).
  ENDMETHOD.

  METHOD invalid_missing_at.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_email_vali03=>is_valid( 'max.mustermannfirma.de' )
      msg = 'E-Mail ohne @ wurde fälschlich akzeptiert'
    ).
  ENDMETHOD.

  METHOD invalid_double_dot.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_email_vali03=>is_valid( 'max..mustermann@firma.de' )
      msg = 'E-Mail mit doppeltem Punkt wurde fälschlich akzeptiert'
    ).
  ENDMETHOD.

  METHOD invalid_tld_too_long.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_email_vali03=>is_valid( 'max@firma.info' )
      msg = 'E-Mail mit 4-stelliger TLD wurde fälschlich akzeptiert'
    ).
  ENDMETHOD.

  METHOD invalid_empty_email.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_email_vali03=>is_valid( '' )
      msg = 'Leere E-Mail wurde fälschlich akzeptiert'
    ).
  ENDMETHOD.

ENDCLASS.
