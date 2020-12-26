;[]=========================================================================[]
;[]                   Дизассемблер монитора-отладчика DemoN                 []
;[] v0.01 - последние изменения 10.10.2004                                  []
;[] v0.02 - последние изменения 20.03.2005                                  []
;[] v0.03 - последние изменения 16.02.2006                                  []
;[] v0.10 - последние изменения 10.09.2006                                  []
;[]                                                                         []
;[] DisAsm         - вывод листинга                                         []
;[] AttrList       - вывод атрибутов строки листинга                        []
;[] UpAdres        - расчет предыдущего адреса строки листинга              []
;[] List           - формирование строки листинга                           []
;[]=========================================================================[]

;[]=========================================================================[]
;[]                            Вывод листинга                               []
;[]=========================================================================[]
DisAsm:
                ld      hl,(ListAdr)            ;адрес первой строки листинга
                ld      de,0x011A               ;координаты печати
.L1             push    de
                push    hl
                push    de  
                ld      a,d
                dec     a
                add     a,a
                ld      c,a
                ld      b,0
                ex      de,hl
                ld      hl,ListAdr
                add     hl,bc
                ld      (hl),e                  ;адрес строки листинга
                inc     hl
                ld      (hl),d
                ex      de,hl  
                pop     de

                call    AttrList                ;окрасить строку

.L2             call    PrintReg
                pop     hl
                call    List
                pop     de

;                push    af                      ;длина кода временно

                ld      a,(ListFormat)          ;форматный вывод
                or      a
                call    nz,LFormat

                push    de
                push    hl
                di
                ld      a,21
                add     a,e
                ld      e,a                     ;новая координата X
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                rst     BiosRst
;                ld      c,Dss.Locate
;                rst     DssRst
                ld      hl,List.String
                ld      bc,32*256+Bios.Lp_Print_Ln2 ;в рег.B длина строки
                rst     BiosRst
                ei
;                ld      c,Dss.PChars
;                rst     DssRst
                pop     hl
                pop     de

                ;печать длины кода в поле метки (временно)
;                pop     af
;                push    de
;                push    hl
;                ld      e,0x24
;                push    de
;                ld      h,0
;                ld      l,a
;                ld      de,.Buf
;                call    NumToStr8
;                pop     de
;                ld      c,Dss.Locate
;                rst     DssRst
;                ld      hl,.Buf
;                ld      c,Dss.PChars
;                rst     DssRst
;                pop     hl
;                pop     de
;                jr      $+5
;.Buf            db      "123",0
                ;end (временно)

                inc     d                       ;следующая строка
                ld      a,(KList.Descript)      ;кол-во строк листинга
                cp      d
                jr      nc,.L1
                ret

;[]=========================================================================[]
;[]                     Вывод атрибутов строки листинга                     []
;[] Вход:  DE - координаты подсветки                                        []
;[]        HL - текущий адрес листинга                                      []
;[]=========================================================================[]
AttrList:
                di
                push    hl                      ;текущий адрес листинга
                push    de                      ;текущие координаты

                push    hl
                ld      bc,(Reg._PC)            ;адрес программного счетчика
                or      a                       ;сброс флага C
                sbc     hl,bc
                pop     hl
                jr      nz,.L2
                ld      a,(Color._PC)           ;цвет программного курсора
                jr      .L0

.L2             push    hl
                push    de
                push    hl
                ld      bc,Rezident.End-Rezident;длина резидента
                ld      hl,(RezAdr)             ;начало резидента
                push    hl
                add     hl,bc                   ;конечный адрес резидента
                pop     de
                dec     de
                dec     de
                dec     de
                dec     de
                pop     bc

                call    AdrArea
                pop     de
                pop     hl
                jr      c,.L3
                ld      a,(Color.RezArea)       ;цвет области размещения резидента
                jr      .L0

.L3             ld      a,(Color.Screen)        ;основной цвет

.L0             ld      (.L1+1),a
                dec     e
                ld      c,Bios.Lp_Set_Place     ;установка позиции печати
                rst     BiosRst
.L1             ld      e,0                     ;цвет подсветки
                ld      bc,54*256+Bios.Lp_Print_Atr ;в рег.B длина строки
                rst     BiosRst
                pop     de
                pop     hl
                ei
                ret

