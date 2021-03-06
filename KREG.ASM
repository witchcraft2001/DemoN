;[]=========================================================================[]
;[]                  ��ࠡ�⪠ ���������� � ���� ॣ���஢                  []
;[] v0.03 - ��᫥���� ��������� 11.03.2006                                  []
;[] v0.10 - ��᫥���� ��������� 14.05.2006                                  []
;[]=========================================================================[]
KReg:
;                ld      a,b                     ;���ﭨ� <Shift><Alt><Ctrl>
;                and     0b11110000
;                jr      z,.L100

                ;��ࠡ�⪠ �������樨 Shift + ᨬ���
;                and     0b11000000              ;<Shift>
;                or      a
;                jp      z,Keyb+6
;                ld      a,d
;                cp      0x80+0x0F               ;Shift+Tab
;                jp      nz,Keyb+6
;                ld      a,2                     ;����� ���� �����
;                ld      (Keyb.WinScreen),a
;                jp      Keyb-3

                ;��ࠡ�⪠ ����樮����� ����
.L100           ld      a,e                     ;ASCII ���
                ld      (.L200+1),a
                ld      a,d                     ;����樮��� ���

                cp      0x56                    ;<Right>
                jr      nz,.L101
                call    .DescCalc
                ld      a,(hl)                  ;���-�� �������
                cp      e
                ld      a,e
                jr      nz,$+3
                xor     a
                inc     a
                ld      (.Coordinate),a         ;⥪��� �������
                jp      Keyb-3

.L101           cp      0x54                    ;<Left>
                jr      nz,.L102
                call    .DescCalc
                ld      a,e                     ;⥪��� �������
                cp      1
                jr      nz,$+4
                ld      a,(hl)                  ;���-�� �������
                inc     a
                dec     a
                ld      (.Coordinate),a         ;⥪��� �������
                jp      Keyb-3

.L102           ld      hl,(.Descript)
                ld      de,(.Coordinate)
                cp      0x52                    ;<Down>
                jr      nz,.L103
                ld      a,d                     ;⥪��� ��ப�
                cp      l
                jr      nz,.L104
                ld      a,h                     ;1-� ��ப�
                dec     a
.L104           inc     a
                jr      .L107+1

.L103           cp      0x58                    ;<Up>
                jr      nz,.L105
                ld      a,d                     ;⥪��� ��ப�
                cp      h
                jr      nz,.L107
                ld      a,l                     ;���� ��᫥���� ��ப�
                inc     a
.L107           dec     a
                ld      h,a
                ld      l,1
                ld      (.Coordinate),hl
                jp      Keyb-3

.L105           ld      b,3
                cp      0x53                    ;<PgDown>
                jr      nz,.L108
                ld      hl,.PgDown
                ld      a,d                     ;⥪��� ��ப�
                cp      (hl)
                jr      c,$+5
                inc     hl
                djnz    $-4
                ld      a,(hl)
                jr      .L107+1

.L108           cp      0x59                    ;<PgUp>
                jr      nz,.L110
                ld      hl,.PgUp
                ld      a,d                     ;⥪��� ��ப�
                cp      (hl)
                jr      nc,$+5
                inc     hl
                djnz    $-4
                ld      a,(hl)
                dec     a
                jr      .L107+1

.L110           cp      0x57                    ;<Home>
                jr      nz,.L111
                ld      a,1
                ld      (.Coordinate),a         ;��ࢠ� �������
                jp      Keyb-3

.L111           cp      0x51                    ;<End>
                jr      nz,.L200
                call    .DescCalc
                ld      a,(hl)                  ;��᫥���� �������
                ld      (.Coordinate),a         ;��ࢠ� �������
                jp      Keyb-3

;.L112           cp      0x0F                    ;<Tab>
;                jr      nz,.L200
;                ld      a,4                     ;����� ���� ���⨭��
;                ld      (Keyb.WinScreen),a
;                jp      Keyb-3

                ;��ࠡ�⪠ ASCII �����
.L200           ld      a,0                     ;ASCII ���
                cp      0x0D                    ;<Enter>
                jp      nz,Keyb+6
