color_menubar              equ $70
color_menubar_highlight    equ $74
color_menubar_active       equ $3F
color_menubar_active_hi    equ $3E
color_menu_dropdown        equ $3F
color_menu_dropdown_hi     equ $3E
color_menu_dropdown_active equ $4F
color_menu_dropdown_act_hi equ $4E
color_menu_dropdown_shadow equ $08
color_editor_top           equ $17
color_editor_left          equ $17
color_editor_title         equ $1F
color_editor_scrollbar     equ $78
color_statusbar            equ $3F
color_statusbar_highlight  equ $3E
color_statusbar_info       equ $30
color_statusbar_info2      equ $31

instruction_indent equ 2
instruction_align  equ 8

chars_tools_top:
.db	$D5, $CD, $20, $CD, $CD
chars_editor_top:
.db	$D1, $CD, $20, $CD, $B8
chars_menu_dropdown_top:
.db	$DA, $C4, $BF
chars_menu_dropdown_frame:
.db	$B3, $20, $B3
chars_menu_dropdown_bottom:
.db	$C0, $C4, $D9
chars_scrollbar:
.db	$18, $19, $DB, $B1

colors_editor:
.db	$1F ; labels, defines, references
.db	$17 ; text, comments
.db	$1C ; numbers, raw nibbles
.db	$1F ; expressions / placeholders
.db	$1D ; flags
.db	$1E ; registers / indirect memory / rst targets
.db	$1B ; pseudo instructions
.db	$1A ; instructions
colors_editor_active:
.db	$9F ; labels, defines, references
.db	$97 ; text, comments
.db	$9C ; numbers, raw nibbles
.db	$9F ; expressions / placeholders
.db	$9D ; flags
.db	$9E ; registers / indirect memory / rst targets
.db	$9B ; pseudo instructions
.db	$9A ; instructions
