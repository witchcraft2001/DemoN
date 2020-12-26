;[]=========================================================================[]
;[]                      Сохранение экрана в файл                           []
;[] v0.03 - последние изменения 11.03.2006                                  []
;[]=========================================================================[]
SaveScr:
                ld      bc,1*256+Dss.GetMem
                rst     DssRst                  ;выделение банки памяти
                ret     c                       ;выход с ошибкой
                ld      (.Id),a
                ld      bc,Dss.SetWin3
                rst     DssRst                  ;включение банки в 3-е окно
                ld      (.Id+1),a               ;замещаемая страница
                ld      de,0                    ;позиция на экране
                ld      hl,0xC000
.L1             push    de
                push    hl
                ld      c,Dss.RdChar
                rst     DssRst                  ;считать символ с экрана
                pop     hl
                pop     de
                ld      (hl),a
                inc     hl
                inc     e
                ld      a,e
                cp      0x50                    ;закончилась строка?
                jr      nz,.L1
                ld      bc,0x0D0A               ;конец строки
                ld      (hl),b
                inc     hl
                ld      (hl),c
                inc     hl
                ld      e,0                     ;начало строки
                inc     d
                ld      a,d
                cp      0x20                    ;конец экрана?
                jr      nz,.L1

                ld      hl,.NameF               ;имя файла
                xor     a                       ;атрибут
                ld      c,Dss.Create
                rst     DssRst
                jr      c,.L2                   ;ошибка
                push    af
                ld      hl,0xC000               ;начало записываемой памяти
                ld      de,82*32                ;размер записываемой инфы
                ld      c,Dss.Write
                rst     DssRst                  ;записать
                pop     af
                ld      c,Dss.Close
                rst     DssRst                  ;закрыть файл

.L2             ld      a,(.Id)                 ;id памяти
                ld      c,Dss.FreeMem
                rst     DssRst                  ;освободить память
                ld      a,(.Id+1)
                out     (EmmWin.P3),a           ;востановили банку
                ret
                
.NameF          db      "demon.$$$",0
.Id             ds      2                       ;id выделенного блока

;11:11 18.02.2011 Заглушка Не было исходника :( 
;                include "d:\workast\demon\screen\scrdemon"

