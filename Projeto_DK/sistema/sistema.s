#########################################################################
# Rotina de tratamento de excecao e interrupcao		v1.4		#
# Lembre-se: Os ecalls originais do Rars possuem precedencia sobre	#
# 	     estes definidos aqui					#
# Os ecalls 1XX usam o BitMap Display e Keyboard Display MMIO Tools	#
#									#
# Marcus Vinicius Lamar							#
# 2019/1								#
#########################################################################

# v1.0 2018/1 by
# Gabriel Alves Castro - 17/0033813
# Henrique Mendes de Freitas Mariano - 17/0012280
# Luthiery Costa Cavalcante - 17/0040631
# Matheus Breder Branquinho Nogueira - 17/0018997
#

# v1.1 2019/1 by
# Alexandre Souza Costa Oliveira - 17/0098168


#definicao do mapa de enderecamento de MMIO
.eqv VGAADDRESSINI0     0xFF000000
.eqv VGAADDRESSFIM0     0xFF012C00
.eqv VGAADDRESSINI1     0xFF100000
.eqv VGAADDRESSFIM1     0xFF112C00 
.eqv NUMLINHAS          240
.eqv NUMCOLUNAS         320
.eqv VGAFRAMESELECT	0xFF200604

.eqv KDMMIO_Ctrl	0xFF200000
.eqv KDMMIO_Data	0xFF200004

.eqv Buffer0Teclado     0xFF200100
.eqv Buffer1Teclado     0xFF200104

.eqv TecladoxMouse      0xFF200110
.eqv BufferMouse        0xFF200114

.eqv AudioBase		0xFF200160
.eqv AudioINL           0xFF200160
.eqv AudioINR           0xFF200164
.eqv AudioOUTL          0xFF200168
.eqv AudioOUTR          0xFF20016C
.eqv AudioCTRL1         0xFF200170
.eqv AudioCTRL2         0xFF200174

# Sintetizador - 2015/1
.eqv NoteData           0xFF200178
.eqv NoteClock          0xFF20017C
.eqv NoteMelody         0xFF200180
.eqv MusicTempo         0xFF200184
.eqv MusicAddress       0xFF200188


.eqv IrDA_CTRL 		0xFF20 0500	
.eqv IrDA_RX 		0xFF20 0504
.eqv IrDA_TX		0xFF20 0508

.eqv STOPWATCH		0xFF200510

.eqv LFSR		0xFF200514

.eqv KeyMap0		0xFF200520
.eqv KeyMap1		0xFF200524
.eqv KeyMap2		0xFF200528
.eqv KeyMap3		0xFF20052C


.data
# UTVEC e UEPC Enquanto nao tem o sistema de gerenciamento de interrupcao e excecao
UEPC:	.word 0x00000000
UTVEC:	.word 0x00000000

# Tabela de caracteres desenhados segundo a fonte 8x8 pixels do ZX-Spectrum
LabelTabChar:
.word 	0x00000000, 0x00000000, 0x10101010, 0x00100010, 0x00002828, 0x00000000, 0x28FE2828, 0x002828FE, 
	0x38503C10, 0x00107814, 0x10686400, 0x00004C2C, 0x28102818, 0x003A4446, 0x00001010, 0x00000000, 
	0x20201008, 0x00081020, 0x08081020, 0x00201008, 0x38549210, 0x00109254, 0xFE101010, 0x00101010, 
	0x00000000, 0x10081818, 0xFE000000, 0x00000000, 0x00000000, 0x18180000, 0x10080402, 0x00804020, 
	0x54444438, 0x00384444, 0x10103010, 0x00381010, 0x08044438, 0x007C2010, 0x18044438, 0x00384404, 
	0x7C482818, 0x001C0808, 0x7840407C, 0x00384404, 0x78404438, 0x00384444, 0x1008047C, 0x00202020, 
	0x38444438, 0x00384444, 0x3C444438, 0x00384404, 0x00181800, 0x00001818, 0x00181800, 0x10081818, 
	0x20100804, 0x00040810, 0x00FE0000, 0x000000FE, 0x04081020, 0x00201008, 0x08044438, 0x00100010, 
	0x545C4438, 0x0038405C, 0x7C444438, 0x00444444, 0x78444478, 0x00784444, 0x40404438, 0x00384440,
	0x44444478, 0x00784444, 0x7840407C, 0x007C4040, 0x7C40407C, 0x00404040, 0x5C404438, 0x00384444, 
	0x7C444444, 0x00444444, 0x10101038, 0x00381010, 0x0808081C, 0x00304848, 0x70484444, 0x00444448, 
	0x20202020, 0x003C2020, 0x92AAC682, 0x00828282, 0x54546444, 0x0044444C, 0x44444438, 0x00384444, 
	0x38242438, 0x00202020, 0x44444438, 0x0C384444, 0x78444478, 0x00444850, 0x38404438, 0x00384404, 
	0x1010107C, 0x00101010, 0x44444444, 0x00384444, 0x28444444, 0x00101028, 0x54828282, 0x00282854, 
	0x10284444, 0x00444428, 0x10284444, 0x00101010, 0x1008047C, 0x007C4020, 0x20202038, 0x00382020, 
	0x10204080, 0x00020408, 0x08080838, 0x00380808, 0x00442810, 0x00000000, 0x00000000, 0xFE000000, 
	0x00000810, 0x00000000, 0x3C043800, 0x003A4444, 0x24382020, 0x00582424, 0x201C0000, 0x001C2020, 
	0x48380808, 0x00344848, 0x44380000, 0x0038407C, 0x70202418, 0x00202020, 0x443A0000, 0x38043C44, 
	0x64584040, 0x00444444, 0x10001000, 0x00101010, 0x10001000, 0x60101010, 0x28242020, 0x00242830, 
	0x08080818, 0x00080808, 0x49B60000, 0x00414149, 0x24580000, 0x00242424, 0x44380000, 0x00384444, 
	0x24580000, 0x20203824, 0x48340000, 0x08083848, 0x302C0000, 0x00202020, 0x201C0000, 0x00380418, 
	0x10381000, 0x00101010, 0x48480000, 0x00344848, 0x44440000, 0x00102844, 0x82820000, 0x0044AA92, 
	0x28440000, 0x00442810, 0x24240000, 0x38041C24, 0x043C0000, 0x003C1008, 0x2010100C, 0x000C1010, 
	0x10101010, 0x00101010, 0x04080830, 0x00300808, 0x92600000, 0x0000000C, 0x243C1818, 0xA55A7E3C, 
	0x99FF5A81, 0x99663CFF, 0x10280000, 0x00000028, 0x10081020, 0x00081020

