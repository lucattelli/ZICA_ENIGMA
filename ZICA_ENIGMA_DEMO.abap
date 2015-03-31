* Z Instant Comprehensive ABAP - The Enigma Machine Demo

REPORT  zica_enigma_demo.

*** <HACK!>
*// This hack exists only to make Github publishing easier. Be sure
*// to replace it with a proper message class in your system.
CONSTANTS : BEGIN OF e,
              001 TYPE string VALUE 'Error while shuffling alphabet.',
            END OF e.
*** </HACK!>

INCLUDE zica_enigma_shuffler. "// CLASS shuffler DEF/IMP

INCLUDE zica_engine_ch_idx. "// CLASS cx_idx DEF/IMP

INCLUDE zica_enigma_plugboard. "// CLASS plugboard DEF/IMP

INCLUDE zica_enigma_rotor. "// CLASS rotor DEF/IMP

INCLUDE zica_enigma_reflector. "// CLASS reflector DEF/IMP

INCLUDE zica_enigma. "// CLASS enigma DEF/IMP

PARAMETER p_om TYPE c LENGTH 40 DEFAULT 'A SIMPLE MESSAGE'.

START-OF-SELECTION.

  BREAK-POINT.

  DATA pb TYPE REF TO plugboard.
  DATA r1 TYPE REF TO rotor.
  DATA r2 TYPE REF TO rotor.
  DATA r3 TYPE REF TO rotor.
  DATA rf TYPE REF TO reflector.
  DATA enigma TYPE REF TO enigma.
  DATA original_message TYPE string.
  DATA encrypted_message TYPE string.

  CREATE OBJECT pb.
  pb->add_inversion( from = 'Q' to = 'A' ).
  pb->add_inversion( from = 'P' to = 'V' ).
  pb->add_inversion( from = 'B' to = 'Z' ).
  pb->add_inversion( from = 'Y' to = 'I' ).
  pb->add_inversion( from = 'O' to = 'U' ).
  pb->add_inversion( from = 'T' to = 'X' ).
  pb->add_inversion( from = 'F' to = 'C' ).
  pb->add_inversion( from = 'G' to = 'D' ).
  pb->add_inversion( from = 'N' to = 'M' ).
  pb->add_inversion( from = 'L' to = 'H' ).

  CREATE OBJECT r1
    EXPORTING
      wiring = 'C:\TEMP\ENIGMA\R1.TXT'.
  r1->save_wiring( 'C:\TEMP\ENIGMA\R1.TXT' ).

  CREATE OBJECT r2
    EXPORTING
      wiring = 'C:\TEMP\ENIGMA\R2.TXT'.
  r2->save_wiring( 'C:\TEMP\ENIGMA\R2.TXT' ).

  CREATE OBJECT r3
    EXPORTING
      wiring = 'C:\TEMP\ENIGMA\R3.TXT'.
  r3->save_wiring( 'C:\TEMP\ENIGMA\R3.TXT' ).

  CREATE OBJECT rf
    EXPORTING
      wiring = 'C:\TEMP\ENIGMA\RF.TXT'.
  rf->save_wiring( 'C:\TEMP\ENIGMA\RF.TXT' ).

  CREATE OBJECT enigma.
  enigma->assembly_plugboard( pb ).
  enigma->assembly_rotor( EXPORTING position = 1 r = r1 ).
  enigma->assembly_rotor( EXPORTING position = 2 r = r2 ).
  enigma->assembly_rotor( EXPORTING position = 3 r = r3 ).
  enigma->assembly_reflector( rf ).

  original_message = p_om.

  encrypted_message = enigma->run_cipher( original_message ).

  WRITE encrypted_message.
