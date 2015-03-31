*----------------------------------------------------------------------*
*       CLASS plugboard DEFINITION
*----------------------------------------------------------------------*
* This class represents the plugboard for Enigma
*----------------------------------------------------------------------*
CLASS plugboard DEFINITION.
  PUBLIC SECTION.
    METHODS : add_inversion IMPORTING from TYPE ch_idx=>type_letter
                                      to TYPE ch_idx=>type_letter,
              send_signal IMPORTING in TYPE ch_idx=>type_index
                          RETURNING value(out) TYPE ch_idx=>type_index,
              return_signal IMPORTING in TYPE ch_idx=>type_index
                            RETURNING value(out) TYPE ch_idx=>type_index.
  PRIVATE SECTION.
    TYPES : BEGIN OF type_inversion,
              a TYPE i,
              b TYPE i,
            END OF type_inversion,
            type_inversion_tab TYPE TABLE OF type_inversion.
    DATA inversions TYPE type_inversion_tab.
ENDCLASS.                    "plugboard DEFINITION

*----------------------------------------------------------------------*
*       CLASS plugboard IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS plugboard IMPLEMENTATION.
  METHOD add_inversion.
    DATA inversion TYPE type_inversion.
    inversion-a = ch_idx=>index_of( from ).
    inversion-b = ch_idx=>index_of( to ).
    APPEND inversion TO me->inversions.
    inversion-a = ch_idx=>index_of( to ).
    inversion-b = ch_idx=>index_of( from ).
    APPEND inversion TO me->inversions.
    SORT me->inversions BY a.
  ENDMETHOD.                    "add_inversion
  METHOD send_signal.
    DATA inversion TYPE type_inversion.
    READ TABLE me->inversions INTO inversion
      WITH KEY a = in BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      out = inversion-b. "// does invert
    ELSE.
      out = in. "// does not invert
    ENDIF.
  ENDMETHOD.                    "send_signal
  METHOD return_signal.
    "// reflector
    out = me->send_signal( in ).
  ENDMETHOD.                    "return_signal
ENDCLASS.                    "plugboard IMPLEMENTATION
