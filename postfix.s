.data

ebp_value:
    .long 0
esp_value:
    .long 0

scala:
    .long 10

negbit:
    .long 1

temp:
    .long 0


.text
    .global postfix

postfix:

    movl %ebp, ebp_value            # salvataggio posizione iniziale di %ebp
    movl %esp, esp_value            # salvataggio posizione iniziale di %esp
    movl %esp, %ebp                 # sposto %esp in %ebp

    pushl %ebx                      # salvataggio dei registri all'inizio del programma
    pushl %ecx
    pushl %edx
    pushl %eax


    movl 4(%ebp), %esi              # prendo il puntatore alla stringa dallo stack e lo metto in %esi

    movl $0, %ebx                   # setto a zero il registro %ebx
    movl $0, %ecx                   # setto a zero il registro %ecx

ripeti:
    movl $0, %eax                   # setto a zero il registro %eax ad ogni nuovo ciclo
    movl $1, negbit                 # resetto negbit ad ogni nuovo ciclo
    
    movb (%ebx,%esi), %cl           # sposto il carattere corrente dalla stringa a %cl

    cmpb $32, %cl                   # if %cl == " " --> jmp invalido
    je invalido

    cmpb $0, %cl                    # if %cl == "\0" --> jmp concludi
    je concludi

    cmpb $10, %cl                   # if %cl == "\n" --> jmp concludi
    je concludi

    cmpb $42, %cl                   # if %cl == "*" --> jmp moltiplica
    je moltiplica

    cmpb $43, %cl                   # if %cl == "+" --> jmp somma
    je somma

    cmpb $45, %cl                   # if %cl == "-" --> jmp negativo
    je negativo

    cmpb $47, %cl                   # if %cl == "/" --> jmp dividi
    je dividi

    cmpb $48, %cl                   # if %cl < "0" --> jmp invalido
    jl invalido

    cmpb $57, %cl                   # if %cl <= "9" --> jmp calcola
    jle calcola

    jmp invalido                    # if %cl > "9" --> jmp invalido

calcola_neg:
    movl $-1, negbit                # se viene trovato il meno prima di un numero --> negbit = -1

calcola:
    subb $48, %cl                   # trasformazione da ascii a numero [-48]

    mull scala                      # moltiplicazione del registro %eax con il valore scala --> %eax *= 10

    addl %ecx, %eax                 # sommo il registro %ecx con %eax

    inc %ebx                        # viene spostato in avanti il puntatore alla stringa
    
    movb (%ebx,%esi), %cl

    cmpb $32, %cl                   # if %cl == " " [il numero è terminato] --> jmp salva
    je salva

    cmpb $48, %cl                   # if %cl < "0" [presenza di un carattere subito dopo un numero] --> jmp invalido
    jl invalido

    cmpb $57, %cl                   # if %cl <= "9" [il numero non è terminato si torna su calcola] --> jmp calcola
    jle calcola
    
    jmp invalido                    # if %cl > "9" [presenza di un carattere subito dopo un numero] --> jmp invalido

salva:   
    imull negbit                    # moltiplicazione del registro %eax con la variabile negbit --> %eax *= negbit

    movb (%ebx,%esi), %cl

    cmpb $0, %cl                    # if %cl == "\0" --> jmp salvaultimo (solo per saltare il controllo con lo spazio)
    je salvaultimo

    cmpb $10, %cl                   # if %cl == "\n" --> jmp salvaultimo (solo per saltare il controllo con lo spazio)
    je salvaultimo
    
    cmpb $32, %cl                   # if %cl != " " [carattere non valido dopo un'operazione] --> jmp invalido
    jne invalido

salvaultimo:
    inc %ebx

    pushl %eax                      # salvo il numero o il risultato dell'operazione sullo stack 
    jmp ripeti                      # torno a ripeti

moltiplica:
    popl %eax
    popl %edx

    mull %edx                       # moltiplico i due valori presi dallo stack --> %eax *= %edx

    inc %ebx
    jmp salva

somma:
    popl %eax
    popl %edx

    addl %edx, %eax                 # sommo i due valori presi dallo stack --> %eax += %edx

    inc %ebx
    jmp salva