# scancode -> ascii
LabelScanCode:
#  	0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
.byte 	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, # 00 a 0F
	0x00, 0x00, 0x00, 0x00, 0x00, 0x71, 0x31, 0x00, 0x00, 0x00, 0x7a, 0x73, 0x61, 0x77, 0x32, 0x00, # 10 a 1F 
	0x00, 0x63, 0x78, 0x64, 0x65, 0x34, 0x33, 0x00, 0x00, 0x20, 0x76, 0x66, 0x74, 0x72, 0x35, 0x00, # 20 a 2F  29 espaco => 20
	0x00, 0x6e, 0x62, 0x68, 0x67, 0x79, 0x36, 0x00, 0x00, 0x00, 0x6d, 0x6a, 0x75, 0x37, 0x38, 0x00, # 30 a 3F 
	0x00, 0x2c, 0x6b, 0x69, 0x6f, 0x30, 0x39, 0x00, 0x00, 0x2e, 0x2f, 0x6c, 0x3b, 0x70, 0x2d, 0x00, # 40 a 4F 
	0x00, 0x00, 0x27, 0x00, 0x00, 0x3d, 0x00, 0x00, 0x00, 0x00, 0x0A, 0x5b, 0x00, 0x5d, 0x00, 0x00, # 50 a 5F   5A enter => 0A (= ao Rars)
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x31, 0x00, 0x34, 0x37, 0x00, 0x00, 0x00, # 60 a 6F 
	0x30, 0x2e, 0x32, 0x35, 0x36, 0x38, 0x00, 0x00,	0x00, 0x2b, 0x33, 0x2d, 0x2a, 0x39, 0x00, 0x00, # 70 a 7F 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00						   		# 80 a 85
# scancode -> ascii (com shift)
LabelScanCodeShift:
.byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x21, 0x00, 0x00, 0x00, 0x5a, 0x53, 0x41, 0x57, 0x40, 0x00, 
	0x00, 0x43, 0x58, 0x44, 0x45, 0x24, 0x23, 0x00, 0x00, 0x00, 0x56, 0x46, 0x54, 0x52, 0x25, 0x00, 
	0x00, 0x4e, 0x42, 0x48, 0x47, 0x59, 0x5e, 0x00, 0x00, 0x00, 0x4d, 0x4a, 0x55, 0x26, 0x2a, 0x00, 
	0x00, 0x3c, 0x4b, 0x49, 0x4f, 0x29, 0x28, 0x00, 0x00, 0x3e, 0x3f, 0x4c, 0x3a, 0x50, 0x5f, 0x00, 
	0x00, 0x00, 0x22, 0x00, 0x00, 0x2b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7b, 0x00, 0x7d, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00

#instructionMessage:     .ascii  "   Instrucao    "
#                        .string "   Invalida!    "

.align 2

#buffer do ReadString, ReadFloat, SDread, etc. 512 caracteres/bytes
TempBuffer:
.space 512

# tabela de conversao hexa para ascii
TabelaHexASCII:		.string "0123456789ABCDEF  "
NumDesnormP:		.string "+desnorm"
NumDesnormN:		.string "-desnorm"
NumZero:		.string "0.00000000"
NumInfP:		.string "+Infinity"
NumInfN:		.string "-Infinity"
NumNaN:			.string "NaN"

