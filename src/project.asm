[org 0x100]
jmp start
%define MIDI_CONTROL_PORT 0331h
%define MIDI_DATA_PORT 0330h
%define MIDI_UART_MODE 3Fh
%define MIDI_PIANO_INSTRUMENT 93h
second: dw 0
minute: dw 0
tickcount: dw 0
sze: dw 20;size of snake
oldisr: dd 0
dngsecond: dw 0
dangerousloc: dw 0
clockd: dw 0
eaten: dw 0
fruitloc:dw 0
timedelay: dw 0
snakescore: dw 0
loc: dw 528
speed: dw 18
delaysec: dw 0
easy: dw 0
med: dw 0
hard: dw 0
score: dw 0
win:db'WOW! your are pro'
scorestr:db'score'
timeendstr: db'Ooops! you have ran out of time and not achieve size of required characters'
endstr: db'Game is over! Better luck next time (o.o)'
indexes times 32*16 dw 0; place for storing indexes of nake so that it is easier to move
kbsir:
push ax

in al,0x60



cmp al,0x12
jne lftkey
mov word[easy],1
;mov word[left],1


lftkey:
cmp al,0x4b;if left key press
jne next

cmp word[right],1; checking right key was pressed so it will no move toward left
je nextt
mov word[cs:easy],1
mov word[right],0; initiallizing all direction to 0 other then left so snake will move in left direction only
mov word[down],0
mov word[up],0
mov word[left],1;left flag on

jmp exit

next:


cmp al,0x4d
jne nextt

cmp word[left],1;checking left key was pressed so it will no move toward right
je nextt

mov word[left],0
mov word[down],0
mov word[up],0
mov word[right],1;initiallizing all direction to 0 other then right so snake will move in right direction only
jmp exit


nextt:
cmp al,0x48
jne nextttt

cmp word[down],1;checking down key was pressed so it will no move toward up
je exit

mov word[right],0
mov word[down],0
mov word[left],0
mov word[up],1;initiallizing all direction to 0 other then up so snake will move in up direction only
jmp exit

nextttt:
cmp al,0x50
jne end
cmp word[up],1;checking down key was pressed so it will no move downward
je exit
mov word[right],0
mov word[left],0
mov word[up],0
mov word[down],1;initiallizing all direction to 0 other then down so snake will move in down direction only
jmp exit
end:
pop ax
jmp far[cs:oldisr]


exit:


    call setup_midi
    mov ch, 60;             default octave(0)
    mov cl, 5;              used for making sure that the user does not go too low or too high with the octaves
.loop:
    call read_character
    call process_input

    cmp bh, 0;              if bad input OR octave change goes out of range
    je .loop

    call get_pitch

    cmp bh, 2;              if shouldn't play note (was an octave switch)
    je .loop

    call play_note

    jmp exiit

;--------------------------------------------------
; Plays a note
;
; IN: AL, CH = pitch, (octave * 12) + 60
; OUT: NONE
; ERR: NONE
; REG: AL

play_note:
    add al, ch;             apply the octave
    out dx, al;             DX will already contain MIDI_DATA_PORT from the setup_midi function

    mov al, 7Fh;            note duration
    out dx, al

    ret

;--------------------------------------------------
; Based on input, returns a pitch to be played
;
; IN: AL = key code
; OUT: AL, BH, CH = pitch, 2 if no pitch to be played, (octave * 12) + 60
; ERR: NONE
; REG: preserved

get_pitch:

    cmp al, 'a'
    je .a
    cmp al, 'k'
    je .k
    cmp al, 'l'
    je .l
    cmp al, 'w'
    je .w


    cmp al, 'z'
    je .z
    cmp al, 'x'
    je .x

.a: mov al, 0
    jmp .end
.k: mov al, 9
    jmp .end
.l: mov al, 11
    jmp .end
.w: mov al, 1
    jmp .end

	
.z: add ch, 12
    add cl, 1
    mov bh, 2
    jmp .end
.x: sub ch, 12
    sub cl, 1
    mov bh, 2
    jmp .end


.end:
    ret

;--------------------------------------------------
; Set's up the MIDI ports for use
;
; IN: NONE
; OUT: NONE
; ERR: NONE
; REG: DX

