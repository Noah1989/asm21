color_menubar              equ $70
color_menubar_highlight    equ $74
color_menubar_active       equ $3F
color_menubar_active_hi    equ $3E
color_menu_dropdown        equ $3F
color_menu_dropdown_hi     equ $3E
color_menu_dropdown_active equ $4F
color_menu_dropdown_act_hi equ $4E
color_menu_dropdown_shadow equ $08
color_editor               equ $17
color_editor_title         equ $1F
color_statusbar            equ $3F
color_statusbar_highlight  equ $3E
color_statusbar_info       equ $30
color_statusbar_info2      equ $31

chars_editor_top:
.db	$D5, $CD, $20, $20, $CD, $B8
chars_editor_frame:
.db	$B3, $20, $B3
chars_menu_dropdown_top:
.db	$DA, $C4, $BF
chars_menu_dropdown_frame:
.db	$B3, $20, $B3
chars_menu_dropdown_bottom:
.db	$C0, $C4, $D9
