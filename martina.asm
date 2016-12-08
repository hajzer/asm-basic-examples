;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte z klavesnice retazec znakov ukonceny znakom "novy riadok".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Vytlacte slova ako reverzne.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 30.11.2002
;
; Subor: martina.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data

NL db 13,10,'$'
pole db 500 dup ( '$' )
pole2 db 500 dup ( '$' )

priznak dw 1
string db 13,10,"Slova vypisane opacne: ",13,10,'$'
.code

pridaj_medzeru PROC NEAR    ;procedura prida medzeru do 'pole2'

      mov al,' '
      mov [di],al
      inc di          ;di sa samozrejme zvysi
      ret

pridaj_medzeru ENDP

Start:

      mov ax,@data
      mov ds,ax

      mov si,OFFSET pole      ;si sa bude pouzivat na pracu s polom (indexaciu)
      mov di,OFFSET pole2     ;di sa bude pouzivat na pracu s polom2 (indexaciu)
      jmp loo

loo_backspace:
      dec bx
      jmp loo

loo_medzera:
      call pridaj_medzeru

loo:

      mov ah,01h            ;nacita znak z klavesnice (ulozi ho do al) a zaroven vypise na obrazovku
      int 21h

      cmp al,' '            ;ak je vlozeny znak medzera
      je  reverz_conf       ;pokracuj reverz_conf
      cmp al,13             ;ak je vlozeny znak "ENTER"
      je reverz_conf2       ;pokracuj reverz_conf2
      cmp al,8              ;ak je vlozeny znak "BACKSPACE"
      je loo_backspace      ;vrat sa naspat
      mov [si]+bx,al        ;do 'pole' sa ulozi nacitany znak
      inc bx                ;bx sluzi na pocitanie znakov v tomto slove
      jmp loo

reverz_conf2:

      mov priznak,0         ;priznak sa nastavi na 0 aby program po otoceni posledneho slova skoncil
      cmp bx,0              ;ak dal enter a slovo ma 0 znakov, skonci bez reverzie
      je koniec

reverz_conf:

       cmp bx,0             ;ak dal medzeru a slovo ma 0 znakov, tak sa vrat naspat bez reverzie
       je loo_medzera       ;a pridaj medzeru
       mov al,[si]+bx-1     ;do al sa ulozi posledny znak z 'pole'
       mov cx,bx            ;cx sa nastavi podla poctu nacitanych znakov

reverz:

       mov [di],al          ;uloz ho do 'pole2' na index di

       inc di               ;ukazovatel sa musi zvysit

       mov bx,cx            ;
       mov al,[si]+bx-2     ;

       loop reverz          ;pokracuj az po nulty znak pola (az kym cx=0)

       cmp priznak,0          ;ak je priznak nastaveny na 0, tak
       je koniec              ;skonci

       call pridaj_medzeru

       mov bx,0
       jmp loo

koniec:
       mov dx,OFFSET NL        ;vypise znak noveho riadku
       mov ah,9
       int 21h

       mov dx,OFFSET string    ;vypise retazec 'string'
       mov ah,9
       int 21h

       mov dx,OFFSET pole2     ;vypise vysledne pole2
       mov ah,9
       int 21h

       mov ax,4c00h            ;vystup do DOS-u
       int 21h

end Start