	;; RK - Evalbot (Cortex M3 de Texas Instrument)
	;; Les deux LEDs sont initialement allum�es
	;; Ce programme lis l'�tat du bouton poussoir 1 connect�e au port GPIOD broche 6
	;; Si bouton poussoir ferm� ==> fait clignoter les deux LED1&2 connect�e au port GPIOF broches 4&5.
   	

; This register controls the clock gating logic in normal Run mode
SYSCTL_RCGC2     EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

;LED 1
PIN4				EQU		0x10
;LED 2
PIN5				EQU		0x20
; Broches select
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5


PIN2				EQU		0x04        ; led ethernet 1 
PIN3				EQU		0x08        ; led ethernet 2 
BROCHE2_3			EQU		0x0C		; led ethernet 1 & led ethernet 2


		AREA    |.text|, CODE, READONLY
	  	ENTRY

		EXPORT LED_CONFIG_ALL
		EXPORT LED_1_ON
		EXPORT LED_2_ON
		EXPORT LED_ALL_ON
		EXPORT LED_1_OFF
		EXPORT LED_2_OFF
		EXPORT LED_ALL_OFF
                EXPORT LED_ETHERNET_ALL_ON
                EXPORT LED_ETHERNET_ALL_OFF
                EXPORT LED_ETHERNET_1_OFF
                EXPORT LED_ETHERNET_1_ON
                EXPORT LED_ETHERNET_2_OFF
                EXPORT LED_ETHERNET_2_ON
                EXPORT LED_ETHERNET_ALL_INVERT

                EXPORT  SET_LED_ACCORDING_TO_SPEED_MODE

		IMPORT	ENABLE_STACK_SYSCTL_RCGC2

                IMPORT	SPEED_MODE_SLOW   
		IMPORT	SPEED_MODE_NORMAL 
		IMPORT	SPEED_MODE_FAST   
		IMPORT	SPEED_MODE_FASTEST					
		IMPORT	CURRENT_MODE

LED_CONFIG_ALL
        push {lr}
		; ;; Enable the Port F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)	
        mov r0, #0x00000028  				;; Enable clock sur GPIO F & D sur lesquels sont branchés les leds
        push {r0}
        BL	ENABLE_STACK_SYSCTL_RCGC2
        	
		;CONFIGURATION LED
        ldr r1, = BROCHE4_5
        ldr r2, = BROCHE2_3
        orr r1, r2

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        str r1, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        str r1, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensit� de sortie (2mA)
        str r1, [r6]


        BL  LED_ETHERNET_ALL_OFF

        pop {lr}
		BX LR

LED_1_ON
        push {lr}                 ; Save link register
        BL   LED_2_OFF
        ldr r6, = GPIO_PORTF_BASE + (PIN4<<2)
        mov r3, #PIN4            ; Load pin 4 pattern (0x10)
        str r3, [r6]             ; Turn on LED 1
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn ON LED 2 (Pin 5)
LED_2_ON
        push {lr}                 ; Save link register
        BL   LED_1_OFF
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


; Function to turn ON LED 1 (Pin 4)
LED_ETHERNET_1_ON
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (PIN2<<2)
        mov r3, #PIN2            ; Load pin 4 pattern (0x10)
        str r3, [r6]             ; Turn on LED 1
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn ON LED 2 (Pin 5)
LED_ETHERNET_2_ON
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE  + (PIN3<<2)
        mov r3, #PIN3            ; Load pin 5 pattern (0x20)
        str r3, [r6]             ; Turn on LED 2
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn OFF LED 1 (Pin 4)
LED_ETHERNET_1_OFF
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (PIN2<<2)
        mov r2, #0x00            ; Clear value
        str r2, [r6]             ; Turn off LED 1
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn OFF LED 2 (Pin 5)
LED_ETHERNET_2_OFF
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (PIN3<<2)
        mov r2, #0x00            ; Clear value
        str r2, [r6]             ; Turn off LED 2
        pop {lr}                 ; Restore link register
        bx lr

LED_ETHERNET_ALL_INVERT
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (BROCHE2_3<<2)
        ldr r0, [r6]             ; Load current LED state into r0
        cmp r0, #BROCHE2_3
        beq TURN_ON             ; If LED is off (==0), branch to turn on
        bl  LED_ETHERNET_ALL_OFF  ; If LED is on, turn it off
        b   DONE
TURN_ON
        bl  LED_ETHERNET_ALL_ON   ; Turn LED on
DONE
        pop {lr}                 
        bx lr

; Function to turn ON both LEDs
LED_ETHERNET_ALL_ON
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (BROCHE2_3<<2)
        mov r3, #0x00        
        str r3, [r6]             ; Turn on both LEDs
        pop {lr}                 ; Restore link register
        bx lr

; Function to turn OFF both LEDs
LED_ETHERNET_ALL_OFF
        push {lr}                 ; Save link register
        ldr r6, = GPIO_PORTF_BASE + (BROCHE2_3<<2)
        mov r2, #BROCHE2_3           
        str r2, [r6]             ; Turn off both LEDs
        pop {lr}                 ; Restore link register
        bx lr


SET_LED_ACCORDING_TO_SPEED_MODE
        push    {lr}
        ldr     r1, =CURRENT_MODE
        ldr     r1, [r1]           ; Load current mode


        ldr     r2, =SPEED_MODE_SLOW
        cmp     r1, r2
        push    {r1}
        BLEQ    LED_ALL_OFF
        pop     {r1}

        ldr     r2, =SPEED_MODE_NORMAL
        cmp     r1, r2
        push    {r1}
        BLEQ    LED_2_ON
        pop     {r1}

        ldr     r2, =SPEED_MODE_FAST
        cmp     r1, r2
        push    {r1}
        BLEQ    LED_1_ON
        pop     {r1}

        ldr     r2, =SPEED_MODE_FASTEST
        cmp     r1, r2
        push    {r1}
        BLEQ    LED_ALL_ON
        pop     {r1}


        pop     {lr}
        BX      lr

        END