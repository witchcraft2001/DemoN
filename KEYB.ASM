;[]=========================================================================[]
;[]                         Обработка клавиатуры                            []
;[] v0.01 - последние изменения 10.10.2004                                  []
;[] v0.02 - последние изменения 27.03.2005                                  []
;[] v0.03 - последние изменения 11.03.2006                                  []
;[] v0.10 - последние изменения 14.05.2006                                  []
;[]=========================================================================[]
                call    CursorRes               ;выкл курсор
                call    Refresh                 ;обновление экрана
                jr      Keyb
                call    CursorRes               ;выкл курсор
Keyb:
                call    Cursor                  ;вкл курсор
                call    CursorSet
                ld      c,Dss.ScanKey           ;состояние клавиатуры
                rst     DssRst
                jr      z,Keyb+6
                ld      a,b                     ;состояние <Shift><Alt><Ctrl>
                and     11110000b
                jr      z,.L100

                ;Обработка комбинации Shift + символ
                and     11000000b              ;<Shift>
                or      a
                jr      z,.L1
                ld      a,d
                cp      0x80+0x0F               ;Shift+Tab
                jr      nz,Keyb+6
                ld      hl,Keyb.WinScreen
                ld      a,(hl)
                dec     a
                jr      nz,$+4
                ld      a,4
                ld      (hl),a                  ;номер окна дампа
                jr      Keyb-3

                ;Обработка комбинации Alt + символ
.L1             ld      a,b
                and     11110000b
                cp      00010000b              ;<Alt>
                jr      nz,.L10
                ld      a,d                     ;позиционный код
                cp      0x80+0x2B               ;<Alt>+<X>
                jr      nz,.L10
                ret     z                       ;выход

                ;Обработка комбинации Ctrl + символ
.L10            cp      00100000b              ;<Ctrl>
                jp      nz,.L0
                ld      a,d                     ;позиционный код

                cp      0x80+0x12               ;<Ctrl>+<E> (dEc/hEx)
                jr      nz,.L11
                ld      a,(DecHex)
                cpl
                ld      (DecHex),a
                jr      Keyb-11

.L11            cp      0x80+0x13               ;<Ctrl>+<R> резидент
                jr      nz,.L12
                call    CursorRes
                ld      b,5                     ;длина строки ввода
                ld      hl,0x1413
                push    hl
                push    bc
                call    CursorSet
                pop     bc
                pop     hl
                call    InputLine
                jp      c,Keyb-3
                call    PutAdres
                jp      c,Keyb-3
                call    KReg.Rez                ;новый адрес резидента
                jr      Keyb-11

.L12            cp      0x80+0x2A               ;<Ctrl>+<Z>
                jp      z,.L202-2               ;выполнение команды

                cp      0x80+0x2C               ;<Ctrl>+<C>
                jp      z,.L200+5               ;выполнение команды

                cp      0x80+0x2D               ;<Ctrl>+<V>
                jp      z,.L203+4               ;пропуск команды

;                cp      0x80+0x48               ;<ScrollLock>
;                call    z,ScreenS               ;сохранение экрана в файл

.L13            ;...
                jp      .L0

                ;Обработка ASCII кодов
.L100           ld      a,e
                cp      0x1B                    ;<Esc> - вкл.системного экрана
                jr      nz,.L200
                xor     a                       ;выкл часов
                ld      (ClockOn),a
		ld	a,(OSScreen)
		ld	b,a
		push	bc
		ld	a,(OSGrafMode)		
                ld      c,Dss.SetVMod		;системный экран
                rst     DssRst
		pop	bc
		ld	a,(DemonScreen)
		cp	b
		jr	nz,.NoRest
		ld	de,0			;Если экраны ОС и Демона совпадают -
		ld	hl,#2050		;восстанавливаем скрин
		ld	a,(BufPage)
		ld	b,a
		ld	c,Dss.WinRest
		ld	ix,#c000
		rst	DssRst
.NoRest		ld      c,Dss.WaitKey
                rst     DssRst			;ждем Any Key
                ld      a,(DemonScreen)
                ld      b,a
		ld	a,3
                ld      c,Dss.SetVMod
		push	bc
                rst     DssRst
		pop	bc
		ld	a,(OSScreen)
		cp	b
		call	z,RefreshScreen		;Если экраны совпадают - перерисовываем
                ld      a,On                    ;вкл часов
                ld      (ClockOn),a
                jp      Keyb+6

                ;Обработка позиционного кода