# tabela de excecoes
#0 : Instruction address misaligned � endere�o da instru��o desalinhado
#1 : Instruction access fault - endere�o fora do segmento .text
#2 : Ilegal Instruction � Instru��o n�o reconhecida
#4 : Load address misaligned � endere�o de load desalinhado (obs.: lw, lh, lhu)
#5 : Load access fault � endere�o fora do segment .data
#6 : Store address misaligned � endere�o de store desalinhado (obs.: sw, sh)
#7 : Store access fault � endere�o fora do segment .data
InstrMisaligned: 	.string "Error: 0 Instruction address misaligned"
InstrAccessFault: 	.string "Error: 1 Instruction access fault"
InstrIlegal:	 	.string "Error: 2 Ilegal Instruction"
LoadMisaligned: 	.string "Error: 4 Load address misaligned"
LoadAccessFault:	.string "Error: 5 Load access fault"
StoreMisaligned:	.string "Error: 6 Store address misaligned"
StoreAccessFault:	.string "Error: 7 Store access fault"
StringPC:			.string "PC:"
StringAddress:		.string "Address:"
StringInstruction:	.string "Instr:"
### Obs.: a forma 'LABEL: instrucao' embora fique feio facilita o debug no Rars, por favor nao reformatar!!!

########################################################################################
.text

###### Devem ser colocadas aqui as identifica��es das interrup��es e exce��es
exceptionHandling:  #j ecallException
					csrr tp, 66	# le a causa da exce��o
					
					# UCAUSE = 0 : Instruction address misaligned � endere�o da instru��o desalinhado
					beq tp, zero, instrMisalignedException
					
					# UCAUSE = 1 : Instruction access fault - endere�o fora do segmento .text
					addi tp, tp, -1	# ( se tp for = 1, ao subtrair por 1, ser� tp = 0 ?)
					beq tp, zero, instrAcessFaultException
					
					# UCAUSE = 2 : Ilegal Instruction � Instru��o n�o reconhecida
					addi tp, tp, -1	# ao subtrair novamente, encontrar� tp = zero ?
					beq tp, zero, instrIlegalException
					
					# UCAUSE 4 : Load address misaligned � endere�o de load desalinhado (obs.: lw, lh, lhu)
					addi tp, tp, -2	# ao subtrair por 2, encontrar� tp = zero ?
					beq tp, zero, loadMisalignedException
					
					# UCAUSE 5 : Load access fault � endere�o fora do segment .data
					addi tp, tp, -1	# ao subtrair novamente, encontrar� tp = zero ?
					beq tp, zero, loadAccessFaultException
					
					# UCAUSE 6 : Store address misaligned � endere�o de store desalinhado (obs.: sw, sh) 
					addi tp, tp, -1	# ao subtrair novamente, encontrar� tp = zero ?
					beq tp, zero, storeMisalignedException

					# UCAUSE 7 : Store access fault � endere�o fora do segment .data
					addi tp, tp, -1	# ao subtrair novamente, encontrar� tp = zero ?
					beq tp, zero, storeAcessFaultException										
					
					## ecall ##
					j ecallException		# Por enquanto somente a exce��o de ecall
	
endException:  	csrrw tp, 65, zero	# le o valor de EPC salvo no registrador uepc (reg 65)
		addi tp, tp, 4		# soma 4 para obter a instrucao seguinte ao ecall
		csrrw zero, 65, tp	# coloca no registrador uepc
		uret


######### Excecao Instruction Misaligned #############
instrMisalignedException:	la a0, InstrMisaligned
	j blueScreen
#############################################################################################

######### Excecao Instruction Acces Fault #############
instrAcessFaultException:	la a0, InstrAccessFault
	j blueScreen
#############################################################################################

######### Excecao Instruction Ilegal #############
instrIlegalException:	la a0, InstrIlegal
	j blueScreen
#############################################################################################

######### Excecao Load Misaligned #############
loadMisalignedException:	la a0, LoadMisaligned
	j blueScreen
#############################################################################################

######### Excecao Load Acess Fault #############
loadAccessFaultException:	la a0, LoadAccessFault
	j blueScreen
#############################################################################################

######### Excecao Store Misaligned #############
storeMisalignedException:	la a0, StoreMisaligned
	j blueScreen
#############################################################################################

######### Excecao Store Acess Fault #############
storeAcessFaultException:	la a0, StoreAccessFault
	j blueScreen
#############################################################################################


############# interrupcao de ECALL ###################
ecallException:     addi    sp, sp, -264              # Salva todos os registradores na pilha
    sw      x1,    0(sp)
    sw      x2,    4(sp)
    sw      x3,    8(sp)
    sw      x4,   12(sp)
    sw      x5,   16(sp)
    sw      x6,   20(sp)
    sw      x7,   24(sp)
    sw      x8,   28(sp)
    sw      x9,   32(sp)
    sw      x10,  36(sp)
    sw      x11,  40(sp)
    sw      x12,  44(sp)
    sw      x13,  48(sp)
    sw      x14,  52(sp)
    sw      x15,  56(sp)
    sw      x16,  60(sp)
    sw      x17,  64(sp)
    sw      x18,  68(sp)
    sw      x19,  72(sp)
    sw      x20,  76(sp)
    sw      x21,  80(sp)
    sw      x22,  84(sp)
    sw      x23,  88(sp)
    sw      x24,  92(sp)
    sw      x25,  96(sp)
    sw      x26, 100(sp)
    sw      x27, 104(sp)
    sw      x28, 108(sp)
    sw      x29, 112(sp)
    sw      x30, 116(sp)
    sw      x31, 120(sp)
    fsw    	f0,  124(sp)
    fsw    	f1,  128(sp)
    fsw    	f2,  132(sp)
    fsw    	f3,  136(sp)
    fsw    	f4,  140(sp)
    fsw    	f5,  144(sp)
    fsw    	f6,  148(sp)
    fsw    	f7,  152(sp)
    fsw    	f8,  156(sp)
    fsw    	f9,  160(sp)
    fsw    	f10, 164(sp)
    fsw    	f11, 168(sp)
    fsw    	f12, 172(sp)
    fsw    	f13, 176(sp)
    fsw    	f14, 180(sp)
    fsw    	f15, 184(sp)
    fsw    	f16, 188(sp)
    fsw    	f17, 192(sp)
    fsw    	f18, 196(sp)
    fsw    	f19, 200(sp)
    fsw    	f20, 204(sp)
    fsw    	f21, 208(sp)
    fsw    	f22, 212(sp)
    fsw    	f23, 216(sp)
    fsw    	f24, 220(sp)
    fsw    	f25, 224(sp)
    fsw    	f26, 228(sp)
    fsw    	f27, 232(sp)
    fsw    	f28, 236(sp)
    fsw    	f29, 240(sp)
    fsw    	f30, 244(sp)
    fsw    	f31, 248(sp)
    
    # Zera os valores dos registradores temporarios
    add     t0, zero, zero
    add     t1, zero, zero
    add     t2, zero, zero
    add     t3, zero, zero
    add     t4, zero, zero
    add     t5, zero, zero
    add     t6, zero, zero
	
