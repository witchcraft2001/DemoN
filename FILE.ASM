;[]=========================================================================[]
;[]                ������� ��楤��� ������-�⫠�稪� DemoN              []
;[] v0.10 - ��᫥���� ��������� 27.08.2006                                  []
;[]=========================================================================[]
LoadFile:
                xor     a                       ;�몫 �ᮢ
                ld      (ClockOn),a
                ld      bc,0x0100+Dss.SelPage   ;��⥬�� ��࠭
                rst     DssRst

                ld      hl,Str.Load             ;ᮮ�饭�� � ����㧪� 䠩��
                ld      c,Dss.PChars
                rst     DssRst

                call    LoadExe

                ld      a,(DemonScreen)
                ld      b,a
                ld      c,Dss.SelPage
                rst     DssRst
                ld      a,On                    ;��� �ᮢ
                ld      (ClockOn),a
                ret

LoadExe:
                ld      hl,FDebug               ;��� 䠩��
                ld      a,1                     ;������ ��� �⥭��
                ld      c,Dss.Open
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                ld      (FId),a                 ;��������� 䠩���� ���������

                ld      hl,FDebug               ;���� ��� ����㧪� ���������
                ld      de,0x7F                 ;���-�� ���뢠���� ����
                ld      c,Dss.Read              ;�⥭��
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                ld      hl,(FDebug)             ;��������� EXE-䠩��
                ld      de,0x5845               ;'EX' �஢�ઠ �����䨪���
                sbc     hl,de
                jr      nz,.L1
                ld      hl,FDebug+3
                ld      a,(hl)                  ;����� EXE-䠩��
                or      a
                jr      nz,.L1
                inc     hl
                ld      e,(hl)                  ;��砫� �ᯮ��塞��� ����
                inc     hl
                ld      d,(hl)
                ld      bc,11                   ;�ய�᪠�� 䫠� �����稪� � ��१�ࢨ஢���� �����
                add     hl,bc
                ld      a,(hl)                  ;��.���� �ᯮ������� ���� � �����
                ld      (FRam),a
                inc     hl
                ld      a,(hl)                  ;��.���� �ᯮ������� ���� � �����
                ld      (FRam+1),a
                inc     hl
                ld      a,(hl)                  ;��.���� ���� ����᪠
                ld      (Reg._PC),a
                ld      (ListAdr),a             ;��.���� ���� ���⨭��
                inc     hl
                ld      a,(hl)                  ;��.���� ���� ����᪠
                ld      (Reg._PC+1),a
                ld      (ListAdr+1),a           ;��.���� ���� ���⨭��
                inc     hl
                ld      a,(hl)                  ;��.���� �⥪� �ணࠬ��
                ld      (Reg._SP),a
                inc     hl
                ld      a,(hl)                  ;��.���� �⥪� �ணࠬ��
                ld      (Reg._SP+1),a
                ld      a,e
                ld      (.L2+2),a
                ld      a,d
                ld      (.L2+3),a

.L1             ld      hl,0
                ld      ix,0                    ;ᬥ饭�� � 䠩��
                ld      bc,2*256+Dss.Move_FP    ;�⭮�⥫쭮 ����
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                push    hl
                ld      de,(FRam)               ;���� �ᯮ������� ����
                set     6,d
                res     7,d                     ;��㧨� �१ 1-� ����
                ld      hl,0x8000
                or      a                       ;����� 䫠� C
                sbc     hl,de                   ;���-�� ���뢠���� ����
                ld      (.L6+1),hl
                ex      de,hl
                ld      (.L6+4),hl
                pop     hl
                call    NBank                   ;��।����� ���-�� �����
                jp      c,PrErDss               ;��室 � �訡���

                ld      (MemId+1),a             ;���-�� �뤥�塞�� ��࠭��
                ld      b,a
                ld      c,Dss.GetMem            ;�뤥����� �����
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���
                ld      (MemId),a               ;id ����� �����

                ld      a,(FId)                 ;䠩���� ���������
                ld      hl,0
.L2             ld      ix,0                    ;ᬥ饭�� � 䠩��
                ld      bc,Dss.Move_FP          ;�⭮�⥫쭮 ��砫�
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                ld      a,(MemId)               ;id ����� �����
                ld      bc,Dss.SetWin1          ;��� 1-� ����� � 1-� ����
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

.L6             ld      de,0x3FFF               ;���-�� ���뢠���� ����
                ld      hl,0x4000               ;���� ����㧪� ����
                ld      a,1                     ;���稪 �����
                ld      (MemId+2),a
.L5             ld      a,(FId)                 ;䠩���� ���������
                ld      c,Dss.Read              ;�⥭��
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                ld      bc,(MemId+1)
                ld      a,b
                cp      c                       ;���২�� ���� 䠩�?
                jr      z,.L4                   ;���室, �᫨ ��

                inc     a
                ld      (MemId+2),a             ;㢥����� ���稪 �����
                ld      a,(MemId)               ;id ����� �����
                ld      c,Dss.SetWin1           ;��� ����� � 1-� ����
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                ld      hl,0x4000               ;���� � ����� ��� ����㧪�
                ld      de,0x3FFF               ;���-�� ����㦠���� ����
                jr      .L5

