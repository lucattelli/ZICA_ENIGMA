*----------------------------------------------------------------------*
*       CLASS ch_idx DEFINITION
*----------------------------------------------------------------------*
* Static utility class that gets INDEX from CHAR and CHAR from INDEX
*----------------------------------------------------------------------*
CLASS ch_idx DEFINITION.
  PUBLIC SECTION.
    TYPES : type_index TYPE i,
            type_letter TYPE c LENGTH 1.
    CLASS-METHODS : index_of IMPORTING letter TYPE type_letter
                             RETURNING value(index) TYPE type_index,
                    letter_of IMPORTING index TYPE type_index
                              RETURNING value(letter) TYPE type_letter.
  PRIVATE SECTION.
    CONSTANTS c_alphabet TYPE string VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
ENDCLASS.                    "ch_idx DEFINITION

*----------------------------------------------------------------------*
*       CLASS ch_idx IMPLEMENTATION
*----------------------------------------------------------------------*
* Static utility class that gets INDEX from CHAR and CHAR from INDEX
*----------------------------------------------------------------------*
CLASS ch_idx IMPLEMENTATION.

  METHOD index_of.
    DATA prefix TYPE string.
    DATA suffix TYPE string.
    SPLIT c_alphabet AT letter INTO prefix suffix.
    index = strlen( prefix ) + 1.
  ENDMETHOD.                    "index_of

  METHOD letter_of.
    DATA offset TYPE i.
    offset = index - 1.
    letter = c_alphabet+offset(1).
  ENDMETHOD.                    "letter_of

ENDCLASS.                    "ch_idx IMPLEMENTATION