setup_midi:
    push ax

    mov dx, MIDI_CONTROL_PORT
    mov al, MIDI_UART_MODE; play notes as soon as they are recieved
    out dx, al

    mov dx, MIDI_DATA_PORT
    mov al, MIDI_PIANO_INSTRUMENT
    out dx, al

    pop ax
    ret
exiit:
jmp exiiit
;--------------------------------------------------
; Checks to make sure that input is acceptable
;
; IN: AL = key code
; OUT: BH = 1 (accpetable) or 0 (not acceptable, or octave is trying to change too far)
; ERR: NONE
; REG: preserved

process_input:

.check_key_code:
    cmp al, 0x4b
    je .safe1
    cmp al, 0x50
    je .safe2
    cmp al, 0x4d
    je .safe3
    cmp al, 0x48
    je .safe
    


.check_octave_code:
    cmp al, 'z'
    je .z
    cmp al, 'x'
    je .x

    jmp .err;               none of the keys pressed were valid keys

.z:
    cmp cl, 10;             if user is about to go out of octave range, then drop down to error
    jne .safe

.x:
    cmp cl, 1
    jne .safe

.err:
    xor bh, bh
    ret



.safe:
mov al, 'w'
    mov bh, 1
    ret	
.safe1:
mov al,'a'
    mov bh, 1
    ret
.safe2:
mov al,'k'
    mov bh, 1
    ret
.safe3:
mov al,'l'
    mov bh, 1
    ret


;--------------------------------------------------
; Reads a single character from the user
;
; IN: NONE
; OUT: AL = key code
; ERR: NONE
; REG: preserved

read_character:
    xor ah, ah
	in al,0x60

    ret
exiiit:
mov al,0x20
out 0x20,al
pop ax
iret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;



printnum: push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov ax, [bp+6] ; load number in ax
mov di,[bp+4]
 mov bx, 10 ; use base 10 for division
 mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
 div bx ; divide by 10
 add dl, 0x30 ; convert digit into ascii value
 push dx ; save ascii value on stack
 inc cx ; increment count of values
 cmp ax,5
 jne t
mov word[clockd],1 
 t:
 cmp ax, 0 ; is the quotient zero
 jnz nextdigit ; if no divide it again
 ;mov di, 78 ; point di to top left column

nextpos:
 pop dx ; remove a digit from the stack
 mov dh, 0x07 ; use normal attribute
 
 
 
 mov [es:di], dx ; print char on screen
cmp dx,0x0739
jne l2
cmp word[clockd],1
jne l2

mov byte[es:di],0x20

l2:
 add di, 2 ; move to next screen location
 loop nextpos ; repeat for all digits on stack
 mov word[clockd],0
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop es
 pop bp
 ret 4  



printstr: push bp
 mov bp, sp
 push es
 push ax
 push cx
 push si
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
  
mov si,[bp+8]; point si to string
 mov cx, [bp+6] ; load length of string in cx
 mov di, [bp+4] 
 mov ah, 0x07 ; normal attribute fixed in al
nextchar: mov al, [si] ; load next char of string
 mov [es:di], ax ; show this char on screen
 add di, 2 ; move to next screen location
 add si, 1 ; move to next char in string
 loop nextchar ; repeat the operation cx times
 mov al,':'
 mov word[es:di+2],ax
 pop di
 pop si
 pop cx
 pop ax
 pop es
 pop bp
 ret 6
grend:
cmp word[ft],0
jne t1
mov al,'&'
mov ah,0x1e
inc word[ft]
jmp ov
t1:
cmp word[ft],1
jne t2
mov al,'$'
mov ah,0x1e
inc word[ft]
jmp ov
t2:
mov al,'@'
mov ah,0x1e
mov word[ft],0
ov:
inc word[timedelay]

cmp word[timedelay],1
jne tme
mov si,1052
mov [es:si],ax
mov word[fruitloc],si
jmp loca
tme: 

cmp word[timedelay],2
jne tme2
mov si,452
mov [es:si],ax
mov word[fruitloc],si
jmp loca
tme2:

cmp word[timedelay],3
jne tme3
mov si,1250
mov [es:si],ax
mov word[fruitloc],si
jmp loca

