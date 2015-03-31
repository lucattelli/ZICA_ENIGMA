*----------------------------------------------------------------------*
*       CLASS reflector DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS reflector DEFINITION.
  PUBLIC SECTION.
    METHODS : constructor IMPORTING wiring TYPE string OPTIONAL,
              save_wiring IMPORTING wiring TYPE string,
              send_signal IMPORTING in TYPE ch_idx=>type_index
                          RETURNING value(out) TYPE ch_idx=>type_index.
  PRIVATE SECTION.
    TYPES : BEGIN OF type_reflection,
              a TYPE i,
              b TYPE i,
            END OF type_reflection,
            type_reflection_tab TYPE TABLE OF type_reflection.
    DATA reflections TYPE type_reflection_tab.
ENDCLASS.                    "reflector DEFINITION

*----------------------------------------------------------------------*
*       CLASS reflector IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS reflector IMPLEMENTATION.
  METHOD constructor.
    DATA t_refs TYPE TABLE OF ch_idx=>type_index.
    DATA reflection TYPE type_reflection.
    DATA reflected_index TYPE i.
    IF NOT wiring IS INITIAL.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename                = wiring
          has_field_separator     = abap_true
        TABLES
          data_tab                = me->reflections
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
          OTHERS                  = 17.
    ENDIF.
    IF me->reflections IS INITIAL.
      DO 26 TIMES.
        APPEND sy-index TO t_refs.
      ENDDO.
      shuffler=>shuffle_numbers_tab( CHANGING tab = t_refs ).
      DO 26 TIMES.
        READ TABLE t_refs INTO reflection-a INDEX sy-index.
        reflected_index = 27 - sy-index.
        READ TABLE t_refs INTO reflection-b INDEX reflected_index.
        APPEND reflection TO me->reflections.
      ENDDO.
      SORT me->reflections BY a.
    ENDIF.

  ENDMETHOD.                    "constructor

  METHOD save_wiring.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = wiring
        write_field_separator   = abap_true
      TABLES
        data_tab                = me->reflections
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
  ENDMETHOD.                    "save_wiring

  METHOD send_signal.
    DATA reflection TYPE type_reflection.
    READ TABLE me->reflections INTO reflection
      WITH KEY a = in BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      out = reflection-b. "// does reflect
    ELSE.
      out = in. "// does not reflect
    ENDIF.
  ENDMETHOD.                    "send_signal
ENDCLASS.                    "reflector IMPLEMENTATION
