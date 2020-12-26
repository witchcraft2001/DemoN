;[]=========================================================================[]
;[]               Подпрограммы-утилиты монитора-отладчика DemoN             []
;[] v0.01 - последние изменения 29.08.2004                                  []
;[] v0.02 - последние изменения 20.03.2005                                  []
;[] v0.03 - последние изменения 25.02.2006                                  []
;[] v0.10 - последние изменения 17.05.2006                                  []
;[]                                                                         []
;[] SaveAllRegs    - сохранение значений регистровых пар                    []
;[] RestAllRegs    - востановление значений регистровых пар                 []
;[] PrnStrColor    - печать строки символов с атрибутами                    []
;[] PrintReg       - печать двухбайтового числа                             []
;[] PrintStrAF     - печать значения регистровой пары AF и флагов           []
;[] PrintStrReg    - печать значений регистровых пар с адресуемыми байтами  []
;[] PrintStrWin    - печать номеров банок в окнах                           []
;[] PrintSPDn      - печать глубины стека                                   []
;[] PrintStrSp     - печать значений стека                                  []
;[] PrintDump      - печать дампа                                           []
;[] PrintStrDump   - печать строки дампа                                    []
;[] ReplSymNoPrint - замена непечатных символов в строке                    []
;[] NumToStr16     - формирование 16-тиричного числа                        []
;[] NumToStr8      - формирование 8-ричного числа                           []
;[] ConvHexStr     - конвертирование числа в HEX-строку                     []
;[] ConvDecStr     - конвертирование 16-битного числа в DEC-строку          []
;[] CursorSet      - прорисовка курсора                                     []
;[] CursorRes      - востановление экрана под курсором                      []
;[] Ld_a_bc        - чтение байта из памяти с проверкой адреса, адрес в BC  []
;[] Ld_a_hl        - чтение байта из памяти с проверкой адреса, адрес в HL  []
;[] Ld_hl_a        - запись байта в память с проверкой адреса, адрес в HL   []
;[] AdrArea        - определение принадлежности адреса области памяти       []
;[]=========================================================================[]

;[]=========================================================================[]
;[]                   Сохранение значений регистровых пар                   []
;[]=========================================================================[]
SaveAllRegs:
                ld      (Reg._HL),hl
                ld      (Reg._DE),de
                ld      (Reg._BC),bc

                ld      (Reg._IX),ix
                ld      (Reg._IY),iy
                push    af
                pop     hl
                ld      (Reg._AF),hl
                ld      a,r
                ld      (Reg._IR),a
                ld      a,i
                ld      (Reg._IR+1),a

                exx
                ex      af,af'

                ld      (Reg._HL_),hl
                ld      (Reg._DE_),de
                ld      (Reg._BC_),bc
                push    af
                pop     hl
                ld      (Reg._AF_),hl
                ex      af,af'
                exx

                ld      hl,WinPage              ;сохранение номеров страниц
                in      a,(EmmWin.P0)           ;0-е окно
                ld      (hl),a
                inc     hl
                in      a,(EmmWin.P1)           ;1-е окно
                ld      (hl),a
                inc     hl
                in      a,(EmmWin.P2)           ;2-е окно
                ld      (hl),a
                inc     hl
                in      a,(EmmWin.P3)           ;3-е окно
                ld      (hl),a
                ret

;[]=========================================================================[]
;[]                 Востановление значений регистровых пар                  []
;[]=========================================================================[]
RestAllRegs:
                ld      a,(Reg._IR)
                ld      r,a
                ld      a,(Reg._IR+1)
                ld      i,a
                ld      hl,(Reg._AF)
                push    hl
                pop     af
                ld      hl,(Reg._HL)
                ld      de,(Reg._DE)
                ld      bc,(Reg._BC)
                ld      ix,(Reg._IX)
                ld      iy,(Reg._IY)

                exx
                ex      af,af'
                ld      hl,(Reg._AF_)
                push    hl
                pop     af
                ld      hl,(Reg._HL_)
                ld      de,(Reg._DE_)
                ld      bc,(Reg._BC_)
                ex      af,af'
                exx

                ret

;[]=========================================================================[]
;[]                         Печать строки символов                          []
;[] Вход:  HL - адрес строки символов                                       []
;[]                                                                         []
;[] Формат строки: 0x16, Столбец, Строка, Символы, 0x00                     []
;[]=========================================================================[]
                ld      a,(Color.Screen)        ;основной цвет
                ld      (PrnStrColor.L1+5),a
