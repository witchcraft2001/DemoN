;[]=========================================================================[]
;[]                       Отладка команд программы                          []
;[] v0.03 - последние изменения 10.03.2006                                  []
;[] v0.10 - последние изменения 18.03.2006                                  []
;[]=========================================================================[]
Step:
                di
                ld      a,(WinPage+2)           ;банка под demon'ом
                ld      (Rezident.Start1+1),a   ;в резидент ее
                ld      (.BankP+1),a
                ld      a,(BankDebug)           ;банка с demon'ом
                ld      (Rezident.BankD+1),a    ;в резидент ее
                ld      (Rezident.BankD1+2),a
                ld      hl,Step.Run+3           ;точка возврата в отладчик
                ld      (Rezident.Return+1),hl  ;прописываем в резиденте
                ld      a,l
                ld      (Rezident.Return1+2),a
                ld      a,h
                ld      (Rezident.Return1+7),a
                ld      hl,(Reg._PC)
                ld      (Rezident.Step+1),hl    ;адрес отлаживаемой команды

                ld      a,(Reg._AF)             ;флаг
                ld      b,a
                call    Ld_a_hl
;                ld      a,(hl)                  ;код команды

                ld      c,a
                and     11001111b
                cp      11000101b              ;PUSH
                call    z,.SpdInc
                cp      11000001b              ;POP
                call    z,.SpdDec

                ld      a,c
                cp      0xCD                    ;CALL
                jr      nz,.L7
                ld      a,(.Flag)
                inc     a
                jp      nz,.L2                  ;без захода в подпрограмму
                jp      .L8
.L7             cp      0xC9                    ;RET
                jp      z,.L9
                cp      0xC3                    ;JP
                jp      z,.L8+3
                cp      0x18                    ;JR
                jp      z,.L6
                cp      0x10                    ;DJNZ
                jr      nz,.L18
                ld      a,(.Flag)
                inc     a
                jp      nz,.L2                  ;без отладки цикла
                ld      a,(Reg._BC+1)
                dec     a
                jr      nz,.L6
                jp      .L2
.L18            inc     hl                      ;следующий байт соманды
                exa
                call    Ld_a_hl
                ld      c,a
                exa
;                ld      c,(hl)
                dec     hl
                cp      0xED                    ;префикс для RETI, RETN
                jr      nz,.L10
                ld      a,c
                cp      0x4D                    ;RETI
                jp      z,.L9
                cp      0x45                    ;RETN
                jp      z,.L9
.L10            cp      0xDD                    ;префикс для IX
                jr      nz,.L25
                ld      a,c
                cp      0xE5                    ;PUSH IX
                call    z,.SpdInc
                cp      0xE1                    ;POP IX
                call    z,.SpdDec
                ld      de,(Reg._IX)
                jr      .L24
.L25            cp      0xFD                    ;префикс для IY
                jr      nz,.L24-4
                ld      a,c
                cp      0xE5                    ;PUSH IY
                call    z,.SpdInc
                cp      0xE1                    ;POP IY
                call    z,.SpdDec
                ld      de,(Reg._IY)
                jr      .L24
                ld      de,(Reg._HL)
.L24            cp      0xE9                    ;JP (HL/IX/IY)
                jr      nz,.L23
                ex      de,hl
                jp      .L2+3
.L23            cp      0x38                    ;JR C,
                jr      nz,.L19
                bit     0,b                     ;флаг C
                jp      z,.L2                   ;нет перехода
                jr      .L6                     ;переход
.L19            cp      0x30                    ;JR NC,
                jr      nz,.L20
                bit     0,b                     ;флаг C
                jp      nz,.L2                  ;нет перехода
                jr      .L6                     ;переход
.L20            cp      0x28                    ;JR Z,
                jr      nz,.L21
                bit     6,b                     ;флаг Z
                jp      z,.L2                   ;нет перехода
                jr      .L6                     ;переход
.L21            cp      0x20                    ;JR NZ,
                jr      nz,.L22
                bit     6,b                     ;флаг Z
                jp      nz,.L2                  ;нет перехода

.L6             inc     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;смещение
                inc     hl
                ld      b,0
                ld      c,a
                bit     7,a                     ;знак числа
                jr      z,$+11
                neg
                or      a                       ;сброс флага C
                ld      c,a
                sbc     hl,bc                   ;отрицательное смещение
                jp      .L2+3
                add     hl,bc                   ;положительное смещение
                jp      .L2+3

.L22            and     11000111b
                cp      11000111b              ;RST x
                jr      nz,.L27
                ld      a,(.Flag)
                inc     a
                jp      nz,.L2                  ;без захода в подпрограмму
                call    .SpdInc
                call    Ld_a_hl
;                ld      a,(hl)                  ;байт комнды
                and     00111000b              ;адрес перехода
                ld      h,0
                ld      l,a
                jp      .L2+3