tme3:
cmp word[timedelay],4
jne tme4
mov si,620
mov[es:si],ax
mov word[fruitloc],si

jmp loca


tme4:
cmp word[timedelay],5
jne tme5
mov si,918
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme5:
cmp word[timedelay],6
jne tme6
mov si,590
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme6:
cmp word[timedelay],7
jne tme7
mov si,2444
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme7:
cmp word[timedelay],8
jne tme8
mov si,820
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme8:
cmp word[timedelay],9
jne tme9
mov si,1586
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme9:
cmp word[timedelay],10
jne tme10
mov si,860
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme10:
cmp word[timedelay],11
jne tme11
mov si,1060
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme11:
cmp word[timedelay],12
jne tme12
mov si,600
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme12:
cmp word[timedelay],13
jne tme13
mov si,930
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme13:
cmp word[timedelay],14
jne tme14
mov si,500
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme14:
cmp word[timedelay],15
jne tme15
mov si,530
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme15:
cmp word[timedelay],16
jne tme16
mov si,750
mov[es:si],ax
mov word[fruitloc],si
jmp loca


tme16:
cmp word[timedelay],17
jne tme17
mov si,2034
mov[es:si],ax
mov word[fruitloc],si
jmp loca


tme17:
cmp word[timedelay],18
jne tme18
mov si,914
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme18:
cmp word[timedelay],19
jne tme19
mov si,738
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme19:
cmp word[timedelay],20
jne tme20
mov si,2346
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme20:
cmp word[timedelay],21
jne tme21
mov si,1000
mov[es:si],ax
mov word[fruitloc],si

jmp loca

tme21:
cmp word[timedelay],22
jne tme22
mov si,450
mov[es:si],ax
mov word[fruitloc],si
jmp loca

tme22:
cmp word[timedelay],23
jne tme23
mov si,734
mov[es:si],ax
mov word[fruitloc],si
jmp loca


tme23:
cmp word[timedelay],24
jne tme24
mov si,1050
mov[es:si],ax
mov word[fruitloc],si
jmp loca


tme24:
cmp word[timedelay],25
jne tme25
mov si,606
mov[es:si],ax
mov word[fruitloc],si
jmp loca
tme25:
mov si,2056
mov word[fruitloc],si

loca:
cmp word[timedelay],26
jl nothi
mov word[timedelay],1
nothi
ret


timer:
push ax
push 0xb800

pop es

push cs 
pop ds
cmp word[med],1
jne nothin
mov word[speed],12
nothin:
cmp word[hard],1
jne nothin2
mov word[speed],4

nothin2:

cmp word[cs:minute],4
jne nothingtodo
cmp word[cs:sze],240
jge winstring
call clrscrn
mov ax,timeendstr
mov cx,75
mov bp,0
push ax
push cx
push bp
call printstr
mov al,0x20
out 0x20,al      

pop ax
iret

winstring:
call clrscrn
mov ax,win
mov cx,17;size of win string
mov bp,0
push ax
push cx
push bp
call printstr

mov al,0x20
out 0x20,al      

pop ax
iret
nothingtodo:
inc word[delayvl]
inc word[delaysec]
inc word[cs:tickcount]
cmp word[boarder],0
jne outsidebd
mov di,160
mov al,'-'
mov ah,60h
boarderup:
mov word[es:di],ax
add di,2
cmp di,318
jne boarderup

mov di,3840
mov al,'-'
mov ah,60h
boarderdown:
mov word[es:di],ax
add di,2
cmp di,3998
jne boarderdown

cmp word[cs:easy],1
je outsidebd
mov di,320
mov al,'|'
mov ah,60h
boarderleft:
mov word[es:di],ax
add di,160
cmp di,3840
jle boarderleft

mov di,478
mov al,'|'
mov ah,60h
boarderrght:
mov word[es:di],ax
add di,160
cmp di,3998
jle boarderrght
inc word[boarder]
outsidebd:


mov ax,strr
mov cx,4
mov bp,66
push ax
push cx
push bp
call printstr
mov ax,strr2
mov cx,5
mov bp,146
push ax
push cx
push bp
call printstr
mov ax,scorestr
mov cx,5
mov bp,0
push ax
push cx
push bp
call printstr

