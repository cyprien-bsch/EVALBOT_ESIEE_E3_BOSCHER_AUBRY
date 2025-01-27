
 ; SW (PORT D)
GPIO_PORTD_BASE		EQU		0x40007000

; Digital enable register
GPIO_O_DEN   		EQU 	0x0000051C  

; Pull up Register (for SW or BUMP)
GPIO_O_PUR			EQU		0x00000510

; Ports
PORT67				EQU		0xC0 ; SW 1 et 2 - Lignes 6 et 7 Port D
PORT6				EQU		0x40 ; SW 1  - Lignes 6 Port D
PORT7				EQU		0x80 ; SW 2  - Lignes 7 Port D

		AREA    |.text|, CODE, READONLY
	  	ENTRY

		EXPORT	SWITCH_INIT
        EXPORT	HANDLE_SWITCH_PRESS

		IMPORT	ENABLE_STACK_SYSCTL_RCGC2
		IMPORT	ROT_RIGHT
		IMPORT	ROT_LEFT          


SWITCH_INIT
        push {lr}
        mov r0, #0x00000008  				; Enable clock sur GPIO D = SW 
        push {r0}
        BL	ENABLE_STACK_SYSCTL_RCGC2

        ;Configuration des switchs : SW1 et SW2
        ldr	r7, = GPIO_PORTD_BASE+GPIO_O_DEN		;; Enable Digital Function 
        ldr r0, = PORT67 		
        str r0, [r7]
        
        ; Pull Up Function
        ldr	r7, = GPIO_PORTD_BASE+GPIO_O_PUR		
        ldr r0, = PORT67	
        str r0, [r7]
        pop {lr}
        BX  lr

HANDLE_SWITCH_PRESS
		ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)
        ldr r4, [r7]
        ; If port 7 pressed 
        cmp r4, #PORT7                                
        beq ROT_RIGHT

        ; If port 6 pressed 
        cmp r4, #PORT6                
        beq ROT_LEFT
		bx	lr

		END