# Verifica o numero da chamada do sistema
    addi    t0, zero, 10
    beq     t0, a7, goToExit          # ecall exit
    addi    t0, zero, 110
    beq     t0, a7, goToExit          # ecall exit
    
    addi    t0, zero, 1               # ecall 1 = print int
    beq     t0, a7, goToPrintInt
    addi    t0, zero, 101             # ecall 1 = print int
    beq     t0, a7, goToPrintInt

    addi    t0, zero, 4               # ecall 4 = print string
    beq     t0, a7, goToPrintString
    addi    t0, zero, 104             # ecall 4 = print string
    beq     t0, a7, goToPrintString

    addi    t0, zero, 11              # ecall 11 = print char
    beq     t0, a7, goToPrintChar
    addi    t0, zero, 111             # ecall 11 = print char
    beq     t0, a7, goToPrintChar

    addi    t0, zero, 30              # ecall 30 = time
    beq     t0, a7, goToTime
    addi    t0, zero, 130             # ecall 30 = time
    beq     t0, a7, goToTime
    
    addi    t0, zero, 32              # ecall 32 = sleep
    beq     t0, a7, goToSleep
    addi    t0, zero, 132             # ecall 32 = sleep
    beq     t0, a7, goToSleep

    addi    t0, zero, 41              # ecall 41 = random
    beq     t0, a7, goToRandom
    addi    t0, zero, 141             # ecall 41 = random
    beq     t0, a7, goToRandom
    
    addi    t0, zero, 31              # ecall 31 = MIDI out
    beq     t0, a7, goToMidiOut       # Generate tone and return immediately
    addi    t0, zero, 131             # ecall 31 = MIDI out
    beq     t0, a7, goToMidiOut

    addi    t0, zero, 33              # ecall 33 = MIDI out synchronous
    beq     t0, a7, goToMidiOutSync   # Generate tone and return upon tone completion
    addi    t0, zero, 133             # ecall 33 = MIDI out synchronous
    beq     t0, a7, goToMidiOutSync
        
                
endEcall: lw	x1, 0(sp)  # recupera QUASE todos os registradores na pilha
	lw	x2,   4(sp)	
	lw	x3,   8(sp)	
	lw	x4,  12(sp)      	
	lw	x5,  16(sp)      	
    	lw	x6,  20(sp)	
    	lw	x7,  24(sp)
    	lw	x8,  28(sp)
    	lw	x9,    32(sp)
#	lw      x10,   36(sp)	# a0 retorno de valor
	lw      x11,   40(sp)
    	lw	x12,   44(sp)
    	lw      x13,   48(sp)
    	lw      x14,   52(sp)
    	lw      x15,   56(sp)
    	lw      x16,   60(sp)
    	lw      x17,   64(sp)
    	lw      x18,   68(sp)
    	lw      x19,   72(sp)
    	lw      x20,   76(sp)
    	lw      x21,   80(sp)
    	lw      x22,   84(sp)
    	lw      x23,   88(sp)
    	lw      x24,   92(sp)
    	lw      x25,   96(sp)
    	lw      x26,  100(sp)
    	lw      x27,  104(sp)
    	lw      x28,  108(sp)
    	lw      x29,  112(sp)
    	lw      x30,  116(sp)
    	lw      x31,  120(sp)
	flw    f0,   124(sp)
    	flw    f1,  128(sp)
    	flw    f2,  132(sp)
    	flw    f3,  136(sp)
    	flw    f4,  140(sp)
    	flw    f5,  144(sp)
    	flw    f6,  148(sp)
    	flw    f7,  152(sp)
    	flw    f8,  156(sp)
    	flw    f9,  160(sp)
