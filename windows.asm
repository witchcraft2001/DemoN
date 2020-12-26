
;IX	- WINDOW DESCRIPTOR
;+0	- FLAG:
;	BITS:	0	-	STANDART WINDOW
;		1	-	0 - WITHOUT HEADER / 1 - WITH HEADER
;		2	-	0 - ORDINARY FRAME / 1 - DOUBLE FRAME
;+1	- X COORD
;+2	- Y COORD
;+3	- LENGHT
;+4	- HEIGHT
;+5	- ATTR


Windows	BIT	0,(IX+0)
	JR	Z,NO_STAND_WIN
	LD	A,(IX+1)
	LD	DE,-4
	ADD	IX,DE
	PUSH	IX
	LD	IX,STANDART
	LD	(IX+5),A
	JR	STAND_WIN
NO_STAND_WIN
	PUSH	IX
STAND_WIN
	CALL	Rectang
	CALL	Frame
	BIT	1,(IX+0)
	CALL	NZ,WinHeader
	POP	HL
;	PUSH	HL
	LD	DE,6
	ADD	HL,DE
	bit	1,(ix+0)
	ld	a,(IX+5)
	jr	z,WinNoHeader
	RRCA
	RRCA
	RRCA
	RRCA
	AND	#7F
	ld      (PrnStrColor.L1+5),a
	push	hl
	call	MenuItemLen
	ld	a,(ix+3)
	sbc	a,b
	ld	e,(ix+1)
	and	a
	rra
	add	a,e
	ld	e,a
	ld	d,(ix+2)
	pop	hl
	CALL	PrnStrColor
	inc	hl
	ld	a,(IX+5)
WinNoHeader
	ld      (PrnStrColor.L1+5),a
	ld	d,(ix+2)		;Координаты в окне
	ld	e,(ix+1)
	inc	d
	inc	d
	inc	e
	inc	e
	ld	a,e
	ld	(PrtXCoord),a
;	LD	(WINDOW_TXT),HL
	CALL	PrnStrColor
;	EX	(DE),HL
	RET

;Рисование заголовка окна
WinHeader
	LD	E,(IX+1)
	LD	D,(IX+2)
	LD	L,(IX+3)
	LD	H,1
	LD	A,(IX+5)
	RRCA
	RRCA
	RRCA
	RRCA
	AND	#7F
	LD	B,A
	LD	A,#20
	CALL	FillBox
	RET

;Процедура освобождения	прямоугольной площади окна
;На вход: IX - адрес описателя
Rectang	LD	E,(IX+1)
	LD	D,(IX+2)
	LD	H,(IX+4)
	LD	L,(IX+3)
	LD	B,(IX+5)
	LD	A,#20
	CALL	FillBox
	RET 

FillBox	PUSH	HL
	PUSH	DE	
FillB1	LD	C,Dss.WrChar
	RST	DssRst
	INC	E
	DEC	L
	JR	NZ,FillB1
	POP	DE
	POP	HL
	INC	D
	DEC	H
	JR	NZ,FillBox
	RET
	
	
Frame	LD	HL,FrameType1
	BIT	2,(IX+0)		;windows type flag
	JR	Z,Frame1
	LD	HL,FrameType2
Frame1	LD	D,(IX+2)
	LD	E,(IX+1)
	LD	B,(IX+5)
	PUSH	DE
	PUSH	HL
;	PUSH	BC
	LD	A,(HL)
	LD	C,Dss.WrChar
	RST	DssRst
;	POP	BC
	POP	HL
	POP	DE
	LD	A,(IX+3)
	DEC	A
	ADD	A,E
	LD	E,A
	INC	HL
	LD	A,(HL)
	LD	C,Dss.WrChar
	PUSH	DE
	PUSH	HL
	RST	DssRst
	POP	HL
	POP	DE
	LD	A,(IX+4)
	DEC	A
	ADD	A,D
	LD	D,A
	INC	HL
	LD	A,(HL)
	PUSH	DE
	PUSH	HL
	LD	C,Dss.WrChar
	RST	DssRst
	POP	HL
	POP	DE
	LD	E,(IX+1)
	INC	HL
	LD	A,(HL)
	LD	C,Dss.WrChar
	RST	DssRst
