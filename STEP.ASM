;[]=========================================================================[]
;[]                       �⫠��� ������ �ணࠬ��                          []
;[] v0.03 - ��᫥���� ��������� 10.03.2006                                  []
;[] v0.10 - ��᫥���� ��������� 18.03.2006                                  []
;[]=========================================================================[]
Step:
                di
                ld      a,(WinPage+2)           ;����� ��� demon'��
                ld      (Rezident.Start1+1),a   ;� १����� ��
                ld      (.BankP+1),a
                ld      a,(BankDebug)           ;����� � demon'��
                ld      (Rezident.BankD+1),a    ;� १����� ��
                ld      (Rezident.BankD1+2),a
                ld      hl,Step.Run+3           ;�窠 ������ � �⫠�稪
                ld      (Rezident.Return+1),hl  ;�ய��뢠�� � १�����
                ld      a,l
                ld      (Rezident.Return1+2),a
                ld      a,h
                ld      (Rezident.Return1+7),a
                ld      hl,(Reg._PC)
                ld      (Rezident.Step+1),hl    ;���� �⫠�������� �������

                ld      a,(Reg._AF)             ;䫠�
                ld      b,a
                call    Ld_a_hl
;                ld      a,(hl)                  ;��� �������

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
                jp      nz,.L2                  ;��� ��室� � ����ணࠬ��
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
                jp      nz,.L2                  ;��� �⫠��� 横��
                ld      a,(Reg._BC+1)
                dec     a
                jr      nz,.L6
                jp      .L2
.L18            inc     hl                      ;᫥���騩 ���� ᮬ����
                exa
                call    Ld_a_hl
                ld      c,a
                exa
;                ld      c,(hl)
                dec     hl
                cp      0xED                    ;��䨪� ��� RETI, RETN
                jr      nz,.L10
                ld      a,c
                cp      0x4D                    ;RETI
                jp      z,.L9
                cp      0x45                    ;RETN
                jp      z,.L9
.L10            cp      0xDD                    ;��䨪� ��� IX
                jr      nz,.L25
                ld      a,c
                cp      0xE5                    ;PUSH IX
                call    z,.SpdInc
                cp      0xE1                    ;POP IX
                call    z,.SpdDec
                ld      de,(Reg._IX)
                jr      .L24
.L25            cp      0xFD                    ;��䨪� ��� IY
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
                bit     0,b                     ;䫠� C
                jp      z,.L2                   ;��� ���室�
                jr      .L6                     ;���室
.L19            cp      0x30                    ;JR NC,
                jr      nz,.L20
                bit     0,b                     ;䫠� C
                jp      nz,.L2                  ;��� ���室�
                jr      .L6                     ;���室
.L20            cp      0x28                    ;JR Z,
                jr      nz,.L21
                bit     6,b                     ;䫠� Z
                jp      z,.L2                   ;��� ���室�
                jr      .L6                     ;���室
.L21            cp      0x20                    ;JR NZ,
                jr      nz,.L22
                bit     6,b                     ;䫠� Z
                jp      nz,.L2                  ;��� ���室�

.L6             inc     hl
                call    Ld_a_hl
;                ld      a,(hl)                  ;ᬥ饭��
                inc     hl
                ld      b,0
                ld      c,a
                bit     7,a                     ;���� �᫠
                jr      z,$+11
                neg
                or      a                       ;��� 䫠�� C
                ld      c,a
                sbc     hl,bc                   ;����⥫쭮� ᬥ饭��
                jp      .L2+3
                add     hl,bc                   ;������⥫쭮� ᬥ饭��
                jp      .L2+3

.L22            and     11000111b
                cp      11000111b              ;RST x
                jr      nz,.L27
                ld      a,(.Flag)
                inc     a
                jp      nz,.L2                  ;��� ��室� � ����ணࠬ��
                call    .SpdInc
                call    Ld_a_hl
;                ld      a,(hl)                  ;���� ������
                and     00111000b              ;���� ���室�
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
                jr      nz,.L2                  ;��� ��室� � ����ணࠬ��
.L26            call    Ld_a_hl
;                ld      a,(hl)                  ;��� �������
                and     00111000b              ;䫠��
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
                bit     7,b                     ;JP/CALL/RET M, 䫠� S
                jr      z,.L2                   ;��� ���室�
                jr      .L5                     ;���室
