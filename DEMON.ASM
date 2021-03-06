;[]=========================================================================[]
;[]                        ������-�⫠�稪 DemoN                           []
;[] v0.01 - ��᫥���� ��������� 10.10.2004                                  []
;[] v0.02 - ��᫥���� ��������� 07.02.2005                                  []
;[] v0.03 - ��᫥���� ��������� 11.03.2006                                  []
;[] v0.10 - ��᫥���� ��������� 27.08.2006                                  []
;[]=========================================================================[]

		DEVICE	ZXSPECTRUM128

;		define	DEBUG		1	;����⨥ ���������� �����襪
;		define	D_PRINTCH_BIOS	1

	        org #8100-512
STARTPRG
		DB	"EXE"	;EXE ID
		DB	#00	;EXE VERSION
		DW	#0200	;CODE OFFSET LOW
		DW	#0000	;CODE OFFSET HIGH
		DW	#0000	;END-BEG ;PRIMARY LOADER
		DW	#0000	;
		DW	#0000	;RESERVED
		DW	#0000	;
		DW	OrgAdr	;LOAD ADDRESS
		DW	OrgAdr	;START ADDRESS
		DW	#C001	;STACK ADDRESS


OrgAdr          equ     0x8100
                org     OrgAdr
;                stack   0xC001

                push    ix                      ;���� ��������� ��ப�
                in      a,(EmmWin.P2)           ;����� � �⫠�稪��
                ld      (BankDebug),a
                in      a,(EmmWin.P0)           ;����� � OS
                ld      (BankOS),a
;                ld      (WinPage),a

;                ld      (Reg._SP),sp            ;���� �⥪�
                call    SaveAllRegs             ;��࠭���� ॣ���஢�� ���
;                ld      a,(BankDebug)
                ld      a,0xFF                  ;��뢠�� ����� � �⫠�稪��
                ld      (WinPage+2),a
                include "cmdline.asm"
                call    nc,LoadFile
                jp      Start                                              

HorizLine       db      8                       ;������⢮ �����
                ;1-����� 2-�⮫��� 3-��ப� 4-ᨬ���
                db      0x4E,0x01,0x00,0xCD, 0x17,0x01,0x03,0xC4
                db      0x17,0x01,0x09,0xC4, 0x17,0x01,0x0F,0xC4
                db      0x17,0x01,0x11,0xCD, 0x4E,0x01,0x15,0xCD
                db      0x4E,0x01,0x1E,0xCD, 0x17,0x01,0x13,0xCD

VerticalLine    db      5                       ;������⢮ �����
                ;1-���� 2-�⮫��� 3-��ப� 4-ᨬ���
                db      0x1D,0x00,0x01,0xBA, 0x10,0x09,0x01,0xB3
                db      0x08,0x0C,0x16,0xBA, 0x14,0x18,0x01,0xBA
                db      0x1D,0x4F,0x01,0xBA

Corner          db      41                      ;㣫� ࠬ��
                ;1-�⮫��� 2-��ப� 3-ᨬ��� 
                db      0x00,0x00,0xC9, 0x00,0x03,0xC7, 0x00,0x09,0xC7
                db      0x00,0x0F,0xC7, 0x00,0x11,0xCC, 0x00,0x15,0xCC
                db      0x00,0x1E,0xC8, 0x06,0x11,0xD1, 0x06,0x13,0xCF
                db      0x09,0x00,0xD1, 0x09,0x03,0xC5, 0x09,0x09,0xC5
                db      0x09,0x0F,0xC5, 0x0C,0x11,0xD1, 0x0C,0x15,0xCB
                db      0x0C,0x1E,0xCA, 0x12,0x0F,0xC2, 0x12,0x11,0xD8
                db      0x12,0x13,0xCF, 0x18,0x00,0xCB, 0x18,0x03,0xB6
                db      0x18,0x09,0xB6, 0x18,0x0F,0xB6, 0x18,0x15,0xCA
                db      0x00,0x13,0xCC, 0x0C,0x13,0xCF, 0x4F,0x00,0xBB
                db      0x18,0x13,0xB9, 0x4F,0x15,0xB9, 0x4F,0x1E,0xBC
                db      0x18,0x11,0xB9, 0x06,0x12,0xB3, 0x12,0x10,0xB3
                db      0x12,0x12,0xB3, 0x09,0x13,0xD1, 0x09,0x14,0xB3
                db      0x09,0x15,0xCF, 0x0C,0x12,0xB3, 0x0E,0x13,0xCB
                db      0x0E,0x14,0xBA, 0x0E,0x15,0xCA