.L4             ld      a,(FId)                 ;䠩���� ���������
                ld      c,Dss.Close             ;������� 䠩�
                rst     DssRst
                jp      c,PrErDss               ;��室 � �訡���

                ld      a,(MemId)               ;id ����� �����
                ld      bc,Bios.Emm_Fn4         ;���᫨�� 䨧 ����� 1-� �����
                rst     BiosRst
                ret     c                       ;��室 � �訡���
                ld      (BankP),a
                ld      a,(MemId+1)             ;���-�� �뤥������ ��࠭��
                dec     a
                jr      z,.L7

                ld      a,(MemId)               ;id ����� �����
                ld      bc,1*256+Bios.Emm_Fn4   ;���᫨�� 䨧 ����� 2-� �����
                rst     BiosRst
                ret     c                       ;��室 � �訡���
                ld      (BankP+1),a
                ld      a,(MemId+1)             ;���-�� �뤥������ ��࠭��
                cp      2
                jr      z,.L7

                ld      a,(MemId)               ;id ����� �����
                ld      bc,2*256+Bios.Emm_Fn4   ;���᫨�� 䨧 ����� 3-� �����
                rst     BiosRst
                ret     c                       ;��室 � �訡���
                ld      (BankP+2),a
                ld      a,(MemId+1)             ;���-�� �뤥������ ��࠭��
                cp      3
                jr      z,.L7

                ld      a,(MemId)               ;id ����� �����
                ld      bc,3*256+Bios.Emm_Fn4   ;���᫨�� 䨧 ����� 4-� �����
                rst     BiosRst
                ret     c                       ;��室 � �訡���
                ld      (BankP+3),a

.L7             ld      hl,WinPage
                ld      de,BankP
                ld      a,(MemId+1)             ;���-�� �뤥������ ��࠭��
                ld      b,a
                cp      5
                jr      c,$+4
                ld      b,4                     ;������砥� �� ����� 4 �����
                ld      a,(FRam+1)              ;��.���� �ᯮ������� ����
                and     0xC0                    ;���� � �ᯮ�������� ����
                or      a                       ;0-� ����
                jr      nz,.L8
                ld      c,a
                ld      a,(de)
                ld      (hl),a                  ;��������� ����� �ணࠬ��
                dec     b
                ret     z                       ;��室, �᫨ ����� ��� �����

                ld      a,c
                inc     de
.L8             inc     hl
                cp      0x40                    ;1-� ����
                jr      nz,.L9
                ld      c,a
                ld      a,(de)
                ld      (hl),a                  ;��������� ����� �ணࠬ��
                dec     b
                ret     z                       ;��室, �᫨ ����� ��� �����

                ld      a,c
                inc     de
.L9             inc     hl
                cp      0x80                    ;2-� ����
                jr      nz,.L10
                ld      c,a
                ld      a,(de)
                ld      (hl),a                  ;��������� ����� �ணࠬ��
                dec     b
                ret     z                       ;��室, �᫨ ����� ��� �����

                ld      a,c
                inc     de
.L10            inc     hl                      ;���� 3-� ����
                ld      a,(de)
                ld      (hl),a                  ;��������� ����� �ணࠬ��

                ret

;[]=========================================================================[]
;[]   ���᫥��� ����室����� ���-�� ����� ��� ����㧪� 䠩�� � ������      []
;[] �室:  HL:IX - ����� 䠩�� � �����                                     []
;[]        DE - ���-�� ���� ��� ����㧪� � 1-� �����                        []
;[] ��室: A - ���-�� ����室���� �����                                     []
;[]        䫠� C - �訡��, ��� �訡�� � A                                  []
;[]=========================================================================[]
NBank:
                push    ix
                ld      b,h
                ld      c,l
                pop     hl
                inc     bc
                xor     a
                inc     a
                sbc     hl,de
                jr      nc,$+4
                jr      .L5
                ld      de,16384                ;ࠧ��� �����
                push    af
.L2             pop     af
.L1             inc     a
                jr      z,.L3
                sbc     hl,de
                jr      nc,.L1
.L5             dec     bc
                push    af
                ld      a,b
                or      c
                jr      nz,.L2
                pop     af
                or      a                       ;����� 䫠� C
                ret

.L3             ld      a,0x1E                  ;"�������筮 �����"
;                JP      ErrorDSS
                ret

BankP           ds      4                       ;����� ����� ����㦠���� �ண�
MemId           ds      3                       ;id-����� ����� ��� 䠩�,
                                                ;���-�� �뤥������ �����,
                                                ;���稪 ����㦥���� �����
FId             db      0                       ;䠩���� ���������
FDebug          ds      128
                db      0
FStart          dw      0x4200
FRam            dw      0                       ;���� �ᯮ������� ���� � �����

