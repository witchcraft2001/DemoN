;[]=========================================================================[]
;[]                Файловые процедуры монитора-отладчика DemoN              []
;[] v0.10 - последние изменения 27.08.2006                                  []
;[]=========================================================================[]
LoadFile:
                xor     a                       ;выкл часов
                ld      (ClockOn),a
                ld      bc,0x0100+Dss.SelPage   ;системный экран
                rst     DssRst

                ld      hl,Str.Load             ;сообщение о загрузке файла
                ld      c,Dss.PChars
                rst     DssRst

                call    LoadExe

                ld      a,(DemonScreen)
                ld      b,a
                ld      c,Dss.SelPage
                rst     DssRst
                ld      a,On                    ;вкл часов
                ld      (ClockOn),a
                ret

LoadExe:
                ld      hl,FDebug               ;имя файла
                ld      a,1                     ;открыть для чтения
                ld      c,Dss.Open
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                ld      (FId),a                 ;запомнить файловый манипулятор

                ld      hl,FDebug               ;буфер для загрузки заголовка
                ld      de,0x7F                 ;кол-во считываемых байт
                ld      c,Dss.Read              ;чтение
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                ld      hl,(FDebug)             ;заголовок EXE-файла
                ld      de,0x5845               ;'EX' проверка идентификатора
                sbc     hl,de
                jr      nz,.L1
                ld      hl,FDebug+3
                ld      a,(hl)                  ;версия EXE-файла
                or      a
                jr      nz,.L1
                inc     hl
                ld      e,(hl)                  ;начало исполняемого кода
                inc     hl
                ld      d,(hl)
                ld      bc,11                   ;пропускаем флаг загрузчика и зарезервированные байты
                add     hl,bc
                ld      a,(hl)                  ;мл.байт расположения кода в памяти
                ld      (FRam),a
                inc     hl
                ld      a,(hl)                  ;ст.байт расположения кода в памяти
                ld      (FRam+1),a
                inc     hl
                ld      a,(hl)                  ;мл.байт адреса запуска
                ld      (Reg._PC),a
                ld      (ListAdr),a             ;мл.байт адреса листинга
                inc     hl
                ld      a,(hl)                  ;ст.байт адреса запуска
                ld      (Reg._PC+1),a
                ld      (ListAdr+1),a           ;ст.байт адреса листинга
                inc     hl
                ld      a,(hl)                  ;мл.байт стека программы
                ld      (Reg._SP),a
                inc     hl
                ld      a,(hl)                  ;ст.байт стека программы
                ld      (Reg._SP+1),a
                ld      a,e
                ld      (.L2+2),a
                ld      a,d
                ld      (.L2+3),a

.L1             ld      hl,0
                ld      ix,0                    ;смещение в файле
                ld      bc,2*256+Dss.Move_FP    ;относительно конца
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                push    hl
                ld      de,(FRam)               ;адрес расположения кода
                set     6,d
                res     7,d                     ;грузим через 1-е окно
                ld      hl,0x8000
                or      a                       ;сбросить флаг C
                sbc     hl,de                   ;кол-во считываемых байт
                ld      (.L6+1),hl
                ex      de,hl
                ld      (.L6+4),hl
                pop     hl
                call    NBank                   ;определить кол-во банок
                jp      c,PrErDss               ;выход с ошибкой

                ld      (MemId+1),a             ;кол-во выделяемых страниц
                ld      b,a
                ld      c,Dss.GetMem            ;выделение памяти
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой
                ld      (MemId),a               ;id блока памяти

                ld      a,(FId)                 ;файловый манипулятор
                ld      hl,0
.L2             ld      ix,0                    ;смещение в файле
                ld      bc,Dss.Move_FP          ;относительно начала
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                ld      a,(MemId)               ;id блока памяти
                ld      bc,Dss.SetWin1          ;вкл 1-ю банку в 1-е окно
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

.L6             ld      de,0x3FFF               ;кол-во считываемых байт
                ld      hl,0x4000               ;адрес загрузки кода
                ld      a,1                     ;счетчик банок
                ld      (MemId+2),a
.L5             ld      a,(FId)                 ;файловый манипулятор
                ld      c,Dss.Read              ;чтение
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                ld      bc,(MemId+1)
                ld      a,b
                cp      c                       ;загрзили весь файл?
                jr      z,.L4                   ;переход, если да

                inc     a
                ld      (MemId+2),a             ;увеличить счетчик банок
                ld      a,(MemId)               ;id блока памяти
                ld      c,Dss.SetWin1           ;вкл банку в 1-е окно
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                ld      hl,0x4000               ;адрес в памяти для загрузки
                ld      de,0x3FFF               ;кол-во загружаемых байт
                jr      .L5

