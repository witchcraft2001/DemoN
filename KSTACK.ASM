;[]=========================================================================[]
;[]               ��ࠡ�⪠ ���������� � ���� ����� �⥪�                   []
;[] v0.10 - ��᫥���� ��������� 18.03.2006                                  []
;[]=========================================================================[]
KStack:
                ld      a,b                     ;���ﭨ� <Shift><Alt><Ctrl>
                and     11110000b
;                ld      b,a
                jr      z,.L100

                ;��ࠡ�⪠ �������樨 Shift + ᨬ���
;                and     11000000b              ;<Shift>
;                or      a
;                jr      z,.L10
;                ld      a,d
;;                cp      0x80+0x0F               ;Shift+Tab
;;                jp      nz,Keyb+6
;;                ld      a,3                     ;����� ���� �����
;;                ld      (Keyb.WinScreen),a
;                jp      Keyb-3

                ;��ࠡ�⪠ �������樨 Ctrl + ᨬ���
;                ld      a,b
                cp      00100000b              ;<Ctrl>
                jp      nz,Keyb+6
                ld      a,d                     ;����樮��� ���
                cp      0x80+0x2B               ;<Ctrl>+<X>
                jp      nz,Keyb+6
                ld      hl,(StackDump)
                ld      bc,(.Coordinate)
                ld      a,b
                ld      b,0x16                  ;x-��न��� 1 ��ப�
                sub     b
                rlca                            ;*2
                ld      b,0
                ld      c,a
                or      a
                sbc     hl,bc
                ld      (Reg._SP),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a
                jp      Keyb-11

                ;��ࠡ�⪠ ����樮����� ����
.L100           ld      a,e                     ;ASCII ���
                ld      (.L200+1),a
                ld      a,d                     ;����樮��� ���

                ld      de,(.Coordinate)        ;⥪�騥 ���न���� �����
                cp      0x56                    ;<Right>
                jr      nz,.L101
                ld      a,(.Descript+2)         ;���-�� �������
                cp      e
                ld      a,e
                jr      nz,$+3
                xor     a
                inc     a
                ld      (.Coordinate),a         ;⥪��� �������
                jp      Keyb-3

.L101           cp      0x54                    ;<Left>
                jr      nz,.L102
                ld      a,e                     ;⥪��� �������
                cp      1
                jr      nz,$+6
                ld      a,(.Descript+2)         ;���-�� �������
                inc     a
                dec     a
                ld      (.Coordinate),a         ;⥪��� �������
                jp      Keyb-3

.L102           ld      hl,(.Descript)
                cp      0x52                    ;<Down>
                jr      nz,.L103
                ld      a,d                     ;⥪��� ��ப�
                cp      l
                jr      nz,.L104
                ld      hl,(StackDump)          ;���� 1-�� ��ப�
                dec     hl
                dec     hl
                ld      (StackDump),hl
                ld      hl,PrintStrSP.StrSp     ;��ப� ����.�⥪�
                ld      a,-1
                cp      (hl)                    ;� �����?
                jr      z,$+3
                dec     (hl)
                jp      Keyb-11
.L104           inc     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L103           cp      0x58                    ;<Up>
                jr      nz,.L105
                ld      a,d                     ;⥪��� ��ப�
                cp      h
                jr      nz,.L107
                ld      hl,(StackDump)          ;���� 1-�� ��ப�
                inc     hl
                inc     hl
                ld      (StackDump),hl
                ld      hl,PrintStrSP.StrSp     ;��ப� ����.�⥪�
                ld      a,(hl)
                cp      7                       ;�� ��᫥���� ��ப�?
                jr      c,$+5
                ld      a,-2
                ld      (hl),a                  ;����.�⥪� �� �������� � ����
                inc     (hl)
                jp      Keyb-11
.L107           dec     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L105           cp      0x53                    ;<PgDown>
                jr      nz,.L108
                ld      a,d                     ;⥪��� ��ப�
                cp      l
                jr      nz,.L106
                ld      hl,(StackDump)
                ld      bc,2*7
                or      a
                sbc     hl,bc
                ld      (StackDump),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a    ;��ப� ����.�⥪�
                jp      Keyb-11
.L106           ld      a,l                     ;�� ��᫥���� ��ப�
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L108           cp      0x59                    ;<PgUp>
                jr      nz,.L110
                ld      a,d                     ;⥪��� ��ப�
                cp      h
                jr      nz,.L109
                ld      hl,(StackDump)
                ld      bc,2*7
                add     hl,bc
                ld      (StackDump),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a    ;��ப� ����.�⥪�
                jp      Keyb-11
.L109           ld      a,h                     ;�� ����� ��ப�
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L110           cp      0x57                    ;<Home>
                jr      nz,.L200
                ld      a,6
                ld      (PrintStrSP.StrSp),a    ;��ப� ����.�⥪�
                jp      Keyb-11

;.L111           cp      0x0F                    ;<Tab>
;                jr      nz,.L200
;                ld      a,1                     ;����� ���� ���⨭��
;                ld      (Keyb.WinScreen),a
;                jp      Keyb-3

                ;��ࠡ�⪠ ASCII �����
.L200           ld      a,0                     ;ASCII ���
                cp      0x0D                    ;<Enter>
                jp      nz,Keyb+6
.L201           ld      b,0                     ;����� ��ப� �����
                ld      hl,0                    ;���न���� ��ப� �����
                call    InputLine               ;���� �᫠
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    PutAdres
                jp      c,.L201                 ;�訡�� � �������� ������
                ld      bc,(.Coordinate)
                ld      a,b
                ld      b,0x16                  ;x-��न��� 1 ��ப�
                sub     b
                ex      de,hl
                ld      hl,(StackDump)
                ld      b,a                     ;����� ��ப� 0..7
                rlca                            ;*2
                dec     c
                ld      c,a
                jr      nz,.L202                ;���室 - �᫨ �����, ���� ����

                ld      a,(PrintStrSP.StrSp)    ;��ப� ����.�⥪�
                cp      b
                jr      z,.L203
                ld      b,0                     ;�� �� ���設� �⥪�
                ex      de,hl                   ;HL - �������� ����
                add     hl,bc
                ld      (StackDump),hl
                ld      a,-1
                ld      (PrintStrSP.StrSp),a
                jr      .L203+4
.L203           ld      (Reg._SP),de            ;���� ������ �� ���設� �⥪�
                jp      Keyb-11

.L202           ld      b,0                     ;���� ������
                or      a
                sbc     hl,bc
                ld      a,d                     ;������ ������ � ������
                call    Ld_hl_a
                inc     hl
                ld      a,e
                call    Ld_hl_a
                jp      Keyb-11


.Coordinate     dw      0x1601                  ;����� (���/��� �����)
.Descript:
                dw      0x161D                  ;��ࢠ�/��᫥���� ��ப� ����
                db      2                       ;���-�� �������

                db      0x01                    ;N �⮫�� �������
                db      5                       ;�ਭ� �������
                db      0x07,5

