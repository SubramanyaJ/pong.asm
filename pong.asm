format ELF64

section '.text' executable
public _start
extrn _exit
extrn printf
extrn InitWindow
extrn WindowShouldClose
extrn CloseWindow
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn IsKeyPressed
extrn IsKeyDown
extrn DrawRectangleV
extrn SetTargetFPS
extrn DrawRectangleLines
extrn DrawCircleV
extrn DrawText
extrn DrawLineV
extrn GetScreenWidth
extrn GetScreenHeight
.__print:
 	movss xmm0, [ball]
 	cvtss2sd xmm0, xmm0
	movss xmm1, [bounding_box]
 	cvtss2sd xmm1, xmm1
 	mov rdi, fmt
 	mov rax, 2
 	call printf

_start:

	mov rdi, [window_dims]
	mov rsi, [window_dims + 4]
	mov rdx, window_title
	call InitWindow

	mov rdi, 165
	call SetTargetFPS

	.__draw_loop:
	call WindowShouldClose
	test rax, rax
	jnz .__exit_drawing

	;; exit condition : KEY_ESCAPE
	mov rdi, 256
	call IsKeyPressed
	test rax, rax
	jz .__past_exit_check
	jmp .__exit_drawing			

.__past_exit_check:
; update ball position x
    movss xmm0, [ball]
	addss xmm0, [ball_velocity]
	ucomiss xmm0, [bounding_box]
	jb .__handle_left
	ucomiss xmm0, [bounding_box + 8]
	ja .__handle_right
	movss [ball], xmm0
	jmp .__past_x_handler

.__handle_left:
	movss xmm1, [left_paddle + 4]
	movss xmm2, [left_paddle + 12]
	addss xmm2, xmm1

	movss xmm0, [ball + 4]
	ucomiss xmm0, xmm1
 	jb .__exit_drawing

	ucomiss xmm0, xmm2
	ja .__exit_drawing

	movss xmm0, [bounding_box]
	movss [ball], xmm0
	movss xmm0, [ball_velocity]
	mulss xmm0, [minus_one]
	movss [ball_velocity], xmm0
	jmp .__past_x_handler

.__handle_right:
	movss xmm1, [right_paddle + 4]
	movss xmm2, [right_paddle + 12]
	addss xmm2, xmm1

	movss xmm0, [ball + 4]
	ucomiss xmm0, xmm1
	jb .__exit_drawing

	ucomiss xmm0, xmm2
	ja .__exit_drawing

	movss xmm0, [bounding_box + 8]
	movss [ball], xmm0
	movss xmm0, [ball_velocity]
	mulss xmm0, [minus_one]
	movss [ball_velocity], xmm0
	jmp .__past_x_handler

.__past_x_handler:

; update ball position y
    movss xmm0, [ball + 4]
	addss xmm0, [ball_velocity + 4]
	ucomiss xmm0, [bounding_box + 4]
	jb .__handle_top
	ucomiss xmm0, [bounding_box + 12]
	ja .__handle_bottom
	movss [ball + 4], xmm0
	jmp .__past_y_handler

.__handle_top:
	movss xmm0, [bounding_box + 4]
	movss [ball + 4], xmm0
	movss xmm0, [ball_velocity + 4]
	mulss xmm0, [minus_one]
	movss [ball_velocity + 4], xmm0
	jmp .__past_y_handler

.__handle_bottom:
	movss xmm0, [bounding_box + 12]
	movss [ball + 4], xmm0
	movss xmm0, [ball_velocity + 4]
	mulss xmm0, [minus_one]
	movss [ball_velocity + 4], xmm0
	jmp .__past_y_handler

.__past_y_handler:

.__test_down:
	mov rdi, 264
	call IsKeyDown
	cmp rax, 5071104
	je .__test_up
	movss xmm0, [right_paddle + 4]
	addss xmm0, [paddle_speed]
	ucomiss xmm0, [paddle_bottom]
	jae .__reset_down
	movss [right_paddle + 4], xmm0
	jmp .__test_up
