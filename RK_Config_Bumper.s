


; The GPIODATA register is the data register
; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de ;lm3s9B92.pdf

GPIO_PORTE_BASE		EQU		0x40024000 

; Digital enable register
; To use the pin as a digital input or output, the ;corresponding GPIODEN bit must be set.
; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

GPIO_O_DEN   		EQU 	0x51C  

; Registre pour activer les switchs  en logiciel (par défaut ;ils sont reliés à la masse donc inactifs)

GPIO_PUR			EQU		0x510

; PORT E : selection des BUMPER GAUCHE et DROIT,LIGNE 01 du Port E

PORT01				EQU		0x03

; PORT E : selection du BUMPER DROIT, LIGNE 0 du Port E

PORT0				EQU		0x01

; PORT E : selection du BUMPER DROIT, LIGNE 1 du Port E

PORT1                           EQU     0x02


DELAY               EQU     0x000FFFFF


		AREA    MyData, DATA, READWRITE

LAST_BUMPER1_STATE  SPACE   4
LAST_BUMPER2_STATE  SPACE   4

        AREA    |.text|, CODE, READONLY
		ENTRY

        EXPORT	BUMPER_INIT
        EXPORT	BUMPER_CHECK_DROIT
        EXPORT	BUMPER_CHECK_GAUCHE
        EXPORT  HANDLE_BUMPER_SET_SPEED

        IMPORT	CALL_MOTEUR_RECULER_SHORT
		IMPORT	MOTEUR_RECULER_SHORT
		IMPORT	LOOP_SHORT
        IMPORT	ROT_LEFT
		IMPORT	ROT_RIGHT
		IMPORT	ENABLE_STACK_SYSCTL_RCGC2
		IMPORT	INCREASE_SPEED_MODE
		IMPORT	REDUCE_SPEED_MODE

        IMPORT  RETURN

BUMPER_INIT

        push {lr}
        mov r0, #0x00000010  				;; Enable clock sur GPIO E
        push {r0}
        BL	ENABLE_STACK_SYSCTL_RCGC2


        ; Enable Digital Function - Port E
		ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN	
        ldr r0, = PORT01		
        str r0, [r7]	

        ; Activer le registre des bumpers, Port E
		ldr r7, = GPIO_PORTE_BASE+GPIO_PUR	
        ldr r0, = PORT01
        str r0, [r7]
		pop {lr}
        BX  lr

BUMPER_CHECK_DROIT
        ldr r7,= GPIO_PORTE_BASE + (PORT0<<2)
        ldr r5, [r7]
        cmp r5,#0x01
		BEQ	RETURN
        bl CALL_MOTEUR_RECULER_SHORT
        B   ROT_LEFT

BUMPER_CHECK_GAUCHE
        ldr r9, = GPIO_PORTE_BASE + (PORT1<<2)
        ldr r10, [r9]
        cmp r10, #0x02
		BEQ	RETURN
       	bl CALL_MOTEUR_RECULER_SHORT
        B   ROT_RIGHT


HANDLE_BUMPER_SET_SPEED
        push    {lr}           

        ; --- Check Bumper 1 (PORT1) ---
        ldr     r9, = GPIO_PORTE_BASE + (PORT1 << 2)
        ldr     r10, [r9]             
        cmp     r10, #0x02            
        bne     HANDLE_BUMPER1_PRESS  
        BL      BUMPER1_NOT_PRESSED   

        ; --- Check Bumper 2 (PORT0) ---
        ldr     r7, = GPIO_PORTE_BASE + (PORT0 << 2)
        ldr     r5, [r7]              
        cmp     r5, #0x01             
        bne     HANDLE_BUMPER2_PRESS  
        BL      BUMPER2_NOT_PRESSED   

        b       HANDLE_BUMPER_END     

HANDLE_BUMPER1_PRESS
        ldr     r11, = LAST_BUMPER1_STATE
        ; Load previous state of Bumper 1
        ldr     r12, [r11]
        ; If already pressed            
        cmp     r12, #1               
        beq     HANDLE_BUMPER_END

        ; If first press 
        ; Update state to "pressed"
        mov     r12, #1               
        str     r12, [r11]
        ; Wait to update the state of the bumper            
        BL      DEBOUNCE_DELAY
        ; Reduce the speed 
        BL      REDUCE_SPEED_MODE    
        ; end of function 
        b       HANDLE_BUMPER_END     

HANDLE_BUMPER2_PRESS
        ldr     r11, = LAST_BUMPER2_STATE
        ; Load previous state of Bumper 2
        ldr     r12, [r11]    
        ; If already pressed                    
        cmp     r12, #1               
        beq     HANDLE_BUMPER_END     

        ; If first press 
        ; Update state to "pressed"
        mov     r12, #1               
        str     r12, [r11]            
        BL      DEBOUNCE_DELAY
        BL      INCREASE_SPEED_MODE   
        b       HANDLE_BUMPER_END     

BUMPER1_NOT_PRESSED
        ldr     r11, = LAST_BUMPER1_STATE
        ; Reset state to "not pressed"
        mov     r12, #0               
        str     r12, [r11]
        bx      lr

BUMPER2_NOT_PRESSED
        ldr     r11, = LAST_BUMPER2_STATE
        ; Reset state to "not pressed"
        mov     r12, #0               
        str     r12, [r11]
        bx      lr

HANDLE_BUMPER_END
        pop     {lr}           
        bx      lr


DEBOUNCE_DELAY
        ldr     R0, =DELAY       
DEBOUNCE_LOOP
        ; Wait for the delay
        SUBS    R0, R0, #1
        BNE     DEBOUNCE_LOOP         
        BX      LR


        END