.L27            cp      11000010b              ;JP flag
                jr      z,.L26
                cp      11000000b              ;RET flag
                jr      z,.L26
                cp      11000100b              ;CALL flag
                jr      nz,.L2
                ld      a,(.Flag)
                inc     a
                jr      nz,.L2                  ;без захода в подпрограмму
.L26            call    Ld_a_hl
;                ld      a,(hl)                  ;код команды
                and     00111000b              ;флаги
                jr      z,.L11                  ;JP/CALL/RET NZ,
                cp      00001000b
                jr      z,.L12                  ;JP/CALL/RET Z,
                cp      00010000b
                jr      z,.L13                  ;JP/CALL/RET NC,
                cp      00011000b
                jr      z,.L14                  ;JP/CALL/RET C,
                cp      00100000b
                jr      z,.L15                  ;JP/CALL/RET PO,
                cp      00101000b
                jr      z,.L16                  ;JP/CALL/RET PE,
                cp      00110000b
                jr      z,.L17                  ;JP/CALL/RET P,
                bit     7,b                     ;JP/CALL/RET M, флаг S
                jr      z,.L2                   ;нет перехода
                jr      .L5                     ;переход
.L11            bit     6,b                     ;флаг Z
                jr      nz,.L2                  ;нет перехода
                jr      .L5                     ;переход
.L12            bit     6,b                     ;флаг Z
                jr      z,.L2                   ;нет перехода
                jr      .L5                     ;переход
.L13            bit     0,b                     ;флаг C
                jr      nz,.L2                  ;нет перехода
                jr      .L5                     ;переход
.L14            bit     0,b                     ;флаг C
                jr      z,.L2                   ;нет перехода
                jr      .L5                     ;переход
.L15            bit     2,b                     ;флаг P/V
                jr      nz,.L2                  ;нет перехода
                jr      .L5                     ;переход
.L16            bit     2,b                     ;флаг P/V
                jr      z,.L2                   ;нет перехода
                jr      .L5                     ;переход
.L17            bit     7,b                     ;флаг S
                jr      nz,.L2                  ;нет перехода

.L5             call    Ld_a_hl
;                ld      a,(hl)                  ;код команды
                and     00000111b              ;отследить RET'ы
                jr      nz,.L8-4
.L9             call    .SpdDec
                ld      hl,(Reg._SP)            ;стек
                dec     hl
                jr      .L8+3
                cp      00000010b              ;отследить JP
                jr      z,.L8+3
.L8             call    .SpdInc
                inc     hl
                call    Ld_a_hl
                ld      b,a
;                ld      a,(hl)
                inc     hl
                call    Ld_a_hl
;                ld      h,(hl)
                ld      h,a
                ld      l,b
                jr      .L2+3
.L2             call    List                    ;следующая команда
                ld      (Reg._PC),hl            ;новый PC
                push    hl
                push    hl
                ld      a,(KList.Descript)      ;количество строк листинга
                call    AdrListTabl             ;нижний адрес листинга
                ld      de,(ListAdr)            ;верхний адрес листинга
                pop     bc                      ;новый PC
                call    AdrArea
                jr      nc,.L1+4

.L1             ld      (ListAdr),bc            ;новая страница листинга
                pop     hl

                call    Ld_a_hl                 ;следующие за командой байты
                ld      c,a
                inc     hl
                call    Ld_a_hl
                ld      b,a
                inc     hl
                call    Ld_a_hl
                push    bc
                push    af
                push    hl

                push    hl
                ld      hl,(RezAdr)             ;адрес посадки резидента
                ld      a,h
                and     11000000b
                cp      10000000b              ;окно посадки резидента
                ld      a,0xFF                  ;FF - резидент во 2-м окне
                jr      nz,.L30
                ld      de,Rezident.RetIn-Rezident
                jr      .L30+4
.L30            ld      de,Rezident.RetIn1-Rezident
                inc     a                       ;0 - резидент не во 2-м окне
                ld      (.WRez),a
                add     hl,de                   ;адрес возврата в резидент
                ex      de,hl                        
                pop     hl
                ld      a,d                     ;прописываем после
                call    Ld_hl_a                 ;отлаживаемой команды
                dec     hl
                ld      a,e
                call    Ld_hl_a
                dec     hl
                ld      a,0xC3                  ;JP
                call    Ld_hl_a

                ld      hl,(RezAdr)             ;адрес посадки
                push    hl                      ;коррекция адресов кода резидента
                ld      (Rezident.K1+1),hl      ;номер банки под отладчиком
                ld      (Rezident.K6+1),hl
                inc     hl
                ld      (Rezident.K3+1),hl      ;аккумулятор прграммы
                ld      (Rezident.RetIn+1),hl
                ld      (Rezident.RetIn1+1),hl
                inc     hl
                ld      (Rezident.K2+1),hl      ;пара HL программы
                ld      (Rezident.K4+1),hl
                inc     hl
                inc     hl
                ld      (Rezident.K5+1),hl      ;1 и 2 байты буфера
                inc     hl
                inc     hl
                ld      (Rezident.K5+7),hl      ;3 и 4 байты буфера
                inc     hl
                inc     hl
                ld      (Rezident.K5+13),hl     ;5 и 6 байты буфера
                inc     hl
                inc     hl
                ld      (Rezident.K5+19),hl     ;7 байт буфера

                ld      a,(.WRez)               ;флаг посадки резидента
                or      a
                jr      nz,.L31
                ld      de,Rezident.Start1-Rezident
                ld      hl,(RezAdr)             ;адрес посадки
                add     hl,de                   ;старт резидента не во 2-м окне
                jr      .L32

