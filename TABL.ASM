;[]=========================================================================[]
;[]             Таблицы дизассемблера монитора-отладчика DemoN              []
;[] v0.01 - последние изменения 10.10.2004                                  []
;[] v0.02 - последние изменения 29.11.2004                                  []
;[] v0.03 - последние изменения 29.01.2006                                  []
;[]=========================================================================[]
Tabl00_3F:
                dw      M00,M01,M02,M03,M04,M05,M06,M07,M08,M09,M0A,M0B,M0C,M0D,M0E,M0F
                dw      M10,M11,M12,M13,M14,M15,M16,M17,M18,M19,M1A,M1B,M1C,M1D,M1E,M1F
                dw      M20,M21,M22,M23,M24,M25,M26,M27,M28,M29,M2A,M2B,M2C,M2D,M2E,M2F
                dw      M30,M31,M32,M33,M34,M35,M36,M37,M38,M39,M3A,M3B,M3C,M3D,M3E,M3F

M00             db      "NOP",0
M01             db      "LD BC,",2
M02             db      "LD (BC),A",0
M03             db      "INC BC",0
M04             db      "INC B",0
M05             db      "DEC B",0
M06             db      "LD B,",1
M07             db      "RLCA",0
M08             db      "EX AF,AF'",0
M09             db      "ADD HL,BC",0
M0A             db      "LD A,(BC)",0
M0B             db      "DEC BC",0
M0C             db      "INC C",0
M0D             db      "DEC C",0
M0E             db      "LD C,",1
M0F             db      "RRCA",0
M10             db      "DJNZ ",3
M11             db      "LD DE,",2
M12             db      "LD (DE),A",0
M13             db      "INC DE",0
M14             db      "INC D",0
M15             db      "DEC D",0
M16             db      "LD D,",1
M17             db      "RLA",0
M18             db      "JR ",3
M19             db      "ADD HL,DE",0
M1A             db      "LD A,(DE)",0
M1B             db      "DEC DE",0
M1C             db      "INC E",0
M1D             db      "DEC E",0
M1E             db      "LD E,",1
M1F             db      "RRA",0
M20             db      "JR NZ,",3
M21             db      "LD HL,",2
M22             db      "LD (),HL",5
M23             db      "INC HL",0
M24             db      "INC H",0
M25             db      "DEC H",0
M26             db      "LD H,",1
M27             db      "DAA",0
M28             db      "JR Z,",3
M29             db      "ADD HL,HL",0
M2A             db      "LD HL,()",5
M2B             db      "DEC HL",0
M2C             db      "INC L",0
M2D             db      "DEC L",0
M2E             db      "LD L,",1
M2F             db      "CPL",0
M30             db      "JR NC,",3
M31             db      "LD SP,",2
M32             db      "LD (),A",5
M33             db      "INC SP",0
M34             db      "INC (HL)",0
M35             db      "DEC (HL)",0
M36             db      "LD (HL),",1
M37             db      "SCF",0
M38             db      "JR C,",3
M39             db      "ADD HL,SP",0
M3A             db      "LD A,()",5
M3B             db      "DEC SP",0
M3C             db      "INC A",0
M3D             db      "DEC A",0
M3E             db      "LD A,",1
M3F             db      "CCF",0

TablC0_FF:
                dw      MC0,MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,MCA,M00,MCC,MCD,MCE,MCF
                dw      MD0,MD1,MD2,MD3,MD4,MD5,MD6,MD7,MD8,MD9,MDA,MDB,MDC,MDD,MDE,MDF
                dw      ME0,ME1,ME2,ME3,ME4,ME5,ME6,ME7,ME8,ME9,MEA,MEB,MEC,M00,MEE,MEF
                dw      MF0,MF1,MF2,MF3,MF4,MF5,MF6,MF7,MF8,MF9,MFA,MFB,MFC,MFD,MFE,MFF