.L11            bit     6,b                     ;䫠� Z
                jr      nz,.L2                  ;��� ���室�
                jr      .L5                     ;���室
.L12            bit     6,b                     ;䫠� Z
                jr      z,.L2                   ;��� ���室�
                jr      .L5                     ;���室
.L13            bit     0,b                     ;䫠� C
                jr      nz,.L2                  ;��� ���室�
                jr      .L5                     ;���室
.L14            bit     0,b                     ;䫠� C
                jr      z,.L2                   ;��� ���室�
                jr      .L5                     ;���室
.L15            bit     2,b                     ;䫠� P/V
                jr      nz,.L2                  ;��� ���室�
                jr      .L5                     ;���室
.L16            bit     2,b                     ;䫠� P/V
                jr      z,.L2                   ;��� ���室�
                jr      .L5                     ;���室
.L17            bit     7,b                     ;䫠� S
                jr      nz,.L2                  ;��� ���室�

.L5             call    Ld_a_hl
;                ld      a,(hl)                  ;��� �������
                and     00000111b              ;��᫥���� RET'�
                jr      nz,.L8-4
.L9             call    .SpdDec
                ld      hl,(Reg._SP)            ;�⥪
                dec     hl
                jr      .L8+3
                cp      00000010b              ;��᫥���� JP
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
.L2             call    List                    ;᫥����� �������
                ld      (Reg._PC),hl            ;���� PC
                push    hl
                push    hl
                ld      a,(KList.Descript)      ;������⢮ ��ப ���⨭��
                call    AdrListTabl             ;������ ���� ���⨭��
                ld      de,(ListAdr)            ;���孨� ���� ���⨭��
                pop     bc                      ;���� PC
                call    AdrArea
                jr      nc,.L1+4

.L1             ld      (ListAdr),bc            ;����� ��࠭�� ���⨭��
                pop     hl

                call    Ld_a_hl                 ;᫥���騥 �� �������� �����
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
                ld      hl,(RezAdr)             ;���� ��ᠤ�� १�����
                ld      a,h
                and     11000000b
                cp      10000000b              ;���� ��ᠤ�� १�����
                ld      a,0xFF                  ;FF - १����� �� 2-� ����
                jr      nz,.L30
                ld      de,Rezident.RetIn-Rezident
                jr      .L30+4
.L30            ld      de,Rezident.RetIn1-Rezident
                inc     a                       ;0 - १����� �� �� 2-� ����
                ld      (.WRez),a
                add     hl,de                   ;���� ������ � १�����
                ex      de,hl                        
                pop     hl
                ld      a,d                     ;�ய��뢠�� ��᫥
                call    Ld_hl_a                 ;�⫠�������� �������
                dec     hl
                ld      a,e
                call    Ld_hl_a
                dec     hl
                ld      a,0xC3                  ;JP
                call    Ld_hl_a

                ld      hl,(RezAdr)             ;���� ��ᠤ��
                push    hl                      ;���४�� ���ᮢ ���� १�����
                ld      (Rezident.K1+1),hl      ;����� ����� ��� �⫠�稪��
                ld      (Rezident.K6+1),hl
                inc     hl
                ld      (Rezident.K3+1),hl      ;�������� ��ࠬ��
                ld      (Rezident.RetIn+1),hl
                ld      (Rezident.RetIn1+1),hl
                inc     hl
                ld      (Rezident.K2+1),hl      ;��� HL �ணࠬ��
                ld      (Rezident.K4+1),hl
                inc     hl
                inc     hl
                ld      (Rezident.K5+1),hl      ;1 � 2 ����� ����
                inc     hl
                inc     hl
                ld      (Rezident.K5+7),hl      ;3 � 4 ����� ����
                inc     hl
                inc     hl
                ld      (Rezident.K5+13),hl     ;5 � 6 ����� ����
                inc     hl
                inc     hl
                ld      (Rezident.K5+19),hl     ;7 ���� ����

                ld      a,(.WRez)               ;䫠� ��ᠤ�� १�����
                or      a
                jr      nz,.L31
                ld      de,Rezident.Start1-Rezident
                ld      hl,(RezAdr)             ;���� ��ᠤ��
                add     hl,de                   ;���� १����� �� �� 2-� ����
                jr      .L32