.L31            inc     hl                      ;старт резидента во 2-м окне
                ld      (.Run1+1),hl

                ld      hl,AdrTmpBuf
                ld      de,Rezident.Start+1     ;сохранение 7 байт в резиденте
                ld      b,3
.L33            ld      a,(hl)
                ld      (de),a
                inc     hl
                inc     de
                ld      a,(hl)
                ld      (de),a
                inc     hl
                inc     de
                inc     de
                inc     de
                inc     de
                inc     de
                djnz    .L33
                ld      a,(hl)
                ld      (de),a

                ld      de,.Run1+2              ;вспомогательная процедура
                ld      b,7                     ;длина
.L34            ld      a,(de)
                ld      (hl),a
                dec     hl
                dec     de
                djnz    .L34
                inc     hl

.L32            ld      (.Run+1),hl

                ld      a,(Reg._AF+1)           ;аккумулятор программы
                ld      (Rezident+1),a          ;в резидент
                ld      hl,(Reg._HL)            ;пара HL
                ld      (Rezident+2),hl         ;в резидент

                pop     hl                      ;адрес посадки резидента
                ld      de,Rezident             ;начало резидента
                ld      bc,.Buffer
                ld      a,Rezident.End-Rezident ;длина резидента
.L3             push    af
                call    Ld_a_hl
                ld      (bc),a                  ;сохранение памяти под резидентом
                ld      a,(de)                  ;копирование резидента
                call    Ld_hl_a
                inc     bc
                inc     de
                inc     hl
                pop     af
                dec     a
                jr      nz,.L3

                ld      a,(WinPage)             ;банка в 0-ом окне
                out     (EmmWin.P0),a

                call    RestAllRegs
                ld      (StackDebug),sp         ;стек отладчика
                ld      sp,(Reg._SP)            ;стек программы
.Run            jp      0                       ;пуск резидента
         
                ld      (Reg._SP),sp            ;стек программы
                ld      sp,(StackDebug)         ;стек отладчика
                call    SaveAllRegs
                in      a,(EmmWin.P0)
                ld      (WinPage),a             ;банка в 0-ом окне
                ld      a,(BankOS)              ;банка с OS
                out     (EmmWin.P0),a

                ld      hl,(RezAdr)
                call    Ld_a_hl
                ld      (WinPage+2),a           ;номер банки во 2-ом окне
                inc     hl                      ;аккумулятор программа
                call    Ld_a_hl
                ld      (Reg._AF+1),a
                ld      a,(.WRez)               ;флаг резидента
                or      a
                jr      z,.L35                  ;не во 2-м окне
                inc     hl                      ;регистр L программы
                call    Ld_a_hl
                ld      (Reg._HL),a
                inc     hl                      ;регистр H программы
                call    Ld_a_hl
                ld      (Reg._HL+1),a
                ld      b,7
                ld      de,AdrTmpBuf
.L36            inc     hl                      ;буфер 7-ми байт
                call    Ld_a_hl
                ld      (de),a                  ;востановили
                inc     de
                djnz    .L36

.L35            pop     hl
                pop     af                      ;востановили код команды
                pop     bc
                call    Ld_hl_a
                dec     hl
                ld      a,b
                call    Ld_hl_a
                dec     hl
                ld      a,c
                call    Ld_hl_a

                ld      de,.Buffer              ;восстановление памяти под резидентом
                ld      hl,(RezAdr)             ;адрес посадки
                ld      b,Rezident.End-Rezident ;длина резидента
.L4             ld      a,(de)
                call    Ld_hl_a
                inc     de
                inc     hl
                djnz    .L4
                ei
                ret

.BankP          ld      a,0xFF                  ;(2) банка под отладчиком
                out     (EmmWin.P2),a           ;(2)
.Run1           jp      0                       ;(3) переход в резидент

.SpdInc         push    af                      ;увеличение глубины стека
                ld      a,(StackDown)
                inc     a
                ld      (StackDown),a
                pop     af
                ret

.SpdDec         push    af                      ;уменьшение глубины стека
                ld      a,(StackDown)
                dec     a
                ld      (StackDown),a
                pop     af
                ret

.Flag           db      On                      ;флаг захода в подпрограммы
.WRez           db      0                       ;флаг окна посадки резидента

.Buffer         ds      Rezident.End-Rezident   ;длина резидента