PrnStrColor:
                ld      a,(hl)
                cp      0x16                    ;код установки позиции курсора
                jr      nz,.L2
                inc     hl
                ld      e,(hl)                  ;столбец
		ld	a,e
		ld	(PrtXCoord),a
                inc     hl
                ld      d,(hl)                  ;строка
                inc     hl
                ld      a,(hl)                  ;символ
.L2             cp	0x0D
		jr	nz,.L3
		inc	d
		ld	a,(PrtXCoord)
		ld	e,a
		jr	.L4
.L3		cp	0x17
		jr	nz,.L1
		inc	hl
		ld	a,(hl)
		ld	(PrnStrColor.L1+5),a
		inc	hl
		ld	a,(hl)
.L1		or      a
                ret     z                       ;выход если конец строки
                push    hl
                push    de
;печать ч/з биос или дсс?
	ifdef D_PRINTCH_BIOS
                ld      h,0x03                  ;атрибут
                ld      l,a
                sub     a                       ;идентификатор окна
;		ld	a,(Demon.Bios_Win)
                ld      bc,SysSymb*256+Bios.Win_Put_Sym
                rst     BiosRst
	else
		ld	b,0x03
		ld	c,Dss.WrChar
		rst	DssRst
	endif
                pop     de
                pop     hl
                inc     e
.L4             inc     hl
                jr      PrnStrColor
PrtXCoord	db	0
;[]=========================================================================[]
;[]                    Печать двухбайтового числа                           []
;[] Вход:  DE - координаты печати                                           []
;[]        HL - значение регистровой пары                                   []
;[]=========================================================================[]
PrintReg:
                di
                push    hl
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                rst     BiosRst
                pop     hl

                ld      a,(DecHex)              ;систем счисления
                or      a
                jr      z,.Hex

                ld      de,.String
                call    ConvDecStr
                jr      .Print

.Hex            ld      a,"#"
                ld      (.String),a
                ld      c,l
                ld      a,h
                call    ConvHexStr
                ld      (.String+1),hl          ;старший байт
                ld      a,c
                call    ConvHexStr
                ld      (.String+3),hl          ;младший байт
.Print          ld      hl,.String              ;печатаемая строка
                ld      bc,5*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                rst     BiosRst
                ei
                ret

.String         db      "#0123"

;[]=========================================================================[]
;[]              Печать значения регистровой пары AF и флагов               []
;[] Вход:  DE - координаты печати                                           []
;[]        HL - значение регистровой пары                                   []
;[]=========================================================================[]
PrintStrAF:
                ld      a,h                     ;значение регистра A
                push    hl
                ld      (.String+11),a

                ld      hl,.String+1            ;двоичное значение
                push    de
                ld      de,0x3031               ;"01"
                ld      b,8
.L1             rlca
                jr      c,$+5
                ld      (hl),d                  ;"0"
                jr      $+3
                ld      (hl),e                  ;"1"
                inc     hl
                djnz    .L1
                pop     de

                inc     b                       ;B=1
                inc     hl
                inc     hl
                call    ReplSymNoPrint

                pop     hl
                ld      a,l                     ;флаги
                push    hl
                ld      hl,.Flags
                ld      b,8
                res     3,a                     ;сброс неизвестных флагов
                res     5,a
.L2             rlca
                jr      c,$+6
                set     5,(hl)                  ;сброшен
                jr      $+4     
                res     5,(hl)                  ;установлен
                inc     hl
                djnz    .L2
                pop     hl

                push    de
                call    PrintReg                ;печать значения рег.пары
                pop     de
                push    de
                ld      a,6
                add     a,e
                ld      e,a
                ld      c,Bios.Lp_Set_Place
                di
                rst     BiosRst
                ld      hl,.String
                ld      bc,13*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                di
                rst     BiosRst
                pop     de
                inc     d
                dec     e
                dec     e
                dec     e
                ld      c,Bios.Lp_Set_Place
                di
                rst     BiosRst
                ld      hl,.Flags
                ld      bc,8*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                di
                rst     BiosRst
                ei
                ret

.String         db      '%01010101 " "'
.Flags          db      "SZ.H.PNC"