.__reset_down:
	movss xmm0, [paddle_bottom]
	movss [right_paddle + 4], xmm0

.__test_up:
	mov rdi, 265
	call IsKeyDown
	cmp rax, 5071104
	je .__test_s
	movss xmm0, [right_paddle + 4]
	subss xmm0, [paddle_speed]
	ucomiss xmm0, [paddle_top]
	jbe .__reset_up
	movss [right_paddle + 4], xmm0
	jmp .__test_s
.__reset_up:
	movss xmm0, [paddle_top]
	movss [right_paddle + 4], xmm0

.__test_s:
	mov rdi, 83
	call IsKeyDown
	cmp rax, 5071104
	je .__test_w
	movss xmm0, [left_paddle + 4]
	addss xmm0, [paddle_speed]
	ucomiss xmm0, [paddle_bottom]
	jae .__reset_s
	movss [left_paddle + 4], xmm0
	jmp .__test_w
.__reset_s:
	movss xmm0, [paddle_bottom]
	movss [left_paddle + 4], xmm0

.__test_w:
	mov rdi, 87
	call IsKeyDown
	cmp rax, 5071104
	je .__begin_drawing
	movss xmm0, [left_paddle + 4]
	subss xmm0, [paddle_speed]
	ucomiss xmm0, [paddle_top]
	jbe .__reset_w
	movss [left_paddle + 4], xmm0
	jmp .__begin_drawing
.__reset_w:
	movss xmm0, [paddle_top]
	movss [left_paddle + 4], xmm0

.__begin_drawing:

	call GetScreenWidth
	mov [window_dims], rax
	call GetScreenHeight
	mov [window_dims + 4], rax


	call BeginDrawing
	mov edi, 0x30012005
	call ClearBackground

	; Calculate middle_top and middle_bottom
;	mov rax, [window_dims]
;	xor rdx, rdx
;	mov rcx, 2
;	div rcx
;	sub rax, 1
;	mov [middle_top], rax

	mov rdi, fmt
	mov rsi, [window_dims]
	mov rdx, [window_dims + 4]
	call printf

	movq xmm0, [middle_top]
	movq xmm1, [middle_bottom]
	mov rdi, 0xFFCCCCCC
	call DrawRectangleV

	;; Bounding Box
	call DrawRectangleV

	movq xmm0, [left_paddle]
	movq xmm1, [left_paddle + 8]
	mov rdi, 0xFF0000FF
	call DrawRectangleV

	movq xmm0, [right_paddle]
	movq xmm1, [right_paddle + 8]
	mov rdi, 0xFFFF0000
	call DrawRectangleV

	movq xmm0, [ball]
	movss xmm1, [ball + 8]
	mov rdi, 0xFF800080
	call DrawCircleV

	call EndDrawing
	jmp .__draw_loop

.__exit_drawing:
	call CloseWindow
	mov rdi, 0
	call _exit

section '.data' writeable
window_title: db "pong", 0
fmt: db "| %d %d |", 10, 0

window_dims:
	dd 800
	dd 600
bounding_box:
	dd 5.0
	dd 5.0
	dd 795.0
	dd 595.0
left_paddle:
	dd 10.0
	dd 10.0
	dd 10.0
	dd 100.0
right_paddle:
	dd 785.0
	dd 10.0
	dd 10.0
	dd 100.0
paddle_speed:
	dd 8.0
paddle_top:
	dd 10.0
paddle_bottom:
	dd 490.0
ball:
	dd 400.0
	dd 300.0
	dd 8.0
ball_velocity:
	dd 2.0
	dd 2.0
	dd 0.0
minus_one:
	dd -1.0
score_r:
	dd 0
score_l:
	dd 0
middle_top:
	dd 399.5
	dd 000.0
middle_bottom:
	dd 1.0
	dd 600.0
screen_size:
	dd 0.0
	dd 0.0