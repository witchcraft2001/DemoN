;[]=========================================================================[]
;[]               ����ணࠬ��-�⨫��� ������-�⫠�稪� DemoN             []
;[] v0.01 - ��᫥���� ��������� 29.08.2004                                  []
;[] v0.02 - ��᫥���� ��������� 20.03.2005                                  []
;[] v0.03 - ��᫥���� ��������� 25.02.2006                                  []
;[] v0.10 - ��᫥���� ��������� 17.05.2006                                  []
;[]                                                                         []
;[] SaveAllRegs    - ��࠭���� ���祭�� ॣ���஢�� ���                    []
;[] RestAllRegs    - ���⠭������� ���祭�� ॣ���஢�� ���                 []
;[] PrnStrColor    - ����� ��ப� ᨬ����� � ��ਡ�⠬�                    []
;[] PrintReg       - ����� ���塠�⮢��� �᫠                             []
;[] PrintStrAF     - ����� ���祭�� ॣ���஢�� ���� AF � 䫠���           []
;[] PrintStrReg    - ����� ���祭�� ॣ���஢�� ��� � ����㥬묨 ���⠬�  []
;[] PrintStrWin    - ����� ����஢ ����� � �����                           []
;[] PrintSPDn      - ����� ��㡨�� �⥪�                                   []
;[] PrintStrSp     - ����� ���祭�� �⥪�                                  []
;[] PrintDump      - ����� �����                                           []
;[] PrintStrDump   - ����� ��ப� �����                                    []
;[] ReplSymNoPrint - ������ �������� ᨬ����� � ��ப�                    []
;[] NumToStr16     - �ନ஢���� 16-��筮�� �᫠                        []
;[] NumToStr8      - �ନ஢���� 8-�筮�� �᫠                           []
;[] ConvHexStr     - �������஢���� �᫠ � HEX-��ப�                     []
;[] ConvDecStr     - �������஢���� 16-��⭮�� �᫠ � DEC-��ப�          []
;[] CursorSet      - ���ᮢ�� �����                                     []
;[] CursorRes      - ���⠭������� ��࠭� ��� ����஬                      []
;[] Ld_a_bc        - �⥭�� ���� �� ����� � �஢�મ� ����, ���� � BC  []
;[] Ld_a_hl        - �⥭�� ���� �� ����� � �஢�મ� ����, ���� � HL  []
;[] Ld_hl_a        - ������ ���� � ������ � �஢�મ� ����, ���� � HL   []
;[] AdrArea        - ��।������ �ਭ��������� ���� ������ �����       []
;[]=========================================================================[]

;[]=========================================================================[]
;[]                   ���࠭���� ���祭�� ॣ���஢�� ���                   []
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

                ld      hl,WinPage              ;��࠭���� ����஢ ��࠭��
                in      a,(EmmWin.P0)           ;0-� ����
                ld      (hl),a
                inc     hl
                in      a,(EmmWin.P1)           ;1-� ����
                ld      (hl),a
                inc     hl
                in      a,(EmmWin.P2)           ;2-� ����
                ld      (hl),a
                inc     hl
                in      a,(EmmWin.P3)           ;3-� ����
                ld      (hl),a
                ret

;[]=========================================================================[]
;[]                 ���⠭������� ���祭�� ॣ���஢�� ���                  []
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
;[]                         ����� ��ப� ᨬ�����                          []
;[] �室:  HL - ���� ��ப� ᨬ�����                                       []
;[]                                                                         []
;[] ��ଠ� ��ப�: 0x16, �⮫���, ��ப�, �������, 0x00                     []
;[]=========================================================================[]
                ld      a,(Color.Screen)        ;�᭮���� 梥�
                ld      (PrnStrColor.L1+5),a
PrnStrColor:
                ld      a,(hl)
                cp      0x16                    ;��� ��⠭���� ����樨 �����
                jr      nz,.L2
                inc     hl
                ld      e,(hl)                  ;�⮫���
		ld	a,e
		ld	(PrtXCoord),a
                inc     hl
                ld      d,(hl)                  ;��ப�
                inc     hl
                ld      a,(hl)                  ;ᨬ���
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
                ret     z                       ;��室 �᫨ ����� ��ப�
                push    hl
                push    de