#   	flw    f10, 164(sp)		# fa0 retorno de valor
    	flw    f11, 168(sp)
    	flw    f12, 172(sp)
    	flw    f13, 176(sp)
    	flw    f14, 180(sp)
    	flw    f15, 184(sp)
    	flw    f16, 188(sp)
    	flw    f17, 192(sp)
    	flw    f18, 196(sp)
    	flw    f19, 200(sp)
    	flw    f20, 204(sp)
    	flw    f21, 208(sp)
    	flw    f22, 212(sp)
    	flw    f23, 216(sp)
    	flw    f24, 220(sp)
    	flw    f25, 224(sp)
    	flw    f26, 228(sp)
    	flw    f27, 232(sp)
    	flw    f28, 236(sp)
    	flw    f29, 240(sp)
    	flw    f30, 244(sp)
    	flw    f31, 248(sp)
    
   	addi    sp, sp, 264
    	j endException


goToExit:   	DE1(goToExitDE2)	# se for a DE2
  		li 	a7, 10		# chama o ecall normal do Rars
  		ecall			# exit ecall
  		
goToExitDE2:	j 	goToExitDE2		# trava o processador

goToPrintInt:	jal     printInt               	# chama printInt
		j       endEcall

goToPrintString: jal     printString           	# chama printString
    		j       endEcall

goToPrintChar:	jal     printChar		# chama printChar
    		j       endEcall
	
goToMidiOut:	jal     midiOut                 # chama MIDIout
    		j       endEcall

goToMidiOutSync:	jal     midiOutSync   	# chama MIDIoutSync
    			j       endEcall

goToTime:	jal     time                    # chama time
    		j       endEcall

goToSleep:	jal     sleep                  	# chama sleep
		j       endEcall

goToRandom:	jal     random                 	# chama random
    		j       endEcall    		
    		    		
    		    		    		    		
####################################################################################################

#############################################
#  BlueScreen                                #
#  a0    =    string		                 #
#############################################
blueScreen:	li t0, 0xFF000000	# frame 0
	li t1, 0xFF100000			# frame 1
	li t2, 0xFF012C00			# end
	li t3, 0xC0C0C0C0			# azul
	
	FOR1_BLUE_SCREEN:	beq t0, t2, EXIT_FOR1_BLUE_SCREEN
		sw t3, 0(t0)	# pixel word azul frame 0
		sw t3, 0(t1)	# pixel word azul frame 1
		addi t0, t0, 4	# proximo word frame 0
		addi t1, t1, 4	# proximo word frame 1
		j FOR1_BLUE_SCREEN
	
	## Printa String de Erro Exception no Frame 0 ##
	EXIT_FOR1_BLUE_SCREEN:	li a1, 4
	li a2, 4
	li a3, 0xC7FF
	li a4, 0	# frame 0
	jal ra, printString
	
	## Printa String de Erro Exception no Frame 1 #
	li a1, 4
	li a2, 4
	li a4, 1	# frame 1
	jal ra, printString
	
	## Printa String "PC: " no Frame 0 ##
	la a0, StringPC
	li a1,4
	li a2, 14
	li a4, 0
	jal ra, printString
	
	## Printa String "PC: " no Frame 1 ##	
	la a0, StringPC
	li a1, 4
	li a2, 14
	li a3, 0xC7FF
	li a4, 1 # frame 1
	jal ra, printString
	
	## Printa Hexadecimal endereco de erro no Frame 0 ##
	csrr a0, 65	# le UEPC
	li a1, 64
	li a2, 14
	li a4, 0
	jal ra, printHex
	
	## Printa Hexadecimal endereco de erro no Frame 1 ##
	csrr a0, 65	# le UEPC
	li a1, 64
	li a2, 14
	li a4, 1
	jal ra, printHex
	
	csrr t0, 66	# le a causa
	
	## Se for causa zero ou 1, ignora Address ##
	beq t0, zero, WHILE1_BLUE_SCREEN
	
	li t1, 1
	beq t0, t1, WHILE1_BLUE_SCREEN
	###############################################
	
	## Se for causa 2, Aparece Instr no lugar de Address ##
	li t1, 2
	beq t0, t1, BlueIlegalInstruction
	#######################################################
	
	## Caso contrario, aparece Address normal #############
	## Printa String Address
	la a0, StringAddress
	li a1, 4
	li a2, 26
	li a4, 0
	jal ra, printString
	
	la a0, StringAddress
	li a1, 4
	li a2, 26
	li a4, 1
	jal ra, printString
	
	j CONTINUAR_BLUE_SCREEN
	
	BlueIlegalInstruction: nop
	la a0, StringInstruction
	li a1, 4
	li a2, 26
	li a4, 0
	jal ra, printString
	
	la a0, StringInstruction
	li a1, 4
	li a2, 26
	li a4, 1
	jal ra, printString
	
	CONTINUAR_BLUE_SCREEN:
	## Printa utval
	csrr a0, 67
	li a4, 0
	li a2, 26
	li a1, 72
	jal ra, printHex
	
	csrr a0, 67
	li a4, 1
	li a2, 26
	li a1, 72
	jal ra, printHex
	
	WHILE1_BLUE_SCREEN: j WHILE1_BLUE_SCREEN

#############################################
#  PrintInt                                 #
#  a0    =    valor inteiro                 #
#  a1    =    x                             #
#  a2    =    y  			    #
#  a3    =    cor                           #
#############################################

