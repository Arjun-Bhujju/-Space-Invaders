BITS 16
ORG 100h  ; COM file format

; Define game variables
%define PLAYER_X 38
%define PLAYER_Y 22
%define BULLET_Y 21
%define ENEMY_START_Y 5

section .data
    player_x db PLAYER_X  ; Player position
    bullet_x db 0
    bullet_y db 0
    bullet_active db 0    ; 0 = no bullet, 1 = active
    enemy_x db 10
    enemy_y db ENEMY_START_Y

section .text
    ; Game Entry
    start:
        call clear_screen
        call draw_player
        call draw_enemy

    game_loop:
        call get_input
        call move_enemy
        call update_bullet
        call check_collision
        jmp game_loop

    ; Clear screen
    clear_screen:
        mov ah, 06h
        mov al, 0
        mov cx, 0
        mov dx, 184Fh
        mov bh, 07h
        int 10h
        ret

    ; Draw player
    draw_player:
        mov ah, 02h
        mov dl, [player_x]
        mov dh, PLAYER_Y
        mov bh, 0
        int 10h
        mov ah, 09h
        mov al, '<'
        mov bl, 0Fh
        int 10h
        ret

    ; Draw enemy
    draw_enemy:
        mov ah, 02h
        mov dl, [enemy_x]
        mov dh, [enemy_y]
        mov bh, 0
        int 10h
        mov ah, 09h
        mov al, 'O'
        mov bl, 0Ch
        int 10h
        ret

    ; Get player input
    get_input:
        mov ah, 01h
        int 16h
        jz no_key
        mov ah, 00h
        int 16h

        cmp al, 'a'
        je move_left
        cmp al, 'd'
        je move_right
        cmp al, ' '
        je shoot_bullet
        jmp no_key

    move_left:
        cmp byte [player_x], 1
        jle no_key
        dec byte [player_x]
        call draw_player
        jmp no_key

    move_right:
        cmp byte [player_x], 75
        jge no_key
        inc byte [player_x]
        call draw_player
        jmp no_key

    shoot_bullet:
        cmp byte [bullet_active], 1
        je no_key
        mov byte [bullet_active], 1
        mov byte [bullet_x], [player_x]
        mov byte [bullet_y], BULLET_Y
        jmp no_key

    ; Move bullet
    update_bullet:
        cmp byte [bullet_active], 0
        je done_bullet
        dec byte [bullet_y]
        call draw_bullet
        cmp byte [bullet_y], 1
        jne done_bullet
        mov byte [bullet_active], 0
    done_bullet:
        ret

    draw_bullet:
        mov ah, 02h
        mov dl, [bullet_x]
        mov dh, [bullet_y]
        mov bh, 0
        int 10h
        mov ah, 09h
        mov al, '|'
        mov bl, 0Fh
        int 10h
        ret

    ; Move enemy
    move_enemy:
        inc byte [enemy_y]
        call draw_enemy
        cmp byte [enemy_y], 23
        jne done_enemy
        mov byte [enemy_y], ENEMY_START_Y
    done_enemy:
        ret

    ; Check collision
    check_collision:
        cmp byte [bullet_active], 1
        jne done_collision
        cmp byte [bullet_x], [enemy_x]
        jne done_collision
        cmp byte [bullet_y], [enemy_y]
        jne done_collision
        mov byte [bullet_active], 0
        mov byte [enemy_y], ENEMY_START_Y
    done_collision:
        ret

no_key:
    ret

exit:
    mov ax, 4C00h
    int 21h