;����� �/� ���� ��� ���?
	ifdef D_PRINTCH_BIOS
                ld      h,0x03                  ;��ਡ��
                ld      l,a
                sub     a                       ;�����䨪��� ����
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
;[]                    ����� ���塠�⮢��� �᫠                           []
;[] �室:  DE - ���न���� ����                                           []
;[]        HL - ���祭�� ॣ���஢�� ����                                   []
;[]=========================================================================[]
PrintReg:
                di
                push    hl
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                rst     BiosRst
                pop     hl

                ld      a,(DecHex)              ;��⥬ ��᫥���
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
                ld      (.String+1),hl          ;���訩 ����
                ld      a,c
                call    ConvHexStr
                ld      (.String+3),hl          ;����訩 ����
.Print          ld      hl,.String              ;���⠥��� ��ப�
                ld      bc,5*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                rst     BiosRst
                ei
                ret

.String         db      "#0123"

;[]=========================================================================[]
;[]              ����� ���祭�� ॣ���஢�� ���� AF � 䫠���               []
;[] �室:  DE - ���न���� ����                                           []
;[]        HL - ���祭�� ॣ���஢�� ����                                   []
;[]=========================================================================[]
PrintStrAF:
                ld      a,h                     ;���祭�� ॣ���� A
                push    hl
                ld      (.String+11),a

                ld      hl,.String+1            ;����筮� ���祭��
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
                ld      a,l                     ;䫠��
                push    hl
                ld      hl,.Flags
                ld      b,8
                res     3,a                     ;��� ���������� 䫠���
                res     5,a
.L2             rlca
                jr      c,$+6
                set     5,(hl)                  ;��襭
                jr      $+4     
                res     5,(hl)                  ;��⠭�����
                inc     hl
                djnz    .L2
                pop     hl

                push    de
                call    PrintReg                ;����� ���祭�� ॣ.����
                pop     de
                push    de
                ld      a,6
                add     a,e
                ld      e,a
                ld      c,Bios.Lp_Set_Place
                di
                rst     BiosRst
                ld      hl,.String
                ld      bc,13*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
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
                ld      bc,8*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                di
                rst     BiosRst
                ei
                ret

.String         db      '%01010101 " "'
.Flags          db      "SZ.H.PNC"

;[]=========================================================================[]
;[]          ����� ���祭�� ॣ���஢�� ��� � ����㥬묨 ���⠬�          []
;[] �室:  DE - ���न���� ����                                           []
;[]        HL - ���祭�� ॣ���஢�� ����                                   []
;[]=========================================================================[]
PrintStrReg:
                push    hl
                ld      b,h
                ld      c,l

                call    Ld_a_bc                 ;ld a,(bc) ����㥬� �����
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

                ld      hl,.String+10           ;������ �������� ᨬ�����
                ld      b,4
                call    ReplSymNoPrint

                pop     hl
                push    de
                call    PrintReg                ;����� ���祭�� ॣ.����
                pop     de
                di
                ld      a,6
                add     a,e
                ld      e,a
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                rst     BiosRst
                ld      hl,.String              ;���⠥��� ��ப�
                ld      bc,14*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                rst     BiosRst
                ei
                ret

.String         db      "0123 4567 ABCD"

;[]=========================================================================[]
;[]                       ����� ����஢ ����� � �����                      []
;[] �室:  HL - ���� ��࠭����� ����஢                                   []
;[]=========================================================================[]
PrintStrWin:
                ld      hl,WinPage              ;�뢮� ����஢ ����� � �����
                ld      de,.String+3
                ld      b,4
