	BITS 16
	org 0x7c00
start:
jmp short begin
nop
times 0x3B db 0

begin:
	
	mov ax, 0x3
	int 0x10			;Ponerlo en modo VGA text mode 3

	cli
	lgdt [gdt_pointer]	;Carga la tabla GDT
	mov eax, cr0
	or eax,0x1
	mov cr0, eax

	;Se cambian los valores anteriores al nuevo segmento
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
	
	;en 16 bits la siguiente linea es 'mov si, text_string'
	
	mov ebx,0xb8000

	; las siguientes 6 lineas reproducen sonido
	mov al, 0xb6
	out 0x43, al
	mov al, 54
	out 0x42, al	
	mov al, 124
	out 0x42, al		
	mov al, 0xff
	out 0x61, al
	jmp CODE_SEG:boot2	;Salto al código
	
copy_target:
bits 32
boot2:	
	boot2:	
	
	; Estas lineas imprimen las primeras 12 lineas rojas
	mov cx, 12
	print_a:

	mov esi, blank
	call print_string	
	dec cx
	jne print_a

	; Acá imprimimos el texto
	mov esi, muerte
	call print_string	

	; Estas lineas imprimen las últimas 12 lineas rojas
	mov cx, 12
	print_b:
	mov esi, blank
	call print_string
	dec cx
	jne print_b
	
	cli
	hlt

	blank db 	'                                                                                ', 0
	muerte db   '                           A LA MIERDA EL PORNOGRIND!                           ', 0

print_string:			; Rutine: muestra string en SI a la pantalla

.repeat:
	lodsb					; Obtiene el caracter the SI y lo pone AL (LODSB -	Load byte at address DS:(E)SI into AL)
	cmp al, 0
	je .done				; Si AL es 0, termina (EOF)

	or eax, 0xc000			;https://en.wikipedia.org/wiki/Video_Graphics_Array#Color_palette
	
	
    mov word [ebx], ax
    add ebx,2	
	
	
	jmp .repeat

.done:
	ret

	
; Esta es la tabla GDT, se pone acá porque luego empieza la sección de 32bits	
gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start
	
disk:
	db 0x0	

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start	
		
times 510-($-$$) db 0	; Llenar el resto del boot sector con 0's
dw 0xAA55				; Los bytes necesarios para hacerlo reconocer como boot