TextStrReg      db      0x16,0x01,0x01,"IX", 0x16,0x01,0x02,"IY"
                db      0x16,0x01,0x04,"HL", 0x16,0x01,0x05,"DE"
                db      0x16,0x01,0x06,"BC", 0x16,0x01,0x07,"AF"
                db      0x16,0x01,0x0A,"HL'", 0x16,0x01,0x0B,"DE'"
                db      0x16,0x01,0x0C,"BC'", 0x16,0x01,0x0D,"AF'"
                db      0x16,0x01,0x10,"PC", 0x16, 0x0A,0x10,"IR"
                db      0x16,0x01,0x14,"SP",0
TextStrLogo     db      0x016,0x01,0x1F,0xC4,0xCD,0xCD
                db      " DemoN v"
                incbin  "VERSION\major.bin"
                db      "."
                incbin  "VERSION\minor.bin"
                db      " build "
                incbin  "VERSION\build.bin"
                db      " (alpha)-"
                incbin  "VERSION\date.bin"
		db	" Igor by AlphA Studio, Hard/WCG"
                db      0x20,0xCD,0xCD,0xC4,0x00
TextStrWin      db      0x16,0x02,0x11," 0 ",0x16,0x08,0x11," 1 "
                db      0x16,0x0E,0x11," 2 ",0x16,0x14,0x11," 3 ",0
TextStrRez      db      0x16,0x0F,0x14,"REZ",0


                ;��楤�� ���ᮢ�� �����
                ;HL - ���� ��砫� ⠡����
DrawLine        ld      c,(hl)                  ;������⢮ �����
                inc     hl
                ld      b,(hl)                  ;����� �����
                inc     hl
                ld      e,(hl)                  ;�⮫���
                inc     hl
                ld      d,(hl)                  ;��ப�
                inc     hl
                ld      a,(hl)                  ;ᨬ���
                push    hl
.L1             push    bc
                push    af
                ld      bc,Dss.WrChar           ;梥� � ॣ.B
                rst     DssRst
                inc     d                       ;���騢���� ���न����
                pop     af
                pop     bc
                djnz    .L1
                pop     hl
                dec     c
                jr      nz,DrawLine+1
                ret

                ;��砫� �ணࠬ��
Start:
                ld      hl,Hello                ;ᮮ�饭�� �ணࠬ��
                ld      c,Dss.PChars            ;�뢥�� ��ப�
                rst     DssRst
		ld	c,Dss.GetVMod		;����騩 ��� ०��
		rst	DssRst
		jp	c,Exit
		ld	(OSGrafMode),a
		ld	a,b
		ld	(OSScreen),a		;� ⥪��� ��࠭�� ��࠭�
		push	bc
		ld	bc,#0100+Dss.GetMem	;१�ࢨ�㥬 1 ��࠭��� ��� �������� ����
		rst	DssRst
		pop	de			;� D - ����� ��࠭��� ��࠭� - OSScreen
		jp	c,Exit			;�訡�� �뤥����� ����� �����
		ld	(BufPage),a		;���࠭�� ��࠭��� � ��६�����
		ld	b,a
		ld	a,(DemonScreen)
		cp	d			;�᫨ ��࠭� �� � ������ �� ᮢ������
		jr	nz,StartNext		;� � �� ��࠭塞 ��࠭ ���
		ld	de,0			;���࠭塞 ��࠭ � ���.��࠭��
		ld	hl,#2050
		ld	ix,#c000
		ld	c,Dss.WinCopy
		rst	DssRst
		
StartNext	ld      a,(DemonScreen)         ;��࠭ �⫠�稪�
                ld      b,a
		ld	a,3			;��⠭����� ०�� 80�32
                ld      c,Dss.SetVMod		;Dss.SelPage