;[]=========================================================================[]
;[]          Печать значений регистровых пар с адресуемыми байтами          []
;[] Вход:  DE - координаты печати                                           []
;[]        HL - значение регистровой пары                                   []
;[]=========================================================================[]
PrintStrReg:
                push    hl
                ld      b,h
                ld      c,l

                call    Ld_a_bc                 ;ld a,(bc) адресуемые байты
                ld      (.String+10),a
                call    ConvHexStr
                ld      (.String),hl
                inc     bc
                call    Ld_a_bc                 ;ld a,(bc)
                ld      (.String+11),a
                call    ConvHexStr
                ld      (.String+2),hl
                inc     bc
                call    Ld_a_bc                 ;ld a,(bc)
                ld      (.String+12),a
                call    ConvHexStr
                ld      (.String+5),hl
                inc     bc
                call    Ld_a_bc                 ;ld a,(bc)
                ld      (.String+13),a
                call    ConvHexStr
                ld      (.String+7),hl

                ld      hl,.String+10           ;замена непечатных символов
                ld      b,4
                call    ReplSymNoPrint

                pop     hl
                push    de
                call    PrintReg                ;печать значения рег.пары
                pop     de
                di
                ld      a,6
                add     a,e
                ld      e,a
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                rst     BiosRst
                ld      hl,.String              ;печатаемая строка
                ld      bc,14*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                rst     BiosRst
                ei
                ret

.String         db      "0123 4567 ABCD"

;[]=========================================================================[]
;[]                       Печать номеров банок в окнах                      []
;[] Вход:  HL - адрес сохраненных номеров                                   []
;[]=========================================================================[]
PrintStrWin:
                ld      hl,WinPage              ;вывод номеров банок в окнах
                ld      de,.String+3
                ld      b,4
.L1             push    bc
                ld      a,(hl)
                inc     hl
                push    hl
                ld      l,a
                ld      h,0
                call    NumToStr8               ;конвертирование в HEX-строку
                inc     de
                inc     de
                inc     de
                pop     hl
                pop     bc
                djnz    .L1

                ld      hl,.String
                jp      PrnStrColor-6

.String         db      0x16,0x02,0x12,"#01"
                db      0x16,0x08,0x12,"#02"
                db      0x16,0x0E,0x12,"#03"
                db      0x16,0x14,0x12,"#04",0

;[]=========================================================================[]
;[]                         Печать глубины стека                            []
;[]=========================================================================[]
PrintSPDn:
                ld      a,(StackDown)
                ld      l,a
                ld      a,0x7F
                cp      l                       ;отрицательное?
                jr      nc,.L1
                res     7,l                     ;сбросить минус
                inc     a
                sub     l
                ld      l,a
.L1             ld      h,0
                ld      de,.String+1
                push    de
                call    ConvDecStr8
                pop     hl
                dec     hl
                ld      bc,3*256+"0"
                ld      (hl),c
                ld      a,(hl)                  ;гашение незначащих нулей
                cp      c
                jr      nz,$+8
                ld      a,0x20
                ld      (hl),a
                inc     hl
                djnz    $-8
                ld      a,(StackDown)
                bit     7,a
                jr      z,$+6
                dec     hl                      ;отрицательное число
                ld      a,"-"
                ld      (hl),a

                ld      de,0x140A
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                di
                rst     BiosRst
                ld      hl,.String              ;печатаемая строка
                ld      bc,4*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                di
                rst     BiosRst
                ei
                ret

.String         ds      4

;[]=========================================================================[]
;[]                          Печать значений стека                          []
;[]=========================================================================[]
PrintStrSP:
                ld      a,(.StrSp)              ;строка с вершиной стека
                inc     a
                jr      z,.L4                   ;если вершина стека не попадает в дамп
                ld      hl,(Reg._SP)
                dec     hl
                dec     hl
                inc     hl
                inc     hl
                dec     a
                jr      nz,$-3
                ld      (StackDump),hl

.L4             ld      hl,(StackDump)          ;начало дампа
                ld      de,#1601                ;координаты печати
                ld      a,-1
                ld      (.StrSp),a

                ld      b,8                     ;кол-во строк дампа
.L3             push    bc
                push    de                      ;координаты
                push    hl
                or      a                       ;сброс флага C
                ld      a,b
                ld      bc,(Reg._SP)            ;адрес вершины стека
                sbc     hl,bc
                jr      nz,.L2
                ld      b,a
                ld      a,8
                sub     b
                ld      (.StrSp),a              ;номер строки в дампе с вершиной стека
                ld      a,(Color._SP)           ;цвет вершины стека
                jr      .L2+3