.L200           ld      a,d
		cp	0x3b			;<F1>
		jr	nz,.L208
		call	DemonHelp
;		ld      c,Dss.WaitKey
;                rst     DssRst			;ждем Any Key

.NoExit		call	RefreshScreen
		jp	Keyb+6
.L208		cp	0x3d
		jr	nz,.L207
		call	LoadBinDialog
		jr	.NoExit
.L207
                cp      0x42                    ;<F8>
                jr      nz,.L201
                ld      a,Off                   ;флаг пропуска подпрограмм
                jr      .L202

.L201           cp      0x41                    ;<F7>
                jr      nz,.L203
                ld      a,On                    ;флаг трассировки подпрограмм
.L202           ld      (Step.Flag),a
                ld      hl,PrintStrSP.StrSp
                ld      a,(hl)                  ;строка вершины стека
                inc     a
                jr      nz,$+5
                ld      a,6                     ;вернуть вершину стека
                ld      (hl),a
                call    Step
                jp      Keyb-11

.L203           cp      0x43                    ;<F9>
                jr      nz,.L204
                ld      hl,(Reg._PC)           
                call    List                    ;следующая команда
                ld      (Reg._PC),hl            ;новый PC
                push    hl
                ld      a,(KList.Descript)      ;количество строк листинга
                call    AdrListTabl             ;нижний адрес листинга
                ld      de,(ListAdr)            ;верхний адрес листинга
                pop     bc                      ;новый PC
                call    AdrArea
                jp      nc,Keyb-11
                ld      (ListAdr),bc            ;новая страница листинга
                jp      Keyb-11

.L204           cp      0x0F                    ;<Tab>
                jr      nz,.L205
                ld      hl,Keyb.WinScreen
                ld      a,(hl)
                inc     a
                cp      5
                jr      nz,$+4
                ld      a,1
                ld      (hl),a                  ;номер окна дампа
                jp      Keyb-3

.L205           cp      0x48                    ;<ScrollLock>
                jr      nz,.L206
                call    SaveScr                 ;сохранение экрана в файл
                jp      Keyb+6

.L206		cp      0x44                    ;<F10>
		jr	nz,.L0
						;выход
		ld	ix,ExitDlg
		call	DialogWindow
                ret
		call	ClearScreen
.L0             ld      a,(.WinScreen)          ;активное окно
                dec     a
                jp      z,KList
                dec     a
                jp      z,KDump
                dec     a
                jp      z,KReg
                jp      KStack

.WinScreen      db      1                       ;номер активного окна
                                                ;1 - окно листинга
                                                ;2 - окно дампа
                                                ;3 - окно регистров
                                                ;4 - окно стека

                ;Прорисовка курсора
Cursor:
                ld      a,(Keyb.WinScreen)      ;активное окно
                dec     a
                jr      z,.L1
                dec     a
                jr      z,.L2
                dec     a
                jr      z,.L3
                ;Окно дампа стека
                ld      de,(KStack.Coordinate)   ;расчет курсора
                ld      hl,KStack.Descript+2
                ld      b,e
                inc     hl
                inc     hl
                djnz    $-2
                ld      a,(hl)                  ;длина курсора
                ld      (KStack.L201+1),a
                ld      b,a
                dec     hl
                ld      e,(hl)                  ;X-координата курсора
                ex      de,hl
                ld      (KStack.L201+3),hl
                ret
                ;Окно листинга
.L1             ld      de,(KList.Coordinate)   ;расчет курсора
                ld      hl,KList.Descript+2
                ld      b,e
                inc     hl
                inc     hl
                djnz    $-2
                ld      a,(hl)                  ;длина курсора
                ld      (KList.L201+1),a
                ld      b,a
                dec     hl
                ld      e,(hl)                  ;X-координата курсора
                ex      de,hl
                ld      (KList.L201+3),hl
                ret
                ;Окно дампа
.L2             ld      de,(KDump.Coordinate)   ;расчет курсора
                ld      hl,KDump.Descript+2
                ld      b,e
                inc     hl
                inc     hl
                djnz    $-2
                ld      a,(hl)                  ;длина курсора
                ld      (KDump.L201+1),a
                ld      b,a
                dec     hl
                ld      e,(hl)                  ;X-координата курсора
                ex      de,hl
                ld      (KDump.L201+3),hl
                ret
                ;Окно регистров
