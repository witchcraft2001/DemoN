;[]=========================================================================[]
;[]                             Вывод часов                                 []
;[] v0.03 - последние изменения 01.02.2006                                  []
;[]=========================================================================[]
Clock:
                ld      a,(ClockOn)             ;флаг вывода часов
                inc     a
                ret     nz
                ld      c,Dss.SysTime
                rst     DssRst                  ;прочитать данные о времени
                ld      de,.String
                push    de
                push    bc
                push    hl
                ld      l,h                     ;часы
                ld      h,0
                call    ConvDecStr8_1
                inc     de
                pop     hl                      ;минуты
                ld      h,0
                call    ConvDecStr8_1
                inc     de
                pop     hl
                ld      l,h                     ;секунды
                ld      h,0
                call    ConvDecStr8_1
                ld      de,71
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                rst     BiosRst : di
                pop     hl
                ld      bc,8*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                rst     BiosRst : di
                ret

.String         db      "00:00:00"