.L2             ld      a,(Color.Screen)        ;основной цвет
                ld      (.L1+1),a               ;записали цвет
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                di
                rst     BiosRst
.L1             ld      e,0                     ;цвет подсветки
                ld      bc,11*256+Bios.Lp_Print_Atr ;в рег.B длина строки
                rst     BiosRst
                pop     hl
                pop     de
                push    de
                push    hl
                call    PrintReg                ;печать адреса
                pop     hl
                pop     de
                push    de
                dec     hl
                dec     hl
                push    hl
                ld      a,6
                add     a,e
                ld      e,a

                inc     hl
                inc     hl
                call    Ld_a_hl
                ld      c,a
                inc     hl
                call    Ld_a_hl
                ld      l,a
                ld      h,c

                call    PrintReg                ;печать значения стека
                pop     hl
                pop     de
                inc     d
                pop     bc
                djnz    .L3
                ei
                ret

.StrSp          db      6

;[]=========================================================================[]
;[]                              Печать дампа                               []
;[]=========================================================================[]
PrintDump:
                ld      de,0x160E               ;координаты
                ld      hl,(Dump1)
                ld      b,8                     ;количество строк
                push    de
                push    bc
                push    hl
                call    PrintStrDump
                pop     hl
                ld      bc,16
                add     hl,bc
                pop     bc
                pop     de
                inc     d                       ;следующая строка
                djnz    $-14
                ret

                ld      hl,Dump                 ;вывод дампа
;                ld      de,0x160E               ;координаты
                ld      b,8                     ;количество строк
                push    de
                push    bc
                ld      c,(hl)                  ;младший байт адреса
                inc     hl
                push    hl
                ld      h,(hl)                  ;старший байт адреса
                ld      l,c
                call    PrintStrDump
                pop     hl
                inc     hl
                pop     bc
                pop     de
                inc     d                       ;следующая строка
                djnz    $-15
                ret

;[]=========================================================================[]
;[]                           Печать строки дампа                           []
;[] Вход:  DE - координаты печати                                           []
;[]        HL - адрес начала строки                                         []
;[]=========================================================================[]
PrintStrDump:
                push    de
                push    hl

                ld      b,h
                ld      c,l
                ld      de,.String
                ld      ix,.String+41
                push    ix

                ld      a,8
.L1             exa
                call    Ld_a_bc                 ;ld a,(bc)
                ld      (ix),a
                inc     ix
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e
                inc     hl
                ld      (hl),d
                inc     hl
                ex      de,hl
                inc     bc
                call    Ld_a_bc                 ;ld a,(bc)
                ld      (ix),a
                inc     ix
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e
                inc     hl
                ld      (hl),d
                inc     hl
                inc     hl
                ex      de,hl
                inc     bc
                exa
                dec     a
                jr      nz,.L1

                ld      b,16
                pop     hl
                call    ReplSymNoPrint          ;замена непечатных символов

                pop     hl
                pop     de
                push    de
                call    PrintReg                ;печать адреса строки
                pop     de
                di
                ld      a,7
                add     a,e
                ld      e,a
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                rst     BiosRst
                ld      hl,.String
                ld      bc,57*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                rst     BiosRst
                ei
                ret

.String         db      "1000 2000 3000 4000 5000 6000 7000 8000  "
                db      "0123456789ABCDEF"

;[]=========================================================================[]
;[]                   Замена непечатных символов в строке                   []
;[] Вход:  B  - длина строки                                                []
;[]        HL - адрес начала строки                                         []
;[]=========================================================================[]
ReplSymNoPrint:
                ld      a,(SymbolNoPrint)
                ld      c,a
.L1             ld      a,(hl)
                cp      127
                jr      z,$+10
                cp      0xFF
                jr      z,$+6
                cp      " "
                jr      nc,$+3
                ld      (hl),c
                inc     hl
                djnz    .L1
                ret

;[]=========================================================================[]
;[]                  Формирование 16-тибитного числа                        []
;[] Вход:  DE - адрес буфера                                                []
;[]        HL - число                                                       []
;[]=========================================================================[]
NumToStr16:
                ld      a,(DecHex)              ;систем счисления
                or      a
                jp      nz,ConvDecStr

                ld      a,"#"
                ld      (de),a
                inc     de
                ld      c,l
                ld      a,h
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e                  ;старший байт
                inc     hl
                ld      (hl),d
                inc     hl
                ex      de,hl
                ld      a,c
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e                  ;младший байт
                inc     hl
                ld      (hl),d
                inc     hl
                ex      de,hl
                ret

