;[]=========================================================================[]
;[]                   �����ᥬ���� ������-�⫠�稪� DemoN                 []
;[] v0.01 - ��᫥���� ��������� 10.10.2004                                  []
;[] v0.02 - ��᫥���� ��������� 20.03.2005                                  []
;[] v0.03 - ��᫥���� ��������� 16.02.2006                                  []
;[] v0.10 - ��᫥���� ��������� 10.09.2006                                  []
;[]                                                                         []
;[] DisAsm         - �뢮� ���⨭��                                         []
;[] AttrList       - �뢮� ��ਡ�⮢ ��ப� ���⨭��                        []
;[] UpAdres        - ���� �।��饣� ���� ��ப� ���⨭��              []
;[] List           - �ନ஢���� ��ப� ���⨭��                           []
;[]=========================================================================[]

;[]=========================================================================[]
;[]                            �뢮� ���⨭��                               []
;[]=========================================================================[]
DisAsm:
                ld      hl,(ListAdr)            ;���� ��ࢮ� ��ப� ���⨭��
                ld      de,0x011A               ;���न���� ����
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
                ld      (hl),e                  ;���� ��ப� ���⨭��
                inc     hl
                ld      (hl),d
                ex      de,hl  
                pop     de

                call    AttrList                ;������ ��ப�

.L2             call    PrintReg
                pop     hl
                call    List
                pop     de

;                push    af                      ;����� ���� �६����

                ld      a,(ListFormat)          ;�ଠ�� �뢮�
                or      a
                call    nz,LFormat

                push    de
                push    hl
                di
                ld      a,21
                add     a,e
                ld      e,a                     ;����� ���न��� X
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                rst     BiosRst
;                ld      c,Dss.Locate
;                rst     DssRst
                ld      hl,List.String
                ld      bc,32*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                rst     BiosRst
                ei
;                ld      c,Dss.PChars
;                rst     DssRst
                pop     hl
                pop     de

                ;����� ����� ���� � ���� ��⪨ (�६����)
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
                ;end (�६����)

                inc     d                       ;᫥����� ��ப�
                ld      a,(KList.Descript)      ;���-�� ��ப ���⨭��
                cp      d
                jr      nc,.L1
                ret

;[]=========================================================================[]
;[]                     �뢮� ��ਡ�⮢ ��ப� ���⨭��                     []
;[] �室:  DE - ���न���� ���ᢥ⪨                                        []
;[]        HL - ⥪�騩 ���� ���⨭��                                      []
;[]=========================================================================[]
AttrList:
                di
                push    hl                      ;⥪�騩 ���� ���⨭��
                push    de                      ;⥪�騥 ���न����

                push    hl
                ld      bc,(Reg._PC)            ;���� �ணࠬ����� ���稪�
                or      a                       ;��� 䫠�� C
                sbc     hl,bc
                pop     hl
                jr      nz,.L2
                ld      a,(Color._PC)           ;梥� �ணࠬ����� �����
                jr      .L0

.L2             push    hl
                push    de
                push    hl
                ld      bc,Rezident.End-Rezident;����� १�����
                ld      hl,(RezAdr)             ;��砫� १�����
                push    hl
                add     hl,bc                   ;������ ���� १�����
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
                ld      a,(Color.RezArea)       ;梥� ������ ࠧ��饭�� १�����
                jr      .L0

.L3             ld      a,(Color.Screen)        ;�᭮���� 梥�

.L0             ld      (.L1+1),a
                dec     e
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                rst     BiosRst
.L1             ld      e,0                     ;梥� ���ᢥ⪨
                ld      bc,54*256+Bios.Lp_Print_Atr ;� ॣ.B ����� ��ப�
                rst     BiosRst
                pop     de
                pop     hl
                ei
                ret

