
.text

MAIN2: nop
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal ra, CRIAR_MAPA

	la a0, Objetos 			# vetor contendo objetos
	li a1, 5				# quantidade objetos
	jal ra, MOVER_OBJETOS 	# move todos os objetos no vetor

	la a0, Personagens		# Vetor Struct Personagem
	li a1, 2				# Quantidade de personagens a ser impresso
	jal ra, CRIAR_PERSONAGENS
WHILED: nop
	li t0, 'x'
	beq a0, t0, EXIT
	
	li a7, 12
	ecall
	
	la a1, Personagens
	jal ra, MOVER_PERSONAGEM
	
	la a0, Objetos 			# vetor contendo objetos
	li a1, 5				# quantidade objetos
	jal ra, MOVER_OBJETOS
	
	jal zero, WHILED
	
	
EXIT: nop
	li a7 10
	ecall
##############################

#################### void cria_mapa()
## Poe o mapa no display
CRIAR_MAPA: nop
	li t0, 0xFF000000 	# endereco inicial
	li t1, 0xFF012C00 	# endereco final display
	la s0, mapa 		# imagem
	addi s0, s0, 8 		# erros de pixel

FOR1_CRIAR_MAPA: nop
	lw t2, 0(s0) 				# pega 4 bytes da imagem
	sw t2, 0(t0) 				# poe no display pedaco de 4bytes
	addi s0, s0, 4 				# vai para os proximos 4 bytes na imagem
	addi t0, t0, 4 				# vai para os proximos 4 bytes no display
	bne t0, t1, FOR1_CRIAR_MAPA # repete o for
	ret
##############################

#################### void criar_personagens()
## Cria os personagens do jogo
# a0 -> vetor struct personagens
# a1 -> quantidade de personagens
CRIAR_PERSONAGENS: nop
	addi t0, a0, 0	# t0 = a0
	addi t1, a1, 0	# t1 = a1
	
	addi sp, sp, -4	# inicia pilha
	sw ra, 0(sp)	# salva ra
	
FOR1_CRIAR_PERSONAGENS: nop
		beq t1, zero, EXIT_FOR1_CRIAR_PERSONAGENS
		
		lw a0, 0(t0)	# imagem[] do personagem
		lw a1, 4(t0)	# posicao X
		lw a2, 8(t0)	# posicao Y
		
		addi sp, sp, -8	# inicia pilha
		sw t1, 0(sp)	# salva contador na pilha
		sw t0, 4(sp)	# salva vetor struct na pilha
		
		jal ra, CRIAR_QUADRADO
		
		lw t1, 0(sp)
		lw t0, 4(sp)
		addi sp, sp, 8
		
		addi t0, t0, 20
		addi t1, t1, -1
		
		jal zero, FOR1_CRIAR_PERSONAGENS
EXIT_FOR1_CRIAR_PERSONAGENS: nop
	
	lw ra, 0(sp)	# le ra
	addi sp, sp, 4	# encerra pilha
	ret
####################

#################### void criar_quadrado(int imagem[], int x, int y)
## Cria o quadrado no display
# a0 -> vetor da imagem
# a1 -> posicao X
# a2 -> posicao Y
CRIAR_QUADRADO: nop
	### achando a posicao no display para desenhar ##
	li t0, 320
	mul t0, t0, a2		# 320 * y
	add t0, t0, a1		# 320 * y + x
	li t1, 0xFF000000	# endere�o inicial
	add t0, t0, t1		# 320*y + x + end.Inicial

	## atribuicoes da imagem ##
	addi t1, a0, 8			# endereco inicial do quadrado
	lw t2, 4(a0)			# altura da imagem
	lw t3, 0(a0)			# contador largura

FOR1_CRIAR_QUADRADO: nop
	lb t4, 0(t1) 		# le byte da imagem do quadrado
	sb t4, 0(t0) 		# poe no display pedaco de 4 bytes da imagem
	addi t1, t1, 1 		# proximo byte da imagem
	addi t0, t0, 1 		# proximo byte do display
	addi t3, t3, -1 	# contador largura --
	beq t3, zero, PULAR_LINHA_CRIAR_QUADRADO # if (contador == 0)

VOLTA_IF: nop
	bne t2,zero, FOR1_CRIAR_QUADRADO
	ret

PULAR_LINHA_CRIAR_QUADRADO: nop
	lw t3, 0(a0)		# reseta contador largura
	addi t4, zero, 320	# colunas em 1 linha

	sub t4, t4, t3 		# 320 - 60, correcao de posicao
	add t0, t0, t4 		# avanca para proxima linha
	addi t2, t2, -1		# contador altura --
	jal zero, VOLTA_IF
##############################