.L3             call    KReg.DescCalc
                ld      d,b
                ld      b,e                     ;колонока в строке
                inc     hl
                inc     hl
                djnz    $-2
                ld      a,(hl)                  ;длина курсора
                ld      (KReg.L201+1),a
                ld      b,a
                dec     hl
                ld      e,(hl)                  ;X-координата курсора
                ex      de,hl
                ld      (KReg.L201+3),hl
                ret

                ;Обработка клавиш в окне листинга
KList:
                ld      a,b                     ;состояние <Shift><Alt><Ctrl>
                and     11110000b
                jr      z,.L100

                ;Обработка комбинации Alt + символ
                cp      00010000b              ;<Alt>
                jr      nz,.L10
                jp      Keyb+6

                ;Обработка комбинации Ctrl + символ
.L10            cp      00100000b              ;<Ctrl>
                jp      nz,Keyb+6

                ld      a,d                     ;позиционный код
                cp      0x80+0x2B               ;<Ctrl>+<X>
                jp      nz,.L20

                call    AdrListTabl-3           ;выборка адреса листинга по N строки
                ld      (Reg._PC),hl
                jp      .NewLA1+3

.L20            ld      a,b
                cp      00100010b              ;правый <Ctrl>
                jr      nz,.L21
                ld      bc,.CtrlTabl
                call    AdrCtrlTabl             ;выборка строки в таблице
                jp      nc,Keyb+6               ;не цифровые клавиши

                ld      a,(.Coordinate+1)
                ld      (bc),a                  ;номер строки листинга
                inc     bc
                call    AdrListTabl             ;выборка адреса листинга по N строки
                ld      a,l
                ld      (bc),a
                inc     bc
                ld      a,h
                ld      (bc),a
                jp      Keyb+6

.L21            cp      00101000b              ;левый <Ctrl>
                jp      nz,Keyb+6

                ld      a,d                     ;позиционный код
                cp      0x80+0x00               ;Ctrl+"`"
                jp      nz,.L22

                ld      a,(.CtrlWin)
                ld      h,a
                ld      l,0
                add     a,0x40                  ;следующее окно
                ld      (.CtrlWin),a
                ld      a,(.Descript+1)
                ld      (.Coordinate+1),a
                jp      .NewLA1

.L22            ld      bc,.CtrlTabl
                call    AdrCtrlTabl             ;выборка строки в таблице
                jp      nc,Keyb+6

                ld      a,(bc)                  ;номер строки листинга
                or      a
                jp      z,Keyb+6                ;нет данных

                inc     bc
                ld      a,(bc)
                ld      l,a
                inc     bc
                ld      a,(bc)
                ld      h,a                     ;адрес из буфера
                jp      .NewLA

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
                ld      hl,(ListAdr+2)          ;адрес следующей строки
                jp      .NewLA1
.L104           inc     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L103           cp      0x58                    ;<Up>
                jr      nz,.L105
                ld      a,d                     ;текущая строка
                cp      h
                jr      nz,.L107
                ld      hl,(ListAdr)            ;адрес верхней строки листинга
                call    UpAdres                 ;предыдущий адрес
                jp      .NewLA1
.L107           dec     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L105           cp      0x53                    ;<PgDown>
                jr      nz,.L108
                ld      a,d                     ;текущая строка
                cp      l
                jr      nz,.L106
                call    AdrListTabl
                jp      .NewLA1
.L106           ld      a,l                     ;на последнюю строку
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L108           cp      0x59                    ;<PgUp>
                jr      nz,.L110
                ld      a,d                     ;текущая строка
                cp      h
                jr      nz,.L109
                dec     l                       ;кол-во строк - 1
                ld      b,l
                ld      hl,(ListAdr)            ;адрес первой строки
                push    bc
                call    UpAdres                 ;предыдущий адрес
                pop     bc
                djnz    $-5
                jp      .NewLA1
.L109           ld      a,h                     ;на первую строку
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L110           cp      0x57                    ;<Home>
                jr      nz,.L111
                ld      a,1
                ld      (.Coordinate),a         ;первая колонка
                jp      Keyb-3

.L111           cp      0x51                    ;<End>
                jr      nz,.L200
                ld      a,(.Descript+2)         ;последняя колонка
                ld      (.Coordinate),a         ;первая колонка
                jp      Keyb-3

                ;Обработка ASCII кодов
.L200           ld      a,0
                cp      0x0D                    ;<Enter>
                jp      nz,.NewPCAdr	;Keyb+6
.L201           ld      b,0                     ;длина строки ввода
                ld      hl,0                    ;координаты строки ввода
                ld      a,(.Coordinate)
                dec     a                       ;колонка адреса
                jr      z,.InAdres
                dec     a                       ;колонка метки
                jr      z,$+5
                dec     a                       ;колонка кода команды
                jr      z,.InCode
                call    InputLine
                jp      Keyb-3
.NewPCAdr	cp	"z"			;<Z>
		jp	nz,Keyb+6		
		call	AdrListTabl-3		;Установить новый PC
		ld	(Reg._PC),HL
		jp	Keyb-11
.InCode         call    InputLine               ;ввод кода в 3 колонке
                jp      c,Keyb-3                ;завершение ввода по <ESC>
                call    PutCode
                jr      c,.L201                 ;ошибка в веденных данных
                call    AdrListTabl-3           ;адрес текущей строки
                ld      de,PutCode.Buffer
                ld      a,(de)                  ;запись кода в память
                call    Ld_hl_a
                inc     de
                inc     hl
                djnz    $-6
                jr      .NewLA1+3

.InAdres        call    InputLine               ;ввод адреса в 1 колонке
                jp      c,Keyb-3                ;завершение ввода по <ESC>
                call    PutAdres
                jr      c,.L201                 ;ошибка в веденных данных

.NewLA          ld      a,(.Coordinate+1)
                dec     a
                jr      z,.NewLA1
                ld      b,a
                push    bc
                call    UpAdres                 ;предыдущий адрес
                pop     bc
                djnz    $-5
.NewLA1         ld      (ListAdr),hl
                jp      Keyb-11

.CtrlWin        db      0                       ;окно для Ctrl+"`"
.CtrlTabl       ds      30                      ;буффер для адр быстр перехода
.Coordinate     dw      0x0201                  ;курсор (стр/кол курсора)
.Descript:
                dw      0x0114                  ;первая/последняя строка окна
                db      4                       ;кол-во колонок

                db      0x1A                    ;N столбца колонки
                db      5                       ;ширина колонки
                db      0x20
                db      14
                db      0x2F
                db      8
                db      0x38
                db      22

;[]=========================================================================[]
;[]                   Выборка адреса листинга из таблицы                    []
;[] Выход: HL - адрес листинга в текущей строке                             []
;[]=========================================================================[]
                ld      a,(KList.Coordinate+1)  ;номер текущей строки листинга
AdrListTabl:
                dec     a
                add     a,a                     ;*2
                ld      e,a
                ld      d,0
                ld      hl,ListAdr              ;таблица адресов листинга
                add     hl,de                   ;строка в таблице
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a                     ;адрес строки листинга
                ret

;[]=========================================================================[]
;[]               Выборка адреса цифровых клавиш из таблицы                 []
;[] Вход:  D  - позиционный код цифровой клавиши                            []
;[]        BC - адрес начала таблицы                                        []
;[] Выход: BC - адрес в таблице                                             []
;[]        Флаг NC - нажата не цифровая клавиша                             []
;[]=========================================================================[]
AdrCtrlTabl:
                ld      a,d
                and     01111111b              ;сброс старшего бита
                dec     a
                dec     a
                cp      0x0A                    ;проверка цифровых клавиш верхнего ряда
                ret     nc
                or      a
                scf
                ret     z                       ;выход, если "0"
                inc     bc
                inc     bc
                inc     bc
                dec     a
                jr      nz,$-4
                ret

;[]=========================================================================[]
;[]                     Получение кода из строки ввода                      []
;[] Вход:  C  - длина строки ввода                                          []
;[] Выход: .Buffer - захваченные байты                                      []
;[]        B - количество захваченных байт                                  []
;[]        флаг C - ошибка                                                  []
;[]=========================================================================[]
PutCode:
                ld      de,InputLine.Buffer
                ld      hl,.Buffer
                ld      a,c
                dec     a
                ret     c                       ;нулевая строка
                inc     a
                srl     a
                ld      b,a
                jr      z,.L3                   ;обработка одного символа
                ld      c,a
                ld      a,0xC9                  ;RET
                jr      nc,$+3
                xor     a                       ;NOP
                ld      (.L3-1),a

.L2             push    hl
                ld      hl,0
                ld      a,2
                call    PutHex
                ld      a,l
                pop     hl
                ret     c                       ;выход с ошибкой
                ld      (hl),a
                inc     hl
                dec     c
                jr      nz,.L2
                or      a
                ret