.L1             push    bc
                ld      a,(hl)
                inc     hl
                push    hl
                ld      l,a
                ld      h,0
                call    NumToStr8               ;�������஢���� � HEX-��ப�
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
;[]                         ����� ��㡨�� �⥪�                            []
;[]=========================================================================[]
PrintSPDn:
                ld      a,(StackDown)
                ld      l,a
                ld      a,0x7F
                cp      l                       ;����⥫쭮�?
                jr      nc,.L1
                res     7,l                     ;����� �����
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
                ld      a,(hl)                  ;��襭�� �������� �㫥�
                cp      c
                jr      nz,$+8
                ld      a,0x20
                ld      (hl),a
                inc     hl
                djnz    $-8
                ld      a,(StackDown)
                bit     7,a
                jr      z,$+6
                dec     hl                      ;����⥫쭮� �᫮
                ld      a,"-"
                ld      (hl),a

                ld      de,0x140A
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                di
                rst     BiosRst
                ld      hl,.String              ;���⠥��� ��ப�
                ld      bc,4*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                di
                rst     BiosRst
                ei
                ret

.String         ds      4

;[]=========================================================================[]
;[]                          ����� ���祭�� �⥪�                          []
;[]=========================================================================[]
PrintStrSP:
                ld      a,(.StrSp)              ;��ப� � ���設�� �⥪�
                inc     a
                jr      z,.L4                   ;�᫨ ���設� �⥪� �� �������� � ����
                ld      hl,(Reg._SP)
                dec     hl
                dec     hl
                inc     hl
                inc     hl
                dec     a
                jr      nz,$-3
                ld      (StackDump),hl

.L4             ld      hl,(StackDump)          ;��砫� �����
                ld      de,#1601                ;���न���� ����
                ld      a,-1
                ld      (.StrSp),a

                ld      b,8                     ;���-�� ��ப �����
.L3             push    bc
                push    de                      ;���न����
                push    hl
                or      a                       ;��� 䫠�� C
                ld      a,b
                ld      bc,(Reg._SP)            ;���� ���設� �⥪�
                sbc     hl,bc
                jr      nz,.L2
                ld      b,a
                ld      a,8
                sub     b
                ld      (.StrSp),a              ;����� ��ப� � ����� � ���設�� �⥪�
                ld      a,(Color._SP)           ;梥� ���設� �⥪�
                jr      .L2+3
.L2             ld      a,(Color.Screen)        ;�᭮���� 梥�
                ld      (.L1+1),a               ;����ᠫ� 梥�
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                di
                rst     BiosRst
.L1             ld      e,0                     ;梥� ���ᢥ⪨
                ld      bc,11*256+Bios.Lp_Print_Atr ;� ॣ.B ����� ��ப�
                rst     BiosRst
                pop     hl
                pop     de
                push    de
                push    hl
                call    PrintReg                ;����� ����
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

                call    PrintReg                ;����� ���祭�� �⥪�
                pop     hl
                pop     de
                inc     d
                pop     bc
                djnz    .L3
                ei
                ret

.StrSp          db      6

;[]=========================================================================[]
;[]                              ����� �����                               []
;[]=========================================================================[]
PrintDump:
                ld      de,0x160E               ;���न����
                ld      hl,(Dump1)
                ld      b,8                     ;������⢮ ��ப
                push    de
                push    bc
                push    hl
                call    PrintStrDump
                pop     hl
                ld      bc,16
                add     hl,bc
                pop     bc
                pop     de
                inc     d                       ;᫥����� ��ப�
                djnz    $-14
                ret

                ld      hl,Dump                 ;�뢮� �����
;                ld      de,0x160E               ;���न����
                ld      b,8                     ;������⢮ ��ப
                push    de
                push    bc
                ld      c,(hl)                  ;����訩 ���� ����
                inc     hl
                push    hl
                ld      h,(hl)                  ;���訩 ���� ����
                ld      l,c
                call    PrintStrDump
                pop     hl
                inc     hl
                pop     bc
                pop     de
                inc     d                       ;᫥����� ��ப�
                djnz    $-15
                ret

;[]=========================================================================[]
;[]                           ����� ��ப� �����                           []
;[] �室:  DE - ���न���� ����                                           []
;[]        HL - ���� ��砫� ��ப�                                         []
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
                call    ReplSymNoPrint          ;������ �������� ᨬ�����

                pop     hl
                pop     de
                push    de
                call    PrintReg                ;����� ���� ��ப�
                pop     de
                di
                ld      a,7
                add     a,e
                ld      e,a
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                rst     BiosRst
                ld      hl,.String
                ld      bc,57*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                rst     BiosRst
                ei
                ret

