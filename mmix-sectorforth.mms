%                             jmp 0x0050:start
%                             ╭────────┬───────────────────────────────────────────────────────────
At        TETRA 0             │0000    │@ - Fetch memory at addr
%                             │ 1      │(addr -- x)
%                             │"@"     │ 
%                             │pop bx
%                             │push word [bx]
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │! - Store x at addr
%                             │ 1      │(x addr --)
%                             │"!"     │
%                             │pop bx
%                             │pop word [bx]
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │sp@ - Get current data stack pointer
%                             │ 3      │(-- addr)       
%                             │"sp@"   │
%                             │push sp
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │rp@ - Get current return stack pointer
%                             │ 3      │(-- addr)       
%                             │"rp@"   │
%                             │push bp
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │0= -1 if top of stack is 0, 0 otherwise
%                             │ 2      │(x -- f)        
%                             │"0="    │
%                             │pop ax
%                             │test ax,ax
%                             │setnz al                ; AL=0  if ZF=1, else AL=1
%                             │dec ax                  ; AL=ff if AL=0, else AL=0
%                             │cbw                     ; AH=AL
%                             │push ax
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │+ Add the two values at the top of the stack
%                             │ 1      │(x1 x2 -- n)    
%                             │"+"     │
%                             │pop bx
%                             │pop ax
%                             │add ax,bx
%                             │push ax
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │nand - NAND the two values at the top of the stack
%                             │ 4      │(x1 x2 -- n)
%                             │"nand"  │
%                             │pop bx
%                             │pop ax
%                             │and ax,bx
%                             │not ax
%                             │push ax
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │exit - Pop return stack and jump to that address
%                             │ 4      │(r:addr --)
%                             │"exit"  │
%                             │xchg sp,bp              ; swap SP and BP, SP controls return stack
%                             │pop si                  ; pop address to next word
%                             │xchg sp,bp              ; restore SP and BP
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │tib - Push TIB address onto stack
%                             │ 3      │(-- TIB)
%                             │"tib"   │
%                             │push word TIB
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │state - Push current state onto stack (0=interp, 1=compile)
%                             │ 5      │(-- state)
%                             │"state" │
%                             │push word STATE
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │>in - Push current read offset from TIB onto stack
%                             │ 3      │(-- a)
%                             │">in"   │
%                             │push word TOIN
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                               lodsw                   ; load next word's address into AX
%                              jmp ax                  ; jump directly to it
%                              dw link
%                              db %3+%%len
%                              db %1
%                              push word HERE
%                              NEXT
%                               dw start_HERE
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │latest - Push address of last word in dictionary onto stack
%                             │ 6      │
%                             │"latest"│
%                             │push word LATEST
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                              dw word_SEMICOLON       ; initialized to last word in dictionary
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │key - Push the next character onto the stack
%                             │ 3      │(-- char)
%                             │"key"   │
%                             │mov ah,0
%                             │int 0x16
%                             │push ax
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │emit - Write a character to the screen
%                             │ 4      │(char --)
%                             │"emit"  │
%                             │pop ax
%                             │call writechar
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │: - Define a new word
%                             │ 1      │(--)
%                             │":"     │
%                             │call token              ; parse word from input
%                             │push si
%                             │mov si,di               ; set parsed word as string copy source
%                             │mov di,[HERE]           ; set current value of HERE as destination
%                             │mov ax,[LATEST]         ; get pointer to latest defined word
%                             │mov [LATEST],di         ; update LATEST to new word being defined
%                             │stosw                   ; link pointer
%                             │mov al,cl
%                             │or al,F_HIDDEN          ; hide new word while it's being defined
%                             │stosb                   ; word length
%                             │rep movsb               ; word name
%                             │mov ax,0x26ff
%                             │stosw                   ; compile near jump, absolute indirect...
%                             │mov ax,DOCOL.addr
%                             │stosw                   ; ...to DOCOL
%                             │mov [HERE],di           ; update HERE to next free position
%                             │mov byte [STATE],1      ; switch to compilation state
%                             │pop si
%                             │NEXT
%                             ╰────────────────────────────────────────────────────────────────────
%     
%                              xchg sp,bp              ; swap SP and BP, SP controls return stack
%                              push si                 ; push current "instruction pointer"
%                              xchg sp,bp              ; restore SP and BP
%                              add ax,4                ; skip word's code field
%                              mov si,ax               ; point "instruction pointer" to word body
%                              NEXT                    ; start executing the word
%     
%                              dw DOCOL
%     
%                             ╭────────┬───────────────────────────────────────────────────────────
%                             │        │; - End the definition of a new word
%                             │ 1      │(--)
%                             │";"     │
%                             │mov bx,[LATEST]
%                             │and byte [bx+2],~F_HIDDEN       ; reveal new word
%                             │mov byte [STATE],0      ; switch to interpretation state
%                             │mov ax,EXIT             ; prepare to compile EXIT
%                             │
%    C O M P I L E            │
%                             │
%                       ┌────►│mov di,[HERE]           
%                       │     │stosw                   ; compile contents of AX to HERE
%                       │     │mov [HERE],di           ; advance HERE to next cell
%                       │     │NEXT
%                       │     ╰────────────────────────────────────────────────────────────────────
%                       │        
%    S T A R T          │        
%        LOC #100       │       
%                       │      cld                     ; clear direction flag
%                       │      push cs                 ; Set up segment registers to point to 
%                       │      push cs                 ;   the same segment as CS.
%                       │      push cs
%                       │      pop ds
%                       │      pop es
%                       │      pop ss
Main     JMP Init       │    ┌─jmp init
%                       │    │
%                       │    │
%    E R R O R          │    │
%                       │    │
%                       │   ┌│►mov ax,0x0921           ; write '!'
%                       │   ││ mov bx,0x0004           ; black background, red text
%                       │   ││ mov cx,2                ; twice
%                       │   ││ int 0x10
%                       │   ││
%    I N I T            │   ││
Init     SWYM           │   ││
%                       │   │└►mov bp,RP0              ; BP is the return stack pointer
%                       │   │  mov sp,SP0              ; SP is the data stack pointer
%                       │   │  mov al,0                ; Fill TIB with zeros, and set STATE
%                       │   │  mov cx,STATE+4          ;   and >IN to 0
%                       │   │  mov di,TIB
%                       │   │  rep stosb
%                       │   │    
%    I N T E R P R E T  │   │  ; Words are read one at time and searched for in the dictionary.
%                       │   │  ; If a word is found in the dictionary, it is either interpreted
%                       │   │  ; (i.e. executed) or compiled, depending on the current state and
%                       │   │  ; the word's IMMEDIATE flag.
%                       │   │    
%                       │   │  ; When a word is not found, the state of the interpreter is reset:
%                       │   │  ; the data and return stacks are cleared as well as the terminal
%                       │   │  ; input buffer, and the interpreter goes into interpretation mode.
%                       │   │    
%                       │┌──│──call token              ; parse word from input
%                       ││  │  mov bx,[LATEST]         ; start searching for it in the dictionary
%                       ││┌─│─►test bx,bx              ; zero?  (.1:)
%                       │││ └──jz error                ; not found, reset interpreter state
%                       │││    mov si,bx
%                       │││    lodsw                   ; skip link
%                       │││    lodsb                   ; read flags+length
%                       │││    mov dl,al               ; save those for later use
%                       │││    test al,F_HIDDEN        ; entry hidden?
%                       │││ ┌──jnz .2                  ; if so, skip it
%                       │││ │  and al,LENMASK          ; mask out flags
%                       │││ │  cmp al,cl               ; same length?
%                       │││ ├──jne .2                  ; if not, skip entry
%                       │││ │  push cx
%                       │││ │  push di
%                       │││ │  repe cmpsb              ; compare strings
%                       │││ │  pop di
%                       │││ │  pop cx
%                       │││┌│──je .3                   ; if equal, search is over
%                       ││││└─►mov bx,[bx]             ; skip to next entry (.2:)
%                       ││└│───jmp .1                  ; try again
%                       ││ └──►mov ax,si               ; after comparison, SI points to code field
%                       ││     mov si,.loop            ; set SI so NEXT loops back to interpreter
%                       ││     
%                       ││     ; Decide whether to interpret or compile the word. The IMMEDIATE
%                       ││     ; flag is located in the most significant bit of the flags+length
%                       ││     ; byte. STATE can only be 0 or 1. A word is only compiled when 
%                       ││     ; the result of ORing these two values together is 1. Decrementing
%                       ││     ; that result sets the zero flag for a conditional jump.
%                       ││     
%                       ││     and dl,F_IMMEDIATE      ; isolate IMMEDIATE flag
%                       ││     or dl,[STATE]           ; OR with state
%                       ││     dec dl                  ; decrement
%                       └│─────jz compile              ; if result is zero, compile
%                        │     jmp ax                  ; otherwise, interpret (execute) the word
%                        │     
%                        │     dw interpreter          ; (.loop:)
%                        │    
%    T O K E N           │     ; Parse a word from the terminal input buffer and return its
%                        │     ; address and length in DI and CX, respectively.
%                        │     
%                        │     ; If after skipping spaces a 0 is found, more input is read from
%                        │     ; the keyboard into the terminal input buffer until return is
%                        │     ; pressed, at which point execution jumps back to the beginning of
%                        │     
%                        │     ; Before reading input from the keyboard, a CRLF is emitted so
%                        │     ; the user can enter input on a fresh, blank line on the screen.
%                        │     
%                        ├────►mov di,[TOIN]           ; starting at the current position in TIB
%                        │     mov cx,-1               ; search "indefinitely"
%                        │     mov al,32               ; for a character that's not a space
%                        │     repe scasb
%                        │     dec di                  ; result is one byte past found character
%                        │     cmp byte [di],0         ; found a 0?
%                        │   ┌─je .readline            ; if so, read more input
%                        │   │ mov cx,-1               ; search "indefinitely" again
%                        │   │ repne scasb             ; this time, for a space
%                        │   │ dec di                  ; adjust DI again
%                        │   │ mov [TOIN],di           ; update current position in TIB
%                        │   │ not cx                  ; after ones' complement, CX=length+1
%                        │   │ dec cx                  ; adjust CX to correct length
%                        │   │ sub di,cx               ; point to start of parsed word
%                        │   │ ret
%                        │   │ 
%    R E A D L I N E     │   │ 
%                        │   │   
%                        │   └►mov al,13
%                        │┌────call writechar          ; CR
%                        ││    mov al,10
%                        │├────call writechar          ; LF
%                        ││    mov di,TIB              ; read into TIB
%                        ││ ┌─►mov ah,0                ; wait until a key is pressed (.1:)
%                        ││ │  int 0x16
%                        ││ │  cmp al,13               ; return pressed?
%                        ││┌│──je .3                   ; if so, finish reading
%                        ││││  cmp al,8                ; backspace pressed?
%                        ││││┌─je .2                   ; if so, erase character
%                        │├│││─call writechar          ; otherwise, write character to screen
%                        │││││ stosb                   ; store character in TIB
%                        │││├│─jmp .1                  ; keep reading
%                        ││││└►cmp di,TIB              ; start of TIB? (.2:)
%                        │││├──je .1                   ; if so, there's nothing to erase
%                        ││││  dec di                  ; erase character in TIB
%                        │├││──call writechar          ; move cursor back one character
%                        ││││  mov ax,0x0a20           ; erase without moving cursor
%                        ││││  mov cx,1
%                        ││││  int 0x10                ; (BH already set to 0 by writechar)
%                        │││└──jmp .1                  ; keep reading
%                        ││└──►mov ax,0x0020           ; (.3:)
%                        ││    stosw                   ; put final delimiter and 0 in TIB
%                        │├────call writechar          ; write a space between user input and
%                        ││    mov word [TOIN],0       ; point >IN to start of TIB
%                        └│────jmp token               ; try parsing a word again
%                         │    
%    W R I T E C H A R    │
%                         │    ; writechar writes a character to the screen. It uses INT 10/AH=0e
%                         │    ; to perform teletype output, writing the character, updating the
%                         │    ; cursor, and scrolling the screen, all in one go. Writing
%                         │    ; backspace using the BIOS only moves the cursor backwards within
%                         │    ; a line, but does not move it back to the previous line.
%                         │    ; writechar addresses that.
%                         │    
%                         └───►push ax                 ; INT 10h/AH=03h clobbers AX in some BIOSes
%                              mov bh,0                ; video page 0 for all BIOS calls
%                              mov ah,3                ; get cursor position (DH=row, DL=column)
%                              int 0x10
%                              pop ax                  ; restore AX
%                              mov ah,0x0e             ; teletype output
%                              mov bl,0x7              ; black background, light grey text
%                              int 0x10
%                              cmp al,8                ; backspace?
%                           ┌──jne .1                  ; if not, nothing else to do
%                           │  test dl,dl              ; was cursor in first column?
%                           ├──jnz .1                  ; if not, nothing else to do
%                           │  mov ah,2                ; move cursor
%                           │  mov dl,79               ; to last column
%                           │  dec dh                  ; of previous row
%                           │  int 0x10
%                           └─►ret                     ; (.1:)
%     
%                              db 0x55, 0xaa