sottrai:
    popl %edx
    popl %eax

    subl %edx, %eax                 # sottraggo i due valori presi dallo stack --> %eax -= %edx
    jmp salva                           

dividi:
    popl temp
    popl %eax

    cmpl $0, %eax                   # if %eax < "0" [%eax negativo e la divisione non può essere fatta] --> jmp invaldo
    jl invalido 

    cmpl $0, temp                   # if temp < "0" [per poter svolgere la divisione bisogna rendere temp positivo mantenendone il significato] --> jmp dividineg
    jl dividineg

    divl temp                       # nessuna condizione prec si è avverata --> %eax /= temp

    inc %ebx
    jmp salva

dividineg:
    movl temp, %edx                 # cambio di segno di temp
    subl %edx, temp
    subl %edx, temp

    movl $0, %edx                   # resetto il registro %edx (dovrà contenere il resto della divisione)
    idivl temp                      # divido i due valori come valoi positivi --> %eax /= temp

    movl %eax, temp                 # cambio di segno di %eax
    subl temp, %eax
    subl temp, %eax

    inc %ebx
    jmp salva  

negativo:
    inc %ebx
    movb (%ebx,%esi), %cl

    cmpb $32, %cl                   # if %cl == " " --> jmp sottrai 
    je sottrai

    cmpb $0, %cl                    # if %cl == "\0" --> jmp sottrai
    je sottrai
    cmpb $10, %cl                   # if %cl == "\n" --> jmp sottrai
    je sottrai

    cmpb $48, %cl                   # if %cl < "0" --> jmp invalido
    jl invalido

    cmpb $57, %cl                   # if %cl <= "9" --> jmp calcola_neg
    jle calcola_neg

    jmp invalido

invalido:
    movl $0, %eax                   # setto i registri a 0
    movl $0, %ecx
    movl $0, %edx
    movl $0, %ebx
    movl 8(%ebp), %edi              # metto il puntatore al primo carattere della stringa di output in %edi

    movb $'I', (%edi)               # creo la stringa "Invalid" + "\0"
    movb $'n', 1(%edi)
    movb $'v', 2(%edi)
    movb $'a', 3(%edi)
    movb $'l', 4(%edi)
    movb $'i', 5(%edi)
    movb $'d', 6(%edi)
    movb $0, 7(%edi)

    jmp fine

concludi:
    movl 8(%ebp), %edi              # metto il puntatore al primo carattere della stringa di output in %edi
    popl %eax                       # prendo il risultato finale dallo stack 

    movl $0, %ecx                   # setto i registri a zero
    movl $0, %edx
    movl $0, %ebx

    cmpl %eax, %ebx                 # if %eax < 0 --> salto l'operazione succesiva che serve solo per i numeri negativi
    jle conta_cifre

    movl $'-', (%ebx,%edi)          # metto al primo posto della stringa di output il carattere "-"
    inc %ebx                        
    inc %ecx                        # incremento la dimensione della stringa (usata dopo)

    movl %eax, %edx                 # cambio di segno di %eax
    subl %edx, %eax
    subl %edx, %eax

    movl $0, %edx

conta_cifre:
    divl scala                      # divido per 10 %eax inserendo il resto in %edx

    pushl %edx                      # metto il numero sullo stack
    movl $0, %edx                   # resetto %edx
    inc %ecx

    cmpl $0, %eax                   # ciclo finché non termina il numero in %eax
    jne conta_cifre

    movl $0, (%ecx,%edi)

converti_stampa:
    popl %eax                       # prendo i numeri dallo stack
    addl $48, %eax                  # converto il numero in ascii
    movl %eax, (%ebx,%edi)          # metto il carattere sulla stringa
    inc %ebx

    cmpl %ebx, %ecx                 # ciclo per il numero di cifre
    jne converti_stampa


fine:
    popl %eax                       # assegni i valori iniziali ai registri 
    popl %edx
	popl %ecx
	popl %ebx

    movl ebp_value,%ebp             # assegno ad %ebp il valore iniziale
    movl esp_value,%esp             # assegno ad %esp il valore iniziale

ret                                 # ritorno al file main.c
