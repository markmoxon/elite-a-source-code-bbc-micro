\ ******************************************************************************
\
\ ELITE-A GAME DATA SOURCE
\
\ Elite-A is an extended version of BBC Micro Elite by Angus Duggan
\
\ The original Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984, and the extra code in Elite-A is copyright Angus Duggan
\
\ The code in this file is identical to Angus Duggan's source discs (it's just
\ been reformatted, and the label names have been changed to be consistent with
\ the sources for the original BBC Micro disc version on which it is based)
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file contains the game data for Elite-A, including the game text.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * WORDS.bin
\
\ This gets loaded as part of elite-loader.asm and gets moved to &0400 during
\ the loading process.
\
\ The binary file also includes the sine and arctan tables, so the three parts
\ end up as follows:
\
\   * Recursive token table:    QQ18 = &0400 to &07FF
\   * Sine lookup table:        SNE  = &07C0 to &07DF
\   * Arctan lookup table:      ACT  = &07E0 to &07FF
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _RELEASED              = (_VARIANT = 1)
 _SOURCE_DISC           = (_VARIANT = 2)
 _BUG_FIX               = (_VARIANT = 3)

 GUARD &6000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 CODE_WORDS% = &0400    \ The address where the code will be run

 LOAD_WORDS% = &2568    \ The address where the code will be loaded

 RE = &23               \ The obfuscation byte used to hide the recursive tokens
                        \ table from crackers viewing the binary code

 ORG CODE_WORDS%

\ ******************************************************************************
\
\       Name: CHAR
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for characters in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CHAR 'x'            Insert ASCII character "x"
\
\ To include an apostrophe, use a backtick character, as in CHAR '`'.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   'x'                 The character to insert into the table
\
\ ******************************************************************************

MACRO CHAR x

 IF x = '`'
   EQUB 39 EOR RE
 ELSE
   EQUB x EOR RE
 ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: TWOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for two-letter tokens in the token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   TWOK 'x', 'y'       Insert two-letter token "xy"
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   'x'                 The first letter of the two-letter token to insert into
\                       the table
\
\   'y'                 The second letter of the two-letter token to insert into
\                       the table
\
\ ******************************************************************************

MACRO TWOK t, k

 IF t = 'A' AND k = 'L'
  EQUB 128 EOR RE
 ENDIF

 IF t = 'L' AND k = 'E'
  EQUB 129 EOR RE
 ENDIF

 IF t = 'X' AND k = 'E'
  EQUB 130 EOR RE
 ENDIF

 IF t = 'G' AND k = 'E'
  EQUB 131 EOR RE
 ENDIF

 IF t = 'Z' AND k = 'A'
  EQUB 132 EOR RE
 ENDIF

 IF t = 'C' AND k = 'E'
  EQUB 133 EOR RE
 ENDIF

 IF t = 'B' AND k = 'I'
  EQUB 134 EOR RE
 ENDIF

 IF t = 'S' AND k = 'O'
  EQUB 135 EOR RE
 ENDIF

 IF t = 'U' AND k = 'S'
  EQUB 136 EOR RE
 ENDIF

 IF t = 'E' AND k = 'S'
  EQUB 137 EOR RE
 ENDIF

 IF t = 'A' AND k = 'R'
  EQUB 138 EOR RE
 ENDIF

 IF t = 'M' AND k = 'A'
  EQUB 139 EOR RE
 ENDIF

 IF t = 'I' AND k = 'N'
  EQUB 140 EOR RE
 ENDIF

 IF t = 'D' AND k = 'I'
  EQUB 141 EOR RE
 ENDIF

 IF t = 'R' AND k = 'E'
  EQUB 142 EOR RE
 ENDIF

 IF t = 'A' AND k = '?'
  EQUB 143 EOR RE
 ENDIF

 IF t = 'E' AND k = 'R'
  EQUB 144 EOR RE
 ENDIF

 IF t = 'A' AND k = 'T'
  EQUB 145 EOR RE
 ENDIF

 IF t = 'E' AND k = 'N'
  EQUB 146 EOR RE
 ENDIF

 IF t = 'B' AND k = 'E'
  EQUB 147 EOR RE
 ENDIF

 IF t = 'R' AND k = 'A'
  EQUB 148 EOR RE
 ENDIF

 IF t = 'L' AND k = 'A'
  EQUB 149 EOR RE
 ENDIF

 IF t = 'V' AND k = 'E'
  EQUB 150 EOR RE
 ENDIF

 IF t = 'T' AND k = 'I'
  EQUB 151 EOR RE
 ENDIF

 IF t = 'E' AND k = 'D'
  EQUB 152 EOR RE
 ENDIF

 IF t = 'O' AND k = 'R'
  EQUB 153 EOR RE
 ENDIF

 IF t = 'Q' AND k = 'U'
  EQUB 154 EOR RE
 ENDIF

 IF t = 'A' AND k = 'N'
  EQUB 155 EOR RE
 ENDIF

 IF t = 'T' AND k = 'E'
  EQUB 156 EOR RE
 ENDIF

 IF t = 'I' AND k = 'S'
  EQUB 157 EOR RE
 ENDIF

 IF t = 'R' AND k = 'I'
  EQUB 158 EOR RE
 ENDIF

 IF t = 'O' AND k = 'N'
  EQUB 159 EOR RE
 ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: CONT
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for control codes in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CONT n              Insert control code token {n}
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   n                   The control code to insert into the table
\
\ ******************************************************************************

MACRO CONT n

 EQUB n EOR RE

ENDMACRO

\ ******************************************************************************
\
\       Name: RTOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for recursive tokens in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   RTOK n              Insert recursive token [n]
\
\                         * Tokens 0-95 get stored as n + 160
\
\                         * Tokens 128-145 get stored as n - 114
\
\                         * Tokens 96-127 get stored as n
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   n                   The number of the recursive token to insert into the
\                       table, in the range 0 to 145
\
\ ******************************************************************************

