
		AREA    |.text|, CODE, READONLY
	  	ENTRY

		EXPORT	ENABLE_STACK_SYSCTL_RCGC2
        EXPORT  RETURN

; This register controls the clock gating logic in normal Run mode
SYSCTL_RCGC2     EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)


ENABLE_STACK_SYSCTL_RCGC2
        ; extract the new GPIO clock(s) to activate 
        pop {r1}
        ; RCGC2
        ldr r6, = SYSCTL_RCGC2  		
        ldr r0, [r6]
        ; Keep the old config
        orr r0, r1
        ; Store new value
        str r0, [r6]
        ;; Wait until clock activates
        nop	   									
		nop	   
		nop	 
        bx  lr

RETURN
		BX lr
        

		END