.String         db      "1000 2000 3000 4000 5000 6000 7000 8000  "
                db      "0123456789ABCDEF"

;[]=========================================================================[]
;[]                   ������ �������� ᨬ����� � ��ப�                   []
;[] �室:  B  - ����� ��ப�                                                []
;[]        HL - ���� ��砫� ��ப�                                         []
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
;[]                  ��ନ஢���� 16-⨡�⭮�� �᫠                        []
;[] �室:  DE - ���� ����                                                []
;[]        HL - �᫮                                                       []
;[]=========================================================================[]
NumToStr16:
                ld      a,(DecHex)              ;��⥬ ��᫥���
                or      a
                jp      nz,ConvDecStr

                ld      a,"#"
                ld      (de),a
                inc     de
                ld      c,l
                ld      a,h
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e                  ;���訩 ����
                inc     hl
                ld      (hl),d
                inc     hl
                ex      de,hl
                ld      a,c
                call    ConvHexStr
                ex      de,hl
                ld      (hl),e                  ;����訩 ����
                inc     hl
                ld      (hl),d
                inc     hl
                ex      de,hl
                ret

;[]=========================================================================[]
;[]                    ��ନ஢���� 8-��⭮�� �᫠                         []
;[] �室:  DE - ���� ����                                                []
;[]        HL - �᫮                                                       []
;[]=========================================================================[]
NumToStr8:
                ld      a,(DecHex)              ;��⥬ ��᫥���
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
;[]                    �������஢���� �᫠ � HEX-��ப�                   []
;[] �室:  A  - �᫮                                                       []
;[] ��室: HL - HEX-��ப�                                                  []
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
;[]             �������஢���� 16-��⭮�� �᫠ � DEC-��ப�               []
;[] �室:  HL - �᫮                                                       []
;[]        DE - ���� ��砫� DEC-��ப�                                     []
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
;[]                           ���ᮢ�� �����                            []
;[] �室:  B  - ����� �����                                               []
;[]        HL - ���न���� �����                                          []
;[]=========================================================================[]
CursorSet:
                ld      (CursorRes+1),hl
                ex      de,hl
                ld      l,b                     ;ࠧ��� �� ���⨪���
                ld      h,1                     ;ࠧ��� �� ��ਧ��⠫�
                ld      (CursorRes+4),hl
                ld      ix,.Buffer
                push    de
                push    hl
                push    ix
                push    bc
	ifdef	D_PRINTCH_BIOS
                xor     a
                ld      c,Bios.Win_Copy_Win     ;����஢���� � ����
                di
                rst     BiosRst
                ei
	else
		ld	a,(BankDebug)
		ld	b,a
		ld	c,Dss.WinCopy
		rst	DssRst
	endif

                pop     bc                      ;� B ����� �����
                pop     hl
                push    hl
                inc     hl
                ld      a,(hl)                  ;梥� ᨬ�����
                ld      (CursorRes.L1+1),a
                ld      a,(Color.Cursor)
.L1             ld      (hl),a
                inc     hl                      ;� ����� 梥�
                inc     hl
                djnz    .L1

                pop     ix
                pop     hl
                pop     de
	ifdef	D_PRINTCH_BIOS
                xor     a
                ld      c,Bios.Win_Restore_Win  ;�뢮� ����� �� ��࠭
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

.Buffer         ds      22*2                    ;max ����� �����

;[]=========================================================================[]
;[]                    ���⠭������� ��࠭� ��� ����஬                    []
;[]=========================================================================[]
CursorRes:
                ld      de,0                    ;���न����
                ld      hl,0                    ;ࠧ���
                ld      b,l                     ;�����
                push    de
                push    hl
                ld      hl,CursorSet.Buffer
                push    hl
.L1             ld      a,0                     ;梥�
                inc     hl                      ;� ����� 梥�
                jr      CursorSet.L1

