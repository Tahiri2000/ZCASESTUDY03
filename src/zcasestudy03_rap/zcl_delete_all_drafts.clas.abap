"! <p class="shorttext synchronized" lang="en">Clears all draft tables of the team</p>
"!
"! WARNING: This class performs REAL, IRREVERSIBLE deletions when executed!
"! There is no dry-run/simulation mode. Every call immediately and
"! permanently (COMMIT WORK) deletes all draft entries older than 30 minutes
"! in all tables listed below.
"! Before running: make sure no team member is actively working on a
"! draft that is younger than 30 minutes but still worth protecting.
CLASS zcl_delete_all_drafts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_draft_table,
             tabname TYPE string,
           END OF ty_draft_table,
           tt_draft_tables TYPE STANDARD TABLE OF ty_draft_table WITH EMPTY KEY.

    METHODS get_draft_tables
      RETURNING VALUE(rt_tables) TYPE tt_draft_tables.

    METHODS delete_old_drafts
      IMPORTING iv_tabname TYPE string
                iv_cutoff  TYPE timestampl
      EXPORTING ev_count   TYPE i
      RAISING   cx_root.

ENDCLASS.

CLASS zcl_delete_all_drafts IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lv_cutoff) = cl_abap_tstmp=>subtractsecs(
                         tstmp = lv_now
                         secs  = 1800 ).  "30 Minuten = 1800 Sekunden

    DATA lv_count TYPE i.

    LOOP AT get_draft_tables( ) INTO DATA(ls_table).

      TRY.
          delete_old_drafts(
            EXPORTING
              iv_tabname = ls_table-tabname
              iv_cutoff  = lv_cutoff
            IMPORTING
              ev_count   = lv_count ).

          out->write( |{ ls_table-tabname }: { lv_count } Einträge gelöscht| ).

        CATCH cx_root INTO DATA(lx_error).
          out->write( |{ ls_table-tabname }: ÜBERSPRUNGEN - { lx_error->get_text( ) }| ).
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_draft_tables.
    rt_tables = VALUE #(
      ( tabname = 'ZCS03_CUST_D' )
      ( tabname = 'ZCS03_T2_CUST_D' )
      ( tabname = 'ZCS03_CSTRDERS_D' )
      ( tabname = 'ZCS03_T2_CUSOR_D' )
      ( tabname = 'ZCS03_ORDRTEMS_D' )
      ( tabname = 'ZCS03_STTISTIC_D' )
    ).
  ENDMETHOD.

  METHOD delete_old_drafts.
    DELETE FROM (iv_tabname)
      WHERE draftentitycreationdatetime < @iv_cutoff.

    ev_count = sy-dbcnt.
    COMMIT WORK.
  ENDMETHOD.

ENDCLASS.
