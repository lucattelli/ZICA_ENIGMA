*----------------------------------------------------------------------*
*       CLASS enigma DEFINITION
*----------------------------------------------------------------------*
* Enigma Machine Instance Class
*----------------------------------------------------------------------*
CLASS enigma DEFINITION.
  PUBLIC SECTION.
    METHODS assembly_plugboard IMPORTING pb TYPE REF TO plugboard.
    METHODS assembly_rotor IMPORTING position TYPE i
                                     r TYPE REF TO rotor.
    METHODS assembly_reflector IMPORTING rf TYPE REF TO reflector.
    METHODS run_cipher IMPORTING message TYPE string
                       RETURNING value(encrypted_message) TYPE string.
  PRIVATE SECTION.
    TYPES : BEGIN OF type_rotor,
              idx TYPE i,
              r TYPE REF TO rotor,
            END OF type_rotor.
    TYPES : type_char TYPE c LENGTH 1,
            type_char_tab TYPE TABLE OF type_char WITH DEFAULT KEY.
    DATA plugboard TYPE REF TO plugboard.
    DATA rotors TYPE TABLE OF type_rotor.
    DATA reflector TYPE REF TO reflector.
    METHODS split_to_char_tab IMPORTING s TYPE string
                              RETURNING value(t_char) TYPE type_char_tab.
ENDCLASS.                    "enigma DEFINITION

*----------------------------------------------------------------------*
*       CLASS enigma IMPLEMENTATION
*----------------------------------------------------------------------*
* Enigma Machine Instance Class
*----------------------------------------------------------------------*
CLASS enigma IMPLEMENTATION.

  METHOD assembly_plugboard.
    me->plugboard = pb.
  ENDMETHOD.                    "assembly_plugboard

  METHOD assembly_rotor.
    DATA rotor TYPE type_rotor.
    rotor-idx = position.
    rotor-r = r.
    APPEND rotor TO me->rotors.
  ENDMETHOD.                    "assembly_rotor

  METHOD assembly_reflector.
    me->reflector = rf.
  ENDMETHOD.                    "assembly_reflector

  METHOD run_cipher.

    DATA t_original_message TYPE type_char_tab.

    DATA original_letter TYPE ch_idx=>type_letter.
    DATA original_index TYPE ch_idx=>type_index.

    DATA in_pb TYPE ch_idx=>type_index.
    DATA out_pb TYPE ch_idx=>type_index.
    DATA in_r TYPE ch_idx=>type_index.
    DATA out_r TYPE ch_idx=>type_index.

    DATA encrypted_index TYPE ch_idx=>type_index.
    DATA encrypted_letter TYPE ch_idx=>type_letter.

    FIELD-SYMBOLS <r> TYPE type_rotor.

    "// split string into indivuletters to be encrypted individually
    t_original_message = me->split_to_char_tab( message ).

    "// for each letter, do encrypt
    LOOP AT t_original_message INTO original_letter.

      CLEAR : original_index, out_pb.

      "// gets alphabet index for letter
      original_index = ch_idx=>index_of( original_letter ).

      "// now we are talking signals, lets send current idx to plugboard
      in_pb = original_index.
      out_pb = me->plugboard->send_signal( in_pb ).

      "// move signal throughout all three rotors
      SORT me->rotors BY idx ASCENDING.
      LOOP AT me->rotors ASSIGNING <r>.
        IF <r>-idx = 1.
          in_r = out_pb. "// move plugboard output signal to rotor input
          "// rotate first rotor before sending signal
          "// note: this may trigger other rotors to rotate as well
          "//       so please check the KNOB event
          <r>-r->rotate( ).
        ELSE.
          "// sends rotor's output signal to next rotor's input
          in_r = out_r.
          CLEAR out_r.
        ENDIF.
        out_r = <r>-r->send_signal( in_r ).
      ENDLOOP.

      "// now, we need to send rotors output to reflector
      in_r = out_r.
      CLEAR out_r.
      out_r = me->reflector->send_signal( in_r ).

      "// now, we need to send the signal all the way back
      in_r = out_r.
      SORT me->rotors BY idx DESCENDING.
      LOOP AT me->rotors ASSIGNING <r>.
        CLEAR out_r.
        out_r = <r>-r->return_signal( in_r ).
        in_r = out_r.
      ENDLOOP.

      "// finally, we pass the signal back into the plugboard
      "// in order to get the final encrypted letter
      in_pb = out_r.
      CLEAR encrypted_index.
      encrypted_index = me->plugboard->return_signal( in_pb ).

      "// build encrypted string
      CLEAR encrypted_letter.
      encrypted_letter = ch_idx=>letter_of( encrypted_index ).
      CONCATENATE encrypted_message
                  encrypted_letter
             INTO encrypted_message.

    ENDLOOP.

  ENDMETHOD.                    "run_cipher

  METHOD split_to_char_tab.
    DATA len TYPE i.
    DATA idx TYPE i.
    DATA char TYPE c LENGTH 1.
    len = strlen( s ).
    DO len TIMES.
      idx = sy-index - 1.
      char = s+idx(1).
      APPEND char TO t_char.
    ENDDO.
    DELETE t_char WHERE table_line EQ ''.
  ENDMETHOD.                    "split_to_char_tab

ENDCLASS.                    "enigma IMPLEMENTATION