cmp word[cs:dngsecond],20
jne no
cmp word[cs:easy],1
je noth
cmp word[cs:med],1
je noth
mov si,1450
mov al, '+'
mov ah, 0x40
mov word[es:si],ax
mov word[dangerousloc],si
no:
cmp word[cs:dngsecond],30
jne noth
mov si,word[dangerousloc]
mov word[es:si],0x0720
mov word[dngsecond],0
mov word[dangerousloc],0
noth:

cmp word[cs:tickcount],18
jne snakep
inc word[cs:second]
inc word[cs:dngsecond]
mov word[cs:tickcount],0
cmp word[cs:second],60
jne snakep
inc word[cs:minute]
mov word[cs:tickcount],0
mov word[cs:second],0
snakep:
cmp word[cs:lives],0
jg output
call clrscrn
mov ax,endstr
mov cx,41
mov bp,0
push ax
push cx
push bp
call printstr
mov al,0x20
out 0x20,al      

pop ax
iret
output:
mov bx,word[cs:lives]
mov bp,158
push bx
push bp
call printnum

mov bp,82
mov bx,[cs:second]
push bx
push bp
call printnum
mov bx,[cs:snakescore]
mov bp,14
push bx
push bp
call printnum
mov bx,[cs:minute]
mov bp,78
push bx
push bp
call printnum
cmp word[cs:speed],0
jle programgo
cmp word[cs:delaysec],363;20 sec
jne goon
sub word[cs:speed],4
mov word[delaysec],0

goon:
mov ax,word[cs:speed]

cmp word[delayvl],ax
je programgo

mov al,0x20
out 0x20,al

pop ax
iret

programgo: 
mov word[delayvl],0

cmp word[flag],0; use so only one time we intitiallize create snake
jne movement

call grend

mov di,word[loc];snake pos
mov ah,0xDD
mov al,'*'
mov si,di
mov bx,0
mov word[es:si],ax;;;;storing di value for the 3 character snake
mov word[indexes+bx],si
mov cx,[cs:sze]
dec cx
move:
add si,2
add bx,2
mov word[indexes+bx],si;2=160;4=162,6=164
mov word[es:si],ax

loop move;2,1,0
;call clrscrn
inc word[flag]; since we only one time initiallizing snake



movement:;this will handle snake movement towards left right




cmp word[left],1
jne rig
mov cx,[cs:sze]
dec cx
mov si,0
;moving the di value of the three character snake, similar step for up,down,left,right
jmp nextr

rig:
jmp rigg
nextr:
mov bx,word[indexes+si];0
add si,2
lft2:
mov dx,bx
mov bx,[indexes+si];1;2
mov [indexes+si],dx;1;2
add si,2

loop lft2;1


sub di,2
cmp di,word[dangerousloc]
jne nope

jmp trminte

nope:

cmp di,word[fruitloc]
jne nex

mov si,0
mov cx,word[cs:sze]
len:
add si,2
loop len
add word[cs:sze],4
mov cx,[cs:sze]
dec cx
bodyinc:
mov dx,word[cs:indexes+si]
add dx,2
add si,2
mov word[cs:indexes+si],dx
loop bodyinc
add word[snakescore],200
mov word[fruitloc],0
call grend


nex:
mov cx,[cs:sze]
mov bp,0
lftlb:
cmp di,word[cs:indexes+bp]
je trminte
add bp,2
loop lftlb


mov si,160
cmp word[easy],1
je reeal
boarderlb:
add si,160
cmp si,di
jl boarderlb
je trminte
jmp real
reeal:
jmp real
trminte:
dec word[cs:lives]
call clrscrn
mov word[cs:sze],20
mov word[cs:second],0
mov word[cs:minute],0
mov word[cs:tickcount],0

mov word[flag],0
mov word[left],1
mov word[loc],528
mov word[boarder],0
cmp word[cs:easy],1
jne medspeed
mov word[speed],18

medspeed:
cmp word[med],1

jne hardspeed

mov word[speed],12

hardspeed:
cmp word[hard],1
jne spee

mov word[speed],4
spee:
mov word[fruitloc],0
mov word[delayvl],0
mov word[delaysec],0
mov al,0x20
out 0x20,al

pop ax
iret




real:

