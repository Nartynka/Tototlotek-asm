section .bss
 var1 resb 4
 input resb 4
 help resb 4
 digitSpace resb 100
 digitSpacePos resb 8

section .data
 msg db "========================================",0x0A,0x09,0x09,"***TOTOLOTEK***",0x0A,0x09,"Sprawdz czy szczescie ci dzis dopisze!",0x0A,"========================================",0x0A
 msg2 db "Maszyna losujaca wylosowala 1 liczbe w przedziale 1-34",0x0A,"Sprobuj ja odgadnac. Uwaga! Masz tylko jedna szanse!",0x0A
 msg3 db "Podaj liczbe: "
 msgL equ $-msg
 win db "***BRAWO! Wygrales***",0x0A
 winL equ $-win
 lose db "Niestety, szczescie ci nie dopisuje :(",0x0A
 loseL equ $-lose
 testt db "1234567890",0x0A

section .text
 global _start

_start:
;get time
 mov rax, 96
 lea rdi, [rsp - 16]
 xor esi, esi
 syscall
;time in ms
 mov ecx, 1000
 mov rax, [rdi + 8]
 xor edx, edx
 div rcx
 mov rdx, [rdi]
 imul rdx, rcx
 add rax, rdx

;time in ms % 34 = random number in [var1]
 xor rdx, rdx
 mov rax, rax
 mov rbp, 34
 div rbp
 add rdx, 1
 mov [var1], edx

;print random number as ascii characters
 mov eax, [var1]
 xor edi, edi
 call _printRAX

;print msg
 mov  edx,msgL
 mov  ecx,msg
 mov  ebx,1
 mov  eax,4
 int  80h


;get user input
 mov eax, 3
 mov edx, 0
 mov edx, 2
 mov ecx, input
 int 80h

;convert input (string) to int
 mov rdi, input
 call string_to_int

;compare if user guesed correctly
;eax = input (int)
;var1 = random

cmp eax, [var1]

je printWin
jne printLose

;end program
 mov rax, 60
 mov rdi, 0
 syscall

printWin:
 mov  edx,winL
 mov  ecx,win
 mov  ebx,1
 mov  eax,4
 int  80h

;end program
 mov rax, 60
 mov rdi, 0
 syscall


printLose:
 mov  edx,loseL
 mov  ecx,lose
 mov  ebx,1
 mov  eax,4
 int  80h

;end program
 mov rax, 60
 mov rdi, 0
 syscall




; args: pointer in RDI to ASCII decimal digits, terminated by a non-digit
; clobbers: ECX
; returns: EAX = atoi(RDI)  (base 10 unsigned)
;          RDI = pointer to first non-digit
string_to_int:
 movzx eax, byte [rdi]    ; start with the first digit
 sub eax, '0'           ; convert from ASCII to number
 cmp al, 9              ; check that it's a decimal digit [0..9]
 jbe .loop_entry        ; too low -> wraps to high value, fails unsigned compare check

 ; else: bad first digit: return 0
 xor eax,eax
 ret

; rotate the loop so we can put the JCC at the bottom where it belongs
; but still check the digit before messing up our total
.next_digit:                  ; do {
 lea eax, [rax*4 + rax]    ; total *= 5
 lea eax, [rax*2 + rcx]    ; total = (total*5)*2 + digit
; imul eax, 10  / add eax, ecx
.loop_entry:
 inc rdi
 movzx ecx, byte [rdi]
 sub ecx, '0'
 cmp ecx, 9
 jbe .next_digit        ; } while( digit <= 9 )

 ret                ; return with total in eax



_printRAX:
 mov rcx, digitSpace
 mov rbx, 10
 mov [rcx], rbx
 inc rcx
 mov [digitSpacePos], rcx

_printRAXLoop:
 mov rdx, 0
 mov rbx, 10
 div rbx
 push rax
 add rdx, 48
 mov rcx, [digitSpacePos]
 mov [rcx], dl
 inc rcx
 mov [digitSpacePos], rcx
 pop rax
 cmp rax, 0
 jne _printRAXLoop

_printRAXLoop2:
 mov rcx, [digitSpacePos]

 ;print rcx
 mov rax, 1
 mov rdi, 1
 mov rsi, rcx
 mov rdx, 1
 syscall

 mov rcx, [digitSpacePos]
 dec rcx
 mov [digitSpacePos], rcx
 cmp rcx, digitSpace
 jge _printRAXLoop2
 ret
