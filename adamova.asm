;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte z klavesnice retazec znakov ukonceny znakom "noveho
; riadku".Nech slovo je postupnost znakov medzi dvoma
; znakmi"medzera".Urcte pocet slov, v ktorych sucet ASCII kodov
; znakov je vacsi ako 100.Pocet vytlacte desiatkovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 20.1.2003
;
; Subor: adamova.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
sucet dw 0
pocet dw 0
vypis db "Pocet slov ktorych sucet ASCII kodov je vacsi ako 100 je:$"
.code

         jmp Start                             ; skok na Start

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

Start:
         mov ax,@data           ; zistime kde su data
         mov ds,ax              ; a ulozime si ich do segmentoveho registra

citaj:
         mov ah,1               ; sluzba nacita a zaroven vypise znak
         int 21h                ; volanie prerusenia

         cmp al,' '             ; nacitany znak porovname zo znakom medzera
         je space               ; ak sa zhoduje skok na navestie space
         cmp al,13              ; nacitany znak porovname zo znakom "novy riadok"
         je last                ; ak sa zhoduje skok na navestie last

         mov ah,0               ; do subregistra ah dame 0
         add sucet,ax           ; pripocitame ASCII hodnotu znaku k celkovemu suctu slova
         jmp citaj              ; skok na citaj

space:
       cmp sucet,100            ; porovnaj sucet ASCII kodov slova a 100
       jg pripocitaj            ; ak sucet je vacsi tak skok na _pripocitaj
       mov sucet,0              ; vynuluj sucet
       jmp citaj                ; skok na _citaj_znak

last:
       cmp sucet,100            ; porovnaj sucet ASCII kodov slova a 100
       jg pripocitaj_last       ; ak sucet je vacsi tak skok na _pripocitaj_EOF
       jmp vypis_text           ; skok na vypis_text

pripocitaj:
       inc pocet                ; zvys pocet o 1
       mov sucet,0              ; vynuluj sucet
       jmp citaj                ; skok

pripocitaj_last:
       inc pocet                ; zvys pocet o 1

vypis_text:                     ; vypise hlasku
       mov dx,OFFSET vypis      ; do registra dx dame offset retazca ktory chceme vypisat
       mov ah,09h               ; sluzba 09 = vypis retazca na STDOUT
       int 21h                  ; volanie prerusenia

       mov ax,pocet             ; vypise pocet slov, ktorych sucet ASCII ...
       mov bx,10                ; vypise to desiatkovo
       call premen              ; pouziva sa pri tom procedura premen

koniec:
       mov ax,4c00h             ; exit do DOS-u
       int 21h                  ; volanie prerusenia

end Start
