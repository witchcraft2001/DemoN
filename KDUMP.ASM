;[]=========================================================================[]
;[]                    ��ࠡ�⪠ ���������� � ���� �����                    []
;[] v0.10 - ��᫥���� ��������� 31.03.2006                                  []
;[]=========================================================================[]
KDump:
                ld      a,b                     ;���ﭨ� <Shift><Alt><Ctrl>
                and     11110000b
                jr      z,.L100

                ;��ࠡ�⪠ �������樨 Ctrl + ᨬ���
.L10            cp      00100000b              ;<Ctrl>
                jp      nz,.L100
                ld      a,d                     ;����樮��� ���

                cp      0x80+0x51               ;<Ctrl>+<End)
                jr      nz,.L11
                ld      hl,.Coordinate          ;⥪��� �������
                ld      a,16
                cp      (hl)
                jr      nc,$+4
                ld      a,32
                inc     a
                ld      (hl),a
                jp      Keyb-3

.L11            cp      0x80+0x57               ;<Ctrl>+<Home)
                jp      nz,Keyb-3
;                jr      nz,.L11
                ld      hl,.Coordinate          ;⥪��� �������
                ld      a,18
                cp      (hl)
                jr      c,$+8
                ld      a,2
                cp      (hl)
                jr      c,$+3
                dec     a
                ld      (hl),a
                jp      Keyb-3

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
                ld      hl,(Dump1)
                ld      bc,16
                add     hl,bc
                ld      (Dump1),hl
                jp      Keyb-11
.L104           inc     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L103           cp      0x58                    ;<Up>
                jr      nz,.L105
                ld      a,d                     ;⥪��� ��ப�
                cp      h
                jr      nz,.L107
                ld      hl,(Dump1)
                ld      bc,16
                or      a
                sbc     hl,bc
                ld      (Dump1),hl
                jp      Keyb-11
.L107           dec     a
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L105           cp      0x53                    ;<PgDown>
                jr      nz,.L108
                ld      a,d                     ;⥪��� ��ப�
                cp      l
                jr      nz,.L106
                ld      hl,(Dump1)
                ld      bc,16*7
                add     hl,bc
                ld      (Dump1),hl
                jp      Keyb-11
.L106           ld      a,l                     ;�� ��᫥���� ��ப�
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L108           cp      0x59                    ;<PgUp>
                jr      nz,.L110
                ld      a,d                     ;⥪��� ��ப�
                cp      h
                jr      nz,.L109
                ld      hl,(Dump1)
                ld      bc,16*7
                or      a
                sbc     hl,bc
                ld      (Dump1),hl
                jp      Keyb-11
                jr      nz,.L109
.L109           ld      a,h                     ;�� ����� ��ப�
                ld      (.Coordinate+1),a
                jp      Keyb-3

.L110           cp      0x57                    ;<Home>
                jr      nz,.L111
                ld      a,1
                ld      (.Coordinate),a         ;��ࢠ� �������
                jp      Keyb-3

.L111           cp      0x51                    ;<End>
                jr      nz,.L200
                ld      a,(.Descript+2)
                ld      (.Coordinate),a         ;��ࢠ� �������
                jp      Keyb-3

                ;��ࠡ�⪠ ASCII �����
.L200           ld      a,0                     ;ASCII ���
                cp      0x0D                    ;<Enter>
                jp      nz,Keyb+6
.L201           ld      b,0                     ;����� ��ப� �����
                ld      hl,0                    ;���न���� ��ப� �����

                ld      a,b
                dec     a
                jr      z,.L202
                dec     a
                jr      z,.L203

                call    InputLine               ;���� ����
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    PutAdres
                jp      c,.L201                 ;�訡�� � �������� ������
                ld      de,16                   ;���-�� ���� � ��ப�
                ld      a,(.Coordinate+1)       ;����� ��ப�
                sub     0x16                    ;���न��� ��ࢮ� ��ப�
                jr      z,$+8
                ld      b,a
                or      a
                sbc     hl,de
                djnz    $-3
                ld      (Dump1),hl
                jp      Keyb-11

.L202           call    InputLineEd             ;���� ᨬ����
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    .L299
                ld      a,c
                sub     18                      ;��ࢠ� ������� � ���� ������
                ld      c,a
                ld      a,(InputLine.Buffer)
                ld      de,256*18+34            ;1-� � ��᫥����+1 �������
                jr      .L204

.L203           call    InputLineEd             ;���� ���� ᨬ����
                jp      c,Keyb-3                ;�����襭�� ����� �� <ESC>
                call    PutCode
                jp      c,.L201                 ;�訡�� � �������� ������
                call    .L299
                ld      a,c
                sub     2                       ;��ࢠ� ������� � ���� ������
                ld      c,a
                ld      a,(PutCode.Buffer)      ;�����뢠��� ����
                ld      de,256*2+18             ;1-� � ��᫥����+1 �������
.L204           add     hl,bc
                call    Ld_hl_a
                ld      a,(InputLine.EntEnd)    ;���� �����祭 ENTER
                or      a
                jp      nz,Keyb-11              ;��
                ld      hl,.Coordinate          ;⥪�騥 ���न���� �����
                inc     (hl)
                ld      a,e                     ;��ࢠ� ������� ������
                cp      (hl)
                jr      nz,.L205
                ld      a,d
                ld      (hl),a                  ;� ��砫� ��ப� ����
                inc     hl
                ld      a,0x1D                  ;��᫥���� ��ப� �����
                cp      (hl)
                jr      nz,.L205-1
                ld      hl,(Dump1)              ;ᤢ����� ����
                ld      bc,16
                add     hl,bc
                ld      (Dump1),hl
                jr      .L205
                inc     (hl)
.L205           call    CursorRes               ;�몫 �����
                call    Refresh                 ;���������� ��࠭�
                call    Cursor                  ;��� �����
                call    CursorSet
                jp      .L201

.L299           ld      de,16                   ;���-�� ���� � ��ப�
                ld      hl,(Dump1)              ;���� � ��ࢮ� ��ப�
                ld      bc,(.Coordinate)
                ld      a,b
                sub     0x16                    ;���न��� ��ࢮ� ��ப�
                ld      b,a
                ret     z
                add     hl,de
                djnz    $-1
                ret

.Coordinate     dw      0x1601                  ;����� (���/��� �����)
.Descript:
                dw      0x161D                  ;��ࢠ�/��᫥���� ��ப� ����
                db      33                      ;���-�� �������

                db      0x0E                    ;N �⮫�� �������
                db      5                       ;�ਭ� �������
                db      0x15,2,0x17,2
                db      0x1A,2,0x1C,2
                db      0x1F,2,0x21,2
                db      0x24,2,0x26,2
                db      0x29,2,0x2B,2
                db      0x2E,2,0x30,2
                db      0x33,2,0x35,2
                db      0x38,2,0x3A,2
                db      0x3E,1,0x3F,1,0x40,1,0x41,1
                db      0x42,1,0x43,1,0x44,1,0x45,1
                db      0x46,1,0x47,1,0x48,1,0x49,1
                db      0x4A,1,0x4B,1,0x4C,1,0x4D,1