.L31            inc     hl                      ;���� १����� �� 2-� ����
                ld      (.Run1+1),hl

                ld      hl,AdrTmpBuf
                ld      de,Rezident.Start+1     ;��࠭���� 7 ���� � १�����
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

                ld      de,.Run1+2              ;�ᯮ����⥫쭠� ��楤��
                ld      b,7                     ;�����
.L34            ld      a,(de)
                ld      (hl),a
                dec     hl
                dec     de
                djnz    .L34
                inc     hl

.L32            ld      (.Run+1),hl

                ld      a,(Reg._AF+1)           ;�������� �ணࠬ��
                ld      (Rezident+1),a          ;� १�����
                ld      hl,(Reg._HL)            ;��� HL
                ld      (Rezident+2),hl         ;� १�����

                pop     hl                      ;���� ��ᠤ�� १�����
                ld      de,Rezident             ;��砫� १�����
                ld      bc,.Buffer
                ld      a,Rezident.End-Rezident ;����� १�����
.L3             push    af
                call    Ld_a_hl
                ld      (bc),a                  ;��࠭���� ����� ��� १����⮬
                ld      a,(de)                  ;����஢���� १�����
                call    Ld_hl_a
                inc     bc
                inc     de
                inc     hl
                pop     af
                dec     a
                jr      nz,.L3

                ld      a,(WinPage)             ;����� � 0-�� ����
                out     (EmmWin.P0),a

                call    RestAllRegs
                ld      (StackDebug),sp         ;�⥪ �⫠�稪�
                ld      sp,(Reg._SP)            ;�⥪ �ணࠬ��
.Run            jp      0                       ;��� १�����
         
                ld      (Reg._SP),sp            ;�⥪ �ணࠬ��
                ld      sp,(StackDebug)         ;�⥪ �⫠�稪�
                call    SaveAllRegs
                in      a,(EmmWin.P0)
                ld      (WinPage),a             ;����� � 0-�� ����
                ld      a,(BankOS)              ;����� � OS
                out     (EmmWin.P0),a

                ld      hl,(RezAdr)
                call    Ld_a_hl
                ld      (WinPage+2),a           ;����� ����� �� 2-�� ����
                inc     hl                      ;�������� �ணࠬ��
                call    Ld_a_hl
                ld      (Reg._AF+1),a
                ld      a,(.WRez)               ;䫠� १�����
                or      a
                jr      z,.L35                  ;�� �� 2-� ����
                inc     hl                      ;ॣ���� L �ணࠬ��
                call    Ld_a_hl
                ld      (Reg._HL),a
                inc     hl                      ;ॣ���� H �ணࠬ��
                call    Ld_a_hl
                ld      (Reg._HL+1),a
                ld      b,7
                ld      de,AdrTmpBuf
.L36            inc     hl                      ;���� 7-�� ����
                call    Ld_a_hl
                ld      (de),a                  ;���⠭�����
                inc     de
                djnz    .L36

.L35            pop     hl
                pop     af                      ;���⠭����� ��� �������
                pop     bc
                call    Ld_hl_a
                dec     hl
                ld      a,b
                call    Ld_hl_a
                dec     hl
                ld      a,c
                call    Ld_hl_a

                ld      de,.Buffer              ;����⠭������� ����� ��� १����⮬
                ld      hl,(RezAdr)             ;���� ��ᠤ��
                ld      b,Rezident.End-Rezident ;����� १�����
.L4             ld      a,(de)
                call    Ld_hl_a
                inc     de
                inc     hl
                djnz    .L4
                ei
                ret

.BankP          ld      a,0xFF                  ;(2) ����� ��� �⫠�稪��
                out     (EmmWin.P2),a           ;(2)
.Run1           jp      0                       ;(3) ���室 � १�����

.SpdInc         push    af                      ;㢥��祭�� ��㡨�� �⥪�
                ld      a,(StackDown)
                inc     a
                ld      (StackDown),a
                pop     af
                ret

.SpdDec         push    af                      ;㬥��襭�� ��㡨�� �⥪�
                ld      a,(StackDown)
                dec     a
                ld      (StackDown),a
                pop     af
                ret

.Flag           db      On                      ;䫠� ��室� � ����ணࠬ��
.WRez           db      0                       ;䫠� ���� ��ᠤ�� १�����

.Buffer         ds      Rezident.End-Rezident   ;����� १�����

