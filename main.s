; Evalbot (Cortex M3 de Texas Instrument)
; programme - Exercice 2.1 : un appui sur SW1 met le Robot ;EVALBOT 
; en rotation sur lui-m�me dans un sens donn�,
; un appui sur SW2 inverse le sens de rotation
; du robot et vice versa.

		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		EXPORT	rotleft
		EXPORT	rotright
		
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

		IMPORT	SWITCH_INIT

		IMPORT	BUMPER_INIT
			
		IMPORT	LED_CONFIG_ALL
		IMPORT 	LED_1_ON
		IMPORT 	LED_2_ON
		IMPORT 	LED_ALL_ON
		IMPORT 	LED_1_OFF
		IMPORT 	LED_2_OFF
		IMPORT 	LED_ALL_OFF
        IMPORT 	LED_ETHERNET_1_OFF
        IMPORT 	LED_ETHERNET_1_ON
        IMPORT 	LED_ETHERNET_2_OFF
        IMPORT	LED_ETHERNET_2_ON
        IMPORT LED_ETHERNET_ALL_ON
        IMPORT LED_ETHERNET_ALL_OFF

        IMPORT	BUMPER_CHECK_DROIT
        IMPORT	BUMPER_CHECK_GAUCHE

		IMPORT 	HANDLE_BUMPER_SET_SPEED

        IMPORT	HANDLE_SWITCH_PRESS
		IMPORT	TRAJECTORY_LEFT
		IMPORT	TRAJECTORY_RIGHT


; This register controls the clock gating logic in normal Run mode
; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf

SYSCTL_PERIPH_GPIOF EQU		0x400FE108


; PORT E : selection du BUMPER DROIT, LIGNE 0 du Port E

PORT0				EQU		0x01

; PORT E : selection du BUMPER DROIT, LIGNE 1 du Port E

PORT1               EQU     0x02

							
__main	
		BL	SWITCH_INIT
		BL	LED_CONFIG_ALL
		BL	MOTEUR_INIT	   		   
		BL 	BUMPER_INIT


INITIAL_STATE    
        bl	HANDLE_SWITCH_PRESS
		BL	HANDLE_BUMPER_SET_SPEED
        b   INITIAL_STATE

rotright    
        BL  LED_ETHERNET_1_ON
        BL  LED_ETHERNET_2_OFF
		BL  MOTEUR_DROIT_ON
        BL  MOTEUR_GAUCHE_ON
        BL  MOTEUR_GAUCHE_AVANT
        BL  MOTEUR_DROIT_AVANT 
		BL	TRAJECTORY_RIGHT
        b   LOOP

rotleft    
        BL  LED_ETHERNET_2_ON
        BL  LED_ETHERNET_1_OFF
        BL  MOTEUR_DROIT_ON
        BL  MOTEUR_GAUCHE_ON
        BL  MOTEUR_DROIT_AVANT
        BL  MOTEUR_GAUCHE_AVANT 
		BL	TRAJECTORY_LEFT
        b	LOOP     

LOOP
		BL  BUMPER_CHECK_GAUCHE
        BL  BUMPER_CHECK_DROIT
		BL	HANDLE_SWITCH_PRESS
		B   LOOP


		END