# ==============================================================================
# Práctica 4 - Ejercicio 1: Buffer de Teclado con Filtro de Caracteres
# Asignatura: Arquitectura del Computador
# Entorno: MARS (MIPS Assembler and Runtime Simulator)
# ==============================================================================

.data
buffer:     .space 64            # Buffer circular de 64 bytes
buf_size:   .word 64             # Tamaño máximo del buffer
head:       .word 0              # Puntero de escritura (índice)
tail:       .word 0              # Puntero de lectura (índice)

# Mensajes de interfaz
msg_inicio: .asciiz "\n==================================================\n>>> Capturando teclado durante 20 segundos...\n"
msg_flush:  .asciiz ">>> Tiempo cumplido (20s). Contenido del buffer:\n["
msg_close:  .asciiz "]\n"
msg_vacio:  .asciiz "(buffer vacio)"

.text
.globl main

main:
loop_principal:
    # 1. Imprimir mensaje de inicio de ventana de 20s
    li $v0, 4
    la $a0, msg_inicio
    syscall

    # 2. Reiniciar punteros del buffer circular
    sw $zero, head
    sw $zero, tail

    # 3. Obtener marca de tiempo inicial (milisegundos)
    li $v0, 30
    syscall
    move $s0, $a0                # $s0 = tiempo_inicial
    li $s1, 20000                # $s1 = 20,000 ms (20 segundos)

bucle_20s:
    # --------------------------------------------------------------------------
    # Verificar si transcurrieron los 20 segundos (usando aritméticas sin signo)
    # --------------------------------------------------------------------------
    li $v0, 30
    syscall
    subu $t0, $a0, $s0           # Resta sin signo para evitar desbordamiento
    li $s1, 20000
    bgeu $t0, $s1, fin_20s       # Salir si el tiempo transcurrido >= 20000 ms

    # --------------------------------------------------------------------------
    # Consulta del teclado usando MMIO (Memory-Mapped I/O)
    # Registro Receiver Control: 0xffff0000 (Bit 0 = Ready)
    # --------------------------------------------------------------------------
    li $t1, 0xffff0000
    lw $t2, 0($t1)               # Leer registro de control del teclado
    andi $t2, $t2, 0x0001        # Mascarar el bit Ready (bit 0)
    beq $t2, $zero, bucle_20s    # Si no hay tecla presionada, esperar

    # --------------------------------------------------------------------------
    # Leer el carácter recibido
    # Registro Receiver Data: 0xffff0004
    # --------------------------------------------------------------------------
    lw $t3, 4($t1)               # $t3 = valor ASCII de la tecla pulsada

    # --------------------------------------------------------------------------
    # Filtrar: Almacenar ÚNICAMENTE letras mayúsculas ('A' <= char <= 'Z')
    # ASCII 'A' = 65, ASCII 'Z' = 90
    # --------------------------------------------------------------------------
    blt $t3, 65, bucle_20s       # Descartar si es menor a 'A'
    bgt $t3, 90, bucle_20s       # Descartar si es mayor a 'Z'

    # --------------------------------------------------------------------------
    # Insertar el carácter en el Buffer Circular
    # --------------------------------------------------------------------------
    la $t4, buffer               # Dirección base del buffer
    lw $t5, head                 # Cargar índice head
    lw $t6, buf_size             # Cargar tamaño del buffer

    # Calcular dirección: buffer + head
    add $t7, $t4, $t5
    sb $t3, 0($t7)               # Guardar carácter en buffer[head]

    # Actualizar puntero circular: head = (head + 1) % buf_size
    addi $t5, $t5, 1
    div $t5, $t6
    mfhi $t5                     # $t5 = head mod buf_size
    sw $t5, head                 # Guardar nuevo head

    j bucle_20s

fin_20s:
    # --------------------------------------------------------------------------
    # Imprimir contenido acumulado en el buffer
    # --------------------------------------------------------------------------
    li $v0, 4
    la $a0, msg_flush
    syscall

    lw $t5, head                 # Cargar head actual
    lw $t8, tail                 # Cargar tail actual

    # Verificar si el buffer está vacío (head == tail)
    beq $t5, $t8, mostrar_vacio

imprimir_caracteres:
    beq $t8, $t5, fin_impresion  # Si tail == head, terminamos de imprimir

    la $t4, buffer               # Dirección base
    add $t7, $t4, $t8            # Dirección de buffer[tail]
    lb $a0, 0($t7)               # Cargar carácter

    # Syscall 11: Imprimir carácter
    li $v0, 11
    syscall

    # Actualizar puntero circular: tail = (tail + 1) % buf_size
    addi $t8, $t8, 1
    lw $t6, buf_size
    div $t8, $t6
    mfhi $t8                     # $t8 = tail mod buf_size
    sw $t8, tail

    j imprimir_caracteres

mostrar_vacio:
    li $v0, 4
    la $a0, msg_vacio
    syscall

fin_impresion:
    li $v0, 4
    la $a0, msg_close
    syscall

    # Repetir proceso indefinidamente
    j loop_principal