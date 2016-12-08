;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte z klavesnice retazec znakov ukonceny znakom "novy riadok".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Urcte pocet znakov velkej abecedy a slovo s maximálnym poctom tychto znakov.
; Pocet vypiste sestnastkovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 18.12.2002
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Princip:
;
;Program cita z klavesnice vzdy jeden znak. Ak nevlozil medzeru, alebo ENTER,
;tak sa znak ulozi do 'pole' a skontroluje ci je znak velky.
;V pripade ze dal medzeru, skontroluje ci pocet velkych pismen v tomto slove
;je >= ako doterajsi maximalny pocet velkych pismen v niektorom z predchadzajucich
;slov. Ak ano, tak dane slovo ulozi do pola 'najviac' a ulozi si maximalny pocet
;velkych pismen v jednom slove.
;V pripade ze dal ENTER je postup taky isty, len sa nastavi priznak na 1, co
;znamena ze treba skoncit ;)



.model small
.stack 100
.data
NL db 13,10,'$'            ;znak noveho riadku
pole db 100 dup ( '$' )    ;tu sa uklada prave nacitavane slovo
najviac db 100 dup ( '$' ) ;tu sa ulozi slovo s najvacsim poctom velkych znakov
pocet dw 0                 ;pocitanie velkych znakov
pocetVSlove dw 0           ;pocitanie velkych znakov v tomto slove
maxPocetVSlove dw 0        ;najvacsi pocet velkych znakov v urcitom slove
priznak db 0               ;priznak sa nastavi na 1 ak dal enter => treba skoncit
.code

velkyZnak PROC NEAR    ;procedura zisti, ci v al je velky znak. Ak ano, tak zvysi pocet o jeden

      cmp al,65                          ;porovnanie al s ascii kodom znaku A
      jb return1                         ;ak je menej, tak to velky znak nie je
      cmp al,90                          ;porovnanie al s ascii kodom znaku Z
      ja return1                         ;ak je viac, tak to velky znak nie je
      inc pocet                          ;zvysi pocitadlo o jeden
      inc pocetVSlove                    ;tiez zvysi pocet velkych znakov v tomto slove
return1:
      ret
velkyZnak ENDP

prepis PROC NEAR    ;procedura skopiruje slovo z 'pole' do 'najviac'

      mov al,'$'           ;na posledny znak pola 'pole' sa musi dat $,
      mov [si]+bx,al       ;aby som vedel kde je koniec slova
      mov bx,0             ;bx sa nastavi na 0
loo2:
      mov al,[si]+bx       ;do al daj bx-tí prvok pola 'pole'
      cmp al,'$'           ;ak je v al $ => koniec slova
      je return2
      mov [di]+bx,al       ;uloz znak do pola 'najviac', na index bx
      inc bx               ;posun sa na dalsi znak
      jmp loo2

return2:
      mov al,'$'           ;ukonci slovo v poli 'najviac' znakom $ (koniec retazca)
      mov [di]+bx,al
      ret
prepis ENDP

Start:

      mov ax,@data
      mov ds,ax
      mov si,OFFSET pole     ;si sa bude pouzivat na pracu s polom (indexaciu)
      mov di,OFFSET najviac  ;to iste s di a polom 'najviac'
loo:

      mov ah,01h            ;nacita znak z klavesnice (ulozi ho do al) a zaroven vypise na obrazovku
      int 21h

      cmp al,' '                  ;ak je vlozeny znak medzera
      je vyhodnotSlovo            ;skoc na vyhodnotSlovo

      cmp al,13                   ;ak je vlozeny znak "ENTER"
      je vyhodnotSlovo_koniec     ;skoc na ...

      call velkyZnak
      mov [si]+bx,al              ;do 'pole' sa ulozi nacitany znak na poziciu bx
      inc bx                      ;pocitanie znakov v tomto slove (vsetkych znakov)
      jmp loo

vyhodnotSlovo_koniec:
      mov priznak,1              ;nastavi priznak na 1, aby som vedel ze treba skoncit
vyhodnotSlovo:
      cmp bx,0                   ;ak slovo ma 0 znakov
      je reset                   ;tak sa resetni
      cmp pocetVSlove,0          ;ak je pocet velkych znakov v tomto slove 0
      je reset                   ;tak sa resetni
      mov ax,pocetVSlove
      cmp ax,maxPocetVSlove      ;porovnaj pocetVSlove, maxPocetVSlove (pocetVSlove je teraz v AX)
      jb reset                   ;ak je pocetVSlove < maxPocetVSlove tak skoc na reset (pocet
                                 ;velkych znakov v tomto slove < pocet velkych znakov v nejakom predchadzajucom slove)
      call prepis                ;inac zavolaj prepis
      mov ax,pocetVSlove
      mov maxPocetVSlove,ax      ;uloz si maximalny pocet velkych znakov v jednom slove
reset:
      mov pocetVSlove,0          ;vynuluje pocet velkych znakov v slove (ide dalsie slovo)
      mov bx,0                   ;vynuluje bx (aby sa znaky zase davali od zaciatku pola)
      cmp priznak,1              ;ak priznak je 1 => treba skoncit
      je koniec
      jmp loo                    ;inac nacitavaj dalsie znaky

koniec:
       call novyRiadok            ;vypise znaky noveho riadku

       ;ak nechces pouzit proceduru premen, tak namiesto tych 3 riadkov daj svoj kod
       mov ax,pocet
       mov bx,16
       call premen

       call novyRiadok

       mov dx,OFFSET najviac       ;vypise pole najviac na obrazovku
       mov ah,9
       int 21h

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

;procedura vypise znak noveho riadku na obrazovku
novyRiadok  proc near
       mov dx,OFFSET NL
       mov ah,9
       int 21h
       ret
novyRiadok endp


end Start