printInt:	addi 	sp, sp, -4			# Aloca espaco
		sw 	ra, 0(sp)			# salva ra
		la 	t0, TempBuffer			# carrega o Endereco do Buffer da String
		
		bge 	a0, zero, ehposprintInt		# Se eh positvo
		li 	t1, '-'				# carrega o sinal -
		sb 	t1, 0(t0)			# coloca no buffer
		addi 	t0, t0, 1			# incrementa endereco do buffer
		sub 	a0, zero, a0			# torna o numero positivo
		
ehposprintInt:  li 	t2, 10				# carrega numero 10
		li 	t1, 0				# carrega numero de digitos com 0
		
loop1printInt:	div 	t4, a0, t2			# divide por 10 (quociente)
		rem 	t3, a0, t2			# resto
		addi 	sp, sp, -4			# aloca espaco na pilha
		sw 	t3, 0(sp)			# coloca resto na pilha
		mv 	a0, t4				# atualiza o numero com o quociente
		addi 	t1, t1, 1			# incrementa o contador de digitos
		bne 	a0, zero, loop1printInt		# verifica se o numero eh zero
				
loop2printInt:	lw 	t2, 0(sp)			# le digito da pilha
		addi 	sp, sp, 4			# libera espaco
		addi 	t2, t2, 48			# converte o digito para ascii
		sb 	t2, 0(t0)			# coloca caractere no buffer
		addi 	t0, t0, 1			# incrementa endereco do buffer
		addi 	t1, t1, -1			# decrementa contador de digitos
		bne 	t1, zero, loop2printInt		# eh o ultimo?
		sb 	zero, 0(t0)			# insere \NULL na string
		
		la 	a0, TempBuffer			# Endereco do buffer da srting
		jal 	printString			# chama o print string
				
		lw 	ra, 0(sp)			# recupera a
		addi 	sp, sp, 4			# libera espaco
fimprintInt:	ret					# retorna
		


#############################################
#  PrintHex                                 #
#  a0    =    valor inteiro                 #
#  a1    =    x                             #
#  a2    =    y                             #
#  a3    =    cor			    #
#############################################

printHex:	addi    sp, sp, -4    		# aloca espaco
    		sw      ra, 0(sp)		# salva ra
		mv 	t0, a0			# Inteiro de 32 bits a ser impresso em Hexa
		la 	t1, TabelaHexASCII	# endereco da tabela HEX->ASCII
		la 	t2, TempBuffer		# onde a string sera montada

		li 	t3,'0'			# Caractere '0'
		sb 	t3,0(t2)		# Escreve '0' no Buffer da String
		li 	t3,'x'			# Caractere 'x'
		sb 	t3,1(t2)		# Escreve 'x' no Buffer da String
		addi 	t2,t2,2			# novo endereco inicial da string

		li 	t3, 28			# contador de nibble   inicio = 28
loopprintHex:	blt 	t3, zero, fimloopprintHex	# terminou? t3<0?
		srl 	t4, t0, t3		# desloca o nibble para direita
		andi 	t4, t4, 0x000F		# mascara o nibble	
		add 	t4, t1, t4		# endereco do ascii do nibble
		lb 	t4, 0(t4)		# le ascii do nibble
		sb 	t4, 0(t2)		# armazena o ascii do nibble no buffer da string
		addi 	t2, t2, 1		# incrementa o endereco do buffer
		addi 	t3, t3, -4		# decrementa o numero do nibble
		j 	loopprintHex
		
fimloopprintHex: sb 	zero,0(t2)		# grava \null na string
		la 	a0, TempBuffer		# Argumento do print String
    		jal	printString		# Chama o print string
    			
		lw 	ra, 0(sp)		# recupera ra
		addi 	sp, sp, 4		# libera espaco
fimprintHex:	ret				# retorna


#####################################
#  PrintSring                       #
#  a0    =  endereco da string      #
#  a1    =  x                       #
#  a2    =  y                       #
#  a3    =  cor		    	    #
#####################################

printString:	addi	sp, sp, -12			# aloca espaco
    		sw	ra, 0(sp)			# salva ra
    		sw	s0, 4(sp)			# salva s0
    		sw a0, 8(sp)			# salva string a0
    		mv	s0, a0              		# s0 = endereco do caractere na string

loopprintString: lb	a0, 0(s0)                 	# le em a0 o caracter a ser impresso
    		beq     a0, zero, fimloopprintString	# string ASCIIZ termina com NULL

    		jal     printChar       		# imprime char
    		
		addi    a1, a1, 8                 	# incrementa a coluna
		li 	t6, 313		
		blt	a1, t6, NaoPulaLinha	    	# se ainda tiver lugar na linha
    		addi    a2, a2, 8                 	# incrementa a linha
    		mv    	a1, zero			# volta a coluna zero

NaoPulaLinha:	addi    s0, s0, 1			# proximo caractere
    		j       loopprintString       		# volta ao loop

fimloopprintString:	lw      ra, 0(sp)    		# recupera ra
			lw 	s0, 4(sp)		# recupera s0 original
			lw a0, 8(sp)
    			addi    sp, sp, 12		# libera espaco
fimprintString:	ret      	    			# retorna


