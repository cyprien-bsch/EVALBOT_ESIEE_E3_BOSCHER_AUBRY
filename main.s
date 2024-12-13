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

; This register controls the clock gating logic in normal Run mode
; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf

SYSCTL_PERIPH_GPIOF EQU		0x400FE108

; The GPIODATA register is the data register
; GPIO Port D (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf

GPIO_PORTD_BASE		EQU		0x40007000 ;pour les SW (PORT D)



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



__main	

; Enable the Port D,E and F peripheral clock by setting bit 3,4,5 (0x38 == 0b111000)		
;(p291 datasheet de lm3s9B96.pdf), (GPIO::FEDCBA)
		
			ldr r6, = SYSCTL_PERIPH_GPIOF  		;; RCGC2
        	mov r0, #0x00000008  				;; Enable clock sur GPIO D = SW 
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

			BL	MOTEUR_INIT	   		   
		
; Activer les deux moteurs droit et gauche

			BL	MOTEUR_DROIT_OFF
			BL	MOTEUR_GAUCHE_OFF

loop	
; Lire dans R4 l'etat des SW
			ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)
			ldr r4, [r7]								
					
;Test des �tats des switchs
; Test de l'�tat de SW2			
			cmp	r4,#0x80								
			beq rotright
; Test l'�tat de SW1			
			cmp r4,#0x40				
			beq rotleft
			b	loop
;Rotation � droite de l'Evalbot		
rotright	
			BL	MOTEUR_DROIT_ON
			BL	MOTEUR_GAUCHE_ON
			BL	MOTEUR_GAUCHE_AVANT
			BL	MOTEUR_DROIT_ARRIERE   

; Lire dans R4 l'etat des SW	
			ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)
			ldr r4, [r7]			
			
;Test de l'�tat de SW1
			cmp r4,#0x40	
			beq rotleft
			b	rotright
; Rotation � gauche de l'Evalbot		
rotleft	
			BL	MOTEUR_DROIT_ON
			BL	MOTEUR_GAUCHE_ON
			BL	MOTEUR_DROIT_AVANT
			BL	MOTEUR_GAUCHE_ARRIERE   
		
			ldr r7,= GPIO_PORTD_BASE + (PORT67<<2)

; Lire dans R4 l'etat des SW
			ldr r4, [r7]			
		
;Test de l'�tat de SW2
			
			cmp r4,#0x80	
			beq rotright

			b	rotleft
			b loop			
       		END