;                ld      bc,0x0054
                rst     DssRst
	ifdef D_PRINTCH_BIOS
		ld	ix,MainWin		;����⨥ ���� �/� ����
		ld	e,00010001b
		rst	BiosRst
		ld	(Demon.Bios_Win),a
;		jr	nc,.lp1
;		ld	c,Dss.EchoKey		;���㣣�ୠ� �����誠
;		rst	DssRst

	endif
.lp1		
;                ld      a,(Color._SP)           ;���ᢥ⪠ ���設� �⥪�
;                ld      b,a
;                ld      de,0x1C01
;                ld      hl,0x010B
;                ld      a," "
;                ld      c,Dss.Clear
;                rst     DssRst
		call	ClearScreen
		call	DrawDemonScreen
	
;		ld	c,Dss.EchoKey		;���㣣�ୠ� �����誠
;		rst	DssRst

                jp      Start1
;���������� ��࠭� ������
RefreshScreen	call	CursorRes
		call	ClearScreen
		call	DrawDemonScreen
		call	Refresh
                call    Cursor                  ;��� �����
                jp    CursorSet

ClearScreen	ld      a,(Color.Screen)
                ld      b,a                     ;���⪠ ��࠭�
                ld      de,0
                ld      hl,0x2050
                ld      c,Bios.Lp_Cls_Win
                rst     BiosRst
		ret		
DrawDemonScreen
                ld      a,(Color.Border)        ;��⠭���� 梥� ࠬ��
                ld      (DrawLine.L1+4),a
                ld      (DrawCorner+10),a
                ld      a,0x14                  ;��� ��������� INC D
                ld      (DrawLine.L1+6),a

                ld      hl,VerticalLine         ;���⨪���� �����
                call    DrawLine

                ld      hl,HorizLine            ;��ਧ��⠫�� �����
                ld      a,0x1C                  ;��� ��������� INC E
                ld      (DrawLine.L1+6),a
                call    DrawLine

                ld      hl,Corner
                ld      b,(hl)                  ;������⢮ 㣫��
DrawCorner      push    bc
                inc     hl
                ld      e,(hl)                  ;�⮫���
                inc     hl
                ld      d,(hl)                  ;��ப�
                inc     hl
                ld      a,(hl)                  ;ᨬ���
                push    hl
                ld      bc,Dss.WrChar           ;梥� � ॣ.B
                rst     DssRst
                pop     hl
                pop     bc
                djnz    DrawCorner

                ld      hl,TextStrReg
                ld      a,(Color.TextStrReg)    ;梥� ॣ���஢�� ���
                ld      (PrnStrColor.L1+5),a
                call    PrnStrColor
                ld      hl,TextStrWin
                ld      a,(Color.TextStrWin)    ;梥� ����஢ ����
                ld      (PrnStrColor.L1+5),a
                call    PrnStrColor
                ld      hl,TextStrLogo
                ld      a,(Color.TextStrLogo)   ;梥� ���� �ணࠬ��
                ld      (PrnStrColor.L1+5),a
                call    PrnStrColor
                ld      hl,TextStrRez
                ld      a,(Color.RezArea)       ;梥� १�����
                ld      (PrnStrColor.L1+5),a
                call    PrnStrColor
		ret
                ds      OrgAdr+0x700-$
Start1:
                call    PreparChar              ;�����⮢�� �ணࠬ����� ����� �����
;                ld      hl,(Reg._PC)
;                ld      hl,0
;                ld      (ListAdr),hl

                call    Refresh
                call    Keyb

Exit:
                ld      hl,(Rst38.Vect+1)       ;����⠭������� ����� DSS
                ld      (0039h),hl

		ld	a,(OSScreen)		;� ⥪��� ��࠭�� ��࠭�
		ld	b,a
		push	bc
		ld	a,(OSGrafMode)
		ld	c,Dss.SetVMod
		
;                ld      bc,0x0100+Dss.SelPage   ;����⠭������� ��࠭� DSS
                rst     DssRst
		pop	bc
		ld	a,(DemonScreen)
		cp	b
		jr	nz,ExitNext
		ld	de,0			;����⠭�������� ��࠭ �� ���.��࠭���
		ld	hl,#2050
		ld	ix,#c000
		ld	c,Dss.WinRest
		ld	a,(BufPage)
		push	af
		ld	b,a
		rst	DssRst
		pop	af
		ld	c,Dss.FreeMem		;�⤠�� ��࠭��� ���� ���⭮ ���
		rst	DssRst
		