.L3             inc     b
                push    hl
                ld      hl,0
                ld      a,1
                call    PutHex
                ld      a,l
                pop     hl
                ret     c                       ;выход с ошибкой
                ld      (hl),a
                or      a
                ret

.Buffer         ds      4

;[]=========================================================================[]
;[]                     Получение адреса из строки ввода                    []
;[] Вход:  C  - длина строки ввода                                          []
;[] Выход: HL - число                                                       []
;[]        флаг C - ошибка                                                  []
;[]=========================================================================[]
PutAdres:
                ld      a,c
                dec     a
                ret     c                       ;нулевая строка
                ld      de,InputLine.Buffer
                ld      hl,0
                ld      a,(de)
                call    CapsLetter
                cp      "X"                     ;hex-число
                jr      z,$+4
                cp      "#"                     ;hex-число
                ld      a,c
                jr      nz,PutDec
                inc     de
                inc     de
                dec     a
                dec     a
                ret     c
                inc     a

PutHex          exa
                ld      a,(de)
                call    Numeric                 ;цифра?
                jr      c,.L1
                call    CapsLetter              ;лат.буквы в верхний регистр
                cp      "F"+1
                ccf
                ret     c                       ;выход с ошибкой
                cp      "A"
                ret     c                       ;выход с ошибкой
                sub     0x07
.L1             sub     0x30
                add     hl,hl                   ;*16
                add     hl,hl
                add     hl,hl
                add     hl,hl
                or      l
                ld      l,a
                inc     de
                inc     de
                exa
                dec     a
                jr      nz,PutHex
                or      a                       ;сброс флага C
                ret

PutDec          exa
                ld      a,(de)
                call    Numeric                 ;цифра?
                ccf
                ret     c                       ;выход если нет
                ld      c,l
                ld      b,h
                add     hl,hl                   ;*10
                add     hl,hl
                add     hl,bc
                add     hl,hl
                ld      b,0
                sub     0x30
                ld      c,a
                add     hl,bc
                inc     de
                inc     de
                exa
                dec     a
                jr      nz,PutDec
                or      a                       ;сброс флага C
                ret

;[]=========================================================================[]
;[]   Проверка кода символа на принадлежность к цифрам (коды 0x30...0x39)   []
;[] Вход:  A  - код символа                                                 []
;[] Выход: флаг C - цифра; Флаг NC - не цифра                               []
;[]=========================================================================[]
Numeric         cp      "0"
                ccf
                ret     nc
                cp      3Ah
                ret

;[]=========================================================================[]
;[]       Перевод символов латинского алфавита a...z в верхний регистр      []
;[] Вход:  A  - код символа                                                 []
;[] Выход: A  - код символа в верхнем регистре                              []
;[]=========================================================================[]
CapsLetter      cp      "a"                     ;<"a"
                ret     c
                cp      "z"+1                   ;>"z"
                ret     nc
                and     11011111b              ;преобразование символа
                ret                   

InputLine1      push    hl
                push    bc
                call    CursorSet
                pop     bc
                pop     hl
		jr	InputLine

;[]=========================================================================[]
;[]                    Ввод строки символов с клавиатуры                    []
;[] Вход:  B  - длина строки ввода                                          []
;[]        HL - координаты курсора                                          []
;[] Выход: флаг C - <Esc> флаг NC - <Enter>                                 []
;[]        C  - длина введенной строки, если <Enter>                        []
;[]=========================================================================[]
InputLineEd:
                ld      a,(Color.InLineEd)      ;цвет строки ввода
                ld      c,a
                xor     a
                jr      InputLine+6
InputLine:
                ld      a,(Color.InLine)        ;цвет строки ввода
                ld      c,a
                ld      a,On
                ld      (.EntEnd),a
                ld      a,0xC3                  ;код JP
                ld      (.L15),a
                ld      (CursPos),hl
                ld      (.Coordinate),hl
                ld      hl,.Pos                
                xor     a                       ;текущая позиция
                ld      (hl),a
                inc     hl
                ld      (hl),c                  ;цвет
                inc     hl
                ld      (hl),b                  ;длина строки редактирования
                inc     hl                      ;начало буфера редактирования
                ld      de,CursorSet.Buffer     ;буфер строки под курсором
                ;ld      c,a                     ;окраска строки редактирования
.L1             ld      a,(de)
                ld      (hl),a
                inc     hl
                inc     de
                ld      (hl),c
                inc     hl
                inc     de
                djnz    .L1

                call    .PrintInLine            ;напечатать строку
                ld      a,(.EntEnd)
                or      a
                call    nz,.EndString           ;курсор в конец строки

.L100           ld      a,On                    ;включить програм курсор 
                ld      (CursOnOff),a
                ld      hl,.L100
                push    hl                      ;адрес возврата
                ld      c,Dss.ScanKey           ;состояние клавиатуры
                rst     DssRst
                jr      z,$-3

                cp      0x20                    ;есть ASCII-код
                jr      c,.L3

                push    af
                ld      a,(.Pos)
                exa
                ld      hl,.Color               ;текущий цвет строки ввода
                ld      a,(Color.InLine)
                cp      (hl)
                call    z,.ClearInLine
                call    z,.HomeString
                call    .NextPos                ;на выходе в HL адрес .Pos
                jr      z,.L12
                ld      a,(CursInsOvr)          ;режим Ins/Ovr
                or      a
                jr      nz,.L12                 ;переход если Ovr
                ld      a,(.Len)
                ld      e,a
                dec     a                       ;длина строки - 1
                add     a,a
                ld      b,0
                ld      c,a
                ld      d,(hl)                  ;позиция печати символа
                ld      hl,.Buffer
                add     hl,bc                   ;конец буфера
                inc     hl
                ld      a,e
                sub     d                       ;кол-во сдвигаемых символов
                add     a,a
                ld      c,a
                ld      d,h
                ld      e,l
                dec     hl
                dec     hl
                lddr                            ;раздвижка строки
.L12            exa
                add     a,a
                ld      b,0
                ld      c,a
                ld      hl,.Buffer
                add     hl,bc                   ;адрес в буфере
                pop     af
                ld      (hl),a                  ;символ в буфер
                call    ResCurs
.L15            jp      .PrintInLine
                jr      .L14     

.L3             cp      0x1B                    ;<Esc>
                jr      nz,.L13
                call    ResCurs
                pop     hl                      ;востановить стек
                scf
                ret

.L13            cp      0x0D                    ;<Enter>
                jr      nz,.L2
                ld      a,On
                ld      (.EntEnd),a
                call    ResCurs
.L14            pop     hl                      ;востановить стек
                call    .EndPos                 ;длина введенной строки
                ret

.L2             ld      a,d
                cp      0x4F                    ;<Del>
                jr      nz,.L9
                call    ResCurs
                ld      hl,.Color               ;текущий цвет строки ввода
                ld      a,(Color.InLine)
                cp      (hl)
                call    z,.ClearInLine
.L11            ld      hl,.Pos
                ld      a,(hl)                  ;позиция курсора
                add     a,a
                ld      e,a
                inc     hl
                inc     hl
                ld      a,(hl)                  ;длина строки
                dec     a
                add     a,a
                sub     e                       ;проверка конца строки
                ld      c,a
                ld      b,0
                ld      d,b
                inc     hl                      ;начало буфера
                add     hl,de                   ;адрес курсора
                push    hl
                pop     de
                inc     hl
                inc     hl
                jr      z,$+4                   ;если в конце строки
                ldir
                ld      a," "
                ld      (de),a                  ;последний символ
                jp      .PrintInLine

.L9             cp      0x0E                    ;<BackSp>
                jr      nz,.L10
                call    ResCurs
                call    .ColorInLine            ;сменить цвет строки
                ld      hl,.Pos
                ld      a,(hl)                  ;позиция курсора
                or      a
                jp      z,.PrintInLine          ;если в начале строки
                dec     (hl)                    ;уменьшить позицию
                ld      hl,CursPos
                dec     (hl)                    ;курсор влево
                jr      .L11

.L10            cp      0x50                    ;<Ins>
                jr      nz,.L5
                ld      a,(CursInsOvr)
                cpl
                ld      (CursInsOvr),a
                ret

.L5             cp      0x56                    ;<Right>
                jr      nz,.L6
                call    ResCurs
                call    .ColorInLine            ;сменить цвет строки
                call    z,.PrintInLine
                call    .EndPos
                ret     z
                ld      a,(.Pos)
                cp      c
                ret     nc
                jp      .NextPos

.L6             cp      0x54                    ;<Left>
                jr      nz,.L7
                call    ResCurs
                call    .ColorInLine            ;сменить цвет строки
                call    z,.PrintInLine
                ld      hl,.Pos                 ;позиция курсора
                ld      a,(hl)
                or      a
                ret     z
                dec     (hl)
                ld      hl,CursPos              ;координаты програм курсора
                dec     (hl)
                ret

