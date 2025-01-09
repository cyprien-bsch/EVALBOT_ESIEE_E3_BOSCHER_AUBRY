	;; RK - Evalbot (Cortex M3 de Texas Instrument)
	;; Les deux LEDs sont initialement allum�es
	;; Ce programme lis l'�tat du bouton poussoir 1 connect�e au port GPIOD broche 6
	;; Si bouton poussoir ferm� ==> fait clignoter les deux LED1&2 connect�e au port GPIOF broches 4&5.
   	

; This register controls the clock gating logic in normal Run mode
SYSCTL_RCGC2     EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

;LED 1
PIN4				EQU		0x10
;LED 2
PIN5				EQU		0x20
; Broches select
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5

BROCHE6				EQU 	0x40		; bouton poussoir 1

; blinking frequency
DUREE   			EQU     0x002FFFFF


		AREA    |.text|, CODE, READONLY
	  	ENTRY

		EXPORT LED_CONFIG_ALL
		EXPORT LED1_CONFIG
		EXPORT LED2_CONFIG
		EXPORT LED_1_ON
		EXPORT LED_2_ON
		EXPORT LED_ALL_ON
		EXPORT LED_1_OFF
		EXPORT LED_2_OFF
		EXPORT LED_ALL_OFF

		IMPORT	ENABLE_STACK_SYSCTL_RCGC2

		; Il faut appeler BLINK après une config
		; Il faut à chaque fois refaire la config
		; Ex : (LED1_CONFIG + BLINK ||LED_CONFIG_ALL + BLINK)

LED_CONFIG_ALL
        push {lr}
		; ;; Enable the Port F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)	
        mov r0, #0x00000028  				;; Enable clock sur GPIO F & D sur lesquels sont branchés les leds
        push {r0}
        BL	ENABLE_STACK_SYSCTL_RCGC2
        	
		;CONFIGURATION LED

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = BROCHE4_5 	
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensit� de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r6]

		ldr r6, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		;Fin configuration LED 
		
        pop {lr}
		BX LR

LED1_CONFIG
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = PIN4 	
        str r0, [r6]
		
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = PIN4 		
        str r0, [r6]
 
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensit� de sortie (2mA)
        ldr r0, = PIN4 			
        str r0, [r6]

        mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (PIN4)
		mov r3, #PIN4       					;; Allume portF broche 4 : 00010000
		ldr r6, = GPIO_PORTF_BASE + (PIN4<<2)  ;; @data Register = @base + (mask<<2) ==> LED1

		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		BX LR
LED2_CONFIG
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = PIN5 	
        str r0, [r6]
		
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = PIN5 		
        str r0, [r6]
 
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensit� de sortie (2mA)
        ldr r0, = PIN5 			
        str r0, [r6]

        mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (PIN4)
		mov r3, #PIN5       					;; Allume portF broche 4 : 00010000
		ldr r6, = GPIO_PORTF_BASE + (PIN5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1

		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		BX LR
		
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Switcher 1

; Function to turn ON LED 1 (Pin 4)
LED_1_ON
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (PIN4<<2)
        mov r3, #PIN4            ; Load pin 4 pattern (0x10)
        str r3, [r6]             ; Turn on LED 1
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn ON LED 2 (Pin 5)
LED_2_ON
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE  + (PIN5<<2)
        mov r3, #PIN5            ; Load pin 5 pattern (0x20)
        str r3, [r6]             ; Turn on LED 2
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn OFF LED 1 (Pin 4)
LED_1_OFF
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (PIN4<<2)
        mov r2, #0x00            ; Clear value
        str r2, [r6]             ; Turn off LED 1
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn OFF LED 2 (Pin 5)
LED_2_OFF
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (PIN5<<2)
        mov r2, #0x00            ; Clear value
        str r2, [r6]             ; Turn off LED 2
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn ON both LEDs
LED_ALL_ON
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (BROCHE4_5<<2)
        mov r3, #BROCHE4_5       ; Load pattern for both LEDs (0x30)
        str r3, [r6]             ; Turn on both LEDs
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn OFF both LEDs
LED_ALL_OFF
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (BROCHE4_5<<2)
        mov r2, #0x00            ; Clear value
        str r2, [r6]             ; Turn off both LEDs
        pop {lr}                 ; Restore link register
        bx lr