;[]=========================================================================[]
;[]                    Формирование 8-битного числа                         []
;[] Вход:  DE - адрес буфера                                                []
;[]        HL - число                                                       []
;[]=========================================================================[]
NumToStr8:
                ld      a,(DecHex)              ;систем счисления
                or      a
                jp      nz,ConvDecStr8

.Hex            ld      a,"#"
                ld      (de),a
                inc     de
                ld      a,l
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e
                inc     hl
                ld      (hl),d
                inc     hl
                ex      de,hl
                ret

;[]=========================================================================[]
;[]                    Конвертирование числа в HEX-строку                   []
;[] Вход:  A  - число                                                       []
;[] Выход: HL - HEX-строка                                                  []
;[]=========================================================================[]
ConvHexStr:
                push    af
                rrca
                rrca
                rrca
                rrca
                and     0x0F
                add     a,0x30
                cp      0x3A
                jr      c,$+4
                add     a,7
                
                ld      l,a
                pop     af
                and     0x0F
                add     a,0x30
                cp      0x3A
                jr      c,$+4
                add     a,7
                ld      h,a
                ret

;[]=========================================================================[]
;[]             Конвертирование 16-битного числа в DEC-строку               []
;[] Вход:  HL - число                                                       []
;[]        DE - адрес начала DEC-строки                                     []
;[]=========================================================================[]
ConvDecStr:
                ld      bc,-10000
                ld      a,0xFF
                inc     a
                add     hl,bc
                jr      c,$-2
                sbc     hl,bc
                add     a,"0"
                ld      (de),a
                inc     de

                ld      bc,-1000
                ld      a,0xFF
                inc     a
                add     hl,bc
                jr      c,$-2
                sbc     hl,bc
                add     a,"0"
                ld      (de),a
                inc     de
ConvDecStr8:
                ld      bc,-100
                ld      a,0xFF
                inc     a
                add     hl,bc
                jr      c,$-2
                sbc     hl,bc
                add     a,"0"
                ld      (de),a
                inc     de
ConvDecStr8_1:
                ld      bc,-10
                ld      a,0xFF
                inc     a
                add     hl,bc
                jr      c,$-2
                sbc     hl,bc

                add     a,"0"
                ld      (de),a
                inc     de

                ld      a,l
                add     a,"0"
                ld      (de),a
                inc     de
                ret

;[]=========================================================================[]
;[]                           Прорисовка курсора                            []
;[] Вход:  B  - длина курсора                                               []
;[]        HL - координаты курсора                                          []
;[]=========================================================================[]
CursorSet:
                ld      (CursorRes+1),hl
                ex      de,hl
                ld      l,b                     ;размер по вертикали
                ld      h,1                     ;размер по горизонтали
                ld      (CursorRes+4),hl
                ld      ix,.Buffer
                push    de
                push    hl
                push    ix
                push    bc
	ifdef	D_PRINTCH_BIOS
                xor     a
                ld      c,Bios.Win_Copy_Win     ;копирование в буфер
                di
                rst     BiosRst
                ei
	else
		ld	a,(BankDebug)
		ld	b,a
		ld	c,Dss.WinCopy
		rst	DssRst
	endif

                pop     bc                      ;в B длина курсора
                pop     hl
                push    hl
                inc     hl
                ld      a,(hl)                  ;цвет символов
                ld      (CursorRes.L1+1),a
                ld      a,(Color.Cursor)
.L1             ld      (hl),a
                inc     hl                      ;к байту цвета
                inc     hl
                djnz    .L1

                pop     ix
                pop     hl
                pop     de
	ifdef	D_PRINTCH_BIOS
                xor     a
                ld      c,Bios.Win_Restore_Win  ;вывод курсора на экран
                di
                rst     BiosRst
                ei
	else
		ld	a,(BankDebug)
		ld	b,a
		ld	c,Dss.WinRest
		rst	DssRst
	endif
                ret

.Buffer         ds      22*2                    ;max длина курсора

;[]=========================================================================[]
;[]                    Востановление экрана под курсором                    []
;[]=========================================================================[]
CursorRes:
                ld      de,0                    ;координаты
                ld      hl,0                    ;размер
                ld      b,l                     ;длина
                push    de
                push    hl
                ld      hl,CursorSet.Buffer
                push    hl