;[]=========================================================================[]
;[]                  Расчет предыдущего адреса строки листинга              []
;[] Вход:  HL - адрес текущей строки                                        []
;[] Выход: HL - адрес предыдущей строки                                     []
;[]=========================================================================[]
UpAdres:
                ld      de,-4
                add     hl,de                   ;4-х байтная команда?
                call    Ld_a_hl
;                ld      a,(hl)
                cp      0xDD                    ;префикс 0xDD
                jr      z,$+8
                or      00110000b              ;маска для префиксов 0xED,0xFD
                cp      0xFD
                jr      nz,.L1
                push    hl
                call    List
                pop     hl
                cp      4
                ret     z

.L1             inc     hl
                push    hl                      ;3-х байтная команда?
                call    List
                pop     hl
                cp      3
                ret     z

                inc     hl
                push    hl                      ;2-х байтная команда?
                call    List
                pop     hl
                cp      2
                ret     z

                inc     hl
                ret                             ;1-о байтная команда!

;[]=========================================================================[]
;[]                     Форматирование строки листинга                      []
;[]=========================================================================[]
LFormat:
                push    hl
                ld      hl,List.String+11       ;начало строки
                ld      bc,2                    ;макс кол-во вставляемых пробелов
.L2             ld      a,(hl)
                or      a
                jr      z,.Exit
                cp      0x20                    ;пробел
                jr      z,.L1
                inc     hl
                dec     c
                jr      nz,.L2

.Exit           pop     hl
                ret

.L1             push    de
                push    bc
                push    hl
                ld      hl,List.String+30       ;конец строки
                ld      d,h
                ld      e,l
                or      a
                sbc     hl,bc
                pop     bc
                push    bc
                push    hl
                sbc     hl,bc                   ;кол-во байт
                ld      b,h
                ld      c,l
                pop     hl
                lddr
                pop     hl
                pop     bc                      ;кол-во пробелов
                ld      b,c
.L3             inc     hl                      ;адрес вставки
                ld      a,0x20
                ld      (hl),a
                djnz    .L3
                pop     de
                pop     hl
                ret

;[]=========================================================================[]
;[]                      Формирование строки листинга                       []
;[] Вход:  HL - адрес памяти дизассемблирования                             []
;[] Выход: HL - следующий за дизассемблированной командой адрес памяти      []
;[]        A  - длина кода команды                                          []
;[]=========================================================================[]
List:
                xor     a                       ;длина кода команды
                ld      (.Byte),a
                push    hl
                ld      d,h
                ld      e,l

                ld      hl,.String              ;очистка буфера строки
;                di                              ;с использованием акселя
;                ld      d,d                     ;включить аксель
;                ld      a,32                    ;длина буфера и байт заполнитель
;                ld      c,c                     ;команда заполнения
;                ld      (hl),a                  ;заполнить
;                ld      b,b                     ;выключить аксель
;                ei
                ld      a,32                    ;длина буфера и байт заполнитель
                ld      b,a
                ld      (hl),a
                inc     hl
                djnz    $-2

                ld      ix,.String+2            ;адрес в строке для след.кода
                ex      de,hl
;                ld      a,(hl)                  ;байт из памяти
                call    Ld_a_hl

                ;===============================
                cp      0xDD                    ;префикс #DD
                jr      z,.L43
                cp      0xFD                    ;префикс #FD
                jp      nz,.L30

                ld      de,"DF"
                ld      a,"Y"
                jr      .L42

.L43            ld      de,"DD"
                ld      a,"X"

.L42            ld      (.String),de            ;префикс в строку
                ld      (.IRS1+1),a             ;корректировка рег.пары
                ld      (.L9+1),a
                ld      (.L13+6),a
                ld      a,1
                ld      (.Byte),a               ;длина кода команды
                pop     hl
                inc     hl
;                ld      a,(hl)                  ;следующий байт команды
                call    Ld_a_hl
                push    hl
                cp      0xCB
                jr      z,.L40                  ;команды #DD(#FD)#CB

                ld      hl,CodeDDFD             ;таблица кодов
                ld      bc,85                   ;размер таблицы
                cpir                            ;поиск кода
                jr      z,.L45
                pop     hl
                ld      bc,ED00
                ld      de,.String+9            ;копирование мнемоники NOP *
                ld      a,(bc)
                or      a
                ret     z
                ld      (de),a
                inc     de
                inc     bc
                jr      $-6

