.data
    prompt: .asciiz "Ingrese un numero entero positivo: "
    resMsg: .asciiz "La paridad es: "

.text
.globl main

# ---------------------------------------------------------
# Programa Principal
# ---------------------------------------------------------
main:
    # Imprimir mensaje de solicitud
    li $v0, 4
    la $a0, prompt
    syscall

    # Leer entero del usuario -> $v0
    li $v0, 5
    syscall
    move $a0, $v0           # $a0 = nG

    # Llamada a la función recursiva
    jal paridad             # Resultado queda en $v0
    move $t1, $v0           # Guardar temporalmente el resultado

    # Imprimir mensaje de resultado
    li $v0, 4
    la $a0, resMsg
    syscall

    # Imprimir el valor retornado (0 = par, 1 = impar)
    li $v0, 1
    move $a0, $t1
    syscall

    # Finalizar el programa
    li $v0, 10
    syscall



paridad:
    # Reservar espacio en la pila para $ra y $a0
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $a0, 0($sp)

    # Caso Base: si n == 0
    bne  $a0, $zero, caso_recursivo
    li   $v0, 0             # paridad(0) = 0
    addi $sp, $sp, 8        # Restaurar pila
    jr   $ra                # Retornar

caso_recursivo:
    # Preparar llamada recursiva: paridad(n - 1)
    addi $a0, $a0, -1
    jal  paridad            # $v0 = paridad(n - 1)

    # Recuperar $ra de la pila
    lw   $ra, 4($sp)

    # Calcular: 1 - paridad(n - 1)
    li   $t0, 1
    sub  $v0, $t0, $v0      # $v0 = 1 - $v0

    # Restaurar marco de pila y retornar
    addi $sp, $sp, 8
    jr   $ra