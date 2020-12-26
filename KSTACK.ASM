;[]=========================================================================[]
;[]               Обработка клавиатуры в окне дампа стека                   []
;[] v0.10 - последние изменения 18.03.2006                                  []
;[]=========================================================================[]
KStack:
                ld      a,b                     ;состояние <Shift><Alt><Ctrl>
                and     11110000b
;                ld      b,a
                jr      z,.L100

                ;Обработка комбинации Shift + символ
;                and     11000000b              ;<Shift>
;                or      a
;                jr      z,.L10
;                ld      a,d
;;                cp      0x80+0x0F               ;Shift+Tab
;;                jp      nz,Keyb+6
;;                ld      a,3                     ;номер окна дампа
;;                ld      (Keyb.WinScreen),a
;                jp      Keyb-3

                ;Обработка комбинации Ctrl + символ
;                ld      a,b
                cp      00100000b              ;<Ctrl>
                jp      nz,Keyb+6
                ld      a,d                     ;позиционный код
                cp      0x80+0x2B               ;<Ctrl>+<X>
                jp      nz,Keyb+6
                ld      hl,(StackDump)
                ld      bc,(.Coordinate)
                ld      a,b
                ld      b,0x16                  ;x-кордината 1 строки
                sub     b
                rlca                            ;*2
                ld      b,0
                ld      c,a
                or      a
                sbc     hl,bc
                ld      (Reg._SP),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a
                jp      Keyb-11

                ;Обработка позиционного кода
.L100           ld      a,e                     ;ASCII код
                ld      (.L200+1),a
                ld      a,d                     ;позиционный код

                ld      de,(.Coordinate)        ;текущие координаты курсора
                cp      0x56                    ;<Right>
                jr      nz,.L101
                ld      a,(.Descript+2)         ;кол-во колонок
                cp      e
                ld      a,e
                jr      nz,$+3
                xor     a
                inc     a
                ld      (.Coordinate),a         ;текущая колонка
                jp      Keyb-3

.L101           cp      0x54                    ;<Left>
                jr      nz,.L102
                ld      a,e                     ;текущая колонка
                cp      1
                jr      nz,$+6
                ld      a,(.Descript+2)         ;кол-во колонок
                inc     a
                dec     a
                ld      (.Coordinate),a         ;текущая колонка
                jp      Keyb-3

.L102           ld      hl,(.Descript)
                cp      0x52                    ;<Down>
                jr      nz,.L103
                ld      a,d                     ;текущая строка
                cp      l
                jr      nz,.L104
                ld      hl,(StackDump)          ;адрес 1-ой строки
                dec     hl
                dec     hl
                ld      (StackDump),hl
                ld      hl,PrintStrSP.StrSp     ;строка верш.стека
                ld      a,-1
                cp      (hl)                    ;в дампе?
                jr      z,$+3
                dec     (hl)
                jp      Keyb-11
.L104           inc     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L103           cp      0x58                    ;<Up>
                jr      nz,.L105
                ld      a,d                     ;текущая строка
                cp      h
                jr      nz,.L107
                ld      hl,(StackDump)          ;адрес 1-ой строки
                inc     hl
                inc     hl
                ld      (StackDump),hl
                ld      hl,PrintStrSP.StrSp     ;строка верш.стека
                ld      a,(hl)
                cp      7                       ;на последней строке?
                jr      c,$+5
                ld      a,-2
                ld      (hl),a                  ;верш.стека не попадает в дамп
                inc     (hl)
                jp      Keyb-11
.L107           dec     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L105           cp      0x53                    ;<PgDown>
                jr      nz,.L108
                ld      a,d                     ;текущая строка
                cp      l
                jr      nz,.L106
                ld      hl,(StackDump)
                ld      bc,2*7
                or      a
                sbc     hl,bc
                ld      (StackDump),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a    ;строка верш.стека
                jp      Keyb-11
.L106           ld      a,l                     ;на последнюю строку
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L108           cp      0x59                    ;<PgUp>
                jr      nz,.L110
                ld      a,d                     ;текущая строка
                cp      h
                jr      nz,.L109
                ld      hl,(StackDump)
                ld      bc,2*7
                add     hl,bc
                ld      (StackDump),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a    ;строка верш.стека
                jp      Keyb-11
.L109           ld      a,h                     ;на первую строку
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L110           cp      0x57                    ;<Home>
                jr      nz,.L200
                ld      a,6
                ld      (PrintStrSP.StrSp),a    ;строка верш.стека
                jp      Keyb-11

;.L111           cp      0x0F                    ;<Tab>
;                jr      nz,.L200
;                ld      a,1                     ;номер окна листинга
;                ld      (Keyb.WinScreen),a
;                jp      Keyb-3

                ;Обработка ASCII кодов
.L200           ld      a,0                     ;ASCII код
                cp      0x0D                    ;<Enter>
                jp      nz,Keyb+6
.L201           ld      b,0                     ;длина строки ввода
                ld      hl,0                    ;координаты строки ввода
                call    InputLine               ;ввод числа
                jp      c,Keyb-3                ;завершение ввода по <ESC>
                call    PutAdres
                jp      c,.L201                 ;ошибка в веденных данных
                ld      bc,(.Coordinate)
                ld      a,b
                ld      b,0x16                  ;x-кордината 1 строки
                sub     b
                ex      de,hl
                ld      hl,(StackDump)
                ld      b,a                     ;номер строки 0..7
                rlca                            ;*2
                dec     c
                ld      c,a
                jr      nz,.L202                ;переход - если данные, иначе алрес

                ld      a,(PrintStrSP.StrSp)    ;строка верш.стека
                cp      b
                jr      z,.L203
                ld      b,0                     ;не на вершине стека
                ex      de,hl                   ;HL - введенный адрес
                add     hl,bc
                ld      (StackDump),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a
                jr      .L203+4
.L203           ld      (Reg._SP),de            ;адрес введен на вершине стека
                jp      Keyb-11

.L202           ld      b,0                     ;ввод данных
                or      a
                sbc     hl,bc
                ld      a,d                     ;запись данных в память
                call    Ld_hl_a
                inc     hl
                ld      a,e
                call    Ld_hl_a
                jp      Keyb-11


.Coordinate     dw      0x1601                  ;курсор (стр/кол курсора)
.Descript:
                dw      0x161D                  ;первая/последняя строка окна
                db      2                       ;кол-во колонок

                db      0x01                    ;N столбца колонки
                db      5                       ;ширина колонки
                db      0x07,5