.L45            ld      hl,84                   ;размер таблицы
                or      a
                sbc     hl,bc
                ld      de,TablDDFD
                jp      .L_12+3
                
.L40            ld      ix,.String+4            ;адрес в строке для след.кода
                ld      de,"BC"                 ;префикс в строку
                ld      (.String+2),de
                ld      a,4                     ;длина кода
                ld      (.Byte),a
                pop     hl
                inc     hl
                call    Ld_a_hl
                ld      b,a
;                ld      b,(hl)                  ;байт-смещение
                inc     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;следующий байт команды
                inc     hl
                push    hl
                ld      c,a
                ld      h,0
                cp      0x40                    ;от 0 до 0x3F (сдвиги)
                jr      c,.L44

                call    .ComCBBit               ;мнемоника BIT,SET,RES
                ld      a,c
                cp      0x80                    ;команда BIT
                jr      nc,.L41
                call    .NomBit                 ;номер бита
                call    .IndexRegSh             ;индексная пара со смещением
                jr      .L46

.L41            call    .NomBit                 ;номер бита
                jr      .L44+3

.L44            call    .ComCBSh                ;мнемоника
                call    .RegName                ;регистр
                jr      nz,$+6
                ld      a,","                   ;разделитель
                ld      (de),a
                inc     de
                call    .IndexRegSh             ;индексная пара со смещением

.L46            ld      a,c
                call    ConvHexStr
                ld      (ix+2),l
                ld      (ix+3),h
                pop     hl
                ret

                ;===============================
.L30            cp      0xCB                    ;префикс #CB
                jp      nz,.L20
                ld      de,"BC"                 ;префикс в строку
                ld      (.String),de
                pop     hl
                inc     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;следующий байт команды
                inc     hl
                push    hl
                ld      c,a
                ld      h,0
                cp      0x40                    ;от 0 до 0x3F (сдвиги)
                jr      nc,.L31
                call    .ComCBSh                ;мнемоника
                jr      .L31+6
.L31            call    .ComCBBit               ;мнемоника
                call    .NomBit                 ;номер бита
                call    .RegName                ;регистр
                call    nz,.HLReg
                ld      a,c
                call    ConvHexStr
                ld      (ix+0),l
                ld      (ix+1),h
                pop     hl
                ld      a,2                     ;длина кода команды
                ret

                ;===============================
.L20            cp      0xED                    ;префикс #ED
                jr      nz,.L10
                ld      a,1
                ld      (.Byte),a               ;длина кода
                ld      de,"DE"                 ;префикс в строку
                ld      (.String),de
                pop     hl
                inc     hl
                push    hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;следующий байт команды
                cp      0x40                    ;от 0 до 0x3F
                jr      c,.L21
                ld      de,TablED-0x40*2
                cp      0x7F                    ;от 0x40 до 0x7E из таблицы
                jr      c,.L_12
                cp      0xA0                    ;от 0x7F до 0x9F
                jr      c,.L21
                ld      de,TablED-0xA0*2+0x40*2-2
                cp      0xBC                    ;от 0xBC до 0xFF
                jr      c,.L_12
.L21            ld      hl,ED00                 ;команда "NOP *"
                jr      .L_2-3

                ;===============================
.L10            ld      ix,.String
                ld      de,Tabl00_3F            ;таблица смещений
                cp      0x40                    ;команды 0x00...0x3F
                jr      c,.L_12
                ld      de,TablC0_FF            ;таблица смещений
                ld      c,a
                sub     0xC0                    ;команды 0xC0...0xFF
                jr      nc,.L_12

                ld      a,c
                cp      0x80
                jr      nc,.L8
                ld      hl,MHALT
                cp      0x76                    ;код команды HALT
                jr      z,.L_2-3

                ld      hl,.String+9
                ld      (hl),"L"                ;мнемоника LD
                inc     hl
                ld      (hl),"D"
                inc     hl
                ld      (hl)," "
                inc     hl
                rrca
                rrca
                rrca
                ex      de,hl
                call    .RegName+1              ;печать регистра
                call    nz,.HLReg
                ld      a,","                   ;разделитель
                ld      (de),a
                inc     de
                call    .RegName                ;печать регистра
                call    nz,.HLReg
                xor     a
                jr      .L1