.L201           ld      b,0                     ;����� ��ப� �����
                ld      hl,0                    ;���न���� ��ப� �����

                ld      a,b
                dec     a
                jp      nz,.L205
                ld      de,(.Coordinate)
                ld      a,d                     ;����� ��ப�
                ld      c,e                     ;����� �������
                ex      de,hl                   ;���न����
                ld      hl,Reg._AF+1            ;ॣ A
                cp      6                       ;��ப� � ��ன AF?
                jr      z,.L207
                ld      hl,Reg._AF_+1           ;ॣ A'
                cp      11                      ;��ப� � ��ன AF'?
                jr      z,.L207
                ld      hl,Reg._AF              ;ॣ F
                cp      7                       ;��ப� � ��ன AF?
                jr      z,$+9
                ld      hl,Reg._AF_             ;ॣ F'
                cp      12                      ;��ப� � ��ன AF'?
                jr      nz,.L206
                ld      a,c                     ;���४�� ����஢ ���
                cp      4                       ;������� 4..6?
                jr      c,$+5
                inc     c
                jr      .L207-4
                cp      3                       ;������� 3?
                jr      z,.L207-4
                dec     c
                ld      a,7
                jr      .L208
.L207           ld      a,10                    ;������� � ��⠬�
                cp      c
                jr      z,.L206
                dec     a
.L208           sub     c                       ;����� ���
                rlca
                rlca
                rlca                            ;����⮢�� ��� ��⮢�� ����権
                ld      b,a
                or      01000110b              ;��� BIT
                ld      ($+16),a
                ld      a,b
                or      11000110b              ;��� SET
                ld      ($+14),a
                ld      a,b
                or      10000110b              ;��� RES
                ld      ($+13),a
                bit     0,(hl)                  ;���ﭨ� ���
                jr      nz,$+7
                set     0,(hl)                  ;��⠭���� ���
                jp      Keyb-11
                res     0,(hl)                  ;��� ���
                jp      Keyb-11

.L206           ex      de,hl                   ;���न����
                call    InputLine               ;���� ᨬ����
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                ld      de,.L204-5
                push    de
                ld      de,(.Coordinate)
                ld      hl,Reg._AF+1
                ld      a,d
                ld      de,0
                cp      6                       ;��ப� � ��ன AF
                ret     z
                ld      hl,Reg._AF_+1
                cp      11                      ;��ப� � ��ன AF'?
                ret     z
                ld      de,(.Coordinate)
                ld      a,e
                sub     6
                ld      e,a
                jr      .L209

.L205           dec     a                       ;����� � ���������
                jr      nz,.L202
                call    InputLine               ;���� �᫠
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    PutCode
                jp      c,.L201                 ;�訡�� � �������� ������
                ld      de,.L204
                push    de
                ld      de,(.Coordinate)
.L209           dec     d
                jr      nz,$+6
                ld      hl,(Reg._IX)
                ret
                dec     d
                jr      nz,$+6
                ld      hl,(Reg._IY)
                ret
                dec     d
                jr      nz,$+6
                ld      hl,(Reg._HL)
                ret
                dec     d
                jr      nz,$+6
                ld      hl,(Reg._DE)
                ret
                dec     d
                jr      nz,$+6
                ld      hl,(Reg._BC)
                ret
                dec     d
                dec     d
                dec     d
                jr      nz,$+6
                ld      hl,(Reg._HL_)
                ret
                dec     d
                jr      nz,$+6
                ld      hl,(Reg._DE_)
                ret
                dec     d
                ld      hl,(Reg._BC_)
                ret

                ld      a,(InputLine.Buffer)
                jr      $+7
.L204           ld      a,(PutCode.Buffer)      ;�����뢠��� ����
                dec     e
                dec     e                       ;ᬥ饭�� � ���������
                add     hl,de                   ;���� � �����
                call    Ld_hl_a                 ;����ᠫ�
                jp      Keyb-11

.L202           dec     a                       ;�������⭮� �᫮ (����� �����)
                jr      nz,.L203
                call    InputLine               ;���� �᫠
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    PutAdres
                jp      c,.L201                 ;�訡�� � �������� ������
                ld      de,Keyb-11
                push    de
                ld      a,l
                ld      de,(.Coordinate)
                dec     e                       ;������� � ��ப�
                jr      nz,$+6
                ld      (WinPage),a             ;0-� ����
                ret
                dec     e
                jr      nz,$+8
                ld      (WinPage+1),a           ;1-� ����
                out     (EmmWin.P1),a
                ret
                dec     e
                jr      nz,$+6
                ld      (WinPage+2),a           ;2-� ����
                ret
                ld      (WinPage+3),a           ;3-� ����
                out     (EmmWin.P3),a
                ret

.L203           dec     a                       ;��㡨�� �⥪�
                jr      nz,.L210
                xor     a                       ;���㫨��
                ld      (StackDown),a
                jp      Keyb-11
           
