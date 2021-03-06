;[]=========================================================================[]
;[]                       ����� ������-�⫠�稪� DemoN                   []
;[] v0.01 - ��᫥���� ��������� 10.10.2004                                  []
;[] v0.02 - ��᫥���� ��������� 11.03.2005                                  []
;[] v0.03 - ��᫥���� ��������� 05.02.2006                                  []
;[] v0.10 - ��᫥���� ��������� 10.09.2006                                  []
;[]=========================================================================[]
SymbolNoPrint   db      #b0;"."                     ;ᨬ���� < �஡���
ClockOn         db      On                      ;�ਧ��� �뢮�� �ᮢ
DemonScreen     db      0                       ;����� ��࠭� �⫠�稪�
OSScreen	db	0			;����� ��࠭� ���
OSGrafMode	db	0			;����᪨� ०�� ��
BufPage		db	255			;����� ��࠭��� � ������ ���஬

Hello           db      13,10
;                db      "����� �⪮�����஢��� ᯥ樠�쭮 ��� ��ᨫ�� �������!",13,10,10
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

PauseFlash      equ     16                      ;���� ������� �ண�.�����

Color:
.Screen         db      00000111b              ;�᭮���� 梥� ��࠭�
.Border         db      00000011b              ;梥� ࠬ��
.TextStrReg     db      00000010b              ;梥� ॣ���஢�� ���
.TextStrWin     db      00000101b              ;梥� ����஢ ����
._SP            db      00000110b              ;���ᢥ⪠ ���設� �⥪�
._PC            db      01110001b              ;���ᢥ⪠ �믮��塞�� ���.
.RezArea        db      00001110b              ;���ᢥ⪠ १�����
.TextStrLogo    db      00000100b              ;梥� ���� �ணࠬ��
.Cursor         db      00011101b              ;梥� �����-㪠��⥫�
.InLine         db      00111111b              ;梥� ��ப� �����
.InLineEd       db      00110001b              ;梥� ��ப� ����� �� ।.

StackDebug      ds      2                       ;���� �⥪� �⫠�稪�
BankDebug       ds      1                       ;����� ����� �⫠�稪�
BankOS          ds      1                       ;����� ����� � OS
RezAdr          dw      0x7000                  ;���� ��ᠤ�� १�����
StackDown       ds      1                       ;��㡨�� �⥪�
StackDump       dw      0x800A                  ;��砫� ����� �⥪�

Reg:                                            ;���祭�� ॣ���஢�� ���
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

WinPage:        db      0xFF,0xFF,0xFF,0xFF     ;���� ������祭��� ��࠭��

Dump1           dw      0x4000                  ;���� ��砫� �������᪮�� �����
Dump:                                           ;���� ��砫� ��ப �����
                dw      InputLine.Buffer;0x4100
                dw      InputLine.Buffer+16;0x8100
                dw      PutCode.Buffer;0xC100
                dw      0x5280
                dw      0x9280
                dw      0xD280
                dw      0x6000
                dw      0xA000

ListAdr:        ds      40                      ;���� �࠭���� ���ᮢ ���⨭��
ListFormat:     db      -1                      ;�ଠ�� �뢮� ���⨭��
                                                ;-1 - ��; 0 - ���

DecHex          db      0                       ;0-HEX FF-DEC ��⥬�

;======== �������� ======
On              equ     0xFF
Off             equ     0
Ins             equ     0
Ovr             equ     0xFF
SysSymb         equ     0x1B                    ;��⥬�� ������������

;����� �१ �/� ����
	ifdef D_PRINTCH_BIOS
Demon.Bios_Win	db	0			;�����䨪��� ���� ����
MainWin		db	80,32,0,0,00110000b,0,0,0
		ds	26,0
	endif

;--------------------------------------
;���������� ���� ��� �� ��室�
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