.L8             and     00111000b              ;ADD,ADC,SUB,SBC,AND,XOR,OR,CP
                rrca
                rrca
                ld      l,a
                ld      h,0
                ld      de,TablM
                add     hl,de                   ;смещение в таблице
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a
                ld      de,.String+9            ;копирование в строку-буфер
                ld      a,(hl)
                ld      (de),a
                inc     de
                inc     hl
                or      a
                jr      nz,$-5
                dec     de
                call    .RegName                ;печать регистра
                call    nz,.HLReg
                xor     a
                jr      .L1

.L_12           ld      l,a                     ;расчет адреса в таблице
                ld      h,0
                add     hl,hl                   ;*2
                add     hl,de
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a                     ;адрес строки-мнемоники

                ld      de,.String+9            ;копирование в строку-буфер
.L_2            ld      a,(hl)
                cp      0x20
                jr      c,.L1
                cp      "x"                     ;индексный регистр
                jr      nz,$+4
.L9             ld      a,"X"
                ld      (de),a
                cp      ")"
                jr      nz,$+9
                ld      (.TablAdr),hl
                ld      (.StrAdr),de
                inc     hl
                inc     de
                jr      .L_2

.L1             exa
                pop     hl                      ;печать байта
                call    Ld_a_hl
;                ld      a,(hl)
                inc     hl
                push    hl
                call    ConvHexStr
                ld      (ix+0),l
                ld      (ix+1),h
                exa
                jp      z,.LE

                dec     a                       ;2-х байтная команда (1)
                jr      nz,.L3
                call    .TwoByteCom
                pop     hl
                ld      a,(.Byte)
                inc     a
                inc     a                       ;длина кода
                ret

.L3             dec     a                       ;3-х байтная команда (2)
                jr      nz,.L4
                call    .ThreeByteCom
                pop     hl
                ld      a,(.Byte)
                add     a,3                     ;длина кода   
                ret

.L4             dec     a                       ;команды относительного перехода (3)
                jr      nz,.L7
                pop     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;2-й байт команды
                inc     hl
                push    hl
                ld      c,a
                call    ConvHexStr
                ld      (ix+2),l
                ld      (ix+3),h
                ld      a,c
                ld      b,0
                pop     hl
                push    hl                      ;текущий адрес
                bit     7,a                     ;знак числа
                jr      z,$+10
                neg
                or      a                       ;сброс флага C
                ld      c,a
                sbc     hl,bc                   ;отрицательное смещение
                jr      $+3
                add     hl,bc                   ;положительное смещение
                call    NumToStr16
                pop     hl
                ld      a,2                     ;длина кода
                ret

.L7             dec     a                       ;команды работы с портами (4)
                jr      nz,.L5
                inc     a
                ld      (.Byte),a               ;длина кода
                ld      de,(.StrAdr)            ;адрес вставки
                call    .TwoByteCom
                jr      .L6

.L5             dec     a                       ;3-х байтные косвенной адресации (5)
                jr      nz,.L11
                ld      a,(.Byte)
                inc     a
                inc     a
                ld      (.Byte),a               ;длина кода
                ld      de,(.StrAdr)            ;адрес вставки
                call    .ThreeByteCom
                jr      .L6

.L11            dec     a                       ;индексные регистры со смещением (6)
                jr      nz,.LE
                ld      a,2
                ld      (.Byte),a               ;длина кода
                ld      de,(.StrAdr)            ;адрес вставки
                pop     hl
                call    Ld_a_hl
                ld      b,a
;                ld      b,(hl)
                inc     hl
                push    hl
                ld      ix,.String+4
                call    .IndexRegSh
.L6             ld      hl,(.TablAdr)           ;адрес в таблице мнемоник
                ld      a,(hl)
                cp      0x20
                jr      nc,.L13
                ld      a,b
                cp      ","                     ;мнемоника оканч. на ","
                jr      nz,.LE
                call    .TwoByteCom
                pop     hl
                ld      a,4                     ;длина кода
                ret