#################### void apagar_quadrado(int imagem[], int x, int y)
## Apaga o quadrado no display
# a0 -> vetor contendo a imagem
# a1 -> posicao X
# a2 -> posicao Y
APAGAR_QUADRADO: nop	
	### achando a posicao no display para desenhar ##
	li t0, 320
	mul t0, t0, a2		# 320 * y
	add t4, t0, a1		# 320 * y + x
	li t1, 0xFF000000	# endere�o inicial
	add t0, t4, t1		# 320*y + x + end.Inicial

	## atribuicoes da imagem ##
	addi t1, a0, 8			# endereco inicial do quadrado
	lw t2, 4(a0)			# altura da imagem
	lw t3, 0(a0)			# contador largura
	
	## achando a posicao no mapa original ##
	la t5, mapa 			# vetor contendo o mapa
	addi t5, t5, 8 			# retira o erro de pixel
	add t5, t5, t4 			# 320*y + x + end.Inicial

FOR1_APAGAR_QUADRADO: nop
	lb t4, 0(t5) 			# le 4 bytes da imagem do quadrado
	sb t4, 0(t0) 			# poe no display pedaco de 4 bytes da imagem
	addi t1, t1, 1 			# proximo byte da imagem
	addi t0, t0, 1 			# proximo byte do display
	addi t5, t5, 1 			# proximo byte do vetor do mapa
	addi t3, t3, -1 		# contador largura --
	beq t3, zero, PULAR_LINHA_APAGAR_QUADRADO # if (contador == 0)

VOLTA_APAGAR_IF: nop
	bne t2, zero, FOR1_APAGAR_QUADRADO
	ret

PULAR_LINHA_APAGAR_QUADRADO: nop
	lw t3, 0(a0)		# reseta contador largura
	addi t4, zero, 320 	# total de 320 colunas em uma linha

	sub t4, t4, t3 		# conserto de distancia 320 - 60
	add t0, t0, t4
	add t5, t5, t4
	addi t2, t2, -1		# contador altura --
	jal zero, VOLTA_APAGAR_IF
##############################

#################### void mover_objetos(struct Objetos[], int quantidade_objetos)
## Move os objetos contidos no vetor
# a0 -> vetor contendo todos os objetos
# a1 -> quantidade de objetos a ser movido
MOVER_OBJETOS: nop
	addi t0, a0, 0	# t0 = a0
	addi t1, a1, 0	# t1, = a1
	
	## salvando retorno pois utilizamos chamada de fun��es ##
	addi sp, sp, -12# inicia pilha
	sw ra, 0(sp)	# salva retorno
	
	## inicia loop for -> percorrer vetor objetos de acordo com quantidade ##
FOR1_MOVER_OBJETOS: nop
		beq t1, zero, EXIT_FOR1_MOVER_OBJETOS	# if ( i == 0 )
		
		## iniciando pilhagem para chamada de funcao ##
		sw t0, 4(sp)	# salva o endereco onde estao os objetos
		sw t1, 8(sp)	# salva o contador de interacoes
		
		lw a0, 0(t0)		# imagem[]
		lw a1, 4(t0)		# posicao X
		lw a2, 8(t0)		# posicao Y
		
		jal ra, APAGAR_QUADRADO
		
		## chama VERIFICAR CHAO ##
		lw t0, 4(sp)	# struct
		lw a0, 0(t0)		# imagem[]
		lw a1, 4(t0)		# posicao X
		lw a2, 8(t0)		# posicao Y
		li a3, 79
		li a4, 0
		jal ra, VERIFICAR_CHAO
		
		# a1 ( se esta no chao )
		
		## CHAMA MOVER __ OBJETO ## 
		lw t0, 4(sp)	# struct
		lw t2, 20(t0)	# le o tipo do objeto
		
		mv a0, t0		# argumento struct
		#bne t2, zero, PULA_BARRIL # nao eh barril
		jal ra, MOVER_BARRIL

		lw t0, 4(sp)	# struct
		sw a0, 0(t0)		# imagem[]
		sw a1, 4(t0)		# posicao X
		sw a2, 8(t0)		# posicao Y
		sw a3, 16(t0)		# direcao

		jal ra, CRIAR_QUADRADO
		
		## retornando valores apos chamada de funcao ##
		lw t0, 4(sp)
		lw t1, 8(sp)
		
PULAR_MOVIMENTO: nop
		addi t1, t1, -1		# contador i --
		addi t0, t0, 28		# proximo objeto
			
		jal zero, FOR1_MOVER_OBJETOS
		
EXIT_FOR1_MOVER_OBJETOS: nop
	lw ra, 0(sp)			# pega ra
	addi sp, sp, 12			# finaliza pilha
	
	ret
################################

