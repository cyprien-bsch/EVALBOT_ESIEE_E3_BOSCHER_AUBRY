; Evalbot (Cortex M3 de Texas Instrument)
; programme - Exercice 2.1 : un appui sur SW1 met le Robot ;EVALBOT 
; en rotation sur lui-m�me dans un sens donn�,
; un appui sur SW2 inverse le sens de rotation
; du robot et vice versa.

		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d�activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arri�re
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d�activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arri�re
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche

		IMPORT	BUMPER_INIT
			
		IMPORT	LED_CONFIG_ALL
		IMPORT 	LED_1_ON
		IMPORT 	LED_2_ON
		IMPORT 	LED_ALL_ON
		IMPORT 	LED_1_OFF
		IMPORT 	LED_2_OFF
		IMPORT 	LED_ALL_OFF



; This register controls the clock gating logic in normal Run mode
; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf

SYSCTL_PERIPH_GPIOF EQU		0x400FE108

; The GPIODATA register is the data register
; GPIO Port D (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf

GPIO_PORTD_BASE		EQU		0x40007000 ;pour les SW (PORT D)
GPIO_PORTE_BASE		EQU		0x40024000 ;pour les BUMPER



; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

GPIO_O_DEN   		EQU 	0x0000051C  

; Pull up Register (for SW or BUMP)
GPIO_O_PUR			EQU		0x00000510

; Port select

PORT67				EQU		0xC0 ; SW 1 et 2 - Lignes 6 et 7 Port D
PORT6				EQU		0x40 ; SW 1  - Lignes 6 Port D
PORT7				EQU		0x80 ; SW 2  - Lignes 7 Port D


; PORT E : selection du BUMPER DROIT, LIGNE 0 du Port E

PORT0				EQU		0x01

; PORT E : selection du BUMPER DROIT, LIGNE 1 du Port E

PORT1               EQU     0x02



DUREE_SHORT 		EQU 	0x002FFFFF
							
__main	

; Enable the Port D,E and F peripheral clock by setting bit 3,4,5 (0x38 == 0b111000)		
;(p291 datasheet de lm3s9B96.pdf), (GPIO::FEDCBA)
		
			ldr r6, = SYSCTL_PERIPH_GPIOF  		;; RCGC2
        	mov r0, #0x00000038  				;; Enable clock sur GPIO D = SW 
			str r0, [r6]
		
;"There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
;tres tres important....;; pas necessaire en simu ou en debbug step by step...
			nop	   									
			nop	   
			nop	   	

;Configuration des switchs : SW1 et SW2
        	ldr	r7, = GPIO_PORTD_BASE+GPIO_O_DEN		;; Enable Digital Function 
        	ldr r0, = PORT67 		
        	str r0, [r7]
			
			ldr	r7, = GPIO_PORTD_BASE+GPIO_O_PUR		;; Pull Up Function
        	ldr r0, = PORT67	
        	str r0, [r7]

; Configure les PWM + GPIO
			BL	LED_CONFIG_ALL
; Config LEDS
			BL	MOTEUR_INIT	   		   
			BL 	BUMPER_INIT
; Activer les deux moteurs droit et gauche

			BL	MOTEUR_DROIT_OFF
			BL	MOTEUR_GAUCHE_OFF

loop    
        ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)
        ldr r4, [r7]                                
                    
        cmp r4,#0x80                                
        beq rotright
        cmp r4,#0x40                
        beq rotleft
        b   loop

rotright    

        BL  BUMPER_CHECK_GAUCHE
        BL  BUMPER_CHECK_DROIT
        BL  LED_1_ON
        BL  LED_2_OFF
        BL  MOTEUR_DROIT_ON
        BL  MOTEUR_GAUCHE_ON
        BL  MOTEUR_GAUCHE_AVANT
        BL  MOTEUR_DROIT_ARRIERE   


        ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)
        ldr r4, [r7]            
        
        cmp r4,#0x40    
        beq rotleft
        b   rotright

rotleft    
        BL  BUMPER_CHECK_GAUCHE
        BL  BUMPER_CHECK_DROIT
        BL  LED_2_ON
        BL  LED_1_OFF
        BL  MOTEUR_DROIT_ON
        BL  MOTEUR_GAUCHE_ON
        BL  MOTEUR_DROIT_AVANT
        BL  MOTEUR_GAUCHE_ARRIERE   
        
        ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)
        ldr r4, [r7]            
        
        cmp r4,#0x80    
        beq rotright
        b   rotleft

BUMPER_CHECK_DROIT
        ldr r7,= GPIO_PORTE_BASE + (PORT0<<2)
        ldr r5, [r7]
        cmp r5,#0x01
		BEQ	RETURN
        bl CALL_MOTEUR_RECULER_SHORT
        B   rotleft

BUMPER_CHECK_GAUCHE
        ldr r9, = GPIO_PORTE_BASE + (PORT1<<2)
        ldr r10, [r9]
        cmp r10, #0x02
		BEQ	RETURN
       	bl CALL_MOTEUR_RECULER_SHORT
        B   rotright

CALL_MOTEUR_RECULER_SHORT
        push {lr}
        BL  MOTEUR_RECULER_SHORT       
        pop {lr}
        BX  LR                         

MOTEUR_RECULER_SHORT
        push {lr}
        BL  MOTEUR_DROIT_ON
        BL  MOTEUR_GAUCHE_ON
        BL  MOTEUR_GAUCHE_ARRIERE
        BL  MOTEUR_DROIT_ARRIERE
        BL  LED_ALL_ON
        pop {lr}
        
        ldr r1, =DUREE_SHORT
        b   LOOP_SHORT

LOOP_SHORT
        subs    r1, r1, #1
        bne     LOOP_SHORT
        push {lr}
        BL  LED_ALL_OFF
        pop {lr}
        BX   lr    
		
		
		
RETURN
		BX lr
        
		END