mov word[indexes],di
mov ah,0xDD
mov al,'O'
mov word[es:di],ax
mov ah,0xDD
mov al,'*'
mov cx,[cs:sze]
dec cx
mov si,0
lft:
mov di,word[indexes+si+2]
mov word[es:di],ax
loop lft
mov di,bx
mov word[es:di],0x0720
mov di,word[indexes]


jmp upp

rigg:

cmp word[right],1
jne uppp
mov cx,[cs:sze]
dec cx
mov si,0
;moving the di value of the three character snake, similar step for up,down,left,right


mov bx,word[indexes+si];0
add si,2
rgt2:
mov dx,bx
mov bx,[indexes+si];1;2
mov [indexes+si],dx;1;2
add si,2

loop rgt2


add di,2

cmp di,word[dangerousloc]
jne nope2
jmp trminte2

nope2:
cmp di,word[fruitloc]
jne nexx


mov si,0
mov cx,word[cs:sze]
len2:
add si,2
loop len2
add word[cs:sze],4
mov cx,[cs:sze]
dec cx
bodyinc2:
mov dx,word[cs:indexes+si]
add dx,2
add si,2
mov word[cs:indexes+si],dx
loop bodyinc2

add word[snakescore],200
mov word[fruitloc],0
call grend

jmp nexx
uppp:
jmp upppp
nexx:
mov cx,[cs:sze]
mov bp,0
rgtrb:
cmp di,word[cs:indexes+bp]
je trminte2
add bp,2
loop rgtrb


mov si,320
boarderrb:
add si,160
cmp si,di
jl boarderrb
je trminte2
jmp real2
upppp:
jmp upp
trminte2:
dec word[cs:lives]
call clrscrn

mov word[cs:second],0
mov word[cs:minute],0
mov word[cs:tickcount],0
mov word[boarder],0
mov word[flag],0
mov word[left],1
mov word[loc],528
mov word[right],0

cmp word[easy],1
jne medspeed2
mov word[speed],18
medspeed2:
cmp word[med],1
jne hardspeed2

mov word[speed],12

hardspeed2:
cmp word[hard],1
jne spee2
mov word[speed],4
spee2:

mov word[sze],20
mov word[delayvl],0
mov word[delaysec],0
mov word[fruitloc],0
mov al,0x20
out 0x20,al

pop ax
iret


real2:
mov word[indexes],di
mov ah,0xDD
mov al,'O'
mov word[es:di],ax

mov ah,0xDD
mov al,'*'

mov cx,[cs:sze]
dec cx

mov si,0
rgt:
mov di,word[indexes+si+2]
mov word[es:di],ax
loop rgt

mov di,bx
mov word[es:di],0x0720
mov di,word[indexes]


jmp upp

upp:
cmp word[up],1
jne downnn
mov cx,[cs:sze]
dec cx
mov si,0
;moving the di value of the three character snake, similar step for up,down,left,right


mov bx,word[indexes+si];0
add si,2
upt2:
mov dx,bx
mov bx,[indexes+si];1;2
mov [indexes+si],dx;1;2
add si,2

loop upt2;1


sub di,160


cmp di,word[dangerousloc]
jne nope3
jmp trmnite3
nope3:
cmp di,word[fruitloc]
jne nexxx

mov si,0
mov cx,word[cs:sze]
len3:
add si,2
loop len3
add word[cs:sze],4
mov cx,[cs:sze]
dec cx
bodyinc3:
mov dx,word[cs:indexes+si]
add dx,2
add si,2
mov word[cs:indexes+si],dx
loop bodyinc3
add word[snakescore],200
mov word[fruitloc],0
call grend

jmp nexxx
downnn:
jmp downn
nexxx:
mov cx,[cs:sze]
mov bp,0
uptub:
cmp di,word[cs:indexes+bp]
je trmnite3
add bp,2
loop uptub

cmp di,318
jl trmnite3

jmp real3

trmnite3:
dec word[cs:lives]
call clrscrn
mov word[cs:second],0
mov word[cs:minute],0
mov word[cs:tickcount],0
mov word[boarder],0
mov word[flag],0
mov word[left],1
mov word[loc],528
mov word[up],0
cmp word[easy],1
jne medspeed3
mov word[speed],18
medspeed3:
cmp word[med],1
jne hardspeed3