MC0             db      "RET NZ",0
MC1             db      "POP BC",0
MC2             db      "JP NZ,",2
MC3             db      "JP ",2
MC4             db      "CALL NZ,",2
MC5             db      "PUSH BC",0
MC6             db      "ADD A,",1
MC7             db      "RST 0",0
MC8             db      "RET Z",0
MC9             db      "RET",0
MCA             db      "JP Z,",2
MCC             db      "CALL Z,",2
MCD             db      "CALL ",2
MCE             db      "ADC A,",1
MCF             db      "RST 8",0
MD0             db      "RET NC",0
MD1             db      "POP DE",0
MD2             db      "JP NC,",2
MD3             db      "OUT (),A",4
MD4             db      "CALL NC,",2
MD5             db      "PUSH DE",0
MD6             db      "SUB ",1
MD7             db      "RST #10",0
MD8             db      "RET C",0
MD9             db      "EXX",0
MDA             db      "JP C,",2
MDB             db      "IN A,()",4
MDC             db      "CALL C,",2
MDD             db      "DD",0
MDE             db      "SBC A,",1
MDF             db      "RST #18",0
ME0             db      "RET PO",0
ME1             db      "POP HL",0
ME2             db      "JP PO,",2
ME3             db      "EX (SP),HL",0
ME4             db      "CALL PO,",2
ME5             db      "PUSH HL",0
ME6             db      "AND ",1
ME7             db      "RST #20",0
ME8             db      "RET PE",0
ME9             db      "JP (HL)",0
MEA             db      "JP PE,",2
MEB             db      "EX DE,HL",0
MEC             db      "CALL PE,",2
MEE             db      "XOR ",1
MEF             db      "RST #28",0
MF0             db      "RET P",0
MF1             db      "POP AF",0
MF2             db      "JP P,",2
MF3             db      "DI",0
MF4             db      "CALL P,",2
MF5             db      "PUSH AF",0
MF6             db      "OR ",1
MF7             db      "RST #30",0
MF8             db      "RET M",0
MF9             db      "LD SP,HL",0
MFA             db      "JP M,",2
MFB             db      "EI",0
MFC             db      "CALL M,",2
MFD             db      "FD",0
MFE             db      "CP ",1
MFF             db      "RST #38",0

MHALT           db      "HALT",0

TablM:
                dw      M80,M88,M90,M98,MA0,MA8,MB0,MB8

M80             db      "ADD A,",0
M88             db      "ADC A,",0
M90             db      "SUB ",0
M98             db      "SBC A,",0
MA0             db      "AND ",0
MA8             db      "XOR ",0
MB0             db      "OR ",0
MB8             db      "CP ",0

CodeDDFD:
                db      0x09,0x19,0x21,0x22,0x23,0x24,0x25,0x26,0x29
                db      0x2A,0x2B,0x2C,0x2D,0x2E,0x34,0x35,0x36,0x39
                db      0x44,0x45,0x46,0x4C,0x4D,0x4E,0x54,0x55,0x56
                db      0x5C,0x5D,0x5E,0x60,0x61,0x62,0x63,0x64,0x65
                db      0x66,0x67,0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E
                db      0x6F,0x70,0x71,0x72,0x73,0x74,0x75,0x77,0x7C
                db      0x7D,0x7E,0x84,0x85,0x86,0x8C,0x8D,0x8E,0x94
                db      0x95,0x96,0x9C,0x9D,0x9E,0xA4,0xA5,0xA6,0xAC
                db      0xAD,0xAE,0xB4,0xB5,0xB6,0xBC,0xBD,0xBE,0xE1
                db      0xE3,0xE5,0xE9,0xF9

TablDDFD:
                dw      DD09,DD19,DD21,DD22,DD23,DD24,DD25,DD26,DD29
                dw      DD2A,DD2B,DD2C,DD2D,DD2E,DD34,DD35,DD36,DD39
                dw      DD44,DD45,DD46,DD4C,DD4D,DD4E,DD54,DD55,DD56
                dw      DD5C,DD5D,DD5E,DD60,DD61,DD62,DD63,DD64,DD65
                dw      DD66,DD67,DD68,DD69,DD6A,DD6B,DD6C,DD6D,DD6E
                dw      DD6F,DD70,DD71,DD72,DD73,DD74,DD75,DD77,DD7C
                dw      DD7D,DD7E,DD84,DD85,DD86,DD8C,DD8D,DD8E,DD94
                dw      DD95,DD96,DD9C,DD9D,DD9E,DDA4,DDA5,DDA6,DDAC
                dw      DDAD,DDAE,DDB4,DDB5,DDB6,DDBC,DDBD,DDBE,DDE1
                dw      DDE3,DDE5,DDE9,DDF9

DD09            db      "ADD Ix,BC",0
DD19            db      "ADD Ix,DE",0
DD21            db      "LD Ix,",2
DD22            db      "LD (),Ix",5
DD23            db      "INC Ix",0
DD24            db      "INC Hx",0
DD25            db      "DEC Hx",0
DD26            db      "LD Hx,",1
DD29            db      "ADD Ix,Ix",0
DD2A            db      "LD Ix,()",5
DD2B            db      "DEC Ix",0
DD2C            db      "INC Lx",0
DD2D            db      "DEC Lx",0
DD2E            db      "LD Lx,",1
DD34            db      "INC )",6
DD35            db      "DEC )",6
DD36            db      "LD ),",6
DD39            db      "ADD Ix,SP",0
DD44            db      "LD B,Hx",0
DD45            db      "LD B,Lx",0
DD46            db      "LD B,)",6
DD4C            db      "LD C,Hx",0
DD4D            db      "LD C,Lx",0
DD4E            db      "LD C,)",6
DD54            db      "LD D,Hx",0
DD55            db      "LD D,Lx",0
DD56            db      "LD D,)",6
DD5C            db      "LD E,Hx",0
DD5D            db      "LD E,Lx",0
DD5E            db      "LD E,)",6
DD60            db      "LD Hx,B",0
DD61            db      "LD Hx,C",0
DD62            db      "LD Hx,D",0
DD63            db      "LD Hx,E",0
DD64            db      "LD Hx,Hx",0
DD65            db      "LD Hx,Lx",0
DD66            db      "LD H,)",6
DD67            db      "LD Lx,A",0
DD68            db      "LD Lx,B",0
DD69            db      "LD Lx,C",0
DD6A            db      "LD Lx,D",0
DD6B            db      "LD Lx,E",0
DD6C            db      "LD Lx,Hx",0
DD6D            db      "LD Lx,Lx",0
DD6E            db      "LD L,)",6
DD6F            db      "LD Lx,A",0
DD70            db      "LD ),B",6
DD71            db      "LD ),C",6
DD72            db      "LD ),D",6
DD73            db      "LD ),E",6
DD74            db      "LD ),H",6
DD75            db      "LD ),L",6
DD77            db      "LD ),A",6
DD7C            db      "LD A,Hx",0
DD7D            db      "LD A,Lx",0
DD7E            db      "LD A,)",6
DD84            db      "ADD A,Hx",0
DD85            db      "ADD A,Lx",0
DD86            db      "ADD A,)",6
DD8C            db      "ADC E,Hx",0
DD8D            db      "ADC E,Lx",0
DD8E            db      "ADC E,)",6
DD94            db      "SUB Hx",0
DD95            db      "SUB Lx",0
DD96            db      "SUB )",6
DD9C            db      "SBC A,Hx",0
DD9D            db      "SBC A,Lx",0
DD9E            db      "SBC A,)",6
DDA4            db      "AND Hx",0
DDA5            db      "AND Lx",0
DDA6            db      "AND )",6
DDAC            db      "XOR Hx",0
DDAD            db      "XOR Lx",0
DDAE            db      "XOR )",6
DDB4            db      "OR Hx",0
DDB5            db      "OR Lx",0
DDB6            db      "OR )",6
DDBC            db      "CP Hx",0
DDBD            db      "CP Lx",0
DDBE            db      "CP )",6
DDE1            db      "POP Ix",0
DDE3            db      "EX (SP),Ix",0
DDE5            db      "PUSH Ix",0
DDE9            db      "JP (Ix)",0
DDF9            db      "LD SP,Ix",0