;[]=========================================================================[]
;[]                  ����� �।��饣� ���� ��ப� ���⨭��              []
;[] �室:  HL - ���� ⥪�饩 ��ப�                                        []
;[] ��室: HL - ���� �।��饩 ��ப�                                     []
;[]=========================================================================[]
UpAdres:
                ld      de,-4
                add     hl,de                   ;4-� ���⭠� �������?
                call    Ld_a_hl
;                ld      a,(hl)
                cp      0xDD                    ;��䨪� 0xDD
                jr      z,$+8
                or      00110000b              ;��᪠ ��� ��䨪ᮢ 0xED,0xFD
                cp      0xFD
                jr      nz,.L1
                push    hl
                call    List
                pop     hl
                cp      4
                ret     z

.L1             inc     hl
                push    hl                      ;3-� ���⭠� �������?
                call    List
                pop     hl
                cp      3
                ret     z

                inc     hl
                push    hl                      ;2-� ���⭠� �������?
                call    List
                pop     hl
                cp      2
                ret     z

                inc     hl
                ret                             ;1-� ���⭠� �������!

;[]=========================================================================[]
;[]                     ��ଠ�஢���� ��ப� ���⨭��                      []
;[]=========================================================================[]
LFormat:
                push    hl
                ld      hl,List.String+11       ;��砫� ��ப�
                ld      bc,2                    ;���� ���-�� ��⠢�塞�� �஡����
.L2             ld      a,(hl)
                or      a
                jr      z,.Exit
                cp      0x20                    ;�஡��
                jr      z,.L1
                inc     hl
                dec     c
                jr      nz,.L2

.Exit           pop     hl
                ret

.L1             push    de
                push    bc
                push    hl
                ld      hl,List.String+30       ;����� ��ப�
                ld      d,h
                ld      e,l
                or      a
                sbc     hl,bc
                pop     bc
                push    bc
                push    hl
                sbc     hl,bc                   ;���-�� ����
                ld      b,h
                ld      c,l
                pop     hl
                lddr
                pop     hl
                pop     bc                      ;���-�� �஡����
                ld      b,c
.L3             inc     hl                      ;���� ��⠢��
                ld      a,0x20
                ld      (hl),a
                djnz    .L3
                pop     de
                pop     hl
                ret

;[]=========================================================================[]
;[]                      ��ନ஢���� ��ப� ���⨭��                       []
;[] �室:  HL - ���� ����� �����ᥬ���஢����                             []
;[] ��室: HL - ᫥���騩 �� �����ᥬ���஢����� �������� ���� �����      []
;[]        A  - ����� ���� �������                                          []
;[]=========================================================================[]
List:
                xor     a                       ;����� ���� �������
                ld      (.Byte),a
                push    hl
                ld      d,h
                ld      e,l

                ld      hl,.String              ;���⪠ ���� ��ப�
;                di                              ;� �ᯮ�짮������ ��ᥫ�
;                ld      d,d                     ;������� ��ᥫ�
;                ld      a,32                    ;����� ���� � ���� �������⥫�
;                ld      c,c                     ;������� ����������
;                ld      (hl),a                  ;���������
;                ld      b,b                     ;�몫���� ��ᥫ�
;                ei
                ld      a,32                    ;����� ���� � ���� �������⥫�
                ld      b,a
                ld      (hl),a
                inc     hl
                djnz    $-2

                ld      ix,.String+2            ;���� � ��ப� ��� ᫥�.����
                ex      de,hl
;                ld      a,(hl)                  ;���� �� �����
                call    Ld_a_hl

                ;===============================
                cp      0xDD                    ;��䨪� #DD
                jr      z,.L43
                cp      0xFD                    ;��䨪� #FD
                jp      nz,.L30

                ld      de,"DF"
                ld      a,"Y"
                jr      .L42

.L43            ld      de,"DD"
                ld      a,"X"

.L42            ld      (.String),de            ;��䨪� � ��ப�
                ld      (.IRS1+1),a             ;���४�஢�� ॣ.����
                ld      (.L9+1),a
                ld      (.L13+6),a
                ld      a,1
                ld      (.Byte),a               ;����� ���� �������
                pop     hl
                inc     hl
