;[]=========================================================================[]
;[]                             �뢮� �ᮢ                                 []
;[] v0.03 - ��᫥���� ��������� 01.02.2006                                  []
;[]=========================================================================[]
Clock:
                ld      a,(ClockOn)             ;䫠� �뢮�� �ᮢ
                inc     a
                ret     nz
                ld      c,Dss.SysTime
                rst     DssRst                  ;������ ����� � �६���
                ld      de,.String
                push    de
                push    bc
                push    hl
                ld      l,h                     ;���
                ld      h,0
                call    ConvDecStr8_1
                inc     de
                pop     hl                      ;������
                ld      h,0
                call    ConvDecStr8_1
                inc     de
                pop     hl
                ld      l,h                     ;ᥪ㭤�
                ld      h,0
                call    ConvDecStr8_1
                ld      de,71
                ld      c,Bios.Lp_Set_Place     ;��⠭���� ����樨 ����
                rst     BiosRst : di
                pop     hl
                ld      bc,8*256+Bios.Lp_Print_Ln2 ;� ॣ.B ����� ��ப�
                rst     BiosRst : di
                ret

.String         db      "00:00:00"

