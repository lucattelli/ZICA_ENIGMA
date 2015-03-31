*----------------------------------------------------------------------*
*       CLASS rotor DEFINITION
*----------------------------------------------------------------------*
* This class represents a single rotor inside Enigma
*----------------------------------------------------------------------*
CLASS rotor DEFINITION.
  PUBLIC SECTION.
    EVENTS knob.
    METHODS : constructor IMPORTING wiring TYPE string OPTIONAL,
              save_wiring IMPORTING wiring TYPE string,
              send_signal IMPORTING in TYPE ch_idx=>type_index
                          RETURNING value(out) TYPE ch_idx=>type_index,
              return_signal IMPORTING in TYPE ch_idx=>type_index
                            RETURNING value(out) TYPE ch_idx=>type_index,
              rotate FOR EVENT knob OF rotor,
              get_position RETURNING value(pos) TYPE ch_idx=>type_index.
  PRIVATE SECTION.
    DATA circuit TYPE TABLE OF ch_idx=>type_index.
    DATA position TYPE ch_idx=>type_index.
    METHODS set_position IMPORTING pos TYPE ch_idx=>type_index.
ENDCLASS.                    "rotor DEFINITION

*----------------------------------------------------------------------*
*       CLASS rotor IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS rotor IMPLEMENTATION.
  METHOD constructor.
    IF NOT wiring IS INITIAL.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename                = wiring
          has_field_separator     = abap_true
        TABLES
          data_tab                = me->circuit
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
    IF me->circuit IS INITIAL.
      DO 26 TIMES.
        APPEND sy-index TO me->circuit.
      ENDDO.
      shuffler=>shuffle_numbers_tab( CHANGING tab = me->circuit ).
    ENDIF.
    position = 1.
  ENDMETHOD.                    "constructor
  METHOD save_wiring.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = wiring
        write_field_separator   = abap_true
      TABLES
        data_tab                = me->circuit
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
    READ TABLE me->circuit INTO out INDEX in.
  ENDMETHOD.                    "send_signal
  METHOD return_signal.
    DATA wire TYPE ch_idx=>type_index.
    LOOP AT me->circuit INTO wire.
      IF wire EQ in.
        out = sy-tabix.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "return_signal
  METHOD rotate.
    DATA wire TYPE ch_idx=>type_index.
    DATA new_circuit TYPE TABLE OF ch_idx=>type_index.
    DATA new_pos TYPE ch_idx=>type_index.
    LOOP AT me->circuit INTO wire FROM 2.
      INSERT wire INTO TABLE new_circuit.
    ENDLOOP.
    CLEAR wire.
    READ TABLE me->circuit INTO wire INDEX 1.
    INSERT wire INTO TABLE new_circuit.
    me->circuit = new_circuit.
    new_pos = me->get_position( ).
    new_pos = new_pos + 1.
    me->set_position( new_pos ).
  ENDMETHOD.                    "rotate
  METHOD get_position.
    pos = me->position.
  ENDMETHOD.                    "get_position
  METHOD set_position.
    IF pos LE 26.
      me->position = pos.
    ELSE.
      me->position = 1.
      RAISE EVENT knob.
    ENDIF.
  ENDMETHOD.                    "set_position
ENDCLASS.                    "rotor IMPLEMENTATION
