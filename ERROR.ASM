;[]=========================================================================[]
;[]                Обработка ошибок монитора-отладчика DemoN                []
;[] v0.10 - последние изменения 27.08.2006                                  []
;[]                                                                         []
;[] ErDss          - определение ошибки DSS по ее коду                      []
;[]=========================================================================[]

;[]=========================================================================[]
;[]                              Ошибки DSS                                 []
;[] Вход:  A  - код ошибки                                                  []
;[] Выход: A  - код ошибки                                                  []
;[]        HL - строка-описание ошибки                                      []
;[]=========================================================================[]
PrErDss:
                call    ErDss
                ld      c,Dss.PChars            ;вывести сообщение об ошибке
                rst     DssRst
                ld      hl,Str.DA               ;перевод строки
                ld      c,Dss.PChars
                rst     DssRst
                ret

ErDss:
.MaxError       equ     0x26
                cp      .MaxError+1             ;максимальный код ошибки + 1
                jr      c,$+4
                ld      a,.MaxError

                push    af
                add     a,a
                ld      hl,.Tabl
                ld      d,0
                ld      e,a
                add     hl,de
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a
                pop     af
                ret

.e01            db      "Invalid function",0
.e02            db      "Invalid drive number",0
.e03            db      "File not found",0
.e04            db      "Path not found",0
.e05            db      "Invalid handle",0
.e06            db      "Too many open files",0
.e07            db      "File already exists",0
.e08            db      "File read only",0
.e09            db      "Root overflow",0
.e0A            db      "No free space",0
.e0B            db      "Directory not empty",0
.e0C            db      "Can't delete current directory",0
.e0D            db      "Invalid media",0
.e0E            db      "Unknown operation",0   ;(невозм. операция)
.e0F            db      "Directory exist",0
.e10            db      "Invalid filename",0
.e11            db      "Invalid EXE-file",0
.e12            db      "Not supported EXE-file",0
.e13            db      "Access denied",0
.e14            db      "Not ready",0
.e15            db      "Seek error",0
.e16            db      "Sector not found",0
.e17            db      "CRC error",0
.e18            db      "Write protect",0
.e19            db      "Read error",0
.e1A            db      "Write error",0
.e1B            db      "Drive failure",0
.e1C            db      "Extended error: 28",0
.e1D            db      "Extended error: 29",0
.e1E            db      "Not enough memory",0
.e1F            db      "Invalid memory block",0
.e20            db      "Extended error: 32",0
.e21            db      "Extended error: 33",0
.e22            db      "Extended error: 34",0
.e23            db      "Too many files",0      ;(список файлов)
.e24            db      "(слишком большая влож. папок или >= 1024 папок)",0
.e25            db      "User abort",0          ;(операция прервана пользователем)
.e26            db      "Unknown error: 38..255",0      ;38

.Tabl           dw      .e01,.e02,.e03,.e04,.e05,.e06,.e07,.e08
                dw      .e09,.e0A,.e0B,.e0C,.e0D,.e0E,.e0F,.e10
                dw      .e11,.e12,.e13,.e14,.e15,.e16,.e17,.e18
                dw      .e19,.e1A,.e1B,.e1C,.e1D,.e1E,.e1F,.e20
                dw      .e21,.e22,.e23,.e24,.e25,.e26

