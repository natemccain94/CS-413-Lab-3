@ ARM Lab 3
@ Nate McCain
@ Simulate the following instruction:
@ COPYDATA address1, address2, length
@ R4 := address1 length, and then it will hold the smaller value between itselft and R5.
@ R5 := address2 length
@ R6 := length value of user input
@ The data from address1 is to be copied into the memory location of address2.
@ First the program should display address1, then it will show what is in
@ address2. Finally, it will execute the COPYDATA instruction and display what
@ is in memory at address2.

@ variables
.data

showAddressOne: .asciz "The string currently stored in address1 is:\n"
lengthAddressOne: .asciz "The length of the string in address1 is: %d\n"
showAddressTwo: .asciz "The string currently stored in address2 is:\n"
lengthAddressTwo: .asciz "The length of the string in address2 is: %d\n"
userAddressPromptOne: .asciz "Enter 1 if you wish to copy address1 into address2.\n"
userAddressPromptTwo: .asciz "Enter 2 if you wish to copy address2 into address1.\n"
userLengthPromptOne: .asciz "Please input the number of characters to copy into address2.\n"
userLengthPromptTwo: .asciz "The length must be between 1 and %d.\n"
lengthTooSmall: .asciz "The COPYDATA instruction requires a length greater than zero.\n"
lengthTooBig: .asciz "The input length is larger than the size of smaller address.\n"
taskCompleteOne: .asciz "The COPYDATA instruction has executed. \n"
taskCompleteTwo: .asciz "The new string in address2 is: \n"

.balign 4
addressOne: .asciz "HelloWorld"

.balign 4
addressTwo: .asciz "EmptyString"

.balign 4
newLine: .asciz "\n"

.equ nul, 0

userInputLength: .asciz "%d"

.text
	.global main
	.extern printf
	.extern scanf

@ Start of the main function
main:

    	B findAddressOneLength  @ Go to the first function to be used.
@__________________________________________________________________________________________________
findAddressOneLength:
    	LDR R4, =addressOne     @ Load address one into R4.
    	MOV R7, #0              @ Set the counter to zero.
    	B lenOneLoop            @ Go to the counting function.

lenOneLoop:
    	LDRB R2, [R4], #1       @ Load the current character into R2, then move index over 1 byte.
    	ADD R7, R7, #1          @ Increment the counter.
    	CMP R2, #nul            @ If the current character is not nul, keep looping.
    	BNE lenOneLoop          @ Return to top of loop.

    	SUB R7, R7, #1          @ If the current character is nul, decrement the counter.
    	MOV R4, R7              @ Store the length of address one into R4.
    	B findAddressTwoLength  @ Go to function to find the length of address 2.
@__________________________________________________________________________________________________
findAddressTwoLength:
    	LDR R5, =addressTwo     @ Load address two into R5.
    	MOV R7, #0              @ Set the counter to zero.
    	B lenTwoLoop            @ Go to the counting function.

lenTwoLoop:
    	LDRB R2, [R5], #1       @ Load the current character into R2, then move index over 1 byte.
    	ADD R7, R7, #1          @ Increment the counter.
    	CMP R2, #nul            @ If the current character is not nul, keep looping.
    	BNE lenTwoLoop          @ Return to top of loop.

    	SUB R7, R7, #1          @ If the current character is nul, decrement the counter.
    	MOV R5, R7              @ Store the length of address two into R5.
    	B displayBeforeCopyData @ Go to the next function to be executed.
@__________________________________________________________________________________________________
displayBeforeCopyData:
	LDR R0, =showAddressOne	    @ Prepare to print the first address message, part 1.
	BL printf		    @ Print the first message, part 1.

	LDR R0, =addressOne	    @ Prepare to print the first address message, part 2.
	BL printf		    @ Print what is in Address1.

	LDR R0, =newLine            @ Prepare to print a newline.
	BL printf                   @ Print the newline.

	LDR R0, =lengthAddressOne   @ Prepare to print the length of Address1.
	MOV R1, R4                  @ Store the length of Address1
	BL printf		    @ Print the length of Address1.

	LDR R0, =showAddressTwo     @ Prepare to print the second address message, part 1.
	BL printf                   @ Print the second message, part 1.

    	LDR R0, =addressTwo         @ Prepare to print the second address message, part 2.
    	BL printf                   @ Print what is in Address2.

    	LDR R0, =newLine            @ Prepare to print a newline.
	BL printf                   @ Print the newline.

    	LDR R0, =lengthAddressTwo   @ Prepare to print the length of Address2.
    	MOV R1, R5                  @ Store the length of Address2.
    	BL printf                   @ Print the length of Address2.

	B getUserCopyDataLength	    @ Branch to the function that gets user input.
@__________________________________________________________________________________________________
setLengthLimit:
    	@ Set the smaller length value (between address1 and address2) in R4.
    	CMP R4, R5                  @ Compare R4 and R5.
    	MOVGT R4, R5                @ If R5 is less than R4, then put the value of R5 in R4.
    	B getUserCopyDataLength     @ Go to the next function.
@__________________________________________________________________________________________________
getUserCopyDataLength:
	LDR R0, =userLengthPromptOne	@ Prepare to print the first prompt for the user.
	BL printf			@ Print the first prompt for the user.

	LDR R0, =userLengthPromptTwo	@ Prepare to print the second prompt for the user.
	MOV R1, R4                      @ Store the length of Address1.
	BL printf			@ Print the second prompt for the user.

	@ Get the user’s input for the length to be copied.
	SUB SP, SP, #4			        @ Prepare to fetch the user’s input length.
	MOV R1, SP			        @ R1 now holds the stack pointer’s address.
	LDR R0, =userInputLength		@ R0 signals the data type of the input.
	BL scanf			        @ Get the user’s input from the console.
	LDR R1, [SP]			        @ Move the user’s input value into R1.
	MOV R6, R1			        @ The user’s input is now in R6.

	B checkLengthValidity	                @ Branch to the function to check the length’s validity.
