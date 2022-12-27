    0000 EA[1E01]5000        jmp 0x0050:start
                            ╭────────┬───────────────────────────────────────────────────────────
    0005 0000               │0000    │@ - Fetch memory at addr
    0007 01                 │ 1      │(addr -- x)
    0008 40                 │"@"     │ 
    0009 5B                 │pop bx
    000A FF37               │push word [bx]
    000C EB76               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    000E [0500]             │        │! - Store x at addr
    0010 01                 │ 1      │(x addr --)
    0011 21                 │"!"     │
    0012 5B                 │pop bx
    0013 8F07               │pop word [bx]
    0015 EB6D               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0017 [0E00]             │        │sp@ - Get current data stack pointer
    0019 03                 │ 3      │(-- addr)       
    001A 737040             │"sp@"   │
    001D 54                 │push sp
    001E EB64               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0020 [1700]             │        │rp@ - Get current return stack pointer
    0022 03                 │ 3      │(-- addr)       
    0023 727040             │"rp@"   │
    0026 55                 │push bp
    0027 EB5B               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0029 [2000]             │        │0= -1 if top of stack is 0, 0 otherwise
    002B 02                 │ 2      │(x -- f)        
    002C 303D               │"0="    │
    002E 58                 │pop ax
    002F 85C0               │test ax,ax
    0031 0F95C0             │setnz al                ; AL=0  if ZF=1, else AL=1
    0034 48                 │dec ax                  ; AL=ff if AL=0, else AL=0
    0035 98                 │cbw                     ; AH=AL
    0036 50                 │push ax
    0037 EB4B               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0039 [2900]             │        │+ Add the two values at the top of the stack
    003B 01                 │ 1      │(x1 x2 -- n)    
    003C 2B                 │"+"     │
    003D 5B                 │pop bx
    003E 58                 │pop ax
    003F 01D8               │add ax,bx
    0041 50                 │push ax
    0042 EB40               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0044 [3900]             │        │nand - NAND the two values at the top of the stack
    0046 04                 │ 4      │(x1 x2 -- n)
    0047 6E616E64           │"nand"  │
    004B 5B                 │pop bx
    004C 58                 │pop ax
    004D 21D8               │and ax,bx
    004F F7D0               │not ax
    0051 50                 │push ax
    0052 EB30               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0054 [4400]             │        │exit - Pop return stack and jump to that address
    0056 04                 │ 4      │(r:addr --)
    0057 65786974           │"exit"  │
    005B 87E5               │xchg sp,bp              ; swap SP and BP, SP controls return stack
    005D 5E                 │pop si                  ; pop address to next word
    005E 87E5               │xchg sp,bp              ; restore SP and BP
    0060 EB22               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0062 [5400]             │        │tib - Push TIB address onto stack
    0064 03                 │ 3      │(-- TIB)
    0065 746962             │"tib"   │
    0068 6A00               │push word TIB
    006A EB18               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    006C [6200]             │        │state - Push current state onto stack (0=interp, 1=compile)
    006E 05                 │ 5      │(-- state)
    006F 7374617465         │"state" │
    0074 680010             │push word STATE
    0077 EB0B               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    0079 [6C00]             │        │>in - Push current read offset from TIB onto stack
    007B 03                 │ 3      │(-- a)
    007C 3E696E             │">in"   │
    007F 680210             │push word TOIN
    0082 EB00               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
    
    0084 AD                  lodsw                   ; load next word's address into AX
    0085 FFE0                jmp ax                  ; jump directly to it
    0087 [7900]              dw link
    0089 04                  db %3+%%len
    008A 68657265            db %1
    008E 68[9300]            push word HERE
    0091 EBF1                NEXT
    
    0093 [0002]              dw start_HERE
                            ╭────────┬───────────────────────────────────────────────────────────
    0095 [8700]             │        │latest - Push address of last word in dictionary onto stack
    0097 06                 │ 6      │
    0098 6C6174657374       │"latest"│
    009E 68[A300]           │push word LATEST
    00A1 EBE1               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
    00A3 [FE00]              dw word_SEMICOLON       ; initialized to last word in dictionary
                            ╭────────┬───────────────────────────────────────────────────────────
    00A5 [9500]             │        │key - Push the next character onto the stack
    00A7 03                 │ 3      │(-- char)
    00A8 6B6579             │"key"   │
    00AB B400               │mov ah,0
    00AD CD16               │int 0x16
    00AF 50                 │push ax
    00B0 EBD2               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    00B2 [A500]             │        │emit - Write a character to the screen
    00B4 04                 │ 4      │(char --)
    00B5 656D6974           │"emit"  │
    00B9 58                 │pop ax
    00BA E82201             │call writechar
    00BD EBC5               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
                            ╭────────┬───────────────────────────────────────────────────────────
    00BF [B200]             │        │: - Define a new word
    00C1 01                 │ 1      │(--)
    00C2 3A                 │":"     │
    00C3 E8B700             │call token              ; parse word from input
    00C6 56                 │push si
    00C7 89FE               │mov si,di               ; set parsed word as string copy source
    00C9 8B3E[9300]         │mov di,[HERE]           ; set current value of HERE as destination
    00CD A1[A300]           │mov ax,[LATEST]         ; get pointer to latest defined word
    00D0 893E[A300]         │mov [LATEST],di         ; update LATEST to new word being defined
    00D4 AB                 │stosw                   ; link pointer
    00D5 88C8               │mov al,cl
    00D7 0C40               │or al,F_HIDDEN          ; hide new word while it's being defined
    00D9 AA                 │stosb                   ; word length
    00DA F3A4               │rep movsb               ; word name
    00DC B8FF26             │mov ax,0x26ff
    00DF AB                 │stosw                   ; compile near jump, absolute indirect...
    00E0 B8[FC00]           │mov ax,DOCOL.addr
    00E3 AB                 │stosw                   ; ...to DOCOL
    00E4 893E[9300]         │mov [HERE],di           ; update HERE to next free position
    00E8 C606001001         │mov byte [STATE],1      ; switch to compilation state
    00ED 5E                 │pop si
    00EE EB94               │NEXT
                            ╰────────────────────────────────────────────────────────────────────
    
    00F0 87E5                xchg sp,bp              ; swap SP and BP, SP controls return stack
    00F2 56                  push si                 ; push current "instruction pointer"
    00F3 87E5                xchg sp,bp              ; restore SP and BP
    00F5 83C004              add ax,4                ; skip word's code field
    00F8 89C6                mov si,ax               ; point "instruction pointer" to word body
    00FA EB88                NEXT                    ; start executing the word
    
    00FC [F000]              dw DOCOL
    
                            ╭────────┬───────────────────────────────────────────────────────────
    00FE [BF00]             │        │; - End the definition of a new word
    0100 81                 │ 1      │(--)
    0101 3B                 │";"     │
    0102 8B1E[A300]         │mov bx,[LATEST]
    0106 806702BF           │and byte [bx+2],~F_HIDDEN       ; reveal new word
    010A C606001000         │mov byte [STATE],0      ; switch to interpretation state
    010F B8[5B00]           │mov ax,EXIT             ; prepare to compile EXIT
                            │
         C O M P I L E      │
                            │
    0112 8B3E[9300]   ┌────►│mov di,[HERE]           
    0116 AB           │     │stosw                   ; compile contents of AX to HERE
    0117 893E[9300]   │     │mov [HERE],di           ; advance HERE to next cell
    011B E966FF       │     │NEXT
                      │     ╰────────────────────────────────────────────────────────────────────
                      │        
         S T A R T    │        
                      │       
    011E FC           │      cld                     ; clear direction flag
    011F 0E           │      push cs                 ; Set up segment registers to point to 
    0120 0E           │      push cs                 ;   the same segment as CS.
    0121 0E           │      push cs
    0122 1F           │      pop ds
    0123 07           │      pop es
    0124 17           │      pop ss
    0125 EB0B         │    ┌─jmp init
                      │    │
                      │    │
         E R R O R    │    │
                      │    │
    0127 B82109       │   ┌│►mov ax,0x0921           ; write '!'
    012A BB0400       │   ││ mov bx,0x0004           ; black background, red text
    012D B90200       │   ││ mov cx,2                ; twice
    0130 CD10         │   ││ int 0x10
                      │   ││
         I N I T      │   ││
                      │   ││
    0132 BDFE76       │   │└►mov bp,RP0              ; BP is the return stack pointer
    0135 BCFEFF       │   │  mov sp,SP0              ; SP is the data stack pointer
    0138 B000         │   │  mov al,0                ; Fill TIB with zeros, and set STATE
    013A B90410       │   │  mov cx,STATE+4          ;   and >IN to 0
    013D BF0000       │   │  mov di,TIB
    0140 F3AA         │   │  rep stosb
                      │   │    
         I N T E R P R│E T│  ; Words are read one at time and searched for in the dictionary.
                      │   │  ; If a word is found in the dictionary, it is either interpreted
                      │   │  ; (i.e. executed) or compiled, depending on the current state and
                      │   │  ; the word's IMMEDIATE flag.
                      │   │    
                      │   │  ; When a word is not found, the state of the interpreter is reset:
                      │   │  ; the data and return stacks are cleared as well as the terminal
                      │   │  ; input buffer, and the interpreter goes into interpretation mode.
                      │   │    
    0142 E83800       │┌──│──call token              ; parse word from input
    0145 8B1E[A300]   ││  │  mov bx,[LATEST]         ; start searching for it in the dictionary
    0149 85DB         ││┌─│─►test bx,bx              ; zero?  (.1:)
    014B 74DA         │││ └──jz error                ; not found, reset interpreter state
    014D 89DE         │││    mov si,bx
    014F AD           │││    lodsw                   ; skip link
    0150 AC           │││    lodsb                   ; read flags+length
    0151 88C2         │││    mov dl,al               ; save those for later use
    0153 A840         │││    test al,F_HIDDEN        ; entry hidden?
    0155 750E         │││ ┌──jnz .2                  ; if so, skip it
    0157 241F         │││ │  and al,LENMASK          ; mask out flags
    0159 38C8         │││ │  cmp al,cl               ; same length?
    015B 7508         │││ ├──jne .2                  ; if not, skip entry
    015D 51           │││ │  push cx
    015E 57           │││ │  push di
    015F F3A6         │││ │  repe cmpsb              ; compare strings
    0161 5F           │││ │  pop di
    0162 59           │││ │  pop cx
    0163 7404         │││┌│──je .3                   ; if equal, search is over
    0165 8B1F         ││││└─►mov bx,[bx]             ; skip to next entry (.2:)
    0167 EBE0         ││└│───jmp .1                  ; try again
    0169 89F0         ││ └──►mov ax,si               ; after comparison, SI points to code field (.3:)
    016B BE[7B01]     ││     mov si,.loop            ; set SI so NEXT loops back to interpreter
                      ││     
                      ││     ; Decide whether to interpret or compile the word. The IMMEDIATE
                      ││     ; flag is located in the most significant bit of the flags+length
                      ││     ; byte. STATE can only be 0 or 1. A word is only compiled when 
                      ││     ; the result of ORing these two values together is 1. Decrementing
                      ││     ; that result sets the zero flag for a conditional jump.
                      ││     
    016E 80E280       ││     and dl,F_IMMEDIATE      ; isolate IMMEDIATE flag
    0171 0A160010     ││     or dl,[STATE]           ; OR with state
    0175 FECA         ││     dec dl                  ; decrement
    0177 7499         └│─────jz compile              ; if result is zero, compile
    0179 FFE0          │     jmp ax                  ; otherwise, interpret (execute) the word
                       │     
    017B [4201]        │     dw interpreter          ; (.loop:)
                       │    
         T O K E N     │     ; Parse a word from the terminal input buffer and return its
                       │     ; address and length in DI and CX, respectively.
                       │     
                       │     ; If after skipping spaces a 0 is found, more input is read from
                       │     ; the keyboard into the terminal input buffer until return is
                       │     ; pressed, at which point execution jumps back to the beginning of
                       │     
                       │     ; Before reading input from the keyboard, a CRLF is emitted so
                       │     ; the user can enter input on a fresh, blank line on the screen.
                       │     
    017D 8B3E0210      ├────►mov di,[TOIN]           ; starting at the current position in TIB
    0181 B9FFFF        │     mov cx,-1               ; search "indefinitely"
    0184 B020          │     mov al,32               ; for a character that's not a space
    0186 F3AE          │     repe scasb
    0188 4F            │     dec di                  ; result is one byte past found character
    0189 803D00        │     cmp byte [di],0         ; found a 0?
    018C 7410          │   ┌─je .readline            ; if so, read more input
    018E B9FFFF        │   │ mov cx,-1               ; search "indefinitely" again
    0191 F2AE          │   │ repne scasb             ; this time, for a space
    0193 4F            │   │ dec di                  ; adjust DI again
    0194 893E0210      │   │ mov [TOIN],di           ; update current position in TIB
    0198 F7D1          │   │ not cx                  ; after ones' complement, CX=length+1
    019A 49            │   │ dec cx                  ; adjust CX to correct length
    019B 29CF          │   │ sub di,cx               ; point to start of parsed word
    019D C3            │   │ ret
                       │   │ 
         R E A D L I N E   │ 
                       │   │   
    019E B00D          │   └►mov al,13
    01A0 E83C00        │┌────call writechar          ; CR
    01A3 B00A          ││    mov al,10
    01A5 E83700        │├────call writechar          ; LF
    01A8 BF0000        ││    mov di,TIB              ; read into TIB
    01AB B400          ││ ┌─►mov ah,0                ; wait until a key is pressed (.1:)
    01AD CD16          ││ │  int 0x16
    01AF 3C0D          ││ │  cmp al,13               ; return pressed?
    01B1 741D          ││┌│──je .3                   ; if so, finish reading
    01B3 3C08          ││││  cmp al,8                ; backspace pressed?
    01B5 7406          ││││┌─je .2                   ; if so, erase character
    01B7 E82500        │├│││─call writechar          ; otherwise, write character to screen
    01BA AA            │││││ stosb                   ; store character in TIB
    01BB EBEE          │││├│─jmp .1                  ; keep reading
    01BD 83FF00        ││││└►cmp di,TIB              ; start of TIB? (.2:)
    01C0 74E9          │││├──je .1                   ; if so, there's nothing to erase
    01C2 4F            ││││  dec di                  ; erase character in TIB
    01C3 E81900        │├││──call writechar          ; move cursor back one character
    01C6 B8200A        ││││  mov ax,0x0a20           ; erase without moving cursor
    01C9 B90100        ││││  mov cx,1
    01CC CD10          ││││  int 0x10                ; (BH already set to 0 by writechar)
    01CE EBDB          │││└──jmp .1                  ; keep reading
    01D0 B82000        ││└──►mov ax,0x0020           ; (.3:)
    01D3 AB            ││    stosw                   ; put final delimiter and 0 in TIB
    01D4 E80800        │├────call writechar          ; write a space between user input and
    01D7 C70602100000  ││    mov word [TOIN],0       ; point >IN to start of TIB
    01DD EB9E          └│────jmp token               ; try parsing a word again
                        │    
         W R I T E C H A│R
                        │    ; writechar writes a character to the screen. It uses INT 10/AH=0e
                        │    ; to perform teletype output, writing the character, updating the
                        │    ; cursor, and scrolling the screen, all in one go. Writing
                        │    ; backspace using the BIOS only moves the cursor backwards within
                        │    ; a line, but does not move it back to the previous line.
                        │    ; writechar addresses that.
                        │    
    01DF 50             └───►push ax                 ; INT 10h/AH=03h clobbers AX in some BIOSes
    01E0 B700                mov bh,0                ; video page 0 for all BIOS calls
    01E2 B403                mov ah,3                ; get cursor position (DH=row, DL=column)
    01E4 CD10                int 0x10
    01E6 58                  pop ax                  ; restore AX
    01E7 B40E                mov ah,0x0e             ; teletype output
    01E9 B307                mov bl,0x7              ; black background, light grey text
    01EB CD10                int 0x10
    01ED 3C08                cmp al,8                ; backspace?
    01EF 750C             ┌──jne .1                  ; if not, nothing else to do
    01F1 84D2             │  test dl,dl              ; was cursor in first column?
    01F3 7508             ├──jnz .1                  ; if not, nothing else to do
    01F5 B402             │  mov ah,2                ; move cursor
    01F7 B24F             │  mov dl,79               ; to last column
    01F9 FECE             │  dec dh                  ; of previous row
    01FB CD10             │  int 0x10
    01FD C3               └─►ret                     ; (.1:)
    
    01FE 55AA                db 0x55, 0xaa