;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Nacitajte z klavesnice retazec znakov ukonceny znakom "novy riadok".
; Nech slovo je postupnost znakov medzi 2 znakmi "medzera".
; Urcte pocet slov obsahujucich len pismena malej abecedy.
; Pocet vytlacte sestnastkovo.
;
; Autor: LALA -> lala (at) linuxor (dot) sk
; Datum: 11.12.2002
;
; Subor: lala.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model small
.stack 100
.data
pocet dw 0
priznak db 0
NL db 13,10,"$"
hlaska db "Pocet slov obsahujucich len pismena malej abecedy je: $"
hlaska2 db "Pocet vyjadreny ako sestnastkove cislo: $"
.code

Start:
      mov ax,@data           ; zistime kde su data a
      mov ds,ax              ; ulozime si ich do segmentoveho registra

reset:
      mov bx,0               ; vynuluje bx  ;; v bx je pocet znakov v slove
      mov priznak,0          ; a priznak
citaj:
      mov ah,1               ; sluzba nacita a zaroven vypise znak
      int 21h

      cmp al,' '             ; nacitany znak porovname zo znakom medzera
      je space               ; ak sa zhoduje skok na navestie space
      cmp al,13              ; nacitany znak porovname zo znakom "novy riadok"
      je last                ; ak sa zhoduje skok na navestie last
      cmp al,'a'             ; porovnaj znak zo znakom 'a'
      jb zle                 ; ak 'a' je vacsie ako al skok na navestie zle
      cmp al,'z'             ; porovnaj znak zo znakom 'z'
      ja zle                 ; ak al je vacsie ako 'z' skok na navestie zle
      cmp priznak,2          ; porovnaj priznak a 2
      je citaj               ; ak sa zhoduju skok na citaj
      mov priznak,1          ; inac do priznaku daj 1
      inc bx                 ; inkrementujeme bx ( pocet znakov v slove )
      jmp citaj              ; skok na citaj
zle:
      mov priznak,2          ; do priznaku daj 2
      inc bx                 ; inkrementujeme bx ( pocet znakov v slove )
      jmp citaj              ; skok na citaj
space:
      cmp bx,0               ; porovname bx a 0
      je  reset              ; ak sa zhoduju skok na reset
      cmp priznak,1          ; porovnaj priznak a 1
      ja reset               ; ak je priznak vacsi ako 1 skok na citaj
      inc pocet              ; inac zvys pocet o 1
      jmp reset              ; skok na citaj
last:
      cmp bx,0               ; porovname bx a 0
      je  vypis              ; ak sa zhoduju skok na vypis
      cmp priznak,1          ; porovnaj priznak a 1
      ja vypis               ; ak je priznak vacsi ako 1 skok na vypis
      inc pocet              ; zvys pocet o 1

vypis:
      mov ah,09h             ; sluzba vypisujuca retazec
      mov dx,OFFSET NL       ; do dx dame retazec ktory chceme vypisat
      int 21h

      mov ah,09h
      mov dx,OFFSET hlaska
      int 21h

      mov ax,pocet          ; do ax dame cislo ktore chceme vypisat
      mov bx,10             ; do bx sustavu v ktorej chceme aby to vypisalo
      call premen           ; volanie funkcie ktora zabezpeci vypis

      mov ah,09h
      mov dx,OFFSET NL
      int 21h

      mov ah,09h
      mov dx,OFFSET hlaska2
      int 21h

      mov ax,pocet
      mov bx,16
      call premen
koniec:
      mov ax,4c00h             ;exit do DOS-u
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