####### mover_barril(struct objeto, int in_ground)
## move o barril
# a0 -> struct objeto
# a1 -> in_ground ( 0 - nao esta no chao, 1 - esta no chao )
MOVER_BARRIL: nop
	addi t0, a0, 0	# t0 = a0 ( struct )
	addi t1, a1, 0	# t1 = a1 ( in_ground ? )
	
	## lendo valores do objeto ##
	lw a0, 0(t0)	# imagem[]
	lw a1, 4(t0)	# posicao X
	lw a2, 8(t0)	# posicao Y
	#lw a3, 12(t0)	# velocidade
	lw a4, 16(t0)	# direcao
	#lw t2, 20(t0)	# is_something ( in_escada )
	
	## verifica se esta descendo escada ##
	lw t2, 20(t0)	# is_something ( in_escada )
	li t3, 5
	bge t2, t3, DESCER_BARRIL_ESCADA
	
	## iniciando pilhagem para chamada de funcoes ##
	addi sp, sp, -12
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	
	## verificando escada ##
	lw t2, 4(a0)	# altura do objeto
	add a2, a2, t2	# desloca verificacao para baixo do objeto
	addi a2, a2, 4	# desloca +4 para baixo em verificacao
	
	li a3, 105		# cor verde
	jal ra, VERIFICAR_ESCADA
	
	mv t3, a0
	
	## encerra pilha, ja que nao havera mais chamadas de funcoes ## 
	lw ra, 0(sp)
	lw t0, 4(sp)	# struct
	lw t1, 8(sp)	# in_ground ?
	addi sp, sp, 12
	
	## le de volta os valores modificados pela funcao ##
	lw a0, 0(t0)	# imagem[]
	lw a2, 8(t0)	# posicao Y
	lw a3, 12(t0)	# velocidade
	lw t2, 20(t0)	# is_something ( in_escada )
	beq t3, zero, BARRIL_FORA_ESCADA
	
	## se estiver detectando a escada ##
	addi t2, t2, 1	# percent in_escada++
	sw t2, 20(t0)	# new percent
	li t3, 5		# se nao estiver completamente dentro da escada
	blt t2, t3, BARRIL_ESPERA_ESCADA
	
	## verifica decisao de barril se ele desce ou nao na escada ##
	mv t3, a0
	li a7, 41
	ecall
	
	li t2, 2
	remu t2, a0, t2
	
	mv a0, t3	# retorna valor original de a0
	
	beq t2, zero, DECIDIU_NAO_DESCER_BARRIL
	
	## se decidiu descer, prossegue normalmente ##
	addi a3, a4, 0	# prepara retorno de funcao
	ret
	## se decidiu nao descer, deve bloquear descida ate finalizar deteccao de escada ##
	DECIDIU_NAO_DESCER_BARRIL: nop
	li t2, -1		# bloqueio de descida
	sw t2, 20(t0)	# salva percent flag de bloqueio
	jal zero, BARRIL_ESPERA_ESCADA	
	BARRIL_FORA_ESCADA: nop
	li t2, 0		# reseta percent
	sw t2, 20(t0)	# salva reset
			
	BARRIL_ESPERA_ESCADA: nop
	## tratamento de animacao barril ##
	la t2, barril1
	beq a0, t2, ANIMACAO_BARRIL1
	la t2, barril2
	beq a0, t2, ANIMACAO_BARRIL2
	la t2, barril4
	beq a0, t2, ANIMACAO_BARRIL3
	la a0, barril1
	
	jal zero, PULAR_ANIMACAO_BARRIL
ANIMACAO_BARRIL1: nop
	la a0, barril2
	jal zero, PULAR_ANIMACAO_BARRIL
ANIMACAO_BARRIL2: nop
	la a0, barril4
	jal zero, PULAR_ANIMACAO_BARRIL
ANIMACAO_BARRIL3: nop
	la a0, barril3
	jal zero, PULAR_ANIMACAO_BARRIL	
	
	## tratamento de movimento do barril ##
PULAR_ANIMACAO_BARRIL: nop
	## verifica se barril esta no chao ##
	bne t1, zero, PULA_BARRIL_GRAVITY	# se estiver no chao, pula
	addi a2, a2, 2
	
PULA_BARRIL_GRAVITY: nop
	## verifica direcao que deve ir ##
	beq a4, zero, MOVER_ESQUERDA_BARRIL
	
	## movendo para direita ##
	add a1, a1, a3		# proximo X ( direita )
	addi a3, a4, 0		# a3 = a4 ( retorno de direcao )
	
	## se bater no fim do mapa direita ## 
	addi t2, zero, 300	# iniciar verificacao de fim de mapa
	blt a1, t2, PULA_MUDAR_DIRECAO
	
	li a3, 0		# 0 = esquerda
PULA_MUDAR_DIRECAO: nop
	ret