.L7             cp      0x57                    ;<Home>
                jr      nz,.L8
                call    ResCurs
                call    .ColorInLine            ;сменить цвет строки
                call    z,.PrintInLine
.HomeString     ld      hl,.Pos                 ;позиция курсора
                ld      a,(hl)
                or      a
                ret     z
                ld      a,(.Coordinate)         ;координаты начала строки
                ld      (CursPos),a
                xor     a
                ld      (hl),a                  ;обнулить позицию печати
                ret

.L8             cp      0x51                    ;<End>
                ret     nz
                call    ResCurs
                call    .ColorInLine            ;сменить цвет строки
                call    z,.PrintInLine
.EndString      call    .EndPos
                ret     z
                ld      a,(.Len)
;                dec     a                       ;длина строки ввода - 1
                sub     c                       ;заполнена полностью?
                jr      nz,$+3
                dec     c
                ld      hl,.Pos
                ld      (hl),c                  ;позиция в конце строки
                ld      a,(.Coordinate)
                add     a,c
                ld      (CursPos),a             ;новая позиция програм курсора
                ret

.PrintInLine    ld      ix,.Buffer              ;буфер строки
                ld      a,(.Len)
                ld      l,a
                ld      h,1                     ;размеры буфера
                ld      de,(.Coordinate)        ;координаты в экране
	ifdef	D_PRINTCH_BIOS
                xor     a
                ld      c,Bios.Win_Restore_Win  ;вывод буфера на экран
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

.ClearInLine    ld      hl,.Len                 ;очистка строки ввода
                ld      b,(hl)                  ;длина строки ввода
                ld      a," "                   ;пробел
                inc     hl                      ;начало буфера строки
                ld      (hl),a
                inc     hl
                djnz    $-3
                xor     a                       ;позиция печати
                ld      (.Pos),a
                exa
                ld      a,(.Coordinate)
                ld      (CursPos),a
                jr      $+10

.ColorInLine    ld      hl,.Color               ;окраска в основной цвет
                ld      a,(Color.InLine)
                cp      (hl)             
                ret     nz
                ld      a,(Color.InLineEd)      ;цвет строки ввода
                ld      (.Color),a
                ld      hl,.Len                 ;длина строки ввода
                ld      b,(hl)
                inc     hl
                inc     hl
                ld      (hl),a
                inc     hl
                djnz    $-3
                ret

.EndPos         ld      hl,.Buffer              ;поиск позиции послед. символа
                ld      a,(.Len)
                ld      c,a
                dec     a
                add     a,a
                ld      e,a
                ld      d,0
                add     hl,de
                ld      a,(hl)
                dec     hl
                dec     hl
                cp      " "                     ;ищем конец строки
                ret     nz
                dec     c
                jr      nz,$-7
                ret

.NextPos        ld      hl,.Pos                 ;расчет следующей позиции
                ld      a,(.Len)
                dec     a
                cp      (hl)
                jr      nz,.L16
                ld      a,(.EntEnd)             ;заканчивать по ENTER
                inc     a
                ret     z                       ;последняя позиция в строке
                ld      a,0xCD                  ;код CALL
                ld      (.L15),a
                ret
.L16            inc     (hl)                    ;увеличение позиции
                ld      a,(CursPos)             ;координаты програм курсора
                inc     a
                ld      (CursPos),a
                ret
;[]=========================================================================[]
;[]                    Копирование из буфера строки ввода                   []
;[]=========================================================================[]
;Вход:
;DE	-	адрес назначения
;C	-	длина строки

.FromBuffer	ld	hl,.Buffer
		ld	b,0
.FB1		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	hl
		inc	de
		dec	c
		jr	nz,.FB1
		ret
;[]=========================================================================[]
;[]                      Копирование в буфер строки ввода                   []
;[]=========================================================================[]
;Вход:
;HL	-	адрес строки
;C	-	длина строки

.ToBuffer	ld	de,.Buffer
.TB1		ld	a,(hl)
		ld	(de),a
		inc	de
		inc	de
		inc	hl
		dec	c
		jr	nz,.TB1
		ret		
.EntEnd         db      On                      ;флаг окончания строки ENTER
.Coordinate     dw      0                       ;начало строки в экране
;последовательность переменных не изменять!
.Pos            db      0                       ;позиция курсора в строке
.Color          db      0                       ;цвет строки ввода
.Len            db      0                       ;длина строки ввода
.Buffer         ds      22*2                    ;буфер строки ввода

