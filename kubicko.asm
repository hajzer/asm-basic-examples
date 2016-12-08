;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte zo suboru retazec znakov ukonceny znakom konca suboru.
; Nech slovo je postupnost znakov medzi dvoma znakmi medzera.
; Urcte pocet slov obsahujucich najviac tri cislice.
; Pocet vytlacte desiatkovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 21.01.2003
;
; Subor: kubicko.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
subor db 'subor.txt',0                ; subor z ktoreho budeme citat
cislo_suboru dw ?                     ; deskriptor suboru
znak db ?                             ; buffer pre znak
sucet dw 0                            ; sucet ASCII kodov slova
pocet dw 0                            ; pocet slov ktorych sucet ...
chyba db "Chyba.$"
text db "Pocet slov obsahujucich najviac 3 cislice je:$"
.code

Start:
      mov ax,@data           ; zistime kde su data a
      mov ds,ax              ; ulozime si ich do segmentoveho registra

      ; otvorenie suboru
      mov ah,3Dh                ; sluzba otvorenia suboru
      mov al,00010000b          ; atributy otvorenia suboru
      mov dx,OFFSET subor       ; ktory subor chceme otvorit
      int 21h                   ; volanie prerusenia
      jc error                  ; ak chyba, skok na err
      mov cislo_suboru,ax       ; inak zapis deskriptor suboru
      jmp read_char             ; skok na read_char

error:
      mov dx,OFFSET chyba       ; vypise hlasku o chybe
      mov ah,9
      int 21h

      jmp ende                  ; a skonci

reset:
      mov sucet,0

read_char:
       mov ah,3Fh               ; citanie zo suboru
       mov bx,cislo_suboru      ; z tohto ( cislo suboru = deskriptor suboru )
       mov cx,1                 ; kolko bajtov chceme nacitat?  jeden
       mov dx,OFFSET znak       ; znak ulozime do premennej znak
       int 21h                  ; volanie prerusenia
       jc  error                ; ak chyba skok na navestie err
       cmp znak,' '             ; ak medzera
       je  space                ; skok na navestie space
       cmp ax,0                 ; ak EOF (t.j. ak pocet nacitanych bajtov je 0)
       je  EOF                  ; skok na navestie koniec
       cmp znak,13              ; enter
       je space
       cmp znak,10              ; LF
       je space
       cmp znak,'0'             ; porovname znak zo znakom '0'
       jb  read_char            ; ak je znak mensi ako znak '0' v zmysle ASCII tabulky skok na zle
       cmp znak,'9'             ; porovname znak zo znakom '9'
       ja  read_char            ; ak je znak vacsi ako znak '9' v zmysle ASCII tabulky skok na zle

       inc sucet                ; zvys sucet o jedna
       jmp read_char            ; skok na read_char

space:
       cmp sucet,0
       je  reset
       cmp sucet,3              ; porovnaj sucet s trojkou
       ja  reset                ; ak je sucet viac ako 3 skok na reset
       inc pocet                ; zvys pocet o jedna
       jmp reset                ; skok na rest

EOF:
       cmp sucet,0              ; porovnaj sucet s trojkou
       je  print                ; ak je sucet viac ako 3 skok na print
       cmp sucet,3              ; porovnaj sucet s trojkou
       ja  print                ; ak je sucet viac ako 3 skok na print
       inc pocet
print:
       mov ah,09h
       mov dx,OFFSET text
       int 21h

       mov ax,pocet          ; do ax dame cislo ktore chceme vypisat
       mov bx,10             ; do bx sustavu v ktorej chceme aby to vypisalo
       call transfer         ; volanie funkcie ktora zabezpeci vypis

ende:
      mov ax,4c00h             ;exit do DOS-u
      int 21h

; Procedura umoznuje vypis cisel v nasle-
; dovnych ciselnych sustavach 2,8,10,16.
;
; Vstup: register AX = cislo
; register BX = zaklad sustavy
;
; Vystup: cez INT 21h na obrazovku

transfer         proc near
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
transfer         endp

end Start




