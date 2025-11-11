section .data
	board: db 0,0,0,0,0,0,0,0,0
	current_player: db 1

	win: db "Player - wins", 0xA
	win_len: equ $-win

	instruct: db "Enter in a number 0-8",0xA
	instruct_len: equ $-instruct

	draw: db "Draw", 0xA
	draw_len: equ $-draw
	board_display: db "  -  |  -  |  -  ",0xA,"----------------",0xA,"  -  |  -  |  -  ",0xA,"----------------",0xA,"  -  |  -  |  -  ",0xA

	board_display_len: equ $ - board_display
section .bss
	buffer resb 10
section .text
global _start

_start:
	call update_board
	mov rax, 1
	mov rdi, 1
	mov rsi, board_display
	mov rdx, board_display_len
	syscall
	call check_win
	jmp userin
userin:
	mov rax,1
	mov rdi,1
	mov rsi,instruct
	mov rdx,instruct_len
	syscall

	mov rax,0
	mov rdi, 0
	mov rsi, buffer
	mov rdx,10
	syscall

	movzx rax,byte[buffer]
	sub rax, "0"
	cmp rax,0
	jl userin
	cmp rax,9
	jg userin

	mov rbx,rax
	cmp byte[board+rbx],0
	jne userin

	cmp byte[current_player],1
	je p1_turn

	cmp byte[current_player], 2
	je p2_turn
	jmp userin
p1_turn:
	mov byte [board+rbx], 1
	mov byte [current_player], 2
	jmp _start
p2_turn:
	mov byte [board+rbx], 2
	mov byte [current_player], 1
	jmp _start
update_board:
	mov rdi, 0
	call get_char
	mov [board_display +2], al

	mov rdi, 1
	call get_char
	mov [board_display +8], al

	mov rdi, 2
	call get_char
	mov [board_display +14], al

	mov rdi, 3
	call get_char
	mov [board_display +37], al

	mov rdi, 4
	call get_char
	mov [board_display + 43], al

	mov rdi, 5
	call get_char
	mov [board_display + 49], al

	mov rdi, 6
	call get_char
	mov [board_display + 72], al

	mov rdi, 7
	call get_char
	mov [board_display + 78], al

	mov rdi, 8
	call get_char
	mov [board_display +84], al

	ret
get_char:
	movzx rax, byte [board+rdi]
	cmp rax, 0
	je .empty
	cmp rax, 1
	je .player_x
	jmp .player_o
.empty:
	mov rax, "-"
	jmp .done
.player_x:
	mov rax, "X"
	jmp .done
.player_o:
	mov rax, "O"
.done:
	ret

check_win:
	mov rdi,0
	mov r8, 0
	mov r9, 0
	mov r10, 0
	call check_draw
	cmp r8,5
	je drawed
	call check_row_loop
	cmp r8,0
	jne .win_found
	call check_col_loop
	cmp r8,0
	jne .win_found
	call check_diagnalo
	cmp r8,0
	jne .win_found
	call check_diagnalt
	cmp r8,0
	jne .win_found
.win_found:
	cmp r8, 1
	je plone
	cmp r8, 2
	je ptone
check_diagnalo:
	movzx r8,byte [board]
	movzx r9,byte [board+4]
	movzx r10,byte [board+8]
	cmp r8,0
	je no_win
	cmp r8,r9
	jne no_win
	cmp r8,r10
	jne no_win
	ret
check_diagnalt:
	movzx r8,byte  [board+2]
	movzx r9,byte  [board+4]
	movzx r10,byte  [board+6]
	cmp r8, 0
	je no_win
	cmp r8,r9
	jne no_win
	cmp r8,r10
	jne no_win
	ret
check_draw:
	cmp byte [board + rdi],0
	jne .loop_draw
	ret
.loop_draw:
	inc rdi
	cmp rdi, 9
	jl check_draw
	mov r8,5
drawed:
	mov rax, 1
	mov rdi, 1
	mov rsi, draw
	mov rdx, draw_len
	syscall
	jmp exit
plone:
	mov byte[win+7], "1"
	jmp winner
ptone:
	mov byte[win+7], "2"
	jmp winner
check_row_loop:
	mov rcx,0
.check_row:
	mov rdi,rcx
	imul rdi, 3
	movzx r8,byte [board + rdi]
	movzx r9,byte [board + rdi+1]
	movzx r10,byte [board + rdi+2]

	cmp r8, 0
	je .next_row
	cmp r8,r9
	jne .next_row
	cmp r8,r10
	jne .next_row
	ret

.next_row:
	inc rcx
	cmp rcx, 3
	jl .check_row
	mov r8,0
	ret
check_col_loop:
	mov rcx,0
.check_col:
	mov rdi,rcx
	movzx r8,byte [board + rdi]
	movzx r9,byte [board + rdi+3]
	movzx r10,byte [board+rdi+6]

	cmp r8, 0
	je .next_col
	cmp r8, r9
	jne .next_col
	cmp r9, r10
	jne .next_col
	ret
.next_col:
	inc rcx
	cmp rcx, 3
	jl .check_col
	mov r8,0
	ret
winner:
	mov rax, 1
	mov rdi, 1
	mov rsi, win
	mov rdx, win_len
	syscall
	jmp exit
no_win:
	mov r8, 0
	ret

exit:
	mov rax, 60
	xor rdi, rdi
	syscall