;[]=========================================================================[]
;[]                  Программное создние мигающего курсора                  []
;[]=========================================================================[]

;======== Подготовка дополнительного знакогенератора ========
PreparChar:
                ld      de,OrgAdr-0x100         ;буфер для 2kB знакогенератора
                ld      c,Bios.Win_Get_ZG       ;получить сист. знакогенератор
                rst     BiosRst
                ld      hl,OrgAdr-0x100+7*256
                ld      bc,0x00FF
                ld      (hl),c
                inc     hl
                djnz    $-2

                ld      de,OrgAdr-0x100         ;уст.знакогенератор 0x5B
                ld      c,Bios.Win_Set_ZG
                ld      a,0x5B
                rst     BiosRst

                ld      hl,(0039h)              ;установка вектора (для мигания курсора)
                ld      (Rst38.Vect+1),hl
                ld      hl,Rst38
                ld      (0039h),hl
                ret

Rst38           di                              ;вектор курсора
                push    iy
                push    ix
                push    hl
                push    de
                push    bc
                push    af
                exx
                exa
                push    hl
                push    de
                push    bc
                push    af
                call    Clock
                ld      a,(CursOnOff)
                or      a
                call    nz,CuttingCurs
                pop     af
                pop     bc
                pop     de
                pop     hl
                exx
                exa
                pop     af
                pop     bc
                pop     de
                pop     hl
                pop     ix
                pop     iy
.Vect           jp      0x0000                  ;адрес сист. вектора RST 38

;======== Обработка программного курсора ========
CuttingCurs     ld      a,(TimerFlash)          ;пауза мигания
                dec     a
                call    z,.L1
                ld      (TimerFlash),a
                ret

.L1             ld      a,(CursPutRes)
                cpl 
                ld      (CursPutRes),a

                ld      de,(CursPos)
                ld      (ResCurs.L1+1),de
                or      a                       ;флаг Put / Res
                jr      z,.L3                   ;установка курсора
                                                ;иначе сброс курсора
                ld      hl,(CursSymb)           ;символ и его цвет
                sub     a                       ;сброс id окна
                ld      b,SysSymb               ;системный знакогенератор
                ld      c,Bios.Win_Put_Sym      ;положить символ
                rst     BiosRst
                ld      a,PauseFlash            ;пауза мигания
                ret

.L3             ld      c,Bios.Win_Get_Sym      ;получить символ
                sub     a                       ;сброс id окна
                rst     BiosRst
                ld      (CursSymb),hl           ;символ и его цвет

                ld      de,(CursPos)            ;позиция печати
                ld      a,(CursInsOvr)          ;флаг режима Ins / Ovr
                or      a
                jr      z,.L4                   ;режим вставки
                                                ;иначе режим замены
                ld      a,h
                rlca
                rlca
                rlca
                rlca
                ld      h,a
                sub     a                       ;сброс id окна
                ld      b,SysSymb               ;системный знакогенератор
;                ld      l,0xDC                  ;курсор режима замены
                ld      c,Bios.Win_Put_Sym      ;символ на экран
                rst     BiosRst
                ld      a,PauseFlash            ;пауза мигания
                ret

.L4             sub     a                       ;сброс id окна
                ld      b,0x5B                  ;модиф. знакогенератор
                ld      c,Bios.Win_Put_Sym      ;символ на экран
                rst     BiosRst
                ld      a,PauseFlash            ;пауза мигания
                ret

;======== Принудительный сброс курсора ========
ResCurs         ld      a,(CursOnOff)
                or      a
                ret     z                       ;курсор не установлен
                push    hl
                ld      a,On
                ld      (CursPutRes),a
                inc     a
                ld      (CursOnOff),a
                ld      a,1                     ;пауза мигания
                ld      (TimerFlash),a
.L1             ld      de,0                    ;последние координаты курсора
                ld      hl,(CursSymb)
                ld      bc,0x1B00+Bios.Win_Put_Sym
                sub     a                       ;сбросить id окна
                rst     BiosRst
                pop     hl
                ret

CursOnOff       db      Off                     ;флаг курсора 00-выкл/FF-вкл
CursPutRes      db      On                      ;флаг 00-Res/FF-Put
CursInsOvr      db      Ins                     ;флаг 00-Ins/FF-Ovr
TimerFlash      db      1                       ;таймер
CursPos         dw      0                       ;позиция курсора
CursSymb        dw      0                       ;символ под курсором