.L210           ;dec     a                       ;���塠�⭮� �᫮
                ;jp      nz,Keyb+6
                call    InputLine               ;���� �᫠ � ॣ ����
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    PutAdres
                jp      c,.L201                 ;�訡�� � �������� ������
                ld      de,Keyb-11
                push    de
                ld      de,(.Coordinate)
                dec     d
                jr      nz,$+6
                ld      (Reg._IX),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._IY),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._HL),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._DE),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._BC),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._AF),hl
                ret
                dec     d
                dec     d
                jr      nz,$+6
                ld      (Reg._HL_),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._DE_),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._BC_),hl
                ret
                dec     d
                jr      nz,$+6
                ld      (Reg._AF_),hl
                ret
                dec     d
                dec     d
                jr      nz,$+13
                dec     e
                jr      z,$+6
                ld      (Reg._IR),hl
                ret
                ld      (Reg._PC),hl
                ret
                dec     e
                jr      z,.L211
.Rez            ld      bc,Rezident.End-Rezident;����� १�����
                push    hl                      ;����� ��砫� १�����
                add     hl,bc                   ;���� ������ ���� १�����
                ld      a,h
                and     11000000b
                ld      d,a
                pop     hl
                ld      a,h
                and     11000000b
                cp      d                       ;१����� ���ᥪ��� ����?
                jr      z,.L212
                ld      h,d
                ld      l,0
                dec     hl                      ;��᫥���� ���� ���� � १����⮬
                or      a
                sbc     hl,bc
.L212           ld      (RezAdr),hl
                ret
.L211           ld      (Reg._SP),hl
                ret

                ;����� ���ਯ�� ��ப� � ���� ॣ���஢
.DescCalc       ld      de,(.Coordinate)        ;⥪�騥 ���न����
                ld      hl,.Descript+1
                ld      b,d                     ;����� ��ப�
                inc     hl                      ;���ਯ�� ��ப�
                inc     hl
                djnz    $-2
                ld      a,(hl)                  ;����� ���ਯ�� ��ப�
                add     a,a
                ld      c,a
                dec     hl
                ld      b,(hl)
                push    bc
                ld      b,0
                ld      hl,.DTabl
                add     hl,bc
                ld      a,(hl)                  ;��砫� ���ਯ��
                inc     hl
                ld      h,(hl)
                ld      l,a
                pop     bc
                ret

.PgDown         db      2,7,12,15
.PgUp           db      14,9,4,2

.Coordinate     dw      0x0101                  ;����� (���/��� �����)

.Descript:
                dw      0x010F                  ;��ࢠ�/���-�� ��ப ����

                db      0x01,0                  ;����� ��ப�, ����� ���ਯ��
                db      0x02,0,0x04,0
                db      0x05,0,0x06,0,0x07,1
                db      0x08,2,0x0A,0,0x0B,0
                db      0x0C,0,0x0D,1,0x0E,2
                db      0x10,3,0x12,4,0x14,5

.DTabl          dw      .D1,.D2,.D3,.D4,.D5,.D6

.D1             db      9                       ;���-�� ������� ��� ���
                db      0x04                    ;N �⮫�� �������
                db      5                       ;�ਭ� �������
                db      0x0A,2,0x0C,2,0x0F,2,0x11,2
                db      0x14,1,0x15,1,0x16,1,0x17,1

.D2             db      10                      ;���-�� ������� ��� ���� AF
                db      0x04                    ;N �⮫�� �������
                db      5                       ;�ਭ� �������
                db      0x0B,1,0x0C,1,0x0D,1,0x0E,1
                db      0x0F,1,0x10,1,0x11,1,0x12,1
                db      0x15,1

.D3             db      6                       ;���-�� ������� ��� 䫠���
                db      0x01                    ;N �⮫�� �������
                db      1                       ;�ਭ� �������
                db      0x02,1,0x04,1
                db      0x06,1,0x07,1,0x08,1

.D4             db      2                       ;���-�� ������� ��� PC IR
                db      0x04                    ;N �⮫�� �������
                db      5                       ;�ਭ� �������
                db      0x0D,5

.D5             db      4                       ;���-�� ������� ��� �����
                db      0x02                    ;N �⮫�� �������
                db      3                       ;�ਭ� �������
                db      0x08,3,0x0E,3,0x14,3

.D6             db      3                       ;���-�� �������
                db      0x04                    ;N �⮫�� �������
                db      5                       ;�ਭ� �������
                db      0x0A,4
                db      0x13,5