@__________________________________________________________________________________________________
checkLengthValidity:
	@ Check that the length is not 0.
    	CMP R6, #0
    	BEQ userLengthTooSmall          @ Go to this function if R6 == 0

	@ Check that the length is not larger than the smaller string length, R4.
    	CMP R6, R4
    	BGT userLengthTooBig            @ Go to this function if R6 > R4

    	@ User's length is valid
    	B getUserCopyDataAddress        @ Go to the function to determine which address to copy.
@__________________________________________________________________________________________________
userLengthTooSmall:
	LDR R0, =lengthTooSmall		@ Prepare to print the error message for length too small.
	BL printf			@ Print the error message.
	B displayBeforeCopyData		@ Return to the function to get the user input length.
@__________________________________________________________________________________________________
userLengthTooBig:
	LDR R0, =lengthTooBig		@ Prepare to print the error message for length too big.
	BL printf			@ Print the error message.
	B displayBeforeCopyData		@ Return to the function to the the user input length.
@__________________________________________________________________________________________________
getUserCopyDataAddress:
    	LDR R0, =userAddressPromptOne   @ Prepare to print the prompt to indicate how to select address one.
    	BL printf                       @ Print the prompt.

    	LDR R0, =userAddressPromptTwo   @ Prepare to print the prompt to indicate how to select address two.
    	BL printf                       @ Print the prompt.

    	SUB SP, SP, #4			@ Prepare to fetch the user’s address to be copied.
	MOV R1, SP	                @ R1 now holds the stack pointer’s address.
	LDR R0, =userInputLength	@ R0 signals the data type of the input.
	BL scanf	                @ Get the user’s input from the console.
	LDR R1, [SP]		        @ Move the user’s input value into R1.
	MOV R7, R1                      @ The user's choice is stored in R7.

	CMP R7, #1                      @ If the user picks option 1,
	BEQ actualWorkOneSetup          @ go to the function that treats addressOne as address1.

	CMP R7, #2                      @ If the user picks option 2,
	BEQ actualWorkTwoSetup          @ go to the function that treats addressTwo as address1.

	B getUserCopyDataAddress        @ Return to the beginning of this function if the user enters an incorrect option.
@__________________________________________________________________________________________________
actualWorkOneSetup:
   	MOV R8, #0                      @ Use R8 as an up-counter.
    	LDR R5, =addressOne             @ Put the starting address of Address One in R5.
    	LDR R9, =addressTwo             @ Put the starting address of Address Two in R9.
    	B actualWork                    @ Go do the actual work.
@__________________________________________________________________________________________________
actualWorkTwoSetup:
    	MOV R8, #0                      @ Use R8 as an up-counter.
    	LDR R9, =addressOne             @ Put the starting address of Address One in R9.
    	LDR R5, =addressTwo             @ Put the starting address of Address Two in R5.
    	B actualWork                    @ Go do the actual work.
@__________________________________________________________________________________________________
actualWork:
    	CMP R8, R6                  @ If R8 is greater than or equal to R6
    	BGE displayChoice           @ Branch to the function that prepares to show the results of COPYDATA.

    	@ While R8 is less than R6, do the following:
    	@ R9 holds address2, and R5 holds address1.
    	LDRB R2, [R5], #1           @ Load the current character to be stored, then move the index over 1 byte.
    	STRB R2, [R9], #1           @ Store the character into address two, then move the index over 1 byte.
    	ADD R8, R8, #1              @ Increment the counter.
    	B actualWork                @ Loop to the beginning of the while loop.
@__________________________________________________________________________________________________
displayChoice:
    	CMP R7, #1                  @ If the user chose address one to be address1,
    	BEQ displayAfterCopyDataOne @ go to the corresponding print function.
    	B displayAfterCopyDataTwo   @ Else, go to the other print function.
@__________________________________________________________________________________________________
displayAfterCopyDataOne:
    	LDR R0, =taskCompleteOne    @ Prepare to print the first message on task completion.
    	BL printf                   @ Print the first message on task completion.

    	LDR R0, =taskCompleteTwo    @ Prepare to print the second message on task completion.
    	BL printf                   @ Print the second message on task completion.

    	@ Display the new string held in Address Two.
    	LDR R0, =addressTwo         @ Prepare to print the new message held in address two.
    	BL printf                   @ Print the new message held in address two.

    	LDR R0, =newLine            @ Prepare to print a newline. This makes the program work for some reason.
    	BL printf                   @ Print the new line.

    	B endProgram                @ End the program.
@__________________________________________________________________________________________________
displayAfterCopyDataTwo:
    	LDR R0, =taskCompleteOne    @ Prepare to print the first message on task completion.
    	BL printf                   @ Print the first message on task completion.

    	LDR R0, =taskCompleteTwo    @ Prepare to print the second message on task completion.
    	BL printf                   @ Print the second message on task completion.

    	@ Display the new string held in Address Two.
    	LDR R0, =addressOne         @ Prepare to print the new message held in address one.
    	BL printf                   @ Print the new message held in address one.

    	LDR R0, =newLine            @ Prepare to print a newline. This makes the program work for some reason.
    	BL printf                   @ Print the new line.

    	B endProgram                @ End the program.
@__________________________________________________________________________________________________
endProgram:
    	@ Operations to end the application.
    	MOV R0, #0
    	MOV R7, #1
    	SVC 0

    	.end
@ END OF PROGRAM