MOVER_ESQUERDA_BARRIL: nop
	## movendo para esquerda ##
	sub a1, a1, a3	# proximo x ( esquerda )
	addi a3, a4, 0		# a3 = a4 ( retorno de direcao )
	
	## se bater no fim do mapa esquerda ##
	addi t2, zero, 2	# iniciar verificacao de fim de mapa
	blt t2, a1, PULA_MUDAR_DIRECAO
	
	li a3, 1		# 1 = direita

	ret
DESCER_BARRIL_ESCADA: nop
	## verificacao de contador para saber quando barril pode verificar parada ##
	li t3, 15
	beq t2, t3, PULA_VERI_STOP_BARRIL # se barril ja desceu 10 posicoes, pode comecar a verificar
	addi t2, t2, 1					# caso contrario, descendo++
	jal zero, PULA_STOP_BARRIL
	
	## verifica se barril tocou no chao ao descer escada ##
	PULA_VERI_STOP_BARRIL: nop
	beq t1, zero, PULA_STOP_BARRIL	# se ainda nao tocou, continua descendo
	li t2, 0	# encerra descida
	xori a4, a4, 1	# inverte direcao
	
	## preparando para retornar ##
	PULA_STOP_BARRIL: nop
	mv a3, a4		# prepara retorno de funcao a3 (direcao)
	addi a2, a2, 2	# proximo Y
	sw t2, 20(t0)	# nova direcao
	
	## tratanado animacao na escada ##
	la t2, barril_escada1
	bne a0, t2, ANIMACAO_BARRIL_ESCADA
	la a0, barril_escada2
	ret
	ANIMACAO_BARRIL_ESCADA: nop
	la a0, barril_escada1	
	ret
#################################

####### mover_mola(int imagem[], int x, int y, int velocidade, int direcao, int in_ground)
## move a mola
# a0 -> imagem[]
# a1 -> posicao X
# a2 -> posicao Y
# a3 -> velocidade
# a4 -> direcao ( 0 - esquerda, 1 - direita )
# a5 -> in_jumping ( 0 - nao esta pulando, > 0 - esta pulando )
## retorna novos valores
# a0 -> nova imagem[]
# a1 -> nova posicao X
# a2 -> nova posicao Y
# a3 -> nova direcao
MOVER_MOLA: nop
	mv t6, a4
	
	la t2, mola
	bne a0, t2, ANIMACAO_MOLA
	la a0, mola1
	jal zero, PULAR_ANIMACAO_MOLA
ANIMACAO_MOLA: nop
	mv a0, t2
	jal zero, PULAR_ANIMACAO_MOLA
	
PULAR_ANIMACAO_MOLA: nop
	
	## se bater no fim do mapa baixo ##
	addi t2, zero, 200	# iniciar verificacao de fim de mapa
	blt t2, a2, PULA_MUDAR_DIRECAO_MOLA
	
	## verifica se mola esta no pulando ##
	bne a5, zero, MOLA_SALTO	# se estiver pulando, pula
	addi a2, a2, 2	# gravidade
	
PULA_MOLA_GRAVITY: nop
	## verifica direcao que deve ir ##
	beq a4, zero, MOVER_BAIXO_MOLA
	
	## movendo para direita ##
	add a1, a1, a3		# proximo X ( direita )
	
	## se bater no fim do mapa direita ## 
	addi t2, zero, 260	# iniciar verificacao de fim de mapa
	blt a1, t2, PULA_MUDAR_DIRECAO_MOLA
	
	li t6, 0		# 0 = baixo
PULA_MUDAR_DIRECAO_MOLA: nop
	mv a3, t6
	ret
MOVER_BAIXO_MOLA: nop
	## movendo para esquerda ##
	add a2, a2, a3	# proximo y ( baixo )
	
	jal zero, PULA_MUDAR_DIRECAO_MOLA
MOLA_SALTO: nop
	
	sub a2, a2, a3	# proximo y ( cima )
	jal zero PULA_MOLA_GRAVITY
#################################

######################## MOVIMENTO DE PERSONAGEM ###################################

