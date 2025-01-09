
		AREA    |.text|, CODE, READONLY
	  	ENTRY

		EXPORT	ENABLE_STACK_SYSCTL_RCGC2


; This register controls the clock gating logic in normal Run mode
SYSCTL_RCGC2     EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)


ENABLE_STACK_SYSCTL_RCGC2
        pop {r1}
        ldr r6, = SYSCTL_RCGC2  		;; RCGC2
        ldr r0, [r6]
        orr r0, r1
        str r0, [r6]
        nop	   									;; tres tres important....
		nop	   
		nop	 
        bx  lr

		END