;                ld      a,(hl)                  ;᫥���騩 ���� �������
                call    Ld_a_hl
                push    hl
                cp      0xCB
                jr      z,.L40                  ;������� #DD(#FD)#CB

                ld      hl,CodeDDFD             ;⠡��� �����
                ld      bc,85                   ;ࠧ��� ⠡����
                cpir                            ;���� ����
                jr      z,.L45
                pop     hl
                ld      bc,ED00
                ld      de,.String+9            ;����஢���� ��������� NOP *
                ld      a,(bc)
                or      a
                ret     z
                ld      (de),a
                inc     de
                inc     bc
                jr      $-6

.L45            ld      hl,84                   ;ࠧ��� ⠡����
                or      a
                sbc     hl,bc
                ld      de,TablDDFD
                jp      .L_12+3
                
.L40            ld      ix,.String+4            ;���� � ��ப� ��� ᫥�.����
                ld      de,"BC"                 ;��䨪� � ��ப�
                ld      (.String+2),de
                ld      a,4                     ;����� ����
                ld      (.Byte),a
                pop     hl
                inc     hl
                call    Ld_a_hl
                ld      b,a
;                ld      b,(hl)                  ;����-ᬥ饭��
                inc     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;᫥���騩 ���� �������
                inc     hl
                push    hl
                ld      c,a
                ld      h,0
                cp      0x40                    ;�� 0 �� 0x3F (ᤢ���)
                jr      c,.L44

                call    .ComCBBit               ;��������� BIT,SET,RES
                ld      a,c
                cp      0x80                    ;������� BIT
                jr      nc,.L41
                call    .NomBit                 ;����� ���
                call    .IndexRegSh             ;�����᭠� ��� � ᬥ饭���
                jr      .L46

.L41            call    .NomBit                 ;����� ���
                jr      .L44+3

.L44            call    .ComCBSh                ;���������
                call    .RegName                ;ॣ����
                jr      nz,$+6
                ld      a,","                   ;ࠧ����⥫�
                ld      (de),a
                inc     de
                call    .IndexRegSh             ;�����᭠� ��� � ᬥ饭���

.L46            ld      a,c
                call    ConvHexStr
                ld      (ix+2),l
                ld      (ix+3),h
                pop     hl
                ret

                ;===============================
.L30            cp      0xCB                    ;��䨪� #CB
                jp      nz,.L20
                ld      de,"BC"                 ;��䨪� � ��ப�
                ld      (.String),de
                pop     hl
                inc     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;᫥���騩 ���� �������
                inc     hl
                push    hl
                ld      c,a
                ld      h,0
                cp      0x40                    ;�� 0 �� 0x3F (ᤢ���)
                jr      nc,.L31
                call    .ComCBSh                ;���������
                jr      .L31+6
.L31            call    .ComCBBit               ;���������
                call    .NomBit                 ;����� ���
                call    .RegName                ;ॣ����
                call    nz,.HLReg
                ld      a,c
                call    ConvHexStr
                ld      (ix+0),l
                ld      (ix+1),h
                pop     hl
                ld      a,2                     ;����� ���� �������
                ret

                ;===============================
.L20            cp      0xED                    ;��䨪� #ED
                jr      nz,.L10
                ld      a,1
                ld      (.Byte),a               ;����� ����
                ld      de,"DE"                 ;��䨪� � ��ப�
                ld      (.String),de
                pop     hl
                inc     hl
                push    hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;᫥���騩 ���� �������
                cp      0x40                    ;�� 0 �� 0x3F
                jr      c,.L21
                ld      de,TablED-0x40*2
                cp      0x7F                    ;�� 0x40 �� 0x7E �� ⠡����
                jr      c,.L_12
                cp      0xA0                    ;�� 0x7F �� 0x9F
                jr      c,.L21
                ld      de,TablED-0xA0*2+0x40*2-2
                cp      0xBC                    ;�� 0xBC �� 0xFF
                jr      c,.L_12