.L13            ld      b,a
                cp      "x"                     ;индексный регистр
                jr      nz,$+4
                ld      a,"X"
                ld      (de),a
                inc     hl
                inc     de
                jr      .L6+3

.LE             pop     hl
                ld      a,(.Byte)               ;длина кода
                inc     a
                ret

;======== печать второго кода двухбайтной команды ========
.TwoByteCom:
                pop     bc                      ;адрес возврата
                pop     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;2-й байт команды
                inc     hl
                push    hl
                push    bc
                ld      c,a
                call    ConvHexStr
                ld      (ix+2),l
                ld      (ix+3),h
                ld      l,c
                ld      h,0
                jp      NumToStr8

;======== печать второго и третьего кода трехбайтной команды ========
.ThreeByteCom:
                pop     bc                      ;адрес возврата
                pop     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;2-й байт команды
                inc     hl
                exa
                call    Ld_a_hl
;                ld      a,(hl)                  ;3-й байт команды
                inc     hl
                push    hl
                push    bc
                ld      b,a
                call    ConvHexStr
                ld      (ix+4),l
                ld      (ix+5),h
                exa
                ld      c,a
                call    ConvHexStr
                ld      (ix+2),l
                ld      (ix+3),h
                ld      h,b                     ;в HL - число
                ld      l,c
                jp      NumToStr16

;======== печать мнемоник команд с префиксом 0xCB (сдвиги, битовые) ========
;A - байт команды
;DE - адрес в строке
.ComCBBit:
                and     11000000b
                rlca
                rlca
                rlca
                rlca
                ld      l,a
                ld      de,CB40-4
                add     hl,de
                jr      .ComCBSh1
.ComCBSh:
                and     00111000b              ;смещение в таблице
                rrca
                rrca
                ld      l,a
                ld      de,TablCB
                add     hl,de
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a
.ComCBSh1       ld      de,.String+9            ;копирование в строку-буфер
                ld      a,(hl)
                ld      (de),a
                inc     de
                inc     hl
                cp      " "                     ;последний символ мнемоники
                jr      nz,$-6
                ret

;======== вычисление номера бита в битовых командах BIT, SET, RES ========
;C - байт команды
;DE - адрес в строке
.NomBit:
                ld      a,c
                and     00111000b              ;номер бита
                rrca
                rrca
                rrca
                add     a,"0"
                ld      (de),a
                ld      a,","
                inc     de
                ld      (de),a
                inc     de
                ret

;======== печать имени регистра ========
;C - команда
;DE - адрес в строке
.RegName:
                ld      a,c
                and     00000111b              ;регистр
                add     a,"B"
                cp      "F"                     ;B,C,D,E
                jr      c,.RN1
                inc     a
                inc     a
                cp      "H"
                jr      z,.RN1
                add     a,3
                cp      "L"
                jr      z,.RN1
                sub     13
                cp      "A"
                ret     nz                      ;относительная адресация
.RN1            ld      (de),a
                inc     de
                xor     a
                ret

;======== печать (HL) ========
;DE - адрес в строке
.HLReg:
                ex      de,hl
                ld      (hl),"("
                inc     hl
                ld      (hl),"H"
                inc     hl
                ld      (hl),"L"
                inc     hl
                ld      (hl),")"
                inc     hl
                ex      de,hl
                ret

;======== печать индексной регистровой пары со смещением ========
;B - смещение
;DE - адрес в строке
.IndexRegSh:
                ld      a,b
                call    ConvHexStr
                ld      (ix+0),l
                ld      (ix+1),h
                ex      de,hl
                ld      (hl),"("
                inc     hl
                ld      (hl),"I"
                inc     hl
.IRS1           ld      (hl),"X"
                inc     hl
                ld      a,"+"                   ;положительное смещение
                ld      (hl),a
                ld      a,b                     ;смещение
                bit     7,b
                jr      z,$+8
                ld      a,"-"                   ;отрицательное смещение
                ld      (hl),a
                ld      a,b                     ;смещение
                neg
                inc     hl
                ex      de,hl
                ld      l,a
                ld      h,0
                call    NumToStr8
                ld      a,")"
                ld      (de),a
                ret


.String         db      "00112233 01234567890123456789012"
.Byte           db      0
.TablAdr        dw      0
.StrAdr         dw      0