############ int mover_personagem(direcao, struct personagem)
### move o personagem na direcao
## direcao = a move para esquerda
## direcao = d move para direita
## direcao = w move para cima
## direcao = s move para baixo
# a0 -> direcao
# a1 -> struct do personagem
MOVER_PERSONAGEM: nop
	## preparamentos para chamada de funcoes ##
	addi sp, sp, -12	# inicia pilha
	sw ra, 0(sp)	# salva ra
	sw a1, 4(sp)	# salva struct
	sw a0, 8(sp)	# salva direcao
	
	## apagando o personagem atual ##
	lw a0, 0(a1)	# imagem[]
	lw a2, 8(a1)	# posicao Y
	lw a4, 16(a1)	# in_escada
	lw a1, 4(a1)	# posicao X	
	jal ra, APAGAR_QUADRADO
	
	## verificacao de animacao de escada ( subida automatica ) ##
	li t2, 2
	blt a4, t2, PULA_ANIMACAO_SUBIDA
	## forca personagem a subir escada, ate determinada posicao ##
	addi a2, a2, -4
	addi a4, a4, 1
	li a3, 0		# in_jumping = false ( verificar isso dps )
	lw t0, 4(sp)	# struct para salvamentos
	li t2, 7		# posicoes a serem subidas
	
	blt a4, t2, RETORNA_MOVIMENTO
	li a4, 0		# finaliza animacao
	jal zero, RETORNA_MOVIMENTO
	PULA_ANIMACAO_SUBIDA: nop
	
	## verificando jogador no chao ##
	li a3, 79
	li a4, 0
	jal ra, VERIFICAR_CHAO
	mv t3, a0	# a0 = in_ground ?
	mv t4, a1	# a1 = on_ground ?
	
	## lendo valores do personagem ##
	lw t0, 4(sp)	# struct
	lw a0, 0(t0)	# imagem[]
	lw a1, 4(t0)	# posicao X
	lw a2, 8(t0)	# posicao Y
	lw a3, 12(t0)	# is_jumping
	lw a4, 16(t0)	# in_escada
	
	## tratando gravidade e colisao com chao ##
	beq t3, zero, SEM_COLISAO 	# se nao estiver dentro do chao, ignora
	addi a2, a2, -1		# sobe o jogador em Y para retira-lo do chao
	SEM_COLISAO: nop
	bne t3, zero, SEM_GRAVITY		# se estiver dentro do chao, ignora
	bne a3, zero, IN_JUMPING		# se estiver pulando, ignora
	bne t4, zero, SEM_GRAVITY		# se estiver sobe o chao, ignora

	bne a4, zero, SEM_GRAVITY		# se estiver na escada, ignora
	
	addi a2, a2, 3		# desce o jogador em Y, atribuindo gravidade
	SEM_GRAVITY: nop
	
	## verificando a direcao ##
	lw t1, 8(sp)	# direcao
	## tratando direcao ##
	li t2, 'd'
	beq t1, t2, MOVER_PERSON_DIREITA
	li t2, 'a'
	beq t1, t2, MOVER_PERSON_ESQUERDA
	li t2, 'w'
	beq t1, t2, MOVER_PERSON_CIMA
	li t2, 's'
	beq t1, t2, MOVER_PERSON_BAIXO
	
RETORNA_MOVIMENTO: nop	
	
	lw a0, 8(sp)
	jal ra, ANIMACAO_PERSONAGEM
	lw t0,4(sp)
	
	## salvando informacoes novas do personagem ##
	sw a0, 0(t0)
	sw a1, 4(t0)
	sw a2, 8(t0)
	sw a3, 12(t0)
	sw a4, 16(t0)
	## criando o personagem na nova posicao ##
	jal ra, CRIAR_QUADRADO
	
	## encerrando pilhagem e retornando ##
	lw ra, 0(sp)
	addi sp, sp, 12
	
	ret
MOVER_PERSON_DIREITA: nop	
	## movendo o personagem em 5 posicoes ##
	addi a1, a1, 5
	li t1, 310	# efeito de comparacao
	li a4, 0
	## verificando se chegou ao fim do mundo da direita
	blt a1, t1, RETORNA_MOVIMENTO
	addi a1, a1, -5	# se chegou, retira o movimento
		
	jal zero, RETORNA_MOVIMENTO
	
MOVER_PERSON_ESQUERDA: nop
	## movendo o personagem em 5 posicoes ##
	addi a1, a1, -5
	li t1, 0	# efeito de comparacao
	li a4, 0	# in_escada
	## verificando se chegou ao fim do mundo da esquerda
	blt t1, a1, RETORNA_MOVIMENTO
	addi a1, a1, 5	# se chegou, retira o movimento
		
	jal zero, RETORNA_MOVIMENTO
MOVER_PERSON_CIMA:nop
	## verificando jogador na escada ##
	li a3, 105
	jal ra, VERIFICAR_ESCADA
	mv t3, a0	# a0 = in_escada ?
	
	## lendo valores do personagem modificado pela funcao ##
	lw t0, 4(sp)	# struct
	lw a0, 0(t0)	# imagem[]
	li a3, 0		# remove jumping ( verificar isso dps )
	## verifica se esta na escada ##
	beq t3, zero, SEM_ESCADA	# se nao estiver na escada, ignora
	
	## verifica se cabeca toca o chao de cima ##
	li a4, 1		# in_escada = true
	li a3, 79
	jal VERIFICAR_CHAO
	
	mv t3, a1	# a1 -> on_ground ? ( touched ground ? )
	
	## lendo valores do personagem modificado pela funcao ##
	lw t0,4(sp)
	lw a0,0(t0)
	lw a1,4(t0)
	li a3, 0		# is_jumping = reset ( verificar isso dps )
	
	## movimento na escada ##
	addi a2, a2, -3	# sobe na escada
	
	## se tocou no chao de cima, ativar animacao automatica de subida ##
	beq t3, zero, RETORNA_MOVIMENTO
	
	li a4, 2
	
	jal zero, RETORNA_MOVIMENTO
	
	## se nao estiver na escada, significa que ele saltou ##
	SEM_ESCADA: nop
	li a3, 1	# is_jumping = true
	jal zero, RETORNA_MOVIMENTO