#########################################################
#  PrintChar                                            #
#  a0 = char(ASCII)                                     #
#  a1 = x                                               #
#  a2 = y                                               #
#  a3 = cores (0x0000bbff) 	b = fundo, f = frente	#
#########################################################
#   t0 = i                                             #
#   t1 = j                                             #
#   t2 = endereco do char na memoria                   #
#   t3 = metade do char (2a e depois 1a)               #
#   t4 = endereco para impressao                       #
#   t5 = background color                              #
#   t6 = foreground color                              #
#########################################################
#	t9 foi convertido para s9 pois nao ha registradores temporarios sobrando dentro desta funcao


printChar:	li 	t4, 0xFF	# t4 temporario
		slli 	t4, t4, 8	# t4 = 0x0000FF00 (no RARS, nao podemos fazer diretamente "andi rd, rs1, 0xFF00")
		and    	t5, a3, t4   	# t5 obtem cor de fundo
    		srli	t5, t5, 8	# numero da cor de fundo
		andi   	t6, a3, 0xFF    # t6 obtem cor de frente

		li 	tp, ' '
		blt 	a0, tp, NAOIMPRIMIVEL	# ascii menor que 32 nao eh imprimivel
		li 	tp, '~'
		bgt	a0, tp, NAOIMPRIMIVEL	# ascii Maior que 126  nao eh imprimivel
    		j       IMPRIMIVEL
    
NAOIMPRIMIVEL:	li      a0, 32		# Imprime espaco

IMPRIMIVEL:	li	tp, NUMCOLUNAS		# Num colunas 320
		mul     t4, tp, a2			# multiplica a2x320  t4 = coordenada y
		add     t4, t4, a1               	# t4 = 320*y + x
		addi    t4, t4, 7                 	# t4 = 320*y + (x+7)
		li      tp, VGAADDRESSINI0          	# Endereco de inicio da memoria VGA0
		beq 	a4, zero, PULAFRAME		# Verifica qual o frame a ser usado em a4
		li      tp, VGAADDRESSINI1          	# Endereco de inicio da memoria VGA1
PULAFRAME:	add     t4, t4, tp               	# t4 = endereco de impressao do ultimo pixel da primeira linha do char
		addi    t2, a0, -32               	# indice do char na memoria
		slli    t2, t2, 3                 	# offset em bytes em relacao ao endereco inicial
		la      t3, LabelTabChar		# endereco dos caracteres na memoria
		add     t2, t2, t3               	# endereco do caractere na memoria
		lw      t3, 0(t2)                 	# carrega a primeira word do char
		li 	t0, 4				# i=4

forChar1I:	beq     t0, zero, endForChar1I		# if(i == 0) end for i
    		addi    t1, zero, 8               	# j = 8

	forChar1J:      beq     t1, zero, endForChar1J    	# if(j == 0) end for j
        		andi    s9, t3, 0x001			# primeiro bit do caracter
        		srli    t3, t3, 1             		# retira o primeiro bit
        		beq     s9, zero, printCharPixelbg1	# pixel eh fundo?
        		sb      t6, 0(t4)             		# imprime pixel com cor de frente
        		j       endCharPixel1
printCharPixelbg1:     	sb      t5, 0(t4)                 	# imprime pixel com cor de fundo
endCharPixel1:     	addi    t1, t1, -1                	# j--
    			addi    t4, t4, -1                	# t4 aponta um pixel para a esquerda
    			j       forChar1J			# vollta novo pixel

endForChar1J: 	addi    t0, t0, -1 		# i--
    		addi    t4, t4, 328           	# 2**12 + 8
    		j       forChar1I		# volta ao loop

endForChar1I:	lw      t3, 4(t2)           	# carrega a segunda word do char
		li 	t0, 4			# i = 4
forChar2I:     	beq     t0, zero, endForChar2I  # if(i == 0) end for i
    		addi    t1, zero, 8             # j = 8

	forChar2J:	beq	t1, zero, endForChar2J    	# if(j == 0) end for j
        		andi    s9, t3, 0x001	    		# pixel a ser impresso
        		srli    t3, t3, 1                 	# desloca para o proximo
        		beq     s9, zero, printCharPixelbg2	# pixel eh fundo?
        		sb      t6, 0(t4)			# imprime cor frente
        		j       endCharPixel2			# volta ao loop

printCharPixelbg2:     	sb      t5, 0(t4)			# imprime cor de fundo

endCharPixel2:     	addi    t1, t1, -1			# j--
    			addi    t4, t4, -1                	# t4 aponta um pixel para a esquerda
    			j       forChar2J

endForChar2J:	addi	t0, t0, -1 		# i--
    		addi    t4, t4, 328		#
    		j       forChar2I		# volta ao loop

endForChar2I:	ret				# retorna

###########################################
#        MidiOut 31 (2015/1)              #
#  a0 = pitch (0-127)                     #
#  a1 = duration in milliseconds          #
#  a2 = instrument (0-15)                 #
#  a3 = volume (0-127)                    #
###########################################


#################################################################################################
#
# Note Data           = 32 bits     |   1'b - Melody   |   4'b - Instrument   |   7'b - Volume   |   7'b - Pitch   |   1'b - End   |   1'b - Repeat   |   11'b - Duration   |
#
# Note Data (ecall) = 32 bits     |   1'b - Melody   |   4'b - Instrument   |   7'b - Volume   |   7'b - Pitch   |   13'b - Duration   |
#
#################################################################################################
midiOut: DE1(midiOutDE2)
	li a7,31		# Chama o ecall normal
	ecall
	j fimmidiOut