.L21            ld      hl,ED00                 ;������� "NOP *"
                jr      .L_2-3

                ;===============================
.L10            ld      ix,.String
                ld      de,Tabl00_3F            ;⠡��� ᬥ饭��
                cp      0x40                    ;������� 0x00...0x3F
                jr      c,.L_12
                ld      de,TablC0_FF            ;⠡��� ᬥ饭��
                ld      c,a
                sub     0xC0                    ;������� 0xC0...0xFF
                jr      nc,.L_12

                ld      a,c
                cp      0x80
                jr      nc,.L8
                ld      hl,MHALT
                cp      0x76                    ;��� ������� HALT
                jr      z,.L_2-3

                ld      hl,.String+9
                ld      (hl),"L"                ;��������� LD
                inc     hl
                ld      (hl),"D"
                inc     hl
                ld      (hl)," "
                inc     hl
                rrca
                rrca
                rrca
                ex      de,hl
                call    .RegName+1              ;����� ॣ����
                call    nz,.HLReg
                ld      a,","                   ;ࠧ����⥫�
                ld      (de),a
                inc     de
                call    .RegName                ;����� ॣ����
                call    nz,.HLReg
                xor     a
                jr      .L1

.L8             and     00111000b              ;ADD,ADC,SUB,SBC,AND,XOR,OR,CP
                rrca
                rrca
                ld      l,a
                ld      h,0
                ld      de,TablM
                add     hl,de                   ;ᬥ饭�� � ⠡���
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a
                ld      de,.String+9            ;����஢���� � ��ப�-����
                ld      a,(hl)
                ld      (de),a
                inc     de
                inc     hl
                or      a
                jr      nz,$-5
                dec     de
                call    .RegName                ;����� ॣ����
                call    nz,.HLReg
                xor     a
                jr      .L1

.L_12           ld      l,a                     ;���� ���� � ⠡���
                ld      h,0
                add     hl,hl                   ;*2
                add     hl,de
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a                     ;���� ��ப�-���������

                ld      de,.String+9            ;����஢���� � ��ப�-����
.L_2            ld      a,(hl)
                cp      0x20
                jr      c,.L1
                cp      "x"                     ;������� ॣ����
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
                pop     hl                      ;����� ����
                call    Ld_a_hl
;                ld      a,(hl)
                inc     hl
                push    hl
                call    ConvHexStr
                ld      (ix+0),l
                ld      (ix+1),h
                exa
                jp      z,.LE

                dec     a                       ;2-� ���⭠� ������� (1)
                jr      nz,.L3
                call    .TwoByteCom
                pop     hl
                ld      a,(.Byte)
                inc     a
                inc     a                       ;����� ����
                ret

.L3             dec     a                       ;3-� ���⭠� ������� (2)
                jr      nz,.L4
                call    .ThreeByteCom
                pop     hl
                ld      a,(.Byte)
                add     a,3                     ;����� ����   
                ret

.L4             dec     a                       ;������� �⭮�⥫쭮�� ���室� (3)
                jr      nz,.L7
                pop     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;2-� ���� �������
                inc     hl
                push    hl
                ld      c,a
                call    ConvHexStr
                ld      (ix+2),l
                ld      (ix+3),h
                ld      a,c
                ld      b,0
                pop     hl
                push    hl                      ;⥪�騩 ����
                bit     7,a                     ;���� �᫠
                jr      z,$+10
                neg
                or      a                       ;��� 䫠�� C
                ld      c,a
                sbc     hl,bc                   ;����⥫쭮� ᬥ饭��
                jr      $+3
                add     hl,bc                   ;������⥫쭮� ᬥ饭��
                call    NumToStr16
                pop     hl
                ld      a,2                     ;����� ����
                ret

.L7             dec     a                       ;������� ࠡ��� � ���⠬� (4)
                jr      nz,.L5
                inc     a
                ld      (.Byte),a               ;����� ����
                ld      de,(.StrAdr)            ;���� ��⠢��
                call    .TwoByteCom
                jr      .L6