.L4             ld      a,(FId)                 ;файловый манипулятор
                ld      c,Dss.Close             ;закрыть файл
                rst     DssRst
                jp      c,PrErDss               ;выход с ошибкой

                ld      a,(MemId)               ;id блока памяти
                ld      bc,Bios.Emm_Fn4         ;вычислить физ номер 1-й банки
                rst     BiosRst
                ret     c                       ;выход с ошибкой
                ld      (BankP),a
                ld      a,(MemId+1)             ;кол-во выделенных страниц
                dec     a
                jr      z,.L7

                ld      a,(MemId)               ;id блока памяти
                ld      bc,1*256+Bios.Emm_Fn4   ;вычислить физ номер 2-й банки
                rst     BiosRst
                ret     c                       ;выход с ошибкой
                ld      (BankP+1),a
                ld      a,(MemId+1)             ;кол-во выделенных страниц
                cp      2
                jr      z,.L7

                ld      a,(MemId)               ;id блока памяти
                ld      bc,2*256+Bios.Emm_Fn4   ;вычислить физ номер 3-й банки
                rst     BiosRst
                ret     c                       ;выход с ошибкой
                ld      (BankP+2),a
                ld      a,(MemId+1)             ;кол-во выделенных страниц
                cp      3
                jr      z,.L7

                ld      a,(MemId)               ;id блока памяти
                ld      bc,3*256+Bios.Emm_Fn4   ;вычислить физ номер 4-й банки
                rst     BiosRst
                ret     c                       ;выход с ошибкой
                ld      (BankP+3),a

.L7             ld      hl,WinPage
                ld      de,BankP
                ld      a,(MemId+1)             ;кол-во выделенных страниц
                ld      b,a
                cp      5
                jr      c,$+4
                ld      b,4                     ;подключаем не более 4 банок
                ld      a,(FRam+1)              ;ст.адрес расположения кода
                and     0xC0                    ;окно с расположением кода
                or      a                       ;0-е окно
                jr      nz,.L8
                ld      c,a
                ld      a,(de)
                ld      (hl),a                  ;подключить банку программы
                dec     b
                ret     z                       ;выход, если больше нет банок

                ld      a,c
                inc     de
.L8             inc     hl
                cp      0x40                    ;1-е окно
                jr      nz,.L9
                ld      c,a
                ld      a,(de)
                ld      (hl),a                  ;подключить банку программы
                dec     b
                ret     z                       ;выход, если больше нет банок

                ld      a,c
                inc     de
.L9             inc     hl
                cp      0x80                    ;2-е окно
                jr      nz,.L10
                ld      c,a
                ld      a,(de)
                ld      (hl),a                  ;подключить банку программы
                dec     b
                ret     z                       ;выход, если больше нет банок

                ld      a,c
                inc     de
.L10            inc     hl                      ;иначе 3-е окно
                ld      a,(de)
                ld      (hl),a                  ;подключить банку программы

                ret

;[]=========================================================================[]
;[]   Вычисление необходимого кол-ва банок для загрузки файла в память      []
;[] Вход:  HL:IX - длина файла в байтах                                     []
;[]        DE - кол-во байт для загрузки в 1-ю банку                        []
;[] Выход: A - кол-во необходимых банок                                     []
;[]        флаг C - ошибка, код ошибки в A                                  []
;[]=========================================================================[]
NBank:
                push    ix
                ld      b,h
                ld      c,l
                pop     hl
                inc     bc
                xor     a
                inc     a
                sbc     hl,de
                jr      nc,$+4
                jr      .L5
                ld      de,16384                ;размер банки
                push    af
.L2             pop     af
.L1             inc     a
                jr      z,.L3
                sbc     hl,de
                jr      nc,.L1
.L5             dec     bc
                push    af
                ld      a,b
                or      c
                jr      nz,.L2
                pop     af
                or      a                       ;сбросить флаг C
                ret

.L3             ld      a,0x1E                  ;"Недостаточно памяти"
;                JP      ErrorDSS
                ret

BankP           ds      4                       ;номера банок загружаемой проги
MemId           ds      3                       ;id-блока памяти под файл,
                                                ;кол-во выделенных банок,
                                                ;счетчик загруженных банок
FId             db      0                       ;файловый манипулятор
FDebug          ds      128
                db      0
FStart          dw      0x4200
FRam            dw      0                       ;адрес расположения кода в памяти

