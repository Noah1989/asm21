gset2 equ $b2

gaddr_l equ $b3
gaddr_h equ $b4

name    equ $b8
color   equ $b9
pattern equ $ba 
palette equ $bb

name_inc    equ $bc
color_inc   equ $bd
pattern_inc equ $be 
palette_inc equ $bf

init_graphics    equ $0500
load_palette     equ $0400
load_chars       equ $0600
clear_screen     equ $0700
clear_screen_col equ $0702
print_byte       equ $0900
get_key          equ $0c00 

org $8100

call clear_screen

; disable highchars mode
ld a, %00110011
out gset2, a

; fill patterns $00..$0f with single color
xor a
out gaddr_l, a
out gaddr_h, a
pat_bigloop:
  ld b, 32
  pat_loop:
    out pattern_inc, a
  djnz pat_loop
  add a, $11
jr nc, pat_bigloop

; fill palettes $00..$0f with all possible colors
xor a
out gaddr_l, a
out gaddr_h, a
pal_loop:
  out palette_inc, a
  inc a
jr nz, pal_loop

; palette $10 for top half of characters
ld b, 8
pal_top_loop:
  out palette_inc, a ; is 0 here
  dec a
  out palette_inc, a
  inc a
djnz pal_top_loop

; palette $11 for bottom half of characters
ld b, 4
pal_bot_loop:
  out palette_inc, a ; is 0 here
  out palette_inc, a
  dec a
  out palette_inc, a
  out palette_inc, a
  inc a
djnz pal_bot_loop

; prepare screen
ld d, $10 ; color
call clear_screen_col
ld d, 1
ld c, 20
clr_loop:
  call setline
  ld a, $11
  ld b, 80
clr_loop2:
    out color_inc, a
  djnz clr_loop2
  inc d
  inc d
  inc d
  dec c
jr nz, clr_loop

; |<--= 16*5 = 80 --->|
; |___________________|_
; |                   | A
; |                   | 6
; |                   |_V
; |00[] 01[] ... 0F[] | A
; |10[] 11[] ... 1F[] |16*3
; |   ...  ...  ...   |= 48
; |F0[] F1[] ... FF[] |_V
; |                   | A
; |                   | 6
; |___________________|_V

;ld c, 0 ; already cleared by loop above
ld d, 6
main_loop:
  call line2
  inc d
  xor a
  cp c
jr nz, main_loop

waitkey:
  call get_key
jr z, waitkey
call clear_screen
call load_palette
call load_chars
call init_graphics
ret

line2:
call line
ld a, -16
add a, c
ld c, a
line:
call setline
ld b, 16
line_loop:
  ld a, c
  call scramble
  call print_byte
  call box2
  in a, name_inc
  inc c
djnz line_loop
inc d
ret

box2:
call box
box:
ld a, c
call scramble
rrca
rrca
rrca
rrca
and $0f
out color, a
ld a, c
call scramble
and $0f
out name_inc, a
ret

setline:
xor a
rr d
rra
out gaddr_l, a
rla
ld b, d
rl d
ld a, b
out gaddr_h, a
ret

scramble:
ld hl, 0
ld e, 4
scramble_loop1:
  rla
  rl h
  rl h
  dec e
jr nz, scramble_loop1
ld e, 4
scramble_loop2:
  rl l
  rla
  rl l
  dec e
jr nz, scramble_loop2
ld a, h
or l
ret