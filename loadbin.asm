LoadBinDialog	ld	ix,.LoadBinWnd
		call	DialogWindow
		ret
.LoadBinEditFN	;ld	hl,.LoadBinFileName
		;ld	c,20
		;call	InputLine.ToBuffer
.L003		ld	hl,#0f24
		ld	b,20
		call	InputLine1
		jr	c,LoadBinDialog
		ld	a,c
		and	a
		jr	z,.L003
		ld	(.filenamelen),a
		push	bc
		ld	de,.LoadBinFileName
		call	InputLine.FromBuffer
		pop	bc
		ld	a,20
		sub	c
		jr	z,.L001
		ld	b,a
		ld	a,32
.L002		ld	(de),a
		inc	de
		djnz	.L002
.L001		jr	LoadBinDialog

.EditAddres	ld	hl,#1021
		ld	b,5
		call	InputLine1
		jr	c,LoadBinDialog
		push	bc
		call	PutAdres
		pop	bc
		jr	c,.EditAddres
		ld	(.LoadToAdr),hl
		ld	de,.AdresTxt
		call	InputLine.FromBuffer
		jr	LoadBinDialog
.EditLenght	ld	hl,#1031
		ld	b,5
		call	InputLine1
		jr	c,LoadBinDialog
		push	bc
		call	PutAdres
		pop	bc
		jr	c,.EditLenght
		ld	(.LoadLen),hl
		ld	de,.LenTxt
		call	InputLine.FromBuffer
		jr	LoadBinDialog
.LoadBIN	
                xor     a
                ld      (ClockOn),a
		ld	c,Dss.Open
		ld	hl,.LoadBinFileName
		push	hl
		ld	a,(.filenamelen)
		ld	d,0
		ld	e,a
		add	hl,de
		ld	(.restadr+1),hl
		ld	(hl),0
		pop	hl
		ld	a,1
		rst	DssRst
		jp	c,.Err1
.restadr	ld	hl,0
		ld	(hl),32
		ld	(.FMid),a
		ld	hl,(.LoadToAdr)
		ld	a,1			;адрес в области #0000-7fff?
		bit	7,h
		jr	z,.adr0000
		inc	a			;#8000-#bfff?
		bit	6,h
		jr	z,.adr
		inc	a			;#c000-ffff !!!
		jr	.adr
.adr0000	bit	6,h
		jr	nz,.adr
		sub	a
.adr		ld	(.bank),a
		set	6,h			;адрес загрузки =>#4XXX
		res	7,h
		ld	(.LoadFirst+4),hl
		push	hl
		ld	hl,0			;Узнаем длину файла
		ld	ix,0
		ld	b,2
		ld	c,Dss.Move_FP
		rst	DssRst
		ld	(.LoadLen),HL
		ld	(.LoadEnd+1),hl
		pop	hl
.Load00		and	a
		ex	hl,de
		ld	de,#8000
		sbc	hl,de
		ld	(.LoadFirst+1),hl
		ld	de,(.LoadEnd+1)
		and	a
		sbc	hl,de
		jr	c,.LoadEnd
.LoadFirst	ld	de,0			;количество байт, которые надо считать в первую банку
		ld	hl,0			;адрес, куда скачать
.LoadNext	call	.Bank1
		ld	c,Dss.Read
		ld	a,(.FMid)
		rst	DssRst
		jr	c,.Err
		ld	hl,.bank
		inc	(hl)
		ld	hl,(.LoadEnd+1)
		ld	de,#4000
		and	a
		sbc	hl,de
		jr	c,.LoadEnd		;Осталось меньше 16Кб
		ld	(.LoadEnd+1),hl
		ld	hl,#4000
		ld	de,#4000
		jr	.LoadNext
.LoadEnd	ld	de,0			;количество байт, которые необходимо дочитать
		call	.Bank1
		ld	hl,#4000
		ld	a,(.FMid)
		ld	c,Dss.Read
		rst	DssRst
		jr	c,.Err
		ld	a,(.FMid)
		ld	c,Dss.Close
		rst	DssRst

		ld	hl,(.LoadToAdr)
		ld	(ListAdr),hl
		ld	a,(WinPage+1)
		out	(EmmWin.P1),a
		ret
.Err		push	af
		ld	a,(.FMid)
		ld	c,Dss.Close
		rst	DssRst
		pop	af
.Err1		call	ErDss
		ld	c,Dss.PChars		;вывод текста ошибки и ожидания any key
		rst	DssRst
		ld	c,Dss.WaitKey
		rst	DssRst
		ret
		
.Bank1		push	hl
		push	de
		ld	a,(.bank)
		ld	l,a
		ld	h,0
		ld	de,WinPage
		add	hl,de
		ld	a,(hl)
		out	(EmmWin.P1),a
		pop	de
		pop	hl
		ret		
		
		

.bank		db	0		
.FMid		db	0
.filenamelen	db	0
.LoadToAdr	dw	#4000
.LoadLen	dw	#1000		
.LoadBinWnd	db	2,23,13,36,6,7
		db	"Load BIN-file",0
		db	"Filename:  "
.LoadBinFileName	ds	20,32
		db	0X0D
		db	"Addres: "
.AdresTxt	db	"#4000   Lenght: "
.LenTxt		db	"#1000"
		db	0x16,10+23,4+13,"OK       Cancel",0
		db	5
		db	35,15,22,2	;Filename
		dw	0,.LoadBinEditFN
		db	32,16,7,2	;Addres
		dw	0,.EditAddres
		db	48,16,7,2	;Lenght
		dw	0,.EditLenght
		db	30,17,8,2	;OK
		dw	0,.LoadBIN
		db	41,17,8,2	;Cancel
		dw	0,0