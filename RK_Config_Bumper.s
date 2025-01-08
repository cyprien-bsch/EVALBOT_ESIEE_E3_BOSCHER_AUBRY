
; This register controls the clock gating logic in normal Run ;mode SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf

SYSCTL_PERIPH_GPIOF EQU		0x400FE108

; The GPIODATA register is the data register
; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de ;lm3s9B92.pdf

GPIO_PORTE_BASE		EQU		0x40024000


; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
; GPIO Direction (p417 datasheet de lm3s9B92.pdf

GPIO_O_DIR   		EQU 	0x400

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

GPIO_O_DR2R   		EQU 	0x500  

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

PORT1               EQU     0x02


        AREA    |.text|, CODE, READONLY
		ENTRY

        EXPORT	BUMPER_INIT
        EXPORT	BUMPER_CHECK_DROIT
        EXPORT	BUMPER_CHECK_GAUCHE


        IMPORT	CALL_MOTEUR_RECULER_SHORT
		IMPORT	MOTEUR_RECULER_SHORT
		IMPORT	LOOP_SHORT
        IMPORT	rotleft
		IMPORT	rotright

BUMPER_INIT
        ; Enable Digital Function - Port E
		ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN	
        ldr r0, = PORT01		
        str r0, [r7]	

        ; Activer le registre des bumpers, Port E
		ldr r7, = GPIO_PORTE_BASE+GPIO_PUR	
        ldr r0, = PORT01
        str r0, [r7]
		BX 	LR

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

	
RETURN
		BX lr
        
        END