;HORIZONTAL LINES
	INC	HL
	LD	A,(HL)
	LD	(FramHor),A
	INC	HL
	PUSH	HL
	LD	H,(IX+2)
	LD	A,(IX+4)
	DEC	A
	ADD 	A,H
	LD 	L,A
	LD	A,(IX+3)
	SUB	2
	LD	C,Dss.WrChar
	LD	E,(IX+1)
	INC	E
	LD	B,(IX+5)
FramHl1	PUSH	AF
	PUSH	HL
	LD	D,H
	LD	A,0
FramHor	EQU	$-1
	PUSH	AF
	RST	DssRst
	POP	AF
	LD	D,L
	RST	DssRst
	POP	HL
	POP	AF
	INC	E
	DEC	A
	JR	NZ,FramHl1
	POP	HL
;VERTICAL LINES
	LD	A,(HL)
	LD	(FramVer),A
	LD	H,(IX+1)
	LD	A,(IX+3)
	DEC	A
	ADD 	A,H
	LD 	L,A
	LD	A,(IX+4)
	SUB	2
	LD	C,Dss.WrChar
	LD	D,(IX+2)
	INC	D
	LD	B,(IX+5)
FramVl1	PUSH	AF
	PUSH	HL
	LD	E,H
	LD	A,0
FramVer	EQU	$-1
	PUSH	AF
	RST	DssRst
	POP	AF
	LD	E,L
	RST	DssRst
	POP	HL
	POP	AF
	INC	D
	DEC	A
	JR	NZ,FramVl1
	RET

;ЛИСТАЕТ ДО СЛЕДУЮЩЕГО ПУНКТА МЕНЮ
MenuItemLen
	LD	B,0
NextMnuItem
	LD	A,(HL)
	INC	HL
	AND	A
	RET	Z
	INC	B
	JR	NextMnuItem


;Прорисовка окна и обработка диалога
DialogWindow
	call	Windows
	inc	hl
;	jp	WinDialog

;ПП обработки диалогового окна
;Dialogs
;+0 (1)	-	Count of Items
;+1 (N)	-	Item Descriptor
;Descriptor
;	+0	-	X
;	+1	-	Y
;	+2	-	Len
;	+3	-	Attrib
;	+4 (2)	-	Hot Key
;	+6 (2)	-	Routine

WinDialog:
	ld	a,(hl)
	ld	(DlgItemsCnt),a
	inc	hl
	ld	(.DialogAdr),hl	
	xor	a
	ld	(SelectedItem),a
.Lp1	ld	a,(SelectedItem)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,0
.DialogAdr	equ $-2
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	b,(hl)
	ex	hl,de
	call	CursorSet
.Lp2	ld	c,Dss.ScanKey
	rst	DssRst
	jr	z,.Lp2
	ld	a,d
	cp	#52		;<Down>
	jr	nz,.Lp3
.LpDn	ld	a,(DlgItemsCnt)
	ld	b,a
	ld	a,(SelectedItem)
	inc	a
	cp	b		;Достигли максимального пункта
	jr	z,.Lp2
.Lp4	ld	(SelectedItem),a
	call	CursorRes
	jr	.Lp1
.Lp3	cp	#58		;<Up>
	jr	nz,.Lp5
.LpUp	ld	a,(SelectedItem)
	and	a
	jr	z,.Lp2
	dec	a
	jr	.Lp4
.Lp5	cp	#54		;<Left>
	jr	z,.LpUp
	cp	#56		;<Right>
	jr	z,.LpDn
.LpAscii
	ld	a,e		;ASCII - код
	cp	#0D		;<Enter>
	jr	nz,.Lp2
	call	CursorRes
	ld	a,(SelectedItem)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,(.DialogAdr)
	add	hl,de
	ld	de,6
	add	hl,de
	ifdef	DEBUG
		push	hl
		ld	de,0
		call	PrintReg
		pop	hl
	endif
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	or	h
	ret	z		;Если адрес =0, то RET
	ifdef	DEBUG
		push	hl
		ld	de,8
		call	PrintReg
		pop	hl
	endif
	jp	(hl)
DlgItemsCnt
	DB	0
SelectedItem
	DB	0
STANDART;    TYPE, X, Y,  L,H,COLOR       
        DEFB    5,10,13,#20,6,7

;Ordinary frame
FrameType1
	DB	#DA,#BF,#D9,#C0,#C4,#B3
;Double frame
FrameType2
	DB	#C9,#BB,#BC,#C8,#CD,#BA