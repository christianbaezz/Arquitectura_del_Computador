# ==============================================================================
# Práctica 4 - Ejercicio 2: Semáforo con Pulsador (Teclas y Temporizadores)
# Asignatura: Arquitectura del Computador
# Entorno: MARS (MIPS Assembler and Runtime Simulator)
# ==============================================================================

.data
# Mensajes de los estados del semáforo
msg_verde:      .asciiz "\n[ESTADO] Semáforo en verde, esperando pulsador.\n"
msg_pulsado:    .asciiz "\n[EVENTO] Pulsador activado: en 20 segundos, el semáforo cambiará a amarillo.\n"
msg_amarillo:   .asciiz "\n[ESTADO] Semáforo en amarillo, en 10 segundos, semáforo en rojo.\n"
msg_rojo:       .asciiz "\n[ESTADO] Semáforo en rojo, en 30 segundos, semáforo en verde.\n"

.text
.globl main

main:
ciclo_semaforo:
    # --------------------------------------------------------------------------
    # ESTADO 1: VERDE (Esperando pulsador 's' indefinidamente)
    # --------------------------------------------------------------------------
    li $v0, 4
    la $a0, msg_verde
    syscall

esperar_pulsador:
    # Consulta de teclado por MMIO (0xffff0000)
    li $t1, 0xffff0000
    lw $t2, 0($t1)               # Leer registro de control
    andi $t2, $t2, 0x0001        # Máscara bit Ready
    beq $t2, $zero, esperar_pulsador # Si no hay tecla, seguir esperando

    # Leer el carácter de la tecla presionada
    lw $t3, 4($t1)

    # Verificar si la tecla es 's' (ASCII 115) o 'S' (ASCII 83)
    beq $t3, 115, pulsador_activado
    beq $t3, 83, pulsador_activado
    j esperar_pulsador           # Si es otra tecla, ignorarla y seguir esperando

pulsador_activado:
    li $v0, 4
    la $a0, msg_pulsado
    syscall

    # Iniciar temporizador de 20 segundos para pasar a amarillo
    li $v0, 30
    syscall
    move $s0, $a0                # Tiempo inicial
    li $s1, 20000                # 20,000 ms (20 segundos)

esperar_20s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bgeu $t0, $s1, estado_amarillo
    j esperar_20s

    # --------------------------------------------------------------------------
    # ESTADO 2: AMARILLO (Duración: 10 segundos)
    # --------------------------------------------------------------------------
estado_amarillo:
    li $v0, 4
    la $a0, msg_amarillo
    syscall

    li $v0, 30
    syscall
    move $s0, $a0                # Tiempo inicial
    li $s1, 10000                # 10,000 ms (10 segundos)

esperar_10s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bgeu $t0, $s1, estado_rojo
    j esperar_10s

    # --------------------------------------------------------------------------
    # ESTADO 3: ROJO (Duración: 30 segundos)
    # --------------------------------------------------------------------------
estado_rojo:
    li $v0, 4
    la $a0, msg_rojo
    syscall

    li $v0, 30
    syscall
    move $s0, $a0                # Tiempo inicial
    li $s1, 30000                # 30,000 ms (30 segundos)

esperar_30s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bgeu $t0, $s1, ciclo_semaforo # Al cumplirse, vuelve a verde y repite el ciclo
    j esperar_30s