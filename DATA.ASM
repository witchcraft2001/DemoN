;[]=========================================================================[]
;[]                       Данные монитора-отладчика DemoN                   []
;[] v0.01 - последние изменения 10.10.2004                                  []
;[] v0.02 - последние изменения 11.03.2005                                  []
;[] v0.03 - последние изменения 05.02.2006                                  []
;[] v0.10 - последние изменения 10.09.2006                                  []
;[]=========================================================================[]
SymbolNoPrint   db      #b0;"."                     ;символы < пробела
ClockOn         db      On                      ;признак вывода часов
DemonScreen     db      0                       ;номер экрана отладчика
OSScreen	db	0			;Номер экрана ОСи
OSGrafMode	db	0			;Графический режим оси
BufPage		db	255			;Номер страницы с оконным буфером

Hello           db      13,10
;                db      "Версия откомпилирована специально для Василия Иванова!",13,10,10
                db      "DemoN v"
                incbin  "VERSION\major.bin"
                db      "."
                incbin  "VERSION\minor.bin"
                db      " build "
                incbin  "VERSION\build.bin"
                db      " (alpha) <Created by Alpha Studio>",13,10
                db      "Last edition "
                incbin  "VERSION\date.bin"
                db      " (BLR "
                incbin  "VERSION\time.bin"
                db      ")",13,10
                db      "FidoNet: Igor Zhadinets 2:454/5.18; "
                db      "e-mail: igor_ast@tut.by",13,10,10,0
Str:
.Load           db      "Load file ...",0x0D,0x0A,0
.DA             db      0x0d,0x0A,0

PauseFlash      equ     16                      ;частота мигания прогр.курсора

Color:
.Screen         db      00000111b              ;основной цвет экрана
.Border         db      00000011b              ;цвет рамки
.TextStrReg     db      00000010b              ;цвет регистровых пар
.TextStrWin     db      00000101b              ;цвет номеров окон
._SP            db      00000110b              ;подсветка вершины стека
._PC            db      01110001b              ;подсветка выполняемой стр.
.RezArea        db      00001110b              ;подсветка резидента
.TextStrLogo    db      00000100b              ;цвет лого программы
.Cursor         db      00011101b              ;цвет курсора-указателя
.InLine         db      00111111b              ;цвет строки ввода
.InLineEd       db      00110001b              ;цвет строки ввода при ред.

StackDebug      ds      2                       ;адрес стека отладчика
BankDebug       ds      1                       ;номер банки отладчика
BankOS          ds      1                       ;номер банки с OS
RezAdr          dw      0x7000                  ;адрес посадки резидента
StackDown       ds      1                       ;глубина стека
StackDump       dw      0x800A                  ;начало дампа стека

Reg:                                            ;значение регистровых пар
._IX            dw      0
._IY            dw      0
._HL            dw      0
._DE            dw      0
._BC            dw      0
._AF            dw      0
._HL_           dw      0
._DE_           dw      0
._BC_           dw      0
._AF_           dw      0
._IR            dw      0
._SP            dw      0x7FFE
._PC            dw      0

WinPage:        db      0xFF,0xFF,0xFF,0xFF     ;адреса подключенных страниц

Dump1           dw      0x4000                  ;адрес начала динамического дампа
Dump:                                           ;адреса начала строк дампа
                dw      InputLine.Buffer;0x4100
                dw      InputLine.Buffer+16;0x8100
                dw      PutCode.Buffer;0xC100
                dw      0x5280
                dw      0x9280
                dw      0xD280
                dw      0x6000
                dw      0xA000

ListAdr:        ds      40                      ;буфер хранения адресов листинга
ListFormat:     db      -1                      ;форматный вывод листинга
                                                ;-1 - да; 0 - нет

DecHex          db      0                       ;0-HEX FF-DEC система

;======== Констатнты ======
On              equ     0xFF
Off             equ     0
Ins             equ     0
Ovr             equ     0xFF
SysSymb         equ     0x1B                    ;системный знакогенератор

;печать через п/п биоса
	ifdef D_PRINTCH_BIOS
Demon.Bios_Win	db	0			;идентификатор окна биоса
MainWin		db	80,32,0,0,00110000b,0,0,0
		ds	26,0
	endif

;--------------------------------------
;Диалоговое окно для пп выхода
;--------------------------------------
ExitDlg		db	6,22,13,32,6,#40
		db	"Confirmation",0
		db	"  You really want to quit?"
		db	0x16,32,17,"OK      Cancel",0
		db	2
		db	29,17,8,2	;Ok
		dw	0,0
		db	39,17,8,2	;Cancel
		dw	0,Keyb.NoExit