MOVER_PERSON_BAIXO:nop
	## verificando jogador na escada ##
	li a3, 105
	jal ra, VERIFICAR_ESCADA
	mv t3, a0	# a0 = in_escada ?
	
	## lendo valores do personagem modificado pela funcao ##
	lw t0, 4(sp)	# struct
	lw a0, 0(t0)	# imagem[]
	li a3, 0		# remove jumping ( verificar isso dps )
	## verifica se esta na escada ##
	beq t3, zero, SEM_ESCADA_BAIXO	# se nao estiver na escada, ignora
	
	## verifica se pe toca o chao de baixo ##
	li a4, 0		# baixo = true
	li a3, 79
	jal VERIFICAR_CHAO
	
	mv t3, a1	# a1 -> on_ground ? ( touched ground ? )
	
	## lendo valores do personagem modificado pela funcao ##
	lw t0,4(sp)
	lw a0,0(t0)
	lw a1,4(t0)
	li a3, 0		# is_jumping = reset ( verificar isso dps )
	
	## se tocou no chao de cima, ativar animacao automatica de subida ##
	bne t3, zero, RETORNA_MOVIMENTO

	## movimento na escada ##
	addi a2, a2, 3	# desce na escada
	jal zero, RETORNA_MOVIMENTO
	
	## se nao estiver na escada ##
	SEM_ESCADA_BAIXO: nop
	jal zero, RETORNA_MOVIMENTO
IN_JUMPING: nop
	## diminui y, pulando ##
	addi a2, a2, -5	# sobe 3 posicoes em Y
	addi a3, a3, 1	# jumping++
	li t2, 3		# maximo de saltos
	blt a3, t2, SEM_GRAVITY
	li a3, 0		# is_jumping = false
	jal zero, SEM_GRAVITY
########################

####### animacao_personagem()
## trata a animacao do personagem
# sem parametros
## retorna nova imagem/skin
# a0 -> new imagem[]
ANIMACAO_PERSONAGEM: nop
	## verifica se esta em force subida escada ##
	la t1, Personagens
	lw t0, 0(t1)	# imagem[]
	lw t4, 16(t1)	# in_escada
	li t3, 2		# flag force
	bge t4, t3, ANIM_PERSON_FORCE_SUBIDA

	## verifica se animacao esta para direita ##
	li t2, 'd'
	beq a0, t2, ANIM_PERSON_DIREITA
	
	## verifica se animacao esta para esquerda ##
	li t2, 'a'
	beq a0, t2, ANIM_PERSON_ESQUERDA

	## verifica se animacao esta na escada ##	
	li t2, 'w'
	beq a0, t2, ANIM_PERSON_CIMA
	
	## verifica se animacao esta na escada ##
	li t2, 's'
	beq a0, t2, ANIM_PERSON_CIMA

VOLTA_ANIM_PERSON_CIMA: nop	
	## caso contrario, idle or jump ##
	la t2, Ultima_direcao
	lb t2, 0(t2)
	
	## se estiver pulando parado ##
	lw t3, 12(t1)	# is_jumping
	beq t3, zero, ANIM_PERSON_IDLE
	
	## caso contrario, verifica qual lado o jogador ficou parado ##
	li t3, 'd'
	beq t2, t3, ANIM_PERSON_JUMPING_RIGHT
	li t3, 'a'
	beq t2, t3, ANIM_PERSON_JUMPING_LEFT
	
	ANIM_PERSON_IDLE: nop
	
	## desvio padrao de frames ##
	la t3, Desvio_padrao
	lb t4, 0(t3)
	li t5, 2
	addi t4, t4, 1
	beq t5, t4, DESVIO_ATINGIDO
	sb t4, 0(t3)
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	DESVIO_ATINGIDO: nop
	li t4, 0
	sb t4, 0(t3)
	
	li t3, 'd'
	beq t2, t3, ANIM_PERSON_IDLE_RIGHT
	la t0, mario_idle_left
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	ANIM_PERSON_IDLE_RIGHT: nop
	la t0, mario_idle_right
	jal zero, ENCERRA_MARIO_ANIMACAO

