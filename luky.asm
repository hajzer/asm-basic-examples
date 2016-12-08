;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte z klavesnice retazec znakov ukonceny znakom "konca suboru".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Urcte pocet slov obsahujucich aspon 2 cislice.
; Pocet vytlacit desiatkovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 8.12.2002
;
; Subor: luky.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
subor db 'subor.txt',0             ; subor z ktoreho budeme citat
cislo_suboru dw ?                  ; deskriptor suboru
znak db ?                          ; buffer pre znak
pocet dw 0                         ; pocet slov ktore obsahuju 2 a viac cislic
pocet_cislic dw 0                  ; pocet cislic v slove
chyba db "Chyba$"
nl db 13,10,"$"
.code

         jmp Start                 ; skok na Start

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
      mov ax,@data
      mov ds,ax

; otvorenie suboru
      mov ah,3dh                        ; otvorenie suboru
      mov al,00010000b                  ; atributy otvorenia suboru
      mov dx,OFFSET subor               ; ktory subor?
      int 21h
      jc _chyba                         ; ak chyba skok na _chyba
      mov cislo_suboru,ax               ; inak uloz deskriptor suboru
      jmp _citaj_znak                   ; skok na _citaj_znak

_chyba:
       mov dx,OFFSET chyba              ; vypese ze nastala chyba
       mov ah,9                         ; sluzba vypise retazec
       int 21h

       jmp _EOF

_citaj_znak:
       mov ah,3fh                       ; sluzba citanie zo suboru
       mov bx,cislo_suboru              ; z tohto suboru sa bude citat
       mov cx,1                         ; kolko bajtov? 1 bajt = 1 znak
       mov dx,OFFSET znak               ; a ulozime si ho do premennej znak
       int 21h
       jc _chyba                        ; ak chyba
       cmp znak,' '                     ; ak medzera
       je _medzera
       cmp ax,0                         ; ak koniec suboru
       je _posledne

       cmp znak,'0'                     ; ak znak je mensi ako znak '0'
       jb _citaj_znak                   ; citaj dalsi znak
       cmp znak,'9'                     ; ak znak je vacsi ako znak '9'
       ja _citaj_znak                   ; citaj dalsi znak

_pripocitaj:
        inc pocet_cislic                ; zvys pocet cislic v slove
        jmp _citaj_znak

_pripocitaj_slovo:
        inc pocet                       ; zvys pocet slov ktore obsahuju viac
        mov pocet_cislic,0              ; ako 2 cislice, vynuluj pocet_cislic
        jmp _citaj_znak

_medzera:
        cmp pocet_cislic,1              ; ak pocet cislic je aspon 2 tak
        ja _pripocitaj_slovo            ; skok na _pripocitaj_slovo

        mov pocet_cislic,0              ; vynuluj pocet_cislic
        jmp _citaj_znak

_posledne:
        cmp pocet_cislic,2
        jb  _EOF
        inc pocet

_EOF:
        mov ah,3Eh               ; sluzba uzatvorenia suboru
        mov bx,cislo_suboru      ; ktory subor chceme uzatvorit? subor, ktoreho
        int 21h                  ; deskriptor suboru je v cislo_suboru

        mov ax,pocet             ; cislo ktore chceme vypisat
        mov bx,10                ; v akej sustave? desiatkovej
        call premen              ; volanie procedury, ktora cislo vypise

        mov ax,4c00h             ;exit do DOS-u
        int 21h

end Start