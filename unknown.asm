;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte zo suboru retazec znakov ukonceny znakom "konca suboru".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Vytlacte subor opacne.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 26.12.2002
;
; Subor: unknown.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
subor db 'subor.txt',0             ; subor z ktoreho budeme citat
cislo_suboru dw ?                  ; deskriptor suboru
znak db ?                          ; buffer pre znak
pocet dw 0                         ; bude obsahovat pocet znakov v subore
chyba db "Chyba$"
nl db 13,10,"$"
.code

Start:
       mov ax,@data                      ; zistime kde su data a
       mov ds,ax                         ; ulozime si ich adresu do segmentoveho
                                        ; registra
; otvorenie suboru
       mov ah,3dh                        ; otvorenie suboru
       mov al,00010000b                  ; atributy otvorenia suboru
       mov dx,OFFSET subor               ; ktory subor?
       int 21h
       jc error                          ; ak chyba skok na _chyba
       mov cislo_suboru,ax               ; inak uloz deskriptor suboru
       jmp getch                         ; skok na getch

error:
       mov dx,OFFSET chyba              ; vypise ze nastala chyba
       mov ah,9                         ; sluzba vypise retazec
       int 21h

       jmp ende                         ; skok na _EOF

getch:
       mov ah,3fh                       ; sluzba citanie zo suboru
       mov bx,cislo_suboru              ; z tohto suboru sa bude citat
       mov cx,1                         ; kolko bajtov? 1 bajt = 1 znak
       mov dx,OFFSET znak               ; a ulozime si ho do premennej znak
       int 21h
       jc error                         ; ak chyba

       cmp ax,0                         ; ak koniec suboru
       je vypis                        ; skok na navestie vypis
       inc pocet                        ; inak inkrementuj pocet

       jmp getch                        ; skok na navestie getch

vypis:
       dec pocet                        ; dekrementuj pocet
       mov ah,42h                       ; sluzba nastavenia pozicie v subore
       mov al,0                         ; od zaciatku
       mov bx,cislo_suboru              ; ktory subor? subor,ktoreho deskriptor
                                        ; je v cislo_suboru
       mov cx,0                         ; o kolko chceme posunut?
       mov dx,pocet                     ; o pocet
       int 21h
       jc error                         ; ak chyba skok na error

       mov ah,3fh                       ; sluzba citanie zo suboru
       mov bx,cislo_suboru              ; z tohto suboru sa bude citat
       mov cx,1                         ; kolko bajtov? 1 bajt = 1 znak
       mov dx,OFFSET znak               ; a ulozime si ho do premennej znak
       int 21h
       jc error                         ; ak chyba skok na error

       mov ah,02h                       ; sluzba ktora vypise znak
       mov dl,znak                     ; do dl si dame znak ktory chceme vypisat
       int 21h

       cmp pocet,0                      ; porovname pocet a 0
       je ende                          ; ak nula skok na _EOF
       jmp vypis                        ; inak skok na vypis

ende:
       mov ah,3Eh               ; sluzba uzatvorenia suboru
       mov bx,cislo_suboru      ; ktory subor chceme uzatvorit? subor, ktoreho
       int 21h                  ; deskriptor suboru je v cislo_suboru

       mov ax,4c00h             ;exit do DOS-u
       int 21h

end Start