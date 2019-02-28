	BITS 16
	org 0x7c00
start:
jmp short begin
nop
times 0x3B db 0

begin:
	mov ax, 0x2401
	int 0x15			;Estas lineas activan A20 bit para acceder a más de 1mb
	
	mov ax, 0x3
	int 0x10			;Ponerlo en modo VGA text mode 3
	
	
	mov [disk],dl
	mov ah, 0x2    ;read sectors
	mov al, 1      ;sectors to read
	mov ch, 0      ;cylinder idx
	mov dh, 0      ;head idx
	mov cl, 2      ;sector idx
	mov dl, [disk] ;disk idx
	mov bx, copy_target;target pointer
	int 0x13

	cli
	lgdt [gdt_pointer]	;Carga la tabla GDT
	mov eax, cr0
	or eax,0x1
	mov cr0, eax
	jmp CODE_SEG:boot2	;Salto al código
	hlt

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
		
times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
dw 0xAA55		; The standard PC boot signature
	
;****************************************
;           32 bits
;****************************************
copy_target:
bits 32
boot2:	

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
	mov al, 0xffff
	out 0x61, al
	
	
	mov cx, 12
	print_a:

	mov esi, blank
	call print_string	; Call our string-printing routine
	dec cx
	jne print_a


	mov esi, muerte
	call print_string	; Call our string-printing routine

	
	
	
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

print_string:			; Routine: output string in SI to screen

.repeat:
	lodsb					; Obtiene el caracter the SI y lo pone AL (LODSB -	Load byte at address DS:(E)SI into AL)
	cmp al, 0
	je .done				; Si AL es 0, termina (EOF)

    ;or eax,0x0E00			;https://en.wikipedia.org/wiki/Video_Graphics_Array#Color_palette
	or eax, 0xc000
	
	
    mov word [ebx], ax
    add ebx,2	
	
	
	jmp .repeat

.done:
	ret


times 2048 - ($-$$) db 0
