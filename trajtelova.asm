;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte zo suboru retazec znakov ukonceny znakom "konca suboru".
; Nech slovo je postupnost znakov medzi dvoma znakmi "medzera".
; Urcte pocet slov s dlzkou delitelnou 2.
; Pocet vytlacte osmickovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 20.1.2003
;
; Subor: trajtelova.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
subor db 'subor2.txt',0                 ; subor z ktoreho budeme citat
cislo_suboru dw ?                      ; deskriptor suboru
znak db ?                              ; buffer pre znak
chyba db "Chyba.$"
sucet dw 0
pocet dw 0
vypis db "Pocet slov ktorych dlzka je delitelna 2 je:$"
osem db "Pocet vytlaceny osmickovo:$"
NEWLINE db 13,10,"$"
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
         mov ah,02h
         int 21h
         loop wn2
         pop ax
         ret
premen         endp

Start:
         mov ax,@data           ; zistime kde su data
         mov ds,ax              ; a ulozime si ich do segmentoveho registra

; otvorenie suboru
         mov ah,3Dh                ; sluzba otvorenia suboru
         mov al,00010000b          ; atributy otvorenia suboru
         mov dx,OFFSET subor       ; ktory subor chceme otvorit
         int 21h
         jc _chyba                  ; ak chyba, skok na _chyba
         mov cislo_suboru,ax       ; inak zapis deskriptor suboru
         jmp citaj_znak            ; skok na citaj_znak

_chyba:
         mov dx,OFFSET chyba       ; vypise hlasku o chybe
         mov ah,9
         int 21h

         jmp koniec                ; a skonci

citaj_znak:
         mov ah,3Fh               ; citanie zo suboru
         mov bx,cislo_suboru      ; z tohto ( cislo suboru = deskriptor suboru )
         mov cx,1                 ; kolko bajtov chceme nacitat?  jeden
         mov dx,OFFSET znak       ; znak ulozime do premennej znak
         int 21h
         jc _chyba                ; ak chyba skok na navestie _chyba
         cmp znak,' '             ; ak medzera
         je medzera               ; skok na navestie _medzera
         cmp ax,0                 ; ak EOF (t.j. ak pocet nacitanych bajtov je 0)
         je EOF                   ; skok na navestie EOF
         cmp znak,13              ; enter
         je medzera
         cmp znak,10              ; LF
         je medzera
         ;cmp znak,08              ; backspace
         ;je medzera
         inc sucet
         jmp citaj_znak

medzera:
         cmp sucet,0
         jne medzera2
         jmp citaj_znak

medzera2:
         mov ax,sucet
         xor dx,dx
         mov bx,2
         div bx
         mov sucet,0
         cmp dx,0
         jne citaj_znak

         inc pocet
         jmp citaj_znak

EOF:
         mov ax,sucet
         xor dx,dx
         mov bx,2
         div bx
         cmp dx,0
         jne vypis_text

         inc pocet

vypis_text:
         mov dx,OFFSET vypis      ; vypise hlasku
         mov ah,09h
         int 21h

         mov ax,pocet             ; vypise pocet slov, ktorych sucet ASCII ...
         mov bx,10                ; vypise to desiatkovo
         call premen              ; pouziva sa pri tom procedura premen

         mov dx,offset NEWLINE
         mov ah,09h
         int 21h

         mov dx,OFFSET osem      ; vypise hlasku
         mov ah,09h
         int 21h

         mov ax,pocet             ; vypise pocet slov, ktorych sucet ASCII ...
         mov bx,8                ; vypise to desiatkovo
         call premen              ; pouziva sa pri tom procedura premen

koniec:
         mov ah,3Eh               ; sluzba uzatvorenia suboru
         mov bx,cislo_suboru      ; ktory subor chceme uzatvorit? subor, ktoreho
         int 21h                  ; deskriptor suboru je v cislo_suboru

         mov ax,4c00h             ;exit do DOS-u
         int 21h

end Start














