.section .text
.global _start

# ============================================================
# 8255 / 8-digit 7-segment display lab
#
# Goal:
#   Scroll the word "SHE" back and forth across an 8-digit
#   7-segment display.
#
# Port usage for Figure A:
#   Port A (0x640) = digit select
#   Port B (0x641) = segment data
#   Port C (0x642) = unused
#   CTRL   (0x643) = 8255 control register
#
# 7-segment bit mapping on Port B:
#   bit:  7 6 5 4 3 2 1 0
#         X g f e d c b a
#
# Character patterns used:
#   S = a,f,g,c,d = 0b01101101 = 0x6D
#   H = f,e,g,b,c = 0b01110110 = 0x76
#   E = a,f,g,e,d = 0b01111001 = 0x79
# ============================================================

.equ PORTA, 0x640      # digit-select port
.equ PORTB, 0x641      # segment-data port
.equ PORTC, 0x642      # not used in this lab
.equ CTRL , 0x643      # 8255 control register

.equ PAT_S, 0x6D       # segments for 'S'
.equ PAT_H, 0x76       # segments for 'H'
.equ PAT_E, 0x79       # segments for 'E'
.equ PAT_BLANK, 0x00   # all segments off

_start:

# ------------------------------------------------------------
# Initialize 8255:
#   Mode 0 for both groups
#   Port A = output
#   Port B = output
#   Port C = output
# ------------------------------------------------------------
mov $0x80, %al
mov $CTRL, %dx
out %al, %dx

mov $0, %bl            # start with SHE at digits 0,1,2
mov $0, %bh            # initial direction = right

main_loop:

mov $250, %si          # number of refresh passes at this position

refresh_frame:

# ---- Digit 0 ----
mov $0, %cl            # CL = digit number being refreshed
call output_digit

# ---- Digit 1 ----
mov $1, %cl
call output_digit

# ---- Digit 2 ----
mov $2, %cl
call output_digit

# ---- Digit 3 ----
mov $3, %cl
call output_digit

# ---- Digit 4 ----
mov $4, %cl
call output_digit

# ---- Digit 5 ----
mov $5, %cl
call output_digit

# ---- Digit 6 ----
mov $6, %cl
call output_digit

# ---- Digit 7 ----
mov $7, %cl
call output_digit

dec %si
jnz refresh_frame

cmp $0, %bh
je move_right

move_left:
dec %bl
cmp $0, %bl
jne main_loop
mov $0, %bh            # reached left edge, now move right
jmp main_loop

move_right:
inc %bl
cmp $5, %bl
jne main_loop
mov $1, %bh            # reached right edge, now move left
jmp main_loop

output_digit:

mov $PAT_BLANK, %al    # default = blank

cmp %bl, %cl
je show_S

mov %bl, %ah
inc %ah
cmp %ah, %cl
je show_H

inc %ah
cmp %ah, %cl
je show_E

jmp send_pattern

show_S:
mov $PAT_S, %al
jmp send_pattern

show_H:
mov $PAT_H, %al
jmp send_pattern

show_E:
mov $PAT_E, %al

send_pattern:
# ------------------------------------------------------------
# Send segment pattern to Port B
# ------------------------------------------------------------
mov $PORTB, %dx
out %al, %dx

mov $1, %al
mov %cl, %ch           # copy digit number for shift count

shift_loop:
cmp $0, %ch
je digit_ready
shl $1, %al
dec %ch
jmp shift_loop

digit_ready:
mov $PORTA, %dx
out %al, %dx

call short_delay

mov $PAT_BLANK, %al
mov $PORTB, %dx
out %al, %dx

mov $0x00, %al
mov $PORTA, %dx
out %al, %dx

ret

short_delay:
mov $400, %cx
sd_loop:
loop sd_loop
ret