MACRO RTOK n

 IF n >= 0 AND n <= 95
  t = n + 160
 ELIF n >= 128
  t = n - 114
 ELSE
  t = n
 ENDIF

 EQUB t EOR RE

ENDMACRO

\ ******************************************************************************
\
\       Name: QQ18
\       Type: Variable
\   Category: Text
\    Summary: The recursive token table for tokens 0-148
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The encodings shown for each recursive text token use the following notation:
\
\   {n}           Control code              n = 0 to 13
\   <n>           Two-letter token          n = 128 to 159
\   [n]           Recursive token           n = 0 to 148
\
\ Other entry points:
\
\   new_name            This part of token 132 is updated with our current
\                       ship's type by routine n_load, so printing token 132
\                       will always show the correct type of our ship
\
\ ******************************************************************************

.QQ18

 RTOK 111               \ Token 0:      "FUEL SCOOPS ON {beep}"
 RTOK 131               \
 CONT 7                 \ Encoded as:   "[111][131]{7}"
 EQUB 0

 CHAR ' '               \ Token 1:      " CHART"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   " CH<138>T"
 TWOK 'A', 'R'
 CHAR 'T'
 EQUB 0

 CHAR 'G'               \ Token 2:      "GOVERNMENT"
 CHAR 'O'               \
 TWOK 'V', 'E'          \ Encoded as:   "GO<150>RNM<146>T"
 CHAR 'R'
 CHAR 'N'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 3:      "DATA ON {selected system name}"
 TWOK 'A', 'T'          \
 CHAR 'A'               \ Encoded as:   "D<145>A[131]{3}"
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          \ Token 4:      "INVENTORY{cr}
 TWOK 'V', 'E'          \               "
 CHAR 'N'               \
 CHAR 'T'               \ Encoded as:   "<140><150>NT<153>Y{12}"
 TWOK 'O', 'R'
 CHAR 'Y'
 CONT 12
 EQUB 0

 CHAR 'S'               \ Token 5:      "SYSTEM"
 CHAR 'Y'               \
 CHAR 'S'               \ Encoded as:   "SYS<156>M"
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CHAR 'P'               \ Token 6:      "PRICE"
 TWOK 'R', 'I'          \
 TWOK 'C', 'E'          \ Encoded as:   "P<158><133>"
 EQUB 0

 CONT 2                 \ Token 7:      "{current system name} MARKET PRICES"
 CHAR ' '               \
 TWOK 'M', 'A'          \ Encoded as:   "{2} <139>RKET [6]S"
 CHAR 'R'
 CHAR 'K'
 CHAR 'E'
 CHAR 'T'
 CHAR ' '
 RTOK 6
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          \ Token 8:      "INDUSTRIAL"
 CHAR 'D'               \
 TWOK 'U', 'S'          \ Encoded as:   "<140>D<136>T<158><128>"
 CHAR 'T'
 TWOK 'R', 'I'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'A'               \ Token 9:      "AGRICULTURAL"
 CHAR 'G'               \
 TWOK 'R', 'I'          \ Encoded as:   "AG<158>CULTU<148>L"
 CHAR 'C'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'A'
 CHAR 'L'
 EQUB 0

 TWOK 'R', 'I'          \ Token 10:     "RICH "
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<158>CH "
 CHAR ' '
 EQUB 0

 CHAR 'A'               \ Token 11:     "AVERAGE "
 TWOK 'V', 'E'          \
 TWOK 'R', 'A'          \ Encoded as:   "A<150><148><131> "
 TWOK 'G', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 12:     "POOR "
 CHAR 'O'               \
 TWOK 'O', 'R'          \ Encoded as:   "PO<153> "
 CHAR ' '
 EQUB 0

 TWOK 'M', 'A'          \ Token 13:     "MAINLY "
 TWOK 'I', 'N'          \
 CHAR 'L'               \ Encoded as:   "<139><140>LY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'U'               \ Token 14:     "UNIT"
 CHAR 'N'               \
 CHAR 'I'               \ Encoded as:   "UNIT"
 CHAR 'T'
 EQUB 0

 CHAR 'V'               \ Token 15:     "VIEW "
 CHAR 'I'               \
 CHAR 'E'               \ Encoded as:   "VIEW "
 CHAR 'W'
 CHAR ' '
 EQUB 0

 TWOK 'Q', 'U'          \ Token 16:     "QUANTITY"
 TWOK 'A', 'N'          \
 TWOK 'T', 'I'          \ Encoded as:   "<154><155><151>TY"
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 TWOK 'A', 'N'          \ Token 17:     "ANARCHY"
 TWOK 'A', 'R'          \
 CHAR 'C'               \ Encoded as:   "<155><138>CHY"
 CHAR 'H'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               \ Token 18:     "FEUDAL"
 CHAR 'E'               \
 CHAR 'U'               \ Encoded as:   "FEUD<128>"
 CHAR 'D'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'M'               \ Token 19:     "MULTI-GOVERNMENT"
 CHAR 'U'               \
 CHAR 'L'               \ Encoded as:   "MUL<151>-[2]"
 TWOK 'T', 'I'
 CHAR '-'
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          \ Token 20:     "DICTATORSHIP"
 CHAR 'C'               \
 CHAR 'T'               \ Encoded as:   "<141>CT<145><153>[25]"
 TWOK 'A', 'T'
 TWOK 'O', 'R'
 RTOK 25
 EQUB 0

 RTOK 91                \ Token 21:     "COMMUNIST"
 CHAR 'M'               \
 CHAR 'U'               \ Encoded as:   "[91]MUN<157>T"
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'C'               \ Token 22:     "CONFEDERACY"
 TWOK 'O', 'N'          \
 CHAR 'F'               \ Encoded as:   "C<159>F<152><144>ACY"
 TWOK 'E', 'D'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'D'               \ Token 23:     "DEMOCRACY"
 CHAR 'E'               \
 CHAR 'M'               \ Encoded as:   "DEMOC<148>CY"
 CHAR 'O'
 CHAR 'C'
 TWOK 'R', 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'C'               \ Token 24:     "CORPORATE STATE"
 TWOK 'O', 'R'          \
 CHAR 'P'               \ Encoded as:   "C<153>P<153><145>E [43]<145>E"
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               \ Token 25:     "SHIP"
 CHAR 'H'               \
 CHAR 'I'               \ Encoded as:   "SHIP"
 CHAR 'P'
 EQUB 0

 CHAR 'P'               \ Token 26:     "PRODUCT"
 RTOK 94                \
 CHAR 'D'               \ Encoded as:   "P[94]]DUCT"
 CHAR 'U'
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 27:     " LASER"
 TWOK 'L', 'A'          \
 CHAR 'S'               \ Encoded as:   " <149>S<144>"
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               \ Token 28:     "HUMAN COLONIAL"
 CHAR 'U'               \
 CHAR 'M'               \ Encoded as:   "HUM<155> COL<159>I<128>"
 TWOK 'A', 'N'
 CHAR ' '
 CHAR 'C'
 CHAR 'O'
 CHAR 'L'
 TWOK 'O', 'N'
 CHAR 'I'
 TWOK 'A', 'L'
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\CHAR 'H'               \ Token 29:     "HYPERSPACE "
\CHAR 'Y'               \
\CHAR 'P'               \ Encoded as:   "HYP<144>SPA<133> "
\TWOK 'E', 'R'
\CHAR 'S'
\CHAR 'P'
\CHAR 'A'
\TWOK 'C', 'E'
\CHAR ' '
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 CHAR 'H'               \ Token 29:     "HYPERSPACE "
 CHAR 'Y'               \
 CHAR 'P'               \ Encoded as:   "HYP<144>[128] "
 TWOK 'E', 'R'
 RTOK 128
 CHAR ' '
 EQUB 0

                        \ --- End of replacement ------------------------------>

 CHAR 'S'               \ Token 30:     "SHORT RANGE CHART"
 CHAR 'H'               \
 TWOK 'O', 'R'          \ Encoded as:   "SH<153>T [42][1]"
 CHAR 'T'
 CHAR ' '
 RTOK 42
 RTOK 1
 EQUB 0

 TWOK 'D', 'I'          \ Token 31:     "DISTANCE"
 RTOK 43                \
 TWOK 'A', 'N'          \ Encoded as:   "<141>[43]<155><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               \ Token 32:     "POPULATION"
 CHAR 'O'               \
 CHAR 'P'               \ Encoded as:   "POPUL<145>I<159>"
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'G'               \ Token 33:     "GROSS PRODUCTIVITY"
 RTOK 94                \
 CHAR 'S'               \ Encoded as:   "G[94]SS [26]IVITY"
 CHAR 'S'
 CHAR ' '
 RTOK 26
 CHAR 'I'
 CHAR 'V'
 CHAR 'I'
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 CHAR 'E'               \ Token 34:     "ECONOMY"
 CHAR 'C'               \
 TWOK 'O', 'N'          \ Encoded as:   "EC<159>OMY"
 CHAR 'O'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR ' '               \ Token 35:     " LIGHT YEARS"
 CHAR 'L'               \
 CHAR 'I'               \ Encoded as:   " LIGHT YE<138>S"
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 CHAR ' '
 CHAR 'Y'
 CHAR 'E'
 TWOK 'A', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'T', 'E'          \ Token 36:     "TECH.LEVEL"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<156>CH.<129><150>L"
 CHAR '.'
 TWOK 'L', 'E'
 TWOK 'V', 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               \ Token 37:     "CASH"
 CHAR 'A'               \
 CHAR 'S'               \ Encoded as:   "CASH"
 CHAR 'H'
 EQUB 0

 CHAR ' '               \ Token 38:     " BILLION"
 TWOK 'B', 'I'          \
 RTOK 129               \ Encoded as:   " <134>[129]I<159>"
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 RTOK 122               \ Token 39:     "GALACTIC CHART{galaxy number}"
 RTOK 1                 \
 CONT 1                 \ Encoded as:   "[122][1]{1}"
 EQUB 0

 CHAR 'T'               \ Token 40:     "TARGET LOST"
 TWOK 'A', 'R'          \
 TWOK 'G', 'E'          \ Encoded as:   "T<138><131>T LO[43]"
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 RTOK 43
 EQUB 0

 RTOK 106               \ Token 41:     "MISSILE JAMMED"
 CHAR ' '               \
 CHAR 'J'               \ Encoded as:   "[106] JAMM<152>"
 CHAR 'A'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               \ Token 42:     "RANGE"
 TWOK 'A', 'N'          \
 TWOK 'G', 'E'          \ Encoded as:   "R<155><131>"
 EQUB 0

 CHAR 'S'               \ Token 43:     "ST"
 CHAR 'T'               \
 EQUB 0                 \ Encoded as:   "ST"

 RTOK 16                \ Token 44:     "QUANTITY OF "
 CHAR ' '               \
 CHAR 'O'               \ Encoded as:   "[16] OF "
 CHAR 'F'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 45:     "SELL"
 CHAR 'E'               \
 RTOK 129               \ Encoded as:   "SE[129]"
 EQUB 0

 CHAR ' '               \ Token 46:     " CARGO{sentence case}"
 CHAR 'C'               \
 TWOK 'A', 'R'          \ Encoded as:   " C<138>GO{6}"
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 CHAR 'E'               \ Token 47:     "EQUIP"
 TWOK 'Q', 'U'          \
 CHAR 'I'               \ Encoded as:   "E<154>IP"
 CHAR 'P'
 EQUB 0

 CHAR 'F'               \ Token 48:     "FOOD"
 CHAR 'O'               \
 CHAR 'O'               \ Encoded as:   "FOOD"
 CHAR 'D'
 EQUB 0

 TWOK 'T', 'E'          \ Token 49:     "TEXTILES"
 CHAR 'X'               \
 TWOK 'T', 'I'          \ Encoded as:   "<156>X<151>L<137>"
 CHAR 'L'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 50:     "RADIOACTIVES"
 TWOK 'D', 'I'          \
 CHAR 'O'               \ Encoded as:   "<148><141>OAC<151><150>S"
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'S'               \ Token 51:     "SLAVES"
 TWOK 'L', 'A'          \
 TWOK 'V', 'E'          \ Encoded as:   "S<149><150>S"
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 52:     "LIQUOR/WINES"
 CHAR 'I'               \
 TWOK 'Q', 'U'          \ Encoded as:   "LI<154><153>/W<140><137>"
 TWOK 'O', 'R'
 CHAR '/'
 CHAR 'W'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'L'               \ Token 53:     "LUXURIES"
 CHAR 'U'               \
 CHAR 'X'               \ Encoded as:   "LUXU<158><137>"
 CHAR 'U'
 TWOK 'R', 'I'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'N'               \ Token 54:     "NARCOTICS"
 TWOK 'A', 'R'          \
 CHAR 'C'               \ Encoded as:   "N<138>CO<151>CS"
 CHAR 'O'
 TWOK 'T', 'I'
 CHAR 'C'
 CHAR 'S'
 EQUB 0

 RTOK 91                \ Token 55:     "COMPUTERS"
 CHAR 'P'               \
 CHAR 'U'               \ Encoded as:   "[91]PUT<144>S"
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'M', 'A'          \ Token 56:     "MACHINERY"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<139>CH<140><144>Y"
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'Y'
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\CHAR 'A'               \ Token 57:     "ALLOYS"
\CHAR 'L'               \
\CHAR 'L'               \ Encoded as:   "ALLOYS"
\CHAR 'O'
\CHAR 'Y'
\CHAR 'S'
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 CHAR 'A'               \ Token 57:     "ALLOYS"
 RTOK 129               \
 CHAR 'O'               \ Encoded as:   "A[129]OYS"
 CHAR 'Y'
 CHAR 'S'
 EQUB 0

                        \ --- End of replacement ------------------------------>

 CHAR 'F'               \ Token 58:     "FIREARMS"
 CHAR 'I'               \
 TWOK 'R', 'E'          \ Encoded as:   "FI<142><138>MS"
 TWOK 'A', 'R'
 CHAR 'M'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 59:     "FURS"
 CHAR 'U'               \
 CHAR 'R'               \ Encoded as:   "FURS"
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 60:     "MINERALS"
 TWOK 'I', 'N'          \
 TWOK 'E', 'R'          \ Encoded as:   "M<140><144><128>S"
 TWOK 'A', 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               \ Token 61:     "GOLD"
 CHAR 'O'               \
 CHAR 'L'               \ Encoded as:   "GOLD"
 CHAR 'D'
 EQUB 0

 CHAR 'P'               \ Token 62:     "PLATINUM"
 CHAR 'L'               \
 TWOK 'A', 'T'          \ Encoded as:   "PL<145><140>UM"
 TWOK 'I', 'N'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 TWOK 'G', 'E'          \ Token 63:     "GEM-STONES"
 CHAR 'M'               \
 CHAR '-'               \ Encoded as:   "<131>M-[43]<159><137>"
 RTOK 43
 TWOK 'O', 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'A', 'L'          \ Token 64:     "ALIEN ITEMS"
 CHAR 'I'               \
 TWOK 'E', 'N'          \ Encoded as:   "<128>I<146> [127]S"
 CHAR ' '
 RTOK 127
 CHAR 'S'
 EQUB 0

 CONT 12                \ Token 65:     "{cr}
 CHAR '1'               \                10{cash} CR{cr}
 CHAR '0'               \                5{cash} CR{cr}
 CONT 0                 \               "
 CHAR '5'               \
 CONT 0                 \ Encoded as:   "{12}10{0}5{0}"
 EQUB 0

 CHAR ' '               \ Token 66:     " CR"
 CHAR 'C'               \
 CHAR 'R'               \ Encoded as:   " CR"
 EQUB 0

 CHAR 'L'               \ Token 67:     "LARGE"
 TWOK 'A', 'R'          \
 TWOK 'G', 'E'          \ Encoded as:   "L<138><131>"
 EQUB 0

 CHAR 'F'               \ Token 68:     "FIERCE"
 CHAR 'I'               \
 TWOK 'E', 'R'          \ Encoded as:   "FI<144><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'S'               \ Token 69:     "SMALL"
 TWOK 'M', 'A'          \
 RTOK 129               \ Encoded as:   "S<139>[129]"
 EQUB 0

 CHAR 'G'               \ Token 70:     "GREEN"
 TWOK 'R', 'E'          \
 TWOK 'E', 'N'          \ Encoded as:   "G<142><146>"
 EQUB 0

 CHAR 'R'               \ Token 71:     "RED"
 TWOK 'E', 'D'          \
 EQUB 0                 \ Encoded as:   "R<152>"

 CHAR 'Y'               \ Token 72:     "YELLOW"
 CHAR 'E'               \
 RTOK 129               \ Encoded as:   "YE[129]OW"
 CHAR 'O'
 CHAR 'W'
 EQUB 0

 CHAR 'B'               \ Token 73:     "BLUE"
 CHAR 'L'               \
 CHAR 'U'               \ Encoded as:   "BLUE"
 CHAR 'E'
 EQUB 0

 CHAR 'B'               \ Token 74:     "BLACK"
 TWOK 'L', 'A'          \
 CHAR 'C'               \ Encoded as:   "B<149>CK"
 CHAR 'K'
 EQUB 0

 RTOK 136               \ Token 75:     "HARMLESS"
 EQUB 0                 \
                        \ Encoded as:   "[136]"

 CHAR 'S'               \ Token 76:     "SLIMY"
 CHAR 'L'               \
 CHAR 'I'               \ Encoded as:   "SLIMY"
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR 'B'               \ Token 77:     "BUG-EYED"
 CHAR 'U'               \
 CHAR 'G'               \ Encoded as:   "BUG-EY<152>"
 CHAR '-'
 CHAR 'E'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'H'               \ Token 78:     "HORNED"
 TWOK 'O', 'R'          \
 CHAR 'N'               \ Encoded as:   "H<153>N<152>"
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               \ Token 79:     "BONY"
 TWOK 'O', 'N'          \
 CHAR 'Y'               \ Encoded as:   "B<159>Y"
 EQUB 0

 CHAR 'F'               \ Token 80:     "FAT"
 TWOK 'A', 'T'          \
 EQUB 0                 \ Encoded as:   "F<145>"

 CHAR 'F'               \ Token 81:     "FURRY"
 CHAR 'U'               \
 CHAR 'R'               \ Encoded as:   "FURRY"
 CHAR 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 94                \ Token 82:     "RODENT"
 CHAR 'D'               \
 TWOK 'E', 'N'          \ Encoded as:   "[94]D<146>T"
 CHAR 'T'
 EQUB 0

 CHAR 'F'               \ Token 83:     "FROG"
 RTOK 94                \
 CHAR 'G'               \ Encoded as:   "F[94]G"
 EQUB 0

 CHAR 'L'               \ Token 84:     "LIZARD"
 CHAR 'I'               \
 TWOK 'Z', 'A'          \ Encoded as:   "LI<132>RD"
 CHAR 'R'
 CHAR 'D'
 EQUB 0

 CHAR 'L'               \ Token 85:     "LOBSTER"
 CHAR 'O'               \
 CHAR 'B'               \ Encoded as:   "LOB[43]<144>"
 RTOK 43
 TWOK 'E', 'R'
 EQUB 0

 TWOK 'B', 'I'          \ Token 86:     "BIRD"
 CHAR 'R'               \
 CHAR 'D'               \ Encoded as:   "<134>RD"
 EQUB 0

 CHAR 'H'               \ Token 87:     "HUMANOID"
 CHAR 'U'               \
 CHAR 'M'               \ Encoded as:   "HUM<155>OID"
 TWOK 'A', 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 EQUB 0

 CHAR 'F'               \ Token 88:     "FELINE"
 CHAR 'E'               \
 CHAR 'L'               \ Encoded as:   "FEL<140>E"
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 TWOK 'I', 'N'          \ Token 89:     "INSECT"
 CHAR 'S'               \
 CHAR 'E'               \ Encoded as:   "<140>SECT"
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 RTOK 11                \ Token 90:     "AVERAGE RADIUS"
 TWOK 'R', 'A'          \
 TWOK 'D', 'I'          \ Encoded as:   "[11]<148><141><136>"
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               \ Token 91:     "COM"
 CHAR 'O'               \
 CHAR 'M'               \ Encoded as:   "COM"
 EQUB 0

 RTOK 91                \ Token 92:     "COMMANDER"
 CHAR 'M'               \
 TWOK 'A', 'N'          \ Encoded as:   "[91]M<155>D<144>"
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR ' '               \ Token 93:     " DESTROYED"
 CHAR 'D'               \
 TWOK 'E', 'S'          \ Encoded as:   " D<137>T[94]Y<152>"
 CHAR 'T'
 RTOK 94
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               \ Token 94:     "RO"
 CHAR 'O'               \
 EQUB 0                 \ Encoded as:   "RO"

 RTOK 14                \ Token 95:     "UNIT  QUANTITY{cr}
 CHAR ' '               \                 PRODUCT   UNIT PRICE FOR SALE{cr}{lf}
 CHAR ' '               \               "
 RTOK 16                \
 CONT 12                \ Encoded as:   "[14]  [16]{13} [26]   [14] [6] F<153>
 CHAR ' '               \                 SA<129>{12}{10}"
 RTOK 26
 CHAR ' '
 CHAR ' '
 CHAR ' '
 RTOK 14
 CHAR ' '
 RTOK 6
 CHAR ' '
 CHAR 'F'
 TWOK 'O', 'R'
 CHAR ' '
 CHAR 'S'
 CHAR 'A'
 TWOK 'L', 'E'
 CONT 12
 CONT 10
 EQUB 0

 CHAR 'F'               \ Token 96:     "FRONT"
 CHAR 'R'               \
 TWOK 'O', 'N'          \ Encoded as:   "FR<159>T"
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'E'          \ Token 97:     "REAR"
 TWOK 'A', 'R'          \
 EQUB 0                 \ Encoded as:   "<142><138>"

 TWOK 'L', 'E'          \ Token 98:     "LEFT"
 CHAR 'F'               \
 CHAR 'T'               \ Encoded as:   "<129>FT"
 EQUB 0

 TWOK 'R', 'I'          \ Token 99:     "RIGHT"
 CHAR 'G'               \
 CHAR 'H'               \ Encoded as:   "<158>GHT"
 CHAR 'T'
 EQUB 0

 RTOK 121               \ Token 100:    "ENERGY LOW{beep}"
 CHAR 'L'               \
 CHAR 'O'               \ Encoded as:   "[121]LOW{7}"
 CHAR 'W'
 CONT 7
 EQUB 0

 RTOK 99                \ Token 101:    "RIGHT ON COMMANDER!"
 RTOK 131               \
 RTOK 92                \ Encoded as:   "[99][131][92]!"
 CHAR '!'
 EQUB 0

 CHAR 'E'               \ Token 102:    "EXTRA "
 CHAR 'X'               \
 CHAR 'T'               \ Encoded as:   "EXT<148> "
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 103:    "PULSE LASER"
 CHAR 'U'               \
 CHAR 'L'               \ Encoded as:   "PULSE[27]"
 CHAR 'S'
 CHAR 'E'
 RTOK 27
 EQUB 0

 TWOK 'B', 'E'          \ Token 104:    "BEAM LASER"
 CHAR 'A'               \
 CHAR 'M'               \ Encoded as:   "<147>AM[27]"
 RTOK 27
 EQUB 0

 CHAR 'F'               \ Token 105:    "FUEL"
 CHAR 'U'               \
 CHAR 'E'               \ Encoded as:   "FUEL"
 CHAR 'L'
 EQUB 0

 CHAR 'M'               \ Token 106:    "MISSILE"
 TWOK 'I', 'S'          \
 CHAR 'S'               \ Encoded as:   "M<157>SI<129>"
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\RTOK 67                \ Token 107:    "LARGE CARGO{sentence case} BAY"
\RTOK 46                \
\CHAR ' '               \ Encoded as:   "[67][46] BAY"
\CHAR 'B'
\CHAR 'A'
\CHAR 'Y'
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 CHAR 'I'               \ Token 107:    "I.F.F.SYSTEM"
 CHAR '.'               \
 CHAR 'F'               \ Encoded as:   "I.F.F.[5]"
 CHAR '.'
 CHAR 'F'
 CHAR '.'
 RTOK 5
 EQUB 0

                        \ --- End of replacement ------------------------------>

 CHAR 'E'               \ Token 108:    "E.C.M.SYSTEM"
 CHAR '.'               \
 CHAR 'C'               \ Encoded as:   "E.C.M.[5]"
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 RTOK 5
 EQUB 0

 RTOK 102               \ Token 109:    "EXTRA PULSE LASERS"
 RTOK 103               \
 CHAR 'S'               \ Encoded as:   "[102][103]S"
 EQUB 0

 RTOK 102               \ Token 110:    "EXTRA BEAM LASERS"
 RTOK 104               \
 CHAR 'S'               \ Encoded as:   "[102][104]S"
 EQUB 0

 RTOK 105               \ Token 111:    "FUEL SCOOPS"
 CHAR ' '               \
 CHAR 'S'               \ Encoded as:   "[105] SCOOPS"
 CHAR 'C'
 CHAR 'O'
 CHAR 'O'
 CHAR 'P'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          \ Token 112:    "ESCAPE POD"
 CHAR 'C'               \
 CHAR 'A'               \ Encoded as:   "<137>CAPE POD"
 CHAR 'P'
 CHAR 'E'
 CHAR ' '
 CHAR 'P'
 CHAR 'O'
 CHAR 'D'
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\RTOK 121               \ Token 113:    "ENERGY BOMB"
\CHAR 'B'               \
\CHAR 'O'               \ Encoded as:   "[121]BOMB"
\CHAR 'M'
\CHAR 'B'
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 RTOK 29                \ Token 113:    "HYPERSPACE UNIT"
 RTOK 14                \
 EQUB 0                 \ Encoded as:   "[29][14]"

                        \ --- End of replacement ------------------------------>

 RTOK 121               \ Token 114:    "ENERGY UNIT"
 RTOK 14                \
 EQUB 0                 \ Encoded as:   "[121][14]"

 CHAR 'D'               \ Token 115:    "DOCKING COMPUTERS"
 CHAR 'O'               \
 CHAR 'C'               \ Encoded as:   "DOCK<140>G [55]"
 CHAR 'K'
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 55
 EQUB 0

 RTOK 122               \ Token 116:    "GALACTIC HYPERSPACE "
 CHAR ' '               \
 RTOK 29                \ Encoded as:   "[122] [29]"
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\CHAR 'M'               \ Token 117:    "MILITARY  LASER"
\CHAR 'I'               \
\CHAR 'L'               \ Encoded as:   "MILIT<138>Y [27]"
\CHAR 'I'
\CHAR 'T'
\TWOK 'A', 'R'
\CHAR 'Y'
\CHAR ' '
\RTOK 27
\EQUB 0
\
\CHAR 'M'               \ Token 118:    "MINING  LASER"
\TWOK 'I', 'N'          \
\TWOK 'I', 'N'          \ Encoded as:   "M<140><140>G [27]"
\CHAR 'G'
\CHAR ' '
\RTOK 27
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 CHAR 'M'               \ Token 117:    "MILITARY LASER"
 CHAR 'I'               \
 CHAR 'L'               \ Encoded as:   "MILIT<138>Y[27]"
 CHAR 'I'
 CHAR 'T'
 TWOK 'A', 'R'
 CHAR 'Y'
 RTOK 27
 EQUB 0

 CHAR 'M'               \ Token 118:    "MINING LASER"
 TWOK 'I', 'N'          \
 TWOK 'I', 'N'          \ Encoded as:   "M<140><140>G[27]"
 CHAR 'G'
 RTOK 27
 EQUB 0

                        \ --- End of replacement ------------------------------>

 RTOK 37                \ Token 119:    "CASH:{cash} CR{cr}
 CHAR ':'               \               "
 CONT 0                 \
 EQUB 0                 \ Encoded as:   "[37]:{0}"

 TWOK 'I', 'N'          \ Token 120:    "INCOMING MISSILE"
 RTOK 91                \
 TWOK 'I', 'N'          \ Encoded as:   "<140>[91]<140>G [106]"
 CHAR 'G'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          \ Token 121:    "ENERGY "
 TWOK 'E', 'R'          \
 CHAR 'G'               \ Encoded as:   "<146><144>GY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'G'               \ Token 122:    "GALACTIC"
 CHAR 'A'               \
 TWOK 'L', 'A'          \ Encoded as:   "GA<149>C<151>C"
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'C'
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\RTOK 115               \ Token 123:    "DOCKING COMPUTERS ON"
\CHAR ' '               \
\CHAR 'O'               \ Encoded as:   "[115] ON"
\CHAR 'N'
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 RTOK 115               \ Token 123:    "DOCKING COMPUTERS ON"
 CHAR ' '               \
 TWOK 'O', 'N'          \ Encoded as:   "[115] <159>"
 EQUB 0

                        \ --- End of replacement ------------------------------>

 CHAR 'A'               \ Token 124:    "ALL"
 RTOK 129               \
 EQUB 0                 \ Encoded as:   "A[129]"

 CONT 5                 \ Token 125:    "FUEL: {fuel level} LIGHT YEARS{cr}
 TWOK 'L', 'E'          \                CASH:{cash} CR{cr}
 CHAR 'G'               \                LEGAL STATUS:"
 TWOK 'A', 'L'          \
 CHAR ' '               \ Encoded as:   "{5}<129>G<128> [43]<145><136>:"
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                \ Token 126:    "COMMANDER {commander name}{cr}
 CHAR ' '               \                {cr}
 CONT 4                 \                {cr}
 CONT 12                \                {sentence case}PRESENT SYSTEM{tab to
 CONT 12                \                column 21}:{current system name}{cr}
 CONT 12                \                HYPERSPACE SYSTEM{tab to column 21}:
 CONT 6                 \                {selected system name}{cr}
 RTOK 145               \                CONDITION{tab to column 21}:"
 CHAR ' '               \
 RTOK 5                 \ Encoded as:   "[92] {4}{12}{12}{12}{6}[145] [5]{9}{2}
 CONT 9                 \                {12}[29][5]{9}{3}{13}C<159><141><151>
 CONT 2                 \                <159>{9}"
 CONT 12
 RTOK 29
 RTOK 5
 CONT 9
 CONT 3
 CONT 12
 CHAR 'C'
 TWOK 'O', 'N'
 TWOK 'D', 'I'
 TWOK 'T', 'I'
 TWOK 'O', 'N'
 CONT 9
 EQUB 0

 CHAR 'I'               \ Token 127:    "ITEM"
 TWOK 'T', 'E'          \
 CHAR 'M'               \ Encoded as:   "I<156>M"
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 0                 \ Token 128:    ""
\                       \
\                       \ Encoded as:   ""

                        \ --- And replaced by: -------------------------------->

 CHAR 'S'               \ Token 128:    "SPACE"
 CHAR 'P'               \
 CHAR 'A'               \ Encoded as:   "SPA<133>"
 TWOK 'C', 'E'
 EQUB 0

                        \ --- End of replacement ------------------------------>

 CHAR 'L'               \ Token 129:    "LL"
 CHAR 'L'               \
 EQUB 0                 \ Encoded as:   "LL"

 TWOK 'R', 'A'          \ Token 130:    "RATING:"
 TWOK 'T', 'I'          \
 CHAR 'N'               \ Encoded as:   "<148><151>NG:"
 CHAR 'G'
 CHAR ':'
 EQUB 0

 CHAR ' '               \ Token 131:    " ON "
 TWOK 'O', 'N'          \
 CHAR ' '               \ Encoded as:   " <159> "
 EQUB 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\CONT 12                \ Token 132:    "{cr}
