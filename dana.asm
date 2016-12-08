;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte zo suboru retazec znakov ukonceny znakom "konca suboru".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Urcte pocet slov, v ktorych sucet ASCII kodov je vacsi ako 100.
; Pocet vytlacit desiatkovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 8.12.2002
;
; Subor: dana.asm
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
hlaska db "Pocet slov ktorych sucet ASCII kodov je vacsi ako 100 je:$"
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
      mov ax,@data               ; zistime kde su data
      mov ds,ax                  ; a ulozime si ich do segmentoveho registra

; otvorenie suboru
      mov ah,3Dh                ; sluzba otvorenia suboru
      mov al,00010000b          ; atributy otvorenia suboru
      mov dx,OFFSET subor       ; ktory subor chceme otvorit
      int 21h
      jc _chyba                 ; ak chyba, skok na _chyba
      mov cislo_suboru,ax       ; inak zapis deskriptor suboru
      jmp _citaj_znak           ; skok na _citaj_znak

_chyba:
      mov dx,OFFSET chyba       ; vypise hlasku o chybe
      mov ah,9
      int 21h

      jmp koniec                ; a skonci

_citaj_znak:
       mov ah,3Fh               ; citanie zo suboru
       mov bx,cislo_suboru      ; z tohto ( cislo suboru = deskriptor suboru )
       mov cx,1                 ; kolko bajtov chceme nacitat?  jeden
       mov dx,OFFSET znak       ; znak ulozime do premennej znak
       int 21h
       jc _chyba                ; ak chyba skok na navestie _chyba
       cmp znak,' '             ; ak medzera
       je _medzera              ; skok na navestie _medzera
       cmp ax,0                 ; ak EOF (t.j. ak pocet nacitanych bajtov je 0)
       je _EOF                  ; skok na navestie koniec
       mov dh,0
       mov dl,znak
       add sucet,dx             ; pripocitaj ASCII hodnotu znaku k celkovemu
                                ; suctu slova
       jmp _citaj_znak

_medzera:
       cmp sucet,100            ; porovnaj sucet ASCII kodov slova a 100
       jg _pripocitaj           ; ak sucet je vacsi tak skok na _pripocitaj
       mov sucet,0              ; vynuluj sucet
       jmp _citaj_znak          ; skok na _citaj_znak

_EOF:
       cmp sucet,100            ; porovnaj sucet ASCII kodov slova a 100
       jg _pripocitaj_EOF       ; ak sucet je vacsi tak skok na _pripocitaj_EOF
       jmp _vypis_hlasku

_pripocitaj:
       inc pocet                ; zvys pocet o 1
       mov sucet,0              ; vynuluj sucet
       jmp _citaj_znak          ; skok

_pripocitaj_EOF:
       inc pocet                ; zvys pocet o 1

_vypis_hlasku:
       mov dx,OFFSET hlaska     ; vypise hlasku
       mov ah,09h
       int 21h

       mov ax,pocet             ; vypise pocet slov, ktorych sucet ASCII ...
       mov bx,10                ; vypise to desiatkovo
       call premen              ; pouziva sa pri tom procedura premen

koniec:
       mov ah,3Eh               ; sluzba uzatvorenia suboru
       mov bx,cislo_suboru      ; ktory subor chceme uzatvorit? subor, ktoreho
       int 21h                  ; deskriptor suboru je v cislo_suboru

       mov ax,4c00h             ;exit do DOS-u
       int 21h

end Start