midiOutDE2:	li      t0, NoteData
    		add     t1, zero, zero

    		# Melody = 0

    		# Definicao do Instrumento
   	 	andi    t2, a2, 0x0000000F
    		slli    t2, t2, 27
    		or      t1, t1, t2

    		# Definicao do Volume
    		andi    t2, a3, 0x0000007F
    		slli    t2, t2, 20
    		or      t1, t1, t2

    		# Definicao do Pitch
    		andi    t2, a0, 0x0000007F
    		slli    t2, t2, 13
    		or      t1, t1, t2

    		# Definicao da Duracao
		li 	t4, 0x1FF
		slli 	t4, t4, 4
		addi 	t4, t4, 0x00F			# t4 = 0x00001FFF
    		and    	t2, a1, t4
    		or      t1, t1, t2

    		# Guarda a definicao da duracao da nota na Word 1
    		j       SintMidOut

SintMidOut:	sw	t1, 0(t0)

	    		# Verifica a subida do clock AUD_DACLRCK para o sintetizador receber as definicoes
	    		li      t2, NoteClock
Check_AUD_DACLRCK:     	lw      t3, 0(t2)
    			beq     t3, zero, Check_AUD_DACLRCK

fimmidiOut:    		ret

###########################################
#        MidiOut 33 (2015/1)              #
#  a0 = pitch (0-127)                     #
#  a1 = duration in milliseconds          #
#  a2 = instrument (0-127)                #
#  a3 = volume (0-127)                    #
###########################################

#################################################################################################
#
# Note Data             = 32 bits     |   1'b - Melody   |   4'b - Instrument   |   7'b - Volume   |   7'b - Pitch   |   1'b - End   |   1'b - Repeat   |   8'b - Duration   |
#
# Note Data (ecall)   	= 32 bits     |   1'b - Melody   |   4'b - Instrument   |   7'b - Volume   |   7'b - Pitch   |   13'b - Duration   |
#
#################################################################################################
midiOutSync: DE1(midiOutSyncDE2)
	li a7,33		# Chama o ecall normal
	ecall
	j fimmidiOutSync
	
midiOutSyncDE2:	li      t0, NoteData
    		add     t1, zero, zero

    		# Melody = 1
    		lui    	t1, 0x08000
		slli	t1,t1,4
		
    		# Definicao do Instrumento
    		andi    t2, a2, 0x00F
    		slli    t2, t2, 27
    		or      t1, t1, t2

    		# Definicao do Volume
    		andi    t2, a3, 0x07F
    		slli    t2, t2, 20
    		or      t1, t1, t2

    		# Definicao do Pitch
    		andi    t2, a0, 0x07F
    		slli    t2, t2, 13
    		or      t1, t1, t2

    		# Definicao da Duracao
		li 	t4, 0x1FF
		slli 	t4, t4, 4
		addi 	t4, t4, 0x00F			# t4 = 0x00001FFF
    		and    	t2, a1, t4
    		or      t1, t1, t2

    		# Guarda a definicao da duracao da nota na Word 1
    		j       SintMidOutSync

SintMidOutSync:	sw	t1, 0(t0)

    		# Verifica a subida do clock AUD_DACLRCK para o sintetizador receber as definicoes
    		li      t2, NoteClock
    		li      t4, NoteMelody

Check_AUD_DACLRCKSync:	lw      t3, 0(t2)
    			beq     t3, zero, Check_AUD_DACLRCKSync

Melody:     	lw      t5, 0(t4)
    		bne     t5, zero, Melody

fimmidiOutSync:	ret

############################################
#  Time                            	   #
#  a0    =    Time                 	   #
#  a1    =    zero	                   #
############################################
time: 	DE1(timeDE2)
	li 	a7,30				# Chama o ecall do Rars
	ecall
	j 	fimTime				# saida

timeDE2: 	li 	t0, STOPWATCH		# carrega endereco do TopWatch
	 	lw 	a0, 0(t0)		# carrega o valor do contador de ms
	 	li 	a1, 0x0000		# contador eh de 32 bits
fimTime: 	ret				# retorna


############################################
#  Sleep                            	   #
#  a0    =    Tempo em ms             	   #
############################################
sleep: DE1(sleepDE2)
	li 	a7, 32				# Chama o ecall do Rars
	ecall			
	j 	fimSleep			# Saida

sleepDE2:	li 	t0, STOPWATCH		# endereco StopWatch
		lw 	t1, 0(t0)		# carrega o contador de ms
		add 	t2, a0, t1		# soma com o tempo solicitado pelo usuario
		
LoopSleep: 	lw 	t1, 0(t0)		# carrega o contador de ms
		blt 	t1, t2, LoopSleep	# nao chegou ao fim volta ao loop
	
fimSleep: 	ret				# retorna


############################################
#  Random                            	   #
#  a0    =    numero randomico        	   #
############################################
random: DE1(randomDE2)		
	li 	a7,41			# Chama o ecall do Rars
	ecall	
	j 	fimRandom		# saida
	
randomDE2: 	li 	t0, LFSR	# carrega endereco do LFSR
		lw 	a0, 0(t0)	# le a word em a0
		
fimRandom:	ret			# retorna