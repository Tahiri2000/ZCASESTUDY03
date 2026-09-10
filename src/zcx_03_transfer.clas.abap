CLASS zcx_03_transfer DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

*     Wert zu lang für ein Zielfeld (z. B. COMPANY, STREET, CITY)
    CONSTANTS:
      BEGIN OF value_too_long,
        msgid TYPE symsgid VALUE 'ZCS03_TRANSFER',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'FIELDNAME',
        attr2 TYPE scx_attrname VALUE 'MAXLEN',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF value_too_long.

*    Postleitzahl konnte nicht aufgelöst werden
    CONSTANTS:
      BEGIN OF invalid_postcode,
        msgid TYPE symsgid VALUE 'ZCS03_TRANSFER',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'POSTCODE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_postcode.

*     Pflichtfeld fehlt im Quelldatensatz
    CONSTANTS:
      BEGIN OF missing_mandatory_field,
        msgid TYPE symsgid VALUE 'ZCS03_TRANSFER',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'FIELDNAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF missing_mandatory_field.

    CONSTANTS:
      BEGIN OF field_is_empty,
        msgid TYPE symsgid VALUE 'ZCS03_TRANSFER',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'FIELDNAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF field_is_empty.

*    DATA fieldname TYPE fieldname.
    DATA fieldname TYPE string.
*    DATA fieldname TYPE char30.
*    DATA fieldname TYPE zdfieldname03.
    DATA maxlen    TYPE i.
    DATA postcode  TYPE zcs03_customers-postcode.

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous                 OPTIONAL
*        fieldname TYPE fieldname                OPTIONAL
        fieldname TYPE string                   OPTIONAL
        maxlen    TYPE i                        OPTIONAL
        postcode  TYPE zcs03_customers-postcode OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_03_transfer IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).

    me->fieldname = fieldname.
    me->maxlen    = maxlen.
    me->postcode  = postcode.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
