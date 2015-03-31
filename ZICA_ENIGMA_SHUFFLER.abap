*----------------------------------------------------------------------*
*       CLASS shuffler DEFINITION
*----------------------------------------------------------------------*
* This static utility class shuffles a list of numbers
*----------------------------------------------------------------------*
CLASS shuffler DEFINITION.
  PUBLIC SECTION.
    TYPES type_numbers_tab TYPE TABLE OF i WITH DEFAULT KEY.
    CLASS-METHODS : shuffle_numbers_tab CHANGING tab TYPE type_numbers_tab.
  PRIVATE SECTION.
    TYPES : BEGIN OF type_shuffle,
              idx TYPE i,
              number TYPE i,
            END OF type_shuffle,
            type_shuffle_tab TYPE TABLE OF type_shuffle WITH DEFAULT KEY.
ENDCLASS.                    "shuffler DEFINITION

*----------------------------------------------------------------------*
*       CLASS shuffler IMPLEMENTATION
*----------------------------------------------------------------------*
* This static utility class shuffles a list of numbers
*----------------------------------------------------------------------*
CLASS shuffler IMPLEMENTATION.

  METHOD shuffle_numbers_tab.

    DATA  : number TYPE LINE OF type_numbers_tab,
            s_item TYPE type_shuffle,
            s_tab TYPE type_shuffle_tab,
            items_count TYPE i,
            items_range TYPE i,
            t_shuffled TYPE STANDARD TABLE OF i WITH DEFAULT KEY,
            index TYPE i.
    FIELD-SYMBOLS <s_item> TYPE type_shuffle.

    "// generate indexed number list (still sorted)
    LOOP AT tab INTO number.
      s_item-idx = sy-tabix.
      s_item-number = number.
      INSERT s_item INTO TABLE s_tab.
    ENDLOOP.

    "// generate shuffled indexes
    DESCRIBE TABLE s_tab LINES items_count.
    items_range = items_count * sy-uzeit.
    LOOP AT s_tab ASSIGNING <s_item>.
      CALL FUNCTION 'GENERAL_GET_RANDOM_INT'
        EXPORTING
          range  = items_range
        IMPORTING
          random = <s_item>-idx.
    ENDLOOP.

    "// sort by shuffled index (this sorts the table)
    SORT s_tab BY idx.

    "// returns the shuffled number list to the caller
    CLEAR tab.
    LOOP AT s_tab INTO s_item.
      APPEND s_item-number TO tab.
    ENDLOOP.

  ENDMETHOD.                    "shuffle_numbers_tab

ENDCLASS.                    "shuffler IMPLEMENTATION