TablCB:
                dw      CB00,CB08,CB10,CB18,CB20,CB28,CB30,CB38

CB00            db      "RLC "
CB08            db      "RRC "
CB10            db      "RL "
CB18            db      "RR "
CB20            db      "SLA "
CB28            db      "SRA "
CB30            db      "SLI "
CB38            db      "SRL "
CB40            db      "BIT "
CB80            db      "RES "
CBC0            db      "SET "

TablED:
                dw      ED40,ED41,ED42,ED43,ED44,ED45,ED46,ED47
                dw      ED48,ED49,ED4A,ED4B,ED44,ED4D,ED4E,ED4F
                dw      ED50,ED51,ED52,ED53,ED44,ED45,ED56,ED57
                dw      ED58,ED59,ED5A,ED5B,ED44,ED4D,ED5E,ED5F
                dw      ED60,ED61,ED62,ED63,ED44,ED45,ED46,ED67
                dw      ED68,ED69,ED6A,ED6B,ED44,ED4D,ED4E,ED6F
                dw      ED70,ED71,ED72,ED73,ED44,ED45,ED56,ED00
                dw      ED78,ED79,ED7A,ED7B,ED44,ED4D,ED5E
                dw      EDA0,EDA1,EDA2,EDA3,ED00,ED00,ED00,ED00
                dw      EDA8,EDA9,EDAA,EDAB,ED00,ED00,ED00,ED00
                dw      EDB0,EDB1,EDB2,EDB3,ED00,ED00,ED00,ED00
                dw      EDB8,EDB9,EDBA,EDBB

ED00            db      "NOP *",0
ED40            db      "IN B,(C)",0
ED41            db      "OUT (C),B",0
ED42            db      "SBC HL,BC",0
ED43            db      "LD (),BC",5
ED44            db      "NEG",0
ED45            db      "RETN",0
ED46            db      "IM 0",0
ED47            db      "LD I,A",0
ED48            db      "IN C,(C)",0
ED49            db      "OUT (C),C",0
ED4A            db      "ADC HL,BC",0
ED4B            db      "LD BC,()",5
ED4D            db      "RETI",0
ED4E            db      "IM 0 *",0
ED4F            db      "LD R,A",0
ED50            db      "IN D,(C)",0
ED51            db      "OUT (C),D",0
ED52            db      "SBC HL,DE",0
ED53            db      "LD (),DE",5
ED56            db      "IM 1",0
ED57            db      "LD A,I",0
ED58            db      "IN E,(C)",0
ED59            db      "OUT (C),E",0
ED5A            db      "ADC HL,DE",0
ED5B            db      "LD DE,()",5
ED5E            db      "IM 2",0
ED5F            db      "LD A,R",0
ED60            db      "IN H,(C)",0
ED61            db      "OUT (C),H",0
ED62            db      "SBC HL,HL",0
ED63            db      "LD (),HL",5
ED67            db      "RRD",0
ED68            db      "IN L,(C)",0
ED69            db      "OUT (C),L",0
ED6A            db      "ADC HL,HL",0
ED6B            db      "LD HL,()",5
ED6F            db      "RLD",0
ED70            db      "IN F,(C)",0
ED71            db      "OUT (C),*",0
ED72            db      "SBC HL,SP",0
ED73            db      "LD (),SP",5
ED78            db      "IN A,(C)",0
ED79            db      "OUT (C),A",0
ED7A            db      "ADC HL,SP",0
ED7B            db      "LD SP,()",5
EDA0            db      "LDI",0
EDA1            db      "CPI",0
EDA2            db      "INI",0
EDA3            db      "OUTI",0
EDA8            db      "LDD",0
EDA9            db      "CPD",0
EDAA            db      "IND",0
EDAB            db      "OUTD",0
EDB0            db      "LDIR",0
EDB1            db      "CPIR",0
EDB2            db      "INIR",0
EDB3            db      "OTIR",0
EDB8            db      "LDDR",0
EDB9            db      "CPDR",0
EDBA            db      "INDR",0
EDBB            db      "OTDR",0

