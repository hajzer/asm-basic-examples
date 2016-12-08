;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte z klavesnice retazec znakov ukonceny znakom "novy riadok".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Urcte pocet slov, ktore maju jeden znak z velkej abecedy a neobsahuju
; cisla. Pocet vypiste v sestnastkovej sustave.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 17.12.2002
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
NL db 13,10,'$'            ;znak noveho riadku
pocetSlov dw 0             ;pocitanie vyhovujucich slov
obsahujeCislo db 0         ;priznak sa nastavi na 1 ak slovo obsahuje cislo
obsahujeVelkyZnak db 0     ;priznak sa nastavi na 1 ak slovo obsahuje velky znak
obsahujeVelkeZnaky db 0    ;priznak sa nastavi na 1 ak slovo obsahuje viac ako jeden velky znak
priznak db 0               ;priznak sa nastavi na 1 ak dal enter => treba skoncit
.code

cislo PROC NEAR       ;procedura zisti, ci v al je cislo. Ak je cislo nastavi priznak obsahujeCislo na 1

      cmp al,48        ;porovnanie al s ascii kodom znaku 0
      jb return        ;ak je menej, tak to cislo nie je
      cmp al,57        ;porovnanie al s ascii kodom znaku 9
      ja return        ;ak je viac, tak to cislo nie je
      mov obsahujeCislo,1
return:
      ret

cislo ENDP

velkyZnak PROC NEAR    ;procedura zisti, ci v al je velky znak. Ak ano, tak nastavi priznak obsahujeVelkyZnak na 1

      cmp al,65                          ;porovnanie al s ascii kodom znaku A
      jb return1                         ;ak je menej, tak to velky znak nie je
      cmp al,90                          ;porovnanie al s ascii kodom znaku Z
      ja return1                         ;ak je viac, tak to velky znak nie je
      cmp obsahujeVelkyZnak,1            ;ak slovo uz obsahuje velky znak
      je return2
      mov obsahujeVelkyZnak,1
      ret
return2:
      mov obsahujeVelkeZnaky,1           ;slovo obsahuje viac ako jeden velky znak
return1:
      ret

velkyZnak ENDP


Start:

      mov ax,@data
      mov ds,ax

loo:

      mov ah,01h            ;nacita znak z klavesnice (ulozi ho do al) a zaroven vypise na obrazovku
      int 21h

      cmp al,' '            ;ak je vlozeny znak medzera
      je vyhodnotSlovo

      cmp al,13             ;ak je vlozeny znak "ENTER"
      je vyhodnotSlovo_koniec

      call cislo
      call velkyZnak

      inc bx                ;bx sluzi na pocitanie znakov v tomto slove
      jmp loo

vyhodnotSlovo_koniec:
      mov priznak,1
vyhodnotSlovo:
      cmp bx,0                   ;ak slovo ma 0 znakov
      je reset
      cmp obsahujeVelkyZnak,0    ;ak slovo neobsahuje velky znak
      je reset
      cmp obsahujeVelkeZnaky,1   ;ak slovo ma viac velkych znakov
      je reset
      cmp obsahujeCislo,1        ;ak slovo obsahuje cislo
      je reset

      inc pocetSlov              ;slovo vyhovuje podmienkam => zvysit pocet slov

reset:
      mov obsahujeVelkyZnak,0    ;vsetky priznaky sa vynuluju
      mov obsahujeCislo,0
      mov obsahujeVelkeZnaky,0
      cmp priznak,1              ;ak priznak je 1 => treba skoncit
      je koniec
      jmp loo

koniec:
       mov dx,OFFSET NL        ;vypise znak noveho riadku
       mov ah,9
       int 21h

       ;ak nechces pouzit proceduru premen, tak namiesto tych 3 riadkov daj svoj kod
       mov ax,pocetSlov
       mov bx,16
       call premen

       mov ax,4c00h            ;vystup do DOS-u
       int 21h

; Procedura umoznuje vypis cisel v nasle-
; dovnych ciselnych sustavach 2,8,10,16.
;
; Vstup: register AX = cislo
; register BX = zaklad sustavy
;
; Vystup: cez INT 21h na obrazovku

premen         proc near
         push ax
         xor cx, cx
wn0:
         xor dx, dx
         div bx
         push dx
         inc cx
         test ax, ax
         jnz wn0
wn2:
         pop dx
         or dl, '0'
         cmp dl, '9'
         jbe wn3
         add dl, 7
wn3:
         mov ah, 2
         int 21h
         loop wn2
         pop ax
         ret
premen         endp
end Start