ANIM_PERSON_CIMA: nop
	bne t4, zero, ANIM_PERSON_ESCADA
	jal zero, VOLTA_ANIM_PERSON_CIMA
	
	ANIM_PERSON_ESCADA: nop
	la t2, mario_escada
	beq t0, t2, MARIO_ESCADA2
	
	la t0, mario_escada
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	MARIO_ESCADA2: nop
	la t0, mario_escada2
	jal zero, ENCERRA_MARIO_ANIMACAO
	
ANIM_PERSON_ESQUERDA: nop
	la t2, Ultima_direcao
	sb a0, 0(t2)
	
	## se estiver pulando, ignora animacao padrao ##
	lw t2, 12(t1)	# in_jumping
	bne t2, zero, ANIM_PERSON_JUMPING_LEFT
	
	## se estiver andando ##
	## animacao do personagem ##
	la t2, mario_run_left
	beq t2, t0, MARIO_PARADO_LEFT # se estiver correndo, poe parado
	
	la t2, mario_idle_left
	beq t2, t0, MARIO_ANDANDO_LEFT	# se estiver parado, poe andando
	
	la t0, mario_run_left		# se estiver andando, poe correndo
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	MARIO_PARADO_LEFT: nop
	la t0, mario_idle_left
	jal zero, ENCERRA_MARIO_ANIMACAO
	MARIO_ANDANDO_LEFT: nop
	la t0, mario_walk_left
	jal zero, ENCERRA_MARIO_ANIMACAO
		
	ANIM_PERSON_JUMPING_LEFT: nop
	la t0, mario_jump_left
	jal zero, ENCERRA_MARIO_ANIMACAO

ANIM_PERSON_DIREITA: nop
	la t2, Ultima_direcao
	sb a0, 0(t2)

	## se estiver pulando, ignora animacao padrao ##
	lw t2, 12(t1)	# in_jumping
	bne t2, zero, ANIM_PERSON_JUMPING_RIGHT
	
	## se estiver andando ##
	## animacao do personagem ##
	la t2, mario_run_right
	beq t2, t0, MARIO_PARADO_RIGHT # se estiver correndo, poe parado
	
	la t2, mario_idle_right
	beq t2, t0, MARIO_ANDANDO_RIGHT	# se estiver parado, poe andando
	
	la t0, mario_run_right		# se estiver andando, poe correndo
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	MARIO_PARADO_RIGHT: nop
	la t0, mario_idle_right
	jal zero, ENCERRA_MARIO_ANIMACAO
	MARIO_ANDANDO_RIGHT: nop
	la t0, mario_walk_right
	jal zero, ENCERRA_MARIO_ANIMACAO
		
	ANIM_PERSON_JUMPING_RIGHT: nop
	la t0, mario_jump_right
	jal zero, ENCERRA_MARIO_ANIMACAO

ANIM_PERSON_FORCE_SUBIDA: nop
	##	verifica qual skin esta atualmente ##
	la t3, mario_finish_escada1
	beq t0, t3, MARIO_FORCE_SUBIDA_2
	
	la t3, mario_finish_escada2
	beq t0, t3, MARIO_FORCE_SUBIDA_3
	
	la t3, mario_finish_escada3
	beq t0, t3, MARIO_FORCE_SUBIDA_4
	
	la t3, mario_finish_escada4
	beq t0, t3, MARIO_FORCE_SUBIDA_5
	
	la t0, mario_finish_escada1
	jal zero, ENCERRA_MARIO_ANIMACAO


	MARIO_FORCE_SUBIDA_2: nop
	la t0, mario_finish_escada2
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	MARIO_FORCE_SUBIDA_3: nop
	la t0, mario_finish_escada3
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	MARIO_FORCE_SUBIDA_4: nop
	la t0, mario_finish_escada4
	jal zero, ENCERRA_MARIO_ANIMACAO
	
	MARIO_FORCE_SUBIDA_5: nop
	la t0, mario_finish_escada5
	jal zero, ENCERRA_MARIO_ANIMACAO		
	
	ENCERRA_MARIO_ANIMACAO: nop
	#sw t0, 0(t1)	# salva nova skin
	mv a0, t0
	ret

####### bool verificar_chao(imagem[], int x, int y, int cor, int corpo)
## verifica se a imagem toca o chao
# a0 -> vetor imagem
# a1 -> posicao X
# a2 -> posicao Y
# a3 -> cor do chao
# a4 -> parte do corpo a verificar ( 0 - ponta do pe, 1 - ponta da cabeca )
VERIFICAR_CHAO: nop
#	li t6, 0xFF000000
#	li t5, 255

	### achando a posicao no display para desenhar ##
	li t0, 320
	mul t0, t0, a2		# 320 * y
	add t0, t0, a1		# 320 * y + x
	la t1, mapa		# endere�o inicial do mapa
	addi t1, t1, 8		# pula struct do mapa