;[]=========================================================================[]
;[]                 �⥭�� ���� �� ����� � �஢�મ� ����               []
;[] �室:  BC ��� HL - ���� � �����                                       []
;[] ��室: A  - ��⠭�� ����                                              []
;[]=========================================================================[]
Ld_a_bc:
                ld      a,11000000b            ;�஢�ઠ ���������
                and     b
                jr      z,.L1                   ;� 0-� ����
                cp      10000000b              ;�� 2-�� ����
                ld      a,(bc)
                ret     nz                      ;�����頥� ����, �᫨ ���
                ld      a,(WinPage+2)           ;����� ����� ��� �⫠�稪��
                out     (EmmWin.P3),a           ;� ���� ���� ��
                set     6,b                     ;���४��㥬 ����
                ld      a,(bc)                  ;�⠥� ����
                res     6,b                     ;���⠭�������� ����
                jr      Ld_a_hl.L1
.L1             ld      a,(WinPage)             ;����� ����� � 0-�
                out     (EmmWin.P3),a           ;� ���� ���� ��
                set     6,b                     ;���४��㥬 ����
                set     7,b
                ld      a,(bc)                  ;�⠥� ����
                res     6,b                     ;���⠭�������� ����
                res     7,b
                jr      Ld_a_hl.L1
Ld_a_hl:
                ld      a,11000000b            ;�஢�ઠ ���������
                and     h
                jr      z,.L2                   ;� 0-� ����
                cp      10000000b              ;�� 2-�� ����
                ld      a,(hl)
                ret     nz                      ;�����頥� ����, �᫨ ���
                ld      a,(WinPage+2)           ;����� ����� ��� �⫠�稪��
                out     (EmmWin.P3),a           ;� ���� ���� ��
                set     6,h                     ;���४��㥬 ����
                ld      a,(hl)                  ;�⠥� ����
                res     6,h                     ;���⠭�������� ����
                jr      .L1
.L2             ld      a,(WinPage)             ;����� ����� � 0-� ����
                out     (EmmWin.P3),a           ;� ���� ���� ��
                set     6,h                     ;���४��㥬 ����
                set     7,h
                ld      a,(hl)                  ;�⠥� ����
                res     6,h                     ;���⠭�������� ����
                res     7,h
.L1             push    af
                ld      a,(WinPage+3)           ;����� ����� �� 3-�� ����
                out     (EmmWin.P3),a           ;���⠭��������
                pop     af
                ret

;[]=========================================================================[]
;[]                 ������ ���� � ������ � �஢�મ� ����                []
;[] �室:  HL - ���� � �����                                              []
;[]        A  - �����뢠��� ����                                           []
;[]=========================================================================[]
Ld_hl_a:
                push    af
                ld      a,11000000b            ;�஢�ઠ ���������
                and     h
                jr      z,.L2                   ;� 0-�� ����
                cp      10000000b              ;�� 2-�� ����?
                jr      z,.L1
                pop     af
                ld      (hl),a                  ;����ᠫ� ����, �᫨ ���
                ret
.L1             ld      a,(WinPage+2)           ;����� ����� ��� �⫠�稪��
                out     (EmmWin.P3),a           ;� ���� ���� ��
                set     6,h                     ;���४��㥬 ����
                pop     af
                ld      (hl),a                  ;��襬 ����
                jr      .L3
.L2             ld      a,(WinPage)             ;����� ����� � 0-��
                out     (EmmWin.P3),a           ;� ���� ���� ��
                set     6,h                     ;���४��㥬 ����
                set     7,h
                pop     af
                ld      (hl),a                  ;��襬 ����
                res     7,h                     ;���⠭�������� ����
.L3             res     6,h
                ld      a,(WinPage+3)           ;����� ����� �� 3-�� ����
                out     (EmmWin.P3),a           ;���⠭��������
                ret

;[]=========================================================================[]
;[]            ��।������ �ਭ��������� ���� ������ �����             []
;[] �室:  HL - ������ ���� ������ �����                                 []
;[]        DE - ���孨� ���� ������ �����                                []
;[]        BC - ����                                                       []
;[] ��室: 䫠� C  - ���� �� �ਭ������� ������ �����                    []
;[]        䫠� NC - ���� �ਭ������� ������ �����                       []
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