ExitNext	
		ld      bc,Dss.Exit             ;��ଠ�쭮� �����襭��
                rst     DssRst                
Return		ret

Refresh:
                di
                ld      de,0x0104               ;�뢮� ���祭�� ॣ���஢
                ld      hl,(Reg._IX)
                call    PrintStrReg
                ld      de,0x0204
                ld      hl,(Reg._IY)
                call    PrintStrReg
                ld      de,0x0404
                ld      hl,(Reg._HL)
                call    PrintStrReg
                ld      de,0x0504
                ld      hl,(Reg._DE)
                call    PrintStrReg
                ld      de,0x0604
                ld      hl,(Reg._BC)
                call    PrintStrReg
                ld      de,0x0A04
                ld      hl,(Reg._HL_)
                call    PrintStrReg
                ld      de,0x0B04
                ld      hl,(Reg._DE_)
                call    PrintStrReg
                ld      de,0x0C04
                ld      hl,(Reg._BC_)
                call    PrintStrReg
                ld      de,0x0704
                ld      hl,(Reg._AF)
                call    PrintStrAF
                ld      de,0x0D04
                ld      hl,(Reg._AF_)
                call    PrintStrAF
                ld      de,0x1004
                ld      hl,(Reg._PC)
                call    PrintReg
                ld      de,0x100D
                ld      hl,(Reg._IR)
                call    PrintReg
                ld      de,0x1404
                ld      hl,(Reg._SP)
                call    PrintReg
                call    PrintSPDn
                ld      de,0x1413
                ld      hl,(RezAdr)
                call    PrintReg

                call    PrintStrWin             ;�뢮� ����஢ ����� � �����

                call    PrintStrSP              ;�뢮� ����� �⥪�

                call    PrintDump
                ei
                jp      DisAsm

DemonHelp	call	CursorRes
		ld	ix,HelpWnd
		jp	DialogWindow
		
;		ld	hl,HelpWndDlg
;		jp	WinDialog
HelpWnd		db	6,16,11,42,7,#27
		db	"DemoN Help Page",0
                db      " DemoN v"
                incbin  "VERSION\major.bin"
                db      "."
                incbin  "VERSION\minor.bin"
                db      " build "
                incbin  "VERSION\build.bin"
                db      " (alpha)-"
                incbin  "VERSION\date.bin"
		db	0x0D
		db	"    Igor by AlphA Studio, Hard/WCG",0x0D,0x0D
		db	"                  OK",0
HelpWndDlg	db	1			;����⥫� ����������� ����
		db	16+19,16,4,2
		dw	0,0

                include "EQU\dss_equ.asm";"D:\WORKAST\EQU\dss_equ"
                include "EQU\bios_equ.asm";"D:\WORKAST\EQU\bios_equ"
                include "EQU\port.asm";"D:\WORKAST\EQU\port"
                include "disasm.asm";"D:\WORKAST\DEMON\disasm"
                include "util.asm";"D:\WORKAST\DEMON\util"
                include "file.asm";"D:\WORKAST\DEMON\file"
                include "error.asm";"D:\WORKAST\DEMON\error"
                include "clock.asm";"D:\WORKAST\DEMON\clock"
                include "keyb.asm";"D:\WORKAST\DEMON\keyb"
                include "kreg.asm";"D:\WORKAST\DEMON\kreg"
                include "kstack.asm";"D:\WORKAST\DEMON\kstack"
                include "kdump.asm";"D:\WORKAST\DEMON\kdump"
                include "rez.asm";"D:\WORKAST\DEMON\rez"
                include "step.asm";"D:\WORKAST\DEMON\step"
                include "savescr.asm";"D:\WORKAST\DEMON\savescr"
                include "data.asm";"D:\WORKAST\DEMON\data"
                include "tabl.asm";"D:\WORKAST\DEMON\tabl"
		include	"loadbin.asm"
		include	"windows.asm"

EndOfDaemon	
		savebin	"demon.exe",STARTPRG,EndOfDaemon-STARTPRG