mov word[speed],12

hardspeed3:
cmp word[hard],1
jne spee3
mov word[speed],4
spee3:
mov word[delayvl],0
mov word[delaysec],0
mov word[fruitloc],0
mov word[cs:sze],20
mov al,0x20
out 0x20,al

pop ax
iret

real3:
mov word[indexes],di
mov ah,0xDD
mov al,'O'
mov word[es:di],ax

mov ah,0xDD
mov al,'*'

mov cx,[cs:sze]
dec cx
mov si,0
upt:
mov di,word[indexes+si+2]
mov word[es:di],ax
loop upt

mov di,bx
mov word[es:di],0x0720
mov di,word[indexes]


downn:
cmp word[down],1

jne clearr
mov cx,[cs:sze]
dec cx
mov si,0



mov bx,word[indexes+si];0
add si,2
downt2:
mov dx,bx
mov bx,[indexes+si];1;2
mov [indexes+si],dx;1;2
add si,2

loop downt2


add di,160

cmp di,word[dangerousloc]
jne nope4
jmp trmnite4
nope4:
cmp di,word[fruitloc]
jne nexxxx
mov si,0
mov cx,word[cs:sze]
len4:
add si,2
loop len4
add word[cs:sze],4
mov cx,[cs:sze]
dec cx
bodyinc4:
mov dx,word[cs:indexes+si]
add dx,2
add si,2
mov word[cs:indexes+si],dx
loop bodyinc4
add word[snakescore],200
mov word[fruitloc],0
call grend

jmp nexxxx
clearr:
jmp clear

nexxxx:
mov cx,[cs:sze]
mov bp,0
downdb:
cmp di,word[cs:indexes+bp]
je trmnite4
add bp,2
loop downdb


cmp di,3840
jge trmnite4
jmp real4

trmnite4:
dec word[cs:lives]
call clrscrn
mov word[cs:second],0
mov word[cs:minute],0
mov word[cs:tickcount],0
mov word[boarder],0
mov word[flag],0
mov word[left],1
mov word[down],0
mov word[loc],528
mov word[sze],20
mov word[fruitloc],0
cmp word[easy],1
jne medspeed4
mov word[speed],18
medspeed4:
cmp word[med],1
jne hardspeed4

mov word[speed],12

hardspeed4:
cmp word[hard],1
jne spee4
mov word[speed],4
spee4:

mov word[delayvl],0
mov word[delaysec],0
mov al,0x20
out 0x20,al

pop ax
iret

real4:
mov word[indexes],di

mov ah,0xDD
mov al,'O'
mov word[es:di],ax

mov ah,0xDD
mov al,'*'

mov cx,[cs:sze]
dec cx
mov si,0
downt:
mov di,word[indexes+si+2]
mov word[es:di],ax
loop downt
mov di,bx
mov word[es:di],0x0720
mov di,word[indexes]
mov cx,0xffff

jmp clear;clear is nothing 

clear:


exitt:

mov al,0x20
out 0x20,al

pop ax
iret


 
clrscrn:; to clear scree before loading game

push es
 push ax
 push cx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 xor di, di ; point di to top left column
 mov ax, 0x0720 ; space char in normal attribute
 mov cx, 2000 ; number of screen locations
 cld ; auto increment mode
 rep stosw ; clear the whole screen
 pop di 
pop cx
 pop ax
 pop es
 ret 
start:





push 0
pop es
mov ax, [es:9*4]
 mov [oldisr], ax ; save offset of old routine
 mov ax, [es:9*4+2]
 mov [oldisr+2], ax 
cli
mov word[es:9*4],kbsir
mov [es:9*4+2],cs
mov word[es:8*4],timer
mov [es:8*4+2],cs
sti
mov dx,start
add dx,15
mov cl,4
shr dx,cl

mov ax,3100h
int 0x21
delayvl: dw 0
program: dw 0
count: dw 0
left: dw 0
right:dw 0
up: dw 0
down: dw 0
flag: dw 0
incr: dw 0
col: dw 0
strr:db'time'
strr2:db'lives'
lives: dw 3
boarder: dw 0
ft: dw 0
dft: dw 0