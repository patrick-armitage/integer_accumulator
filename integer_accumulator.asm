TITLE Integer Accumulator

; Author:              Patrick Armitage
; Date:                02/04/2016
; Description: A MASM program which receives user input of multiple integers
;              within the range of -1 to -100, as many entries as the user 
;              desires, then finds the sum and average of all the entries, 
;              prints the results, and gives a personal parting message.

INCLUDE Irvine32.inc

.data
remmsg      BYTE  "Remainder = ",0
authorname  BYTE  "Patrick Armitage",0
ec_desc     BYTE  "**EC: Numbers the lines during user input.",0
intro_1     BYTE  "Welcome to the Integer Accumulator by ",0
prompt_1    BYTE  "What is your name? ",0
username    BYTE  16 DUP(0)   ; user enters--must be one more than string size
intro_2     BYTE  "Hello, ",0
intro_3     BYTE  "Please enter numbers in [-100, -1]",0dh,0ah
            BYTE  "Enter a non-negative number when you are finished to see the results.",0
prompt_2    BYTE  "Enter number ",0
colon       BYTE  ": ",0
outofrange  BYTE  "Out of range.  Enter a number greater than -100.",0
LOWERLIMIT  EQU   -100  ; lowest valid number user is allowed to enter
curr_num    DWORD ?   ; user enters
curr_total  DWORD 0   ; start with zero and add each number to total
num_terms   DWORD 0   ; increment this each time a term is entered
no_entries  BYTE  "It seems you haven't entered any negative numbers!",0
terms_msg_1 BYTE  "You entered ",0
terms_msg_2 BYTE  " valid numbers.",0
sum_msg     BYTE  "The sum of your valid numbers is ",0
average_msg BYTE  "The rounded average is ",0
average     DWORD ?  ; must be calculated
remainder   DWORD 0  ; start at zero for comparison later on
goodbye_1   BYTE  "Thank you for playing Integer Accumulator!  "
            BYTE  "It's been a pleasure to meet you, ",0
period      BYTE  ".",0

.code
main PROC

;########## INTRODUCTION
; Introduce this program
  mov   edx, OFFSET intro_1
  call  WriteString
  mov   edx, OFFSET authorname
  call  WriteString
  call  CrLf
  mov   edx, OFFSET ec_desc
  call  WriteString
  call  CrLf

; Prompt user to enter username
  mov   edx, OFFSET prompt_1
  call  WriteString
  mov   ecx, 15               ; string size allowed
  mov   edx, OFFSET username  ; mov string to edx so ReadString can write to it
  call  ReadString
  mov   edx, OFFSET intro_2
  call  WriteString
  mov   edx, OFFSET username
  call  WriteString
  call  CrLf
  call  CrLf

;########## GET TERMS
; Explain the rules of entering terms and ask for a term
  mov   edx, OFFSET intro_3
  call  WriteString
  call  CrLf
terms:
  mov   edx, OFFSET prompt_2
  call  WriteString
  mov   eax, num_terms
  add   eax, 1             ; we add 1 to num terms since we haven't incremented
                           ; it yet--that comes at the end of the loop
  call  WriteDec
  mov   edx, OFFSET colon
  call  WriteString
  call  ReadInt
  mov   curr_num, eax      ; save the current number
  mov   eax, curr_num
  cmp   eax, LOWERLIMIT    ; validates curr_num is >= -100
  jl    invalid
  cmp   eax, -1
  jg    end_terms          ; if number entered is > -1, jump to end terms
  mov   ebx, curr_total
  add   eax, ebx           ; add curr_num to the total
  mov   curr_total, eax
  mov   eax, num_terms
  add   eax, 1  ; increment by 1 each time a term is added
  mov   num_terms, eax
  jmp   terms   ; if this line is reached, then manually jump back to terms

; Print user input invalid message, then jump back to terms (post test loop)
invalid:
  mov   edx, OFFSET outofrange
  call  WriteString
  call  CrLf
  jmp   terms      ; since they entered too low a number, jump back to the loop

; We jump here once the user has entered a positive number to determine whether
; to end early (sum == 0) or display the results
end_terms:
  mov   eax, curr_total
  cmp   eax, 0
  jl    display_results ; if the jump does not occur, we print a special message
                        ; indicating that the user has ended the program early
                        ; without any terms that are valid
  mov   edx, OFFSET no_entries
  call  WriteString
  call  CrLf
  jmp   ending

;########## DISPLAY RESULTS
; Calculate and display the sum and rounded average of the numbers
display_results:
  mov   edx, OFFSET terms_msg_1
  call  WriteString
  mov   eax, num_terms         ; first we write the number of terms user entered
  call  WriteDec
  mov   edx, OFFSET terms_msg_2
  call  WriteString
  call  CrLf
  mov   edx, OFFSET sum_msg
  call  WriteString
  mov   eax, curr_total        ; then we write the sum of the terms
  call  WriteInt               ; use WriteInt to preserve integer sign
  call  CrLf
  mov   edx, 0 ; store 0 in edx so that when division is performed, it has room
  mov   eax, curr_total
  cdq          ; convert eax to quadword to allow for signed divison
  mov   ebx, num_terms
  idiv  ebx    ; use idiv for signed integers
  mov   average, eax
  mov   remainder, edx
  mov   eax, remainder
  cmp   eax, 0
  je    write_average    ; if remainder still equals default of 0, skip ahead
  mov   eax, remainder
  mov   ebx, -2
  mul   ebx      ; multiply remainder by 2 to compare it to num_terms, which is
                 ; the original divisor.  Since remainder is a negative number,
                 ; we must multiply by -2 to make it positive.  The idea in 
                 ; comparing the two is best illustrated in an example: if the
                 ; original divisor (num terms) is 5, and the remainder is 3,
                 ; then 3 * 2 = 6, and 6 > 5, therefore we round up.  If in this
                 ; example the remainder is only 2, then 2 * 2 = 4, and 4 < 5,
                 ; therefore we round down.
  mov   remainder, eax
  cmp   eax, num_terms
  jge   increase_average
  jmp   write_average
increase_average:
  mov   eax, average
  sub   eax, 1         ; we increase it by -1 through rounding the remainder up
  mov   average, eax
write_average:
  mov   edx, OFFSET average_msg
  call  WriteString
  mov   eax, average
  call  WriteInt
  call  CrLf

;########## GOODBYE
; Print parting message to user
ending:
  call  CrLf
  mov   edx, OFFSET goodbye_1
  call  WriteString
  mov   edx, OFFSET username  ; say goodbye to the user personally
  call  WriteString
  mov   edx, OFFSET period
  call  WriteString
  call  CrLf

  exit  ; exit to operating system
main ENDP

END main
