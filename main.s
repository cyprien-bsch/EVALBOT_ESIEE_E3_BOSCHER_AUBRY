; Evalbot (Cortex M3 de Texas Instrument)

		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		EXPORT	ROT_LEFT
		EXPORT	ROT_RIGHT
		
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d�activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d�activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant

		IMPORT	SWITCH_INIT

		IMPORT	BUMPER_INIT
			
		IMPORT	LED_CONFIG_ALL
        IMPORT 	LED_ETHERNET_1_OFF
        IMPORT 	LED_ETHERNET_1_ON
        IMPORT 	LED_ETHERNET_2_OFF
        IMPORT	LED_ETHERNET_2_ON

        IMPORT	BUMPER_CHECK_DROIT
        IMPORT	BUMPER_CHECK_GAUCHE

		IMPORT 	HANDLE_BUMPER_SET_SPEED

        IMPORT	HANDLE_SWITCH_PRESS
		IMPORT	TRAJECTORY_LEFT
		IMPORT	TRAJECTORY_RIGHT


							
; Main program entry point
__main	
		BL      SWITCH_INIT         ; Initialize switches
		BL      LED_CONFIG_ALL      ; Initialize all LEDs
		BL      MOTEUR_INIT         ; Initialize motors      
		BL      BUMPER_INIT         ; Initialize bumper sensors

; Initial program loop 
INITIAL_STATE    
		bl      HANDLE_SWITCH_PRESS ; Check and handle switch presses (to choose the start rotation direction)
		BL      HANDLE_BUMPER_SET_SPEED ; Adjust speed based in function of the bumper state
		b       INITIAL_STATE

; Turn robot right 
ROT_RIGHT    
		; Visual indicator for right turn
		BL      LED_ETHERNET_1_ON   
		BL      LED_ETHERNET_2_OFF
		; Enable motors
		BL      MOTEUR_DROIT_ON     
		BL      MOTEUR_GAUCHE_ON
		; Set motor directions
		BL      MOTEUR_GAUCHE_AVANT 
		BL      MOTEUR_DROIT_AVANT 
		; Set appropriate trajectory
		BL      TRAJECTORY_RIGHT    
		b       LOOP

; Turn robot left 
ROT_LEFT    
		; Visual indicator for left turn
		BL      LED_ETHERNET_2_ON   
		BL      LED_ETHERNET_1_OFF
		; Enable motors
		BL      MOTEUR_DROIT_ON     
		BL      MOTEUR_GAUCHE_ON
		; Set motor directions
		BL      MOTEUR_DROIT_AVANT  
		BL      MOTEUR_GAUCHE_AVANT 
		; Set appropriate trajectory
		BL      TRAJECTORY_LEFT     
		b       LOOP     

; Main loop
LOOP
		; Check left bumper
		BL      BUMPER_CHECK_GAUCHE 
		; Check right bumper
		BL      BUMPER_CHECK_DROIT  
		; Check switches
		BL      HANDLE_SWITCH_PRESS 
		B       LOOP
		END