#	add t6, t6, t0		# para debug
	add t0, t0, t1		# 320*y + x + end.Inicial

	bne a4, zero, PONTA_CABECA
	## atribuicoes da imagem caso seja para o pe ##
	lw t1, 4(a0)			# altura da imagem
	li t2, 320				# 320
	addi t1, t1, -1			# subtrai altura por 1
	mul t1, t1, t2			# 320 * (altura - 1)
	jal zero, CONTINUA_VERIFICAR_CHAO
PONTA_CABECA: nop
	li t1, 320	# proxima linha
CONTINUA_VERIFICAR_CHAO: nop
	add t0, t0, t1			# vai para a linha em questao
#	add t6, t6, t1			# para debug
	lw t2, 0(a0)			# largura da imagem
	addi t3, t2, 0			# salva largura

FOR1_VERIFICAR_CHAO: nop
		beq t2, zero, EXIT_FOR1_VERIFICAR_CHAO
		lb t1, 0(t0)	# le o byte do mapa
#		sb t5, 0(t6)	# para debug
		beq t1, a3, ENCONTROU_CHAO
		addi t0, t0, 1	# proximo byte do mapa
#		addi t6, t6, 1	# para debug
		addi t2, t2, -1	# contador largura --	
		jal zero, FOR1_VERIFICAR_CHAO
EXIT_FOR1_VERIFICAR_CHAO: nop
	li a0, 0
	sub t0, t0, t3		# retora t0 ao original
#	li t5, 105			# para debug
#	sub t6, t6, t3		# para debug
#	addi t6, t6, 320	# para debug
	addi t0, t0, 320	# vai para a ultima linha
FOR2_VERIFICAR_CHAO: nop
		beq t3, zero, EXIT_FOR2_VERIFICAR_CHAO
		lb t1, 0(t0)	# le o byte do mapa
#		sb t5, 0(t6)	# para debug
		beq t1, a3, ENCONTROU_CHAO2
		addi t0, t0, 1	# proximo byte do mapa
		addi t3, t3, -1	# contador largura --
#		addi t6, t6, 1	# para debug
		jal zero, FOR2_VERIFICAR_CHAO
EXIT_FOR2_VERIFICAR_CHAO: nop
	li a1, 0
	ret
ENCONTROU_CHAO: nop
	li a0, 1
	sub t0, t0, t3		# retora t0 ao original
	addi t0, t0, 320	# vai para a ultima linha
#	li t5, 105			# para debug
#	sub t6, t6, t3		# para debug
#	addi t6, t6, 320	# para debug
	jal zero, FOR2_VERIFICAR_CHAO
ENCONTROU_CHAO2: nop
	li a1, 1
	ret
	
#######################

####### bool verificar_escada(imagem[], int x, int y, int cor)
## verifica se a imagem toca a escada
# a0 -> vetor imagem
# a1 -> posicao X
# a2 -> posicao Y
# a3 -> cor do chao
VERIFICAR_ESCADA: nop
	#li t6, 0xFF000000 # uso para debug

	### achando a posicao no display para desenhar ##
	li t0, 320
	mul t0, t0, a2		# 320 * y
	add t0, t0, a1		# 320 * y + x
	la t1, mapa		# endere�o inicial do mapa
	addi t1, t1, 8		# pula struct do mapa
	#add t6, t6, t0
	add t0, t0, t1		# 320*y + x + end.Inicial
	
	lw t1, 0(a0)			# largura da imagem
	lw t2, 4(a0)			# altura da imagem
	#srai t2, t2, 1			# divide altura por 2, utilizado caso queira apenas metdade do corpo
	#li t5, 248
FOR1_VERIFICAR_ESCADA: nop
		beq t2, zero, EXIT_FOR1_VERIFICAR_ESCADA
		
		## verificar se pixel eh igual a cor ##
		lb t3, 0(t0)
		#sb t5, 0(t6)
		beq t3, a3, ENCONTROU_ESCADA
		
		## verifica quebra de linha ##
		addi t1, t1, -1
		addi t0, t0, 1
		#addi t6, t6, 1
		bne t1, zero, NAO_QUEBRA_LINHA
		## se ja alcancou largura da image, quebra linha ##
		addi t0, t0, 320
		lw t1, 0(a0)
		sub t0, t0, t1
		#addi t6, t6, 320
		#sub t6, t6, t1
		addi t2, t2, -1	# contador de linhas --
NAO_QUEBRA_LINHA: nop
		jal zero, FOR1_VERIFICAR_ESCADA

EXIT_FOR1_VERIFICAR_ESCADA: nop
		li a0, 0
		ret
ENCONTROU_ESCADA: nop
		li a0, 1
		ret
#######################