.L1             ld      a,0                     ;цвет
                inc     hl                      ;к байту цвета
                jr      CursorSet.L1

;[]=========================================================================[]
;[]                 Чтение байта из памяти с проверкой адреса               []
;[] Вход:  BC или HL - адрес в памяти                                       []
;[] Выход: A  - считанный байт                                              []
;[]=========================================================================[]
Ld_a_bc:
                ld      a,11000000b            ;проверка диапазона
                and     b
                jr      z,.L1                   ;в 0-м окне
                cp      10000000b              ;во 2-ом окне
                ld      a,(bc)
                ret     nz                      ;возвращаем байт, если нет
                ld      a,(WinPage+2)           ;номер банки под отладчиком
                out     (EmmWin.P3),a           ;в третье окно ее
                set     6,b                     ;корректируем адрес
                ld      a,(bc)                  ;читаем байт
                res     6,b                     ;востанавливаем адрес
                jr      Ld_a_hl.L1
.L1             ld      a,(WinPage)             ;номер банки в 0-м
                out     (EmmWin.P3),a           ;в третье окно ее
                set     6,b                     ;корректируем адрес
                set     7,b
                ld      a,(bc)                  ;читаем байт
                res     6,b                     ;востанавливаем адрес
                res     7,b
                jr      Ld_a_hl.L1
Ld_a_hl:
                ld      a,11000000b            ;проверка диапазона
                and     h
                jr      z,.L2                   ;в 0-м окне
                cp      10000000b              ;во 2-ом окне
                ld      a,(hl)
                ret     nz                      ;возвращаем байт, если нет
                ld      a,(WinPage+2)           ;номер банки под отладчиком
                out     (EmmWin.P3),a           ;в третье окно ее
                set     6,h                     ;корректируем адрес
                ld      a,(hl)                  ;читаем байт
                res     6,h                     ;востанавливаем адрес
                jr      .L1
.L2             ld      a,(WinPage)             ;номер банки в 0-м окне
                out     (EmmWin.P3),a           ;в третье окно ее
                set     6,h                     ;корректируем адрес
                set     7,h
                ld      a,(hl)                  ;читаем байт
                res     6,h                     ;востанавливаем адрес
                res     7,h
.L1             push    af
                ld      a,(WinPage+3)           ;номер банки из 3-го окна
                out     (EmmWin.P3),a           ;востанавливаем
                pop     af
                ret

;[]=========================================================================[]
;[]                 Запись байта в память с проверкой адреса                []
;[] Вход:  HL - адрес в памяти                                              []
;[]        A  - записываемый байт                                           []
;[]=========================================================================[]
Ld_hl_a:
                push    af
                ld      a,11000000b            ;проверка диапазона
                and     h
                jr      z,.L2                   ;в 0-ом окне
                cp      10000000b              ;во 2-ом окне?
                jr      z,.L1
                pop     af
                ld      (hl),a                  ;записали байт, если нет
                ret
.L1             ld      a,(WinPage+2)           ;номер банки под отладчиком
                out     (EmmWin.P3),a           ;в третье окно ее
                set     6,h                     ;корректируем адрес
                pop     af
                ld      (hl),a                  ;пишем байт
                jr      .L3
.L2             ld      a,(WinPage)             ;номер банки в 0-ом
                out     (EmmWin.P3),a           ;в третье окно ее
                set     6,h                     ;корректируем адрес
                set     7,h
                pop     af
                ld      (hl),a                  ;пишем байт
                res     7,h                     ;востанавливаем адрес
.L3             res     6,h
                ld      a,(WinPage+3)           ;номер банки из 3-го окна
                out     (EmmWin.P3),a           ;востанавливаем
                ret

;[]=========================================================================[]
;[]            Определение принадлежности адреса области памяти             []
;[] Вход:  HL - нижний адрес области памяти                                 []
;[]        DE - верхний адрес области памяти                                []
;[]        BC - адрес                                                       []
;[] Выход: флаг C  - адрес не принадлежит области памяти                    []
;[]        флаг NC - адрес принадлежит области памяти                       []
;[]=========================================================================[]
AdrArea:
                or      a
                sbc     hl,bc
                ret     c
                ex      de,hl
                or      a
                sbc     hl,bc
                ccf
                ret

