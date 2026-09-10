*Implementierung in Code
*IF zcl_email_vali03=>is_valid( ls_customer-email ) = abap_false.
*  " ungültige E-Mail ins Memo-Feld schreiben
*  ls_customer-memo = |{ ls_customer-memo }
*Ungültige E-Mail-Adresse: { ls_customer-email }|.
*ENDIF.

CLASS zcl_email_vali03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA gv_email_pattern TYPE string READ-ONLY.

*     Prüft die Syntax einer E-Mail-Adresse per Regular Expression.
*     @parameter iv_email | zu prüfende E-Mail-Adresse
*     @parameter rv_valid | abap_true = syntaktisch gültig
    CLASS-METHODS is_valid
      IMPORTING iv_email        TYPE string
      RETURNING VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS class_constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_email_vali03 IMPLEMENTATION.

    METHOD class_constructor.
        gv_email_pattern =
            '^[A-Za-zÀ-ÖØ-öø-ÿ0-9_%+-]+(\.[A-Za-zÀ-ÖØ-öø-ÿ0-9_%+-]+)*' &&
            '@[A-Za-zÀ-ÖØ-öø-ÿ0-9-]+(\.[A-Za-zÀ-ÖØ-öø-ÿ0-9-]+)*' &&
            '\.[A-Za-zÀ-ÖØ-öø-ÿ]{2,3}$'.
    ENDMETHOD.

    METHOD is_valid.

        DATA(lv_email) = |{ iv_email }|.
        CONDENSE lv_email.

        IF lv_email IS INITIAL.   "ist email Feld leer?
          rv_valid = abap_false.
          RETURN.
        ENDIF.

        rv_valid = xsdbool( matches(
                                    val  = lv_email
                                    pcre = gv_email_pattern
                                    )
        ).
    ENDMETHOD.

ENDCLASS.
