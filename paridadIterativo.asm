.data
    prompt: .asciiz "Ingrese un numero entero positivo (n): "
    result: .asciiz "La paridad es: "

.text
.globl main

main:
    # 1. Imprimir el prompt para pedir el número
    li $v0, 4
    la $a0, prompt
    syscall

    # 2. Leer el número entero 'n' desde el teclado
    li $v0, 5
    syscall
    move $a0, $v0           # Pasamos 'n' al registro $a0 (argumento de la función)

    # 3. Llamar a la función de paridad iterativa
    jal paridad_iterativa   # El resultado regresará en $v0

    # 4. Guardar temporalmente el resultado
    move $t1, $v0

    # 5. Imprimir el texto del resultado
    li $v0, 4
    la $a0, result
    syscall

    # 6. Imprimir el valor del resultado (0 o 1)
    li $v0, 1
    move $a0, $t1
    syscall

    # 7. Finalizar el programa de manera limpia
    li $v0, 10
    syscall

# ------------------------------------------------------------------
# Función Paridad Iterativa
# Reemplaza la recursión por un bucle simple.
# Complejidad Espacial: O(1) -> No requiere usar la pila ($sp).
# ------------------------------------------------------------------
paridad_iterativa:
    li   $v0, 0             # Inicializamos el resultado en 0 (caso base para n = 0)
    li   $t0, 1             # Registro constante con el valor 1 para alternar

bucle:
    beq  $a0, $zero, fin    # Si n == 0, salimos del bucle
    sub  $v0, $t0, $v0      # $v0 = 1 - $v0 (alterna el resultado entre 0 y 1 en cada ciclo)
    addi $a0, $a0, -1       # Decrementamos n (n = n - 1)
    j    bucle              # Salto incondicional para la siguiente iteración

fin:
    jr   $ra                # Retorno al main