\CONT 8                 \                {all caps}EQUIPMENT: {sentence case}"
\RTOK 47                \
\CHAR 'M'               \ Encoded as:   "{12}{8}[47]M<146>T:{6}"
\TWOK 'E', 'N'
\CHAR 'T'
\CHAR ':'
\CONT 6
\EQUB 0

                        \ --- And replaced by: -------------------------------->

 CONT 12                \ Token 132:    "{cr}
 RTOK 25                \                SHIP:          "
 CHAR ':'               \
 CHAR ' '               \ Encoded as:   "{12}[25]:          "

.new_name

 CHAR ' '               \ This part is updated with our current ship's type in
 CHAR ' '               \ the n_load routine, so printing token 132 will always
 CHAR ' '               \ show the correct type of our ship
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 EQUB 0

                        \ --- End of replacement ------------------------------>

 CHAR 'C'               \ Token 133:    "CLEAN"
 TWOK 'L', 'E'          \
 TWOK 'A', 'N'          \ Encoded as:   "C<129><155>"
 EQUB 0

 CHAR 'O'               \ Token 134:    "OFFENDER"
 CHAR 'F'               \
 CHAR 'F'               \ Encoded as:   "OFF<146>D<144>"
 TWOK 'E', 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               \ Token 135:    "FUGITIVE"
 CHAR 'U'               \
 CHAR 'G'               \ Encoded as:   "FUGI<151><150>"
 CHAR 'I'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 EQUB 0

 CHAR 'H'               \ Token 136:    "HARMLESS"
 TWOK 'A', 'R'          \
 CHAR 'M'               \ Encoded as:   "H<138>M<129>SS"
 TWOK 'L', 'E'
 CHAR 'S'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 137:    "MOSTLY HARMLESS"
 CHAR 'O'               \
 RTOK 43                \ Encoded as:   "MO[43]LY [136]"
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 RTOK 136
 EQUB 0

 RTOK 12                \ Token 138:    "POOR "
 EQUB 0                 \
                        \ Encoded as:   "[12]"

 RTOK 11                \ Token 139:    "AVERAGE "
 EQUB 0                 \
                        \ Encoded as:   "[11]"

 CHAR 'A'               \ Token 140:    "ABOVE AVERAGE "
 CHAR 'B'               \
 CHAR 'O'               \ Encoded as:   "ABO<150> [11]"
 TWOK 'V', 'E'
 CHAR ' '
 RTOK 11
 EQUB 0

 RTOK 91                \ Token 141:    "COMPETENT"
 CHAR 'P'               \
 CHAR 'E'               \ Encoded as:   "[91]PET<146>T"
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 142:    "DANGEROUS"
 TWOK 'A', 'N'          \
 TWOK 'G', 'E'          \ Encoded as:   "D<155><131>[94]<136>"
 RTOK 94
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'D'               \ Token 143:    "DEADLY"
 CHAR 'E'               \
 CHAR 'A'               \ Encoded as:   "DEADLY"
 CHAR 'D'
 CHAR 'L'
 CHAR 'Y'
 EQUB 0

 CHAR '-'               \ Token 144:    "---- E L I T E ----"
 CHAR '-'               \
 CHAR '-'               \ Encoded as:   "---- E L I T E ----"
 CHAR '-'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR ' '
 CHAR 'I'
 CHAR ' '
 CHAR 'T'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR '-'
 EQUB 0

 CHAR 'P'               \ Token 145:    "PRESENT"
 TWOK 'R', 'E'          \
 CHAR 'S'               \ Encoded as:   "P<142>S<146>T"
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 \ Token 146:    "{all caps}GAME OVER"
 CHAR 'G'               \
 CHAR 'A'               \ Encoded as:   "{8}GAME O<150>R"
 CHAR 'M'
 CHAR 'E'
 CHAR ' '
 CHAR 'O'
 TWOK 'V', 'E'
 CHAR 'R'
 EQUB 0

 SKIP 5                 \ These bytes appear to be unused

\ ******************************************************************************
\
\       Name: SNE
\       Type: Variable
\   Category: Maths (Geometry)
\    Summary: Sine/cosine table
\  Deep dive: The sine, cosine and arctan tables
\             Drawing circles
\             Drawing ellipses
\
\ ------------------------------------------------------------------------------
\
\ This lookup table contains sine values for the first half of a circle, from 0
\ to 180 degrees (0 to PI radians). In terms of circle or ellipse line segments,
\ there are 64 segments in a circle, so this contains sine values for segments
\ 0 to 31.
\
\ In terms of segments, to calculate the sine of the angle at segment x, we look
\ up the value in SNE + x, and to calculate the cosine of the angle we look up
\ the value in SNE + ((x + 16) mod 32).
\
\ In terms of radians, to calculate the following:
\
\   sin(theta) * 256
\
\ where theta is in radians, we look up the value in:
\
\   SNE + (theta * 10)
\
\ To calculate the following:
\
\   cos(theta) * 256
\
\ where theta is in radians, look up the value in:
\
\   SNE + ((theta * 10) + 16) mod 32
\
\ Theta must be between 0 and 3.1 radians, so theta * 10 is between 0 and 31.
\
\ ******************************************************************************

.SNE

 FOR I%, 0, 31

  N = ABS(SIN((I% / 64) * 2 * PI))

  IF N >= 1
   EQUB 255
  ELSE
   EQUB INT(256 * N + 0.5)
  ENDIF

 NEXT

\ ******************************************************************************
\
\       Name: ACT
\       Type: Variable
\   Category: Maths (Geometry)
\    Summary: Arctan table
\  Deep dive: The sine, cosine and arctan tables
\
\ ------------------------------------------------------------------------------
\
\ This table contains lookup values for arctangent calculations involving angles
\ in the range 0 to 45 degrees (or 0 to PI / 4 radians).
\
\ To calculate the value of theta in the following:
\
\   theta = arctan(t)
\
\ where 0 <= t < 1, we look up the value in:
\
\   ACT + (t * 32)
\
\ The result will be an integer representing the angle in radians, where 256
\ represents a full circle of 360 degrees (2 * PI radians). The result of the
\ lookup will therefore be an integer in the range 0 to 31, as this represents
\ 0 to 45 degrees (0 to PI / 4 radians).
\
\ The table does not support values of t >= 1 or t < 0 directly, so if we need
\ to calculate the arctangent for an angle greater than 45 degrees, we can apply
\ the following calculation to the result from the table:
\
\   * For t > 1, arctan(t) = 64 - arctan(1 / t)
\
\ For negative values of t where -1 < t < 0, we can apply the following
\ calculation to the result from the table:
\
\   * For t < 0, arctan(-t) = 128 - arctan(t)
\
\ Finally, if t < -1, we can do the first calculation to get arctan(|t|), and
\ the second to get arctan(-|t|).
\
\ ******************************************************************************

.ACT

 FOR I%, 0, 31

  EQUB INT((128 / PI) * ATN(I% / 32) + 0.5)

 NEXT

\ ******************************************************************************
\
\ Save WORDS.bin
\
\ ******************************************************************************

 PRINT "WORDS"
 PRINT "Assembled at ", ~CODE_WORDS%
 PRINT "Ends at ", ~P%
 PRINT "Code size is ", ~(P% - CODE_WORDS%)
 PRINT "Execute at ", ~LOAD_WORDS%
 PRINT "Reload at ", ~LOAD_WORDS%

 PRINT "S.WORDS ", ~CODE_WORDS%, " ", ~P%, " ", ~LOAD_WORDS%, " ", ~LOAD_WORDS%
 SAVE "3-assembled-output/WORDS.bin", CODE_WORDS%, P%, LOAD_WORDS%