.L5             dec     a                       ;3-� ����� ��ᢥ���� ����樨 (5)
                jr      nz,.L11
                ld      a,(.Byte)
                inc     a
                inc     a
                ld      (.Byte),a               ;����� ����
                ld      de,(.StrAdr)            ;���� ��⠢��
                call    .ThreeByteCom
                jr      .L6

.L11            dec     a                       ;������� ॣ����� � ᬥ饭��� (6)
                jr      nz,.LE
                ld      a,2
                ld      (.Byte),a               ;����� ����
                ld      de,(.StrAdr)            ;���� ��⠢��
                pop     hl
                call    Ld_a_hl
                ld      b,a
;                ld      b,(hl)
                inc     hl
                push    hl
                ld      ix,.String+4
                call    .IndexRegSh
.L6             ld      hl,(.TablAdr)           ;���� � ⠡��� ��������
                ld      a,(hl)
                cp      0x20
                jr      nc,.L13
                ld      a,b
                cp      ","                     ;��������� �����. �� ","
                jr      nz,.LE
                call    .TwoByteCom
                pop     hl
                ld      a,4                     ;����� ����
                ret

.L13            ld      b,a
                cp      "x"                     ;������� ॣ����
                jr      nz,$+4
                ld      a,"X"
                ld      (de),a
                inc     hl
                inc     de
                jr      .L6+3

.LE             pop     hl
                ld      a,(.Byte)               ;����� ����
                inc     a
                ret

;======== ����� ��ண� ���� ���塠�⭮� ������� ========
.TwoByteCom:
                pop     bc                      ;���� ������
                pop     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;2-� ���� �������
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

;======== ����� ��ண� � ���쥣� ���� ��塠�⭮� ������� ========
.ThreeByteCom:
                pop     bc                      ;���� ������
                pop     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;2-� ���� �������
                inc     hl
                exa
                call    Ld_a_hl
;                ld      a,(hl)                  ;3-� ���� �������
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
                ld      h,b                     ;� HL - �᫮
                ld      l,c
                jp      NumToStr16

;======== ����� �������� ������ � ��䨪ᮬ 0xCB (ᤢ���, ��⮢�) ========
;A - ���� �������
;DE - ���� � ��ப�
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
                and     00111000b              ;ᬥ饭�� � ⠡���
                rrca
                rrca
                ld      l,a
                ld      de,TablCB
                add     hl,de
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a
.ComCBSh1       ld      de,.String+9            ;����஢���� � ��ப�-����
                ld      a,(hl)
                ld      (de),a
                inc     de
                inc     hl
                cp      " "                     ;��᫥���� ᨬ��� ���������
                jr      nz,$-6
                ret

;======== ���᫥��� ����� ��� � ��⮢�� �������� BIT, SET, RES ========
;C - ���� �������
;DE - ���� � ��ப�
.NomBit:
                ld      a,c
                and     00111000b              ;����� ���
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

;======== ����� ����� ॣ���� ========
;C - �������
;DE - ���� � ��ப�
.RegName:
                ld      a,c
                and     00000111b              ;ॣ����
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
                ret     nz                      ;�⭮�⥫쭠� ������
.RN1            ld      (de),a
                inc     de
                xor     a
                ret

;======== ����� (HL) ========
;DE - ���� � ��ப�
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

;======== ����� �����᭮� ॣ���஢�� ���� � ᬥ饭��� ========
;B - ᬥ饭��
;DE - ���� � ��ப�
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
                ld      a,"+"                   ;������⥫쭮� ᬥ饭��
                ld      (hl),a
                ld      a,b                     ;ᬥ饭��
                bit     7,b
                jr      z,$+8
                ld      a,"-"                   ;����⥫쭮� ᬥ饭��
                ld      (hl),a
                ld      a,b                     ;ᬥ饭��
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

