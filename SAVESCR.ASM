;[]=========================================================================[]
;[]                      ���࠭���� ��࠭� � 䠩�                           []
;[] v0.03 - ��᫥���� ��������� 11.03.2006                                  []
;[]=========================================================================[]
SaveScr:
                ld      bc,1*256+Dss.GetMem
                rst     DssRst                  ;�뤥����� ����� �����
                ret     c                       ;��室 � �訡���
                ld      (.Id),a
                ld      bc,Dss.SetWin3
                rst     DssRst                  ;����祭�� ����� � 3-� ����
                ld      (.Id+1),a               ;����頥��� ��࠭��
                ld      de,0                    ;������ �� ��࠭�
                ld      hl,0xC000
.L1             push    de
                push    hl
                ld      c,Dss.RdChar
                rst     DssRst                  ;����� ᨬ��� � ��࠭�
                pop     hl
                pop     de
                ld      (hl),a
                inc     hl
                inc     e
                ld      a,e
                cp      0x50                    ;�����稫��� ��ப�?
                jr      nz,.L1
                ld      bc,0x0D0A               ;����� ��ப�
                ld      (hl),b
                inc     hl
                ld      (hl),c
                inc     hl
                ld      e,0                     ;��砫� ��ப�
                inc     d
                ld      a,d
                cp      0x20                    ;����� ��࠭�?
                jr      nz,.L1

                ld      hl,.NameF               ;��� 䠩��
                xor     a                       ;��ਡ��
                ld      c,Dss.Create
                rst     DssRst
                jr      c,.L2                   ;�訡��
                push    af
                ld      hl,0xC000               ;��砫� �����뢠���� �����
                ld      de,82*32                ;ࠧ��� �����뢠���� ����
                ld      c,Dss.Write
                rst     DssRst                  ;�������
                pop     af
                ld      c,Dss.Close
                rst     DssRst                  ;������� 䠩�

.L2             ld      a,(.Id)                 ;id �����
                ld      c,Dss.FreeMem
                rst     DssRst                  ;�᢮������ ������
                ld      a,(.Id+1)
                out     (EmmWin.P3),a           ;���⠭����� �����
                ret
                
.NameF          db      "demon.$$$",0
.Id             ds      2                       ;id �뤥������� �����

;11:11 18.02.2011 �����誠 �� �뫮 ��室���� :( 
;                include "d:\workast\demon\screen\scrdemon"

