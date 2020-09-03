
;;;;;;;;;;;;;;;;;;; yazd --addr:0x8000 --entry:0x8000 --entry:0x931e --entry:0x9327 --lst HddBoot.orig.bin > test.lst


        ORG     8000h

        ; Entry Point
        ; --- START PROC L8000 ---
L8000:  JP      L800F

L8003:  DB      0C3h
        DB      0FCh
        DB      83h
        DB      0C3h
        DB      0FCh
        DB      83h
        DB      0C3h
        DB      0Ch
        DB      80h
        DB      0AFh
        DB      18h
        DB      02h

L800F:  LD      A,0FFh          
        LD      (0F409h),A      ; Scratch + 0x09
        DI
        LD      SP,0F800h       ; Stack in second half of video character ram
        XOR     A
        OUT     (50h),A         ; Reset memory banking
        OUT     (0Bh),A         ; Reset VDU Character Rom Latch
        LD      (0F40Ah),A      ; Scratch + 0x0A
        IN      A,(09h)         ; Colour "wait off" output (Yes, set by inputting from port)
        XOR     A
        SET     7,A
        OUT     (1Ch),A         ; Enable extended PCG ram

        LD      HL,854Dh        ; End of 6545 register table
        LD      B,10h
L802C:  LD      A,B
        DEC     A
        OUT     (0Ch),A
        LD      A,(HL)
        OUT     (0Dh),A
        DEC     HL
        DJNZ    L802C
        LD      A,40h           ; Switch in Color RAM
        OUT     (08h),A         ; Color control port


        ; Clear color RAM
        LD      HL,0F800h
L803D:  LD      (HL),0Eh
        INC     HL
        LD      A,H
        OR      A
        JR      NZ,L803D
        OUT     (08h),A         ; Switch out Color RAM

        ; Copy interrupt service routine 
        LD      HL,931Eh
        LD      DE,0100h
        LD      BC,0039h
        LDIR


        CALL    L824C           ; Clear screen and display a fake block cursor in top left corner
        CALL    L80AC           ; Clear attribute RAM

        ; Enable interrupt mode 2 and set the interrupt vector to 0x100
        LD      A,01h
        LD      I,A
        IM      2

        CALL    0109h           ; Setup PIO ports

        DI
        LD      SP,3000h        ; Setup Stack
        LD      A,00h
        LD      (0F411h),A      ; Scratch + 0x11
        LD      A,0Dh           ; "M" keyu
        CALL    L8500           ; Keyboard scan
        JP      Z,L83FC         ; Jump to monitor
        ;JP      LB100
        JP      hack

        ; --- START PROC L8074 ---
L8074:  LD      DE,0AA55h
        OR      A
        SBC     HL,DE
        JP      Z,L83C5
        LD      A,(0F409h)
        OR      A
        JP      NZ,L83B3
        ; --- START PROC L8084 ---
L8084:  LD      C,20h           ; ' '
        CALL    L847B
        LD      HL,89DEh
        CALL    L8361
        LD      HL,854Eh
        LD      DE,0000h
        CALL    L82B3
        EI
        ; --- START PROC L8099 ---
L8099:  CALL    L8282
        CP      02h
        JR      Z,L80C3
        CP      0Dh
        JP      Z,L83FC
        CP      13h
        JP      Z,L8124
        JR      L8099

        ; --- START PROC L80AC ---
L80AC:  LD      A,90h                           ; Select attribute RAM
        OUT     (1Ch),A
        LD      HL,0F000h                       
L80B3:  LD      (HL),00h                        ; Clear it
        INC     HL
        BIT     3,H
        JR      Z,L80B3
        LD      A,80h
        OUT     (1Ch),A                         ; Enable extended PCG, disable attribute RAM
        RET

L80BF:  DB      3Eh             ; '>'
        DB      01h
        DB      18h
        DB      01h

        ; --- START PROC L80C3 ---
L80C3:  XOR     A
        LD      (0038h),A
L80C7:  LD      HL,854Eh
        LD      DE,0000h
        CALL    L82B3
        CALL    L828D
        CALL    L8432
        JP      NZ,L83C5
        LD      B,03h
        LD      C,35h           ; '5'
        DI
L80DE:  PUSH    BC
        CALL    L847B
L80E2:  DJNZ    L80E2
        POP     BC
        DJNZ    L80DE
        EI
        LD      HL,0F24Ah
        LD      B,05h
        CALL    L82AD
        LD      DE,003Bh
        ADD     HL,DE
        LD      B,05h
        CALL    L82AD
        LD      HL,811Fh
        LD      DE,0F24Ah
        LD      BC,0005h
        LDIR
        CALL    L8230
        LD      HL,0FA4Ah
        LD      B,05h
L810C:  LD      (HL),09h
        INC     HL
        DJNZ    L810C
        CALL    L8237
        CALL    L8282
        CP      02h
        JP      NZ,L81B1
        JP      L80C7

L811F:  DB      45h             ; 'E'
        DB      52h             ; 'R'
        DB      52h             ; 'R'
        DB      4Fh             ; 'O'
        DB      52h             ; 'R'

        ; --- START PROC L8124 ---
L8124:  LD      A,03h
        OUT     (03h),A
        LD      HL,87EDh
        LD      DE,0140h
        CALL    L82B3
        CALL    L81DC
        CALL    L823E
        LD      HL,0F1D0h
        LD      B,0Ch
        LD      A,01h
        CALL    L81AC
        CALL    L8245
        LD      A,0FFh
        OUT     (48h),A         ; 'H'
        LD      C,80h
        CALL    L847B
        CALL    L8DF5
        LD      A,0FFh
        LD      (0132h),A
        LD      (0134h),A
        LD      (0135h),A
        ; --- START PROC L815B ---
L815B:  PUSH    HL
        LD      HL,(0134h)
        INC     HL
        LD      (0134h),HL
        CALL    L81CE
        POP     HL
        CALL    L81CE
        LD      DE,8196h
        LD      A,0C3h
        LD      (0000h),A
        ; --- START PROC L8172 ---
L8172:  EX      DE,HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        EX      DE,HL
        LD      A,H
        OR      L
        JR      Z,L815B
        LD      (0001h),HL
        PUSH    DE
        CALL    0000h
        POP     DE
        CALL    L8275
        JR      NZ,L8193
        CP      30h             ; '0'
        JP      Z,L81B1
        CP      37h             ; '7'
        JP      Z,L8124
        ; --- START PROC L8193 ---
L8193:  JP      L8172

L8196:  DB      0BEh
        DB      90h
        DB      0F5h
        DB      90h
        DB      83h
        DB      91h
        DB      34h             ; '4'
        DB      91h
        DB      0Bh
        DB      8Fh
        DB      00h
        DB      92h
        DB      0D3h
        DB      91h
        DB      6Bh             ; 'k'
        DB      92h
        DB      40h             ; '@'
        DB      92h
        DB      0B9h
        DB      8Fh
        DB      00h
        DB      00h

        ; --- START PROC L81AC ---
L81AC:  LD      (HL),A
        INC     HL
        DJNZ    L81AC
        RET

        ; --- START PROC L81B1 ---
L81B1:  LD      HL,931Eh
        LD      DE,0100h
        LD      BC,0039h
        LDIR
        CALL    0109h
        CALL    L80AC
        LD      HL,854Eh
        LD      DE,0000h
        CALL    L82B3
        JP      L8099

        ; --- START PROC L81CE ---
L81CE:  PUSH    HL
        PUSH    DE
        LD      HL,(0134h)
        LD      DE,0F331h
        CALL    L84BE
        POP     DE
        POP     HL
        RET

        ; --- START PROC L81DC ---
L81DC:  CALL    L8230
        LD      HL,0F941h
        LD      B,08h
        LD      A,80h
        CALL    L81F5
        LD      HL,0F96Fh
        LD      B,08h
        XOR     A
        CALL    L81F5
        JP      L8237

        ; --- START PROC L81F5 ---
L81F5:  PUSH    AF
        LD      (HL),A
        INC     HL
        RRCA
        RRCA
        RRCA
        RRCA
        LD      (HL),A
        INC     HL
        POP     AF
        ADD     A,10h
        DJNZ    L81F5
        RET

L8204:  DB      0F5h
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      0F1h
        DB      0C9h
        DB      0F5h
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      0F1h
        DB      0C9h
        DB      0CDh
        DB      95h
        DB      83h
        DB      0CDh
        DB      04h
        DB      82h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      11h
        DB      00h
        DB      0F8h
        DB      01h
        DB      0FFh
        DB      07h
        DB      7Eh             ; '~'
        DB      2Fh             ; '/'
        DB      12h
        DB      23h             ; '#'
        DB      13h
        DB      0Bh
        DB      78h             ; 'x'
        DB      0B1h
        DB      20h             ; ' '
        DB      0F6h
        DB      0CDh
        DB      0Bh
        DB      82h
        DB      0C3h
        DB      71h             ; 'q'
        DB      82h

        ; --- START PROC L8230 ---
L8230:  PUSH    AF
        LD      A,40h           ; '@'
        OUT     (08h),A
        POP     AF
        RET

        ; --- START PROC L8237 ---
L8237:  PUSH    AF
        LD      A,00h
        OUT     (08h),A
        POP     AF
        RET

        ; --- START PROC L823E ---
L823E:  PUSH    AF
        LD      A,90h
        OUT     (1Ch),A
        POP     AF
        RET

        ; --- START PROC L8245 ---
L8245:  PUSH    AF
        LD      A,80h
        OUT     (1Ch),A
        POP     AF
        RET

        ; --- START PROC L824C ---
L824C:  PUSH    HL
        PUSH    DE
        PUSH    BC
        LD      HL,0F000h
        LD      DE,0F001h
        LD      BC,0400h
        LD      (HL),20h        ; ' '
        LDIR
        LD      A,80h
        LD      (0F000h),A
        OUT     (1Ch),A
        LD      HL,0F800h
        LD      B,10h
L8268:  LD      (HL),0FFh
        INC     HL
        DJNZ    L8268
        POP     BC
        POP     DE
        POP     HL
        RET

        ; --- START PROC L8271 ---
L8271:  CALL    L83A4
        RET

        ; --- START PROC L8275 ---
L8275:  XOR     A
L8276:  CALL    L8500
        RET     Z
        INC     A
        CP      40h             ; '@'
        JR      NZ,L8276
        OR      0FFh
        RET

        ; --- START PROC L8282 ---
L8282:  CALL    L8275
        JR      NZ,L8282
L8287:  CALL    L8500
        JR      Z,L8287
        RET

        ; --- START PROC L828D ---
L828D:  LD      HL,0F25Eh
        LD      DE,0040h
        PUSH    HL
        LD      B,03h
        CALL    L82AD
        POP     HL
        ADD     HL,DE
        LD      B,03h
        CALL    L82AD
        LD      HL,0F271h
        PUSH    HL
        LD      B,04h
        CALL    L82AD
        POP     HL
        ADD     HL,DE
        LD      B,04h
        ; --- START PROC L82AD ---
L82AD:  LD      (HL),20h        ; ' '
        INC     HL
        DJNZ    L82AD
        RET

        ; --- START PROC L82B3 ---
L82B3:  PUSH    BC
        XOR     A
        LD      (0F400h),A
        LD      BC,0F000h
        EX      DE,HL
        ADD     HL,BC
        EX      DE,HL
        LD      A,40h           ; '@'
        CALL    L82C5
        POP     BC
        RET

        ; --- START PROC L82C5 ---
L82C5:  CALL    L8395
        PUSH    DE
        POP     IY
        LD      E,A
        LD      D,00h
        XOR     A
        LD      (0F402h),A
        PUSH    HL
        POP     IX
        INC     HL
        INC     HL
        LD      C,(IX+01h)
L82DA:  LD      B,(IX+00h)
        PUSH    IY
L82DF:  CALL    L8334
        EX      AF,AF'
        LD      A,(0F400h)
        OR      A
        JP      NZ,L8304
        EX      AF,AF'
        CP      01h
        JP      NZ,L82F6
        CALL    L8334
        JP      L82DF

L82F6:  CP      02h
        JP      NZ,L8305
        CALL    L8334
        LD      (0F406h),A
        JP      L82DF

L8304:  EX      AF,AF'
L8305:  LD      (IY+00h),A
        EXX
        LD      BC,0800h
        ADD     IY,BC
        LD      A,(0F400h)
        OR      A
        JP      NZ,L8321
        CALL    L8230
        LD      A,(0F406h)
        LD      (IY+00h),A
        CALL    L8237
L8321:  LD      BC,0F801h
        ADD     IY,BC
        EXX
        DJNZ    L82DF
        POP     IY
        ADD     IY,DE
        DEC     C
        JP      NZ,L82DA
        JP      L8271

        ; --- START PROC L8334 ---
L8334:  LD      A,(0F402h)
        DEC     A
        JP      M,L8342
        LD      (0F402h),A
        LD      A,(0F404h)
        RET

L8342:  LD      A,(HL)
        INC     HL
        OR      A
        RET     NZ
        LD      A,(HL)
        INC     HL
        DEC     A
        BIT     7,A
        JP      Z,L8359
        RES     7,A
        LD      (0F402h),A
        LD      A,(HL)
        INC     HL
        LD      (0F404h),A
        RET

L8359:  LD      (0F402h),A
        XOR     A
        LD      (0F404h),A
        RET

        ; --- START PROC L8361 ---
L8361:  PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL
        PUSH    IX
        PUSH    IY
        LD      A,0FFh
        LD      (0F400h),A
        LD      B,(HL)
        INC     HL
        LD      C,(HL)
        INC     HL
        PUSH    HL
        LD      L,(HL)
        LD      H,00h
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,HL
        LD      DE,0F000h
        ADD     HL,DE
        EX      DE,HL
        POP     HL
        INC     HL
L8381:  LD      A,10h
        CALL    L82C5
        INC     C
        LD      DE,0F000h
        DJNZ    L8381
        POP     IY
        POP     IX
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET

        ; --- START PROC L8395 ---
L8395:  EXX
        POP     HL
        EXX
        PUSH    IY
        PUSH    IX
        PUSH    DE
        PUSH    BC
        PUSH    AF
        PUSH    HL
        EXX
        PUSH    HL
        EXX
        RET

        ; --- START PROC L83A4 ---
L83A4:  EXX
        POP     HL
        EXX
        POP     HL
        POP     AF
        POP     BC
        POP     DE
        POP     IX
        POP     IY
        EXX
        PUSH    HL
        EXX
        RET

        ; --- START PROC L83B3 ---
L83B3:  XOR     A
        LD      (0038h),A
        CALL    L8432
        JR      NZ,L83C5
        LD      SP,3000h
        CALL    0109h
        JP      L8084

        ; --- START PROC L83C5 ---
L83C5:  XOR     A
        OUT     (50h),A         ; 'P'
        LD      SP,8000h
        CALL    L83D6
        LD      HL,0E000h
        LD      A,04h
        JP      0FFDFh

        ; --- START PROC L83D6 ---
L83D6:  XOR     A
        OUT     (1Ch),A
        LD      HL,94F7h
        LD      DE,6000h
        LD      BC,0B08h
        LDIR
        CALL    L840A
        LD      HL,83F3h
        LD      DE,0FFDFh
        LD      BC,0010h
        LDIR
        RET

L83F3:  DB      0D3h
        DB      50h             ; 'P'
        DB      3Ah             ; ':'
        DB      38h             ; '8'
        DB      80h
        DB      32h             ; '2'
        DB      38h             ; '8'
        DB      00h
        DB      0E9h

        ; --- START PROC L83FC ---
L83FC:  LD      SP,8000h
        CALL    L83D6
        LD      HL,0E003h
        LD      A,04h
        JP      0FFDFh

        ; --- START PROC L840A ---
L840A:  LD      HL,9360h
        LD      DE,6B00h
        LD      BC,0197h
        LDIR
        LD      HL,6F00h
        LD      B,00h
        LD      A,B
L841B:  LD      (HL),00h
        INC     HL
        DJNZ    L841B
        LD      HL,842Ch
        LD      DE,6FFAh
        LD      BC,0006h
        LDIR
        RET

L842C:  DB      00h
        DB      0EBh
        DB      00h
        DB      31h             ; '1'
        DB      32h             ; '2'
        DB      38h             ; '8'

        ; --- START PROC L8432 ---
L8432:  DI
        CALL    L91F2
        JR      Z,L843A
        XOR     A
        RET

L843A:  LD      A,(0038h)
        OUT     (48h),A         ; 'H'
        LD      A,2Ch           ; ','
        OUT     (44h),A         ; 'D'
        LD      DE,0000h
L8446:  DEC     DE
        LD      A,D
        OR      E
        JR      NZ,L8446
        LD      BC,0000h
L844E:  IN      A,(44h)         ; 'D'
        BIT     1,A
        RET     NZ
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,L844E
        LD      A,0D0h
        OUT     (44h),A         ; 'D'
L845C:  IN      A,(44h)         ; 'D'
        BIT     0,A
        JR      NZ,L845C
        LD      A,00h
        OUT     (44h),A         ; 'D'
        LD      A,0FFh
        OUT     (48h),A         ; 'H'
        INC     A
        RET

L846C:  DB      0E5h
        DB      21h             ; '!'
        DB      7Ah             ; 'z'
        DB      00h
        DB      2Bh             ; '+'
        DB      7Ch             ; '|'
        DB      0B5h
        DB      20h             ; ' '
        DB      0FBh
        DB      10h
        DB      0F6h
        DB      0E1h
        DB      0C9h

        ; --- START PROC L8479 ---
L8479:  LD      C,30h           ; '0'
        ; --- START PROC L847B ---
L847B:  LD      L,00h
        PUSH    AF
L847E:  DI
        IN      A,(02h)
        OR      40h             ; '@'
        OUT     (02h),A
        LD      B,C
L8486:  DJNZ    L8486
        IN      A,(02h)
        AND     0BFh
        OUT     (02h),A
        LD      B,C
L848F:  DJNZ    L848F
        DEC     L
        JR      NZ,L847E
        POP     AF
        RET

L8496:  DB      7Ch             ; '|'
        DB      0CDh
        DB      9Bh
        DB      84h
        DB      7Dh             ; '}'
        DB      0F5h
        DB      0CBh
        DB      1Fh
        DB      0CBh
        DB      1Fh
        DB      0CBh
        DB      1Fh
        DB      0CBh
        DB      1Fh
        DB      0CDh
        DB      0B3h
        DB      84h
        DB      0EDh
        DB      5Bh             ; '['
        DB      36h             ; '6'
        DB      01h
        DB      12h
        DB      13h
        DB      0F1h
        DB      0CDh
        DB      0B3h
        DB      84h
        DB      12h
        DB      0C9h
        DB      0E6h
        DB      0Fh
        DB      0FEh
        DB      0Ah
        DB      38h             ; '8'
        DB      02h
        DB      0C6h
        DB      07h
        DB      0C6h
        DB      30h             ; '0'
        DB      0C9h

        ; --- START PROC L84BE ---
L84BE:  XOR     A
        LD      (0130h),A
        LD      BC,2710h
        CALL    L84E1
        LD      BC,03E8h
        CALL    L84E1
        LD      BC,0064h
        CALL    L84E1
        LD      BC,000Ah
        CALL    L84E1
        LD      BC,0001h
        CALL    L84E1
        RET

        ; --- START PROC L84E1 ---
L84E1:  EX      DE,HL
        LD      (HL),30h        ; '0'
        EX      DE,HL
L84E5:  PUSH    DE
        LD      D,B
        LD      E,C
        SBC     HL,DE
        JR      C,L84F7
        POP     DE
        EX      DE,HL
        LD      A,0FFh
        LD      (0130h),A
        INC     (HL)
        EX      DE,HL
        JR      L84E5

L84F7:  ADD     HL,DE
        POP     DE
        LD      A,(0130h)
        OR      A
        RET     Z
        INC     DE
        RET

        ; --- START PROC L8500 ---
L8500:  PUSH    BC
        LD      B,A
        LD      C,A
        LD      A,12h
        OUT     (0Ch),A
        LD      A,B
        RRCA
        RRCA
        RRCA
        RRCA
        LD      B,A
        OUT     (0Dh),A
        LD      A,13h
        OUT     (0Ch),A
        LD      A,B
        OUT     (0Dh),A
        LD      A,01h
        OUT     (0Bh),A
        LD      A,10h
        OUT     (0Ch),A
        IN      A,(0Dh)
        LD      A,1Fh
        OUT     (0Ch),A
        OUT     (0Dh),A
L8526:  IN      A,(0Ch)
        BIT     7,A
        JR      Z,L8526
        IN      A,(0Ch)
        CPL
        LD      B,A
        XOR     A
        OUT     (0Bh),A
        LD      A,10h
        OUT     (0Ch),A
        IN      A,(0Dh)
        BIT     6,B
        LD      A,C
        POP     BC
        RET

L853E:  DB      6Bh             ; 'k'
        DB      40h             ; '@'
        DB      51h             ; 'Q'
        DB      37h             ; '7'
        DB      12h
        DB      09h
        DB      10h
        DB      12h
        DB      48h             ; 'H'
        DB      0Fh
        DB      2Fh             ; '/'
        DB      0Fh
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      40h             ; '@'
        DB      10h
        DB      01h
        DB      00h
        DB      01h
        DB      02h
        DB      0Fh
        DB      83h
        DB      00h
        DB      0BEh
        DB      80h
        DB      84h
        DB      81h
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      02h
        DB      0F1h
        DB      20h             ; ' '
        DB      91h
        DB      8Dh
        DB      8Bh
        DB      8Ch
        DB      8Eh
        DB      8Fh
        DB      90h
        DB      92h
        DB      20h             ; ' '
        DB      02h
        DB      0CFh
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      0A7h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      0A3h
        DB      0A4h
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      0A5h
        DB      0A6h
        DB      00h
        DB      8Ch
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      02h
        DB      0F1h
        DB      20h             ; ' '
        DB      93h
        DB      96h
        DB      94h
        DB      99h
        DB      9Ah
        DB      98h
        DB      97h
        DB      95h
        DB      20h             ; ' '
        DB      02h
        DB      0CFh
        DB      20h             ; ' '
        DB      0ADh
        DB      0AEh
        DB      0AFh
        DB      0B0h
        DB      0B1h
        DB      0A8h
        DB      0BDh
        DB      0B2h
        DB      0B3h
        DB      0ADh
        DB      0B5h
        DB      0B6h
        DB      0B7h
        DB      0B8h
        DB      0A9h
        DB      0AAh
        DB      0B8h
        DB      0BEh
        DB      0BAh
        DB      0BBh
        DB      0BFh
        DB      0BAh
        DB      0ABh
        DB      0ACh
        DB      20h             ; ' '
        DB      0B4h
        DB      20h             ; ' '
        DB      0B9h
        DB      0BCh
        DB      0CFh
        DB      0C5h
        DB      0D2h
        DB      0C8h
        DB      0C9h
        DB      0CEh
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      02h
        DB      0F1h
        DB      20h             ; ' '
        DB      9Bh
        DB      9Ch
        DB      9Dh
        DB      9Eh
        DB      9Fh
        DB      0A0h
        DB      0A1h
        DB      0A2h
        DB      20h             ; ' '
        DB      02h
        DB      0CFh
        DB      20h             ; ' '
        DB      0C0h
        DB      0C1h
        DB      0C2h
        DB      0C3h
        DB      0C4h
        DB      0C2h
        DB      0C6h
        DB      0C7h
        DB      0D4h
        DB      0C0h
        DB      0C1h
        DB      0CAh
        DB      0CBh
        DB      0CCh
        DB      0CDh
        DB      0CBh
        DB      0CCh
        DB      0D0h
        DB      0D1h
        DB      0D4h
        DB      0CAh
        DB      0D1h
        DB      0D4h
        DB      20h             ; ' '
        DB      0DDh
        DB      0D3h
        DB      0DEh
        DB      0D5h
        DB      0DAh
        DB      0D6h
        DB      0DBh
        DB      0D7h
        DB      0D3h
        DB      0D9h
        DB      0DCh
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      02h
        DB      0Eh
        DB      00h
        DB      99h
        DB      20h             ; ' '
        DB      56h             ; 'V'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      73h             ; 's'
        DB      69h             ; 'i'
        DB      6Fh             ; 'o'
        DB      6Eh             ; 'n'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      2Eh             ; '.'
        DB      30h             ; '0'
        DB      33h             ; '3'
        DB      00h
        DB      98h
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      02h
        DB      09h
        DB      00h
        DB      92h
        DB      20h             ; ' '
        DB      50h             ; 'P'
        DB      52h             ; 'R'
        DB      45h             ; 'E'
        DB      53h             ; 'S'
        DB      53h             ; 'S'
        DB      20h             ; ' '
        DB      4Bh             ; 'K'
        DB      45h             ; 'E'
        DB      59h             ; 'Y'
        DB      20h             ; ' '
        DB      54h             ; 'T'
        DB      4Fh             ; 'O'
        DB      20h             ; ' '
        DB      53h             ; 'S'
        DB      45h             ; 'E'
        DB      4Ch             ; 'L'
        DB      45h             ; 'E'
        DB      43h             ; 'C'
        DB      54h             ; 'T'
        DB      20h             ; ' '
        DB      4Fh             ; 'O'
        DB      50h             ; 'P'
        DB      54h             ; 'T'
        DB      49h             ; 'I'
        DB      4Fh             ; 'O'
        DB      4Eh             ; 'N'
        DB      00h
        DB      91h
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      83h
        DB      00h
        DB      91h
        DB      80h
        DB      87h
        DB      00h
        DB      93h
        DB      80h
        DB      87h
        DB      00h
        DB      92h
        DB      80h
        DB      84h
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      81h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      42h             ; 'B'
        DB      02h
        DB      0Eh
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      89h
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      4Dh             ; 'M'
        DB      02h
        DB      0Eh
        DB      00h
        DB      89h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      53h             ; 'S'
        DB      02h
        DB      0Eh
        DB      00h
        DB      89h
        DB      20h             ; ' '
        DB      81h
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      89h
        DB      00h
        DB      91h
        DB      80h
        DB      82h
        DB      00h
        DB      93h
        DB      80h
        DB      82h
        DB      00h
        DB      92h
        DB      80h
        DB      8Ah
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      81h
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0D8h
        DB      0DFh
        DB      0E0h
        DB      0E0h
        DB      0E2h
        DB      02h
        DB      0Eh
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0EEh
        DB      0EFh
        DB      0F0h
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0E8h
        DB      0E1h
        DB      0E9h
        DB      0EAh
        DB      02h
        DB      0Eh
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      81h
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      81h
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0E3h
        DB      0E4h
        DB      0E5h
        DB      0E6h
        DB      0E7h
        DB      02h
        DB      0Eh
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0F1h
        DB      0F2h
        DB      0F3h
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0EBh
        DB      0EDh
        DB      0ECh
        DB      02h
        DB      0Eh
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      81h
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      42h             ; 'B'
        DB      6Fh             ; 'o'
        DB      6Fh             ; 'o'
        DB      74h             ; 't'
        DB      20h             ; ' '
        DB      44h             ; 'D'
        DB      69h             ; 'i'
        DB      73h             ; 's'
        DB      6Bh             ; 'k'
        DB      65h             ; 'e'
        DB      74h             ; 't'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      02h
        DB      0Eh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      4Dh             ; 'M'
        DB      6Fh             ; 'o'
        DB      6Eh             ; 'n'
        DB      69h             ; 'i'
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      02h
        DB      0Eh
        DB      00h
        DB      86h
        DB      20h             ; ' '
        DB      81h
        DB      00h
        DB      85h
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      53h             ; 'S'
        DB      65h             ; 'e'
        DB      6Ch             ; 'l'
        DB      66h             ; 'f'
        DB      20h             ; ' '
        DB      54h             ; 'T'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      02h
        DB      0Eh
        DB      00h
        DB      84h
        DB      20h             ; ' '
        DB      81h
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      85h
        DB      00h
        DB      91h
        DB      80h
        DB      88h
        DB      00h
        DB      93h
        DB      80h
        DB      88h
        DB      00h
        DB      92h
        DB      80h
        DB      86h
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      02h
        DB      07h
        DB      00h
        DB      88h
        DB      20h             ; ' '
        DB      28h             ; '('
        DB      43h             ; 'C'
        DB      29h             ; ')'
        DB      31h             ; '1'
        DB      39h             ; '9'
        DB      38h             ; '8'
        DB      37h             ; '7'
        DB      2Ch             ; ','
        DB      20h             ; ' '
        DB      4Dh             ; 'M'
        DB      69h             ; 'i'
        DB      63h             ; 'c'
        DB      72h             ; 'r'
        DB      6Fh             ; 'o'
        DB      62h             ; 'b'
        DB      65h             ; 'e'
        DB      65h             ; 'e'
        DB      20h             ; ' '
        DB      53h             ; 'S'
        DB      79h             ; 'y'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      6Dh             ; 'm'
        DB      73h             ; 's'
        DB      20h             ; ' '
        DB      4Ch             ; 'L'
        DB      69h             ; 'i'
        DB      6Dh             ; 'm'
        DB      69h             ; 'i'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      64h             ; 'd'
        DB      2Ch             ; ','
        DB      20h             ; ' '
        DB      41h             ; 'A'
        DB      75h             ; 'u'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      72h             ; 'r'
        DB      61h             ; 'a'
        DB      6Ch             ; 'l'
        DB      69h             ; 'i'
        DB      61h             ; 'a'
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      02h
        DB      07h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      44h             ; 'D'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      69h             ; 'i'
        DB      67h             ; 'g'
        DB      6Eh             ; 'n'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      73h             ; 's'
        DB      20h             ; ' '
        DB      61h             ; 'a'
        DB      6Eh             ; 'n'
        DB      64h             ; 'd'
        DB      20h             ; ' '
        DB      6Dh             ; 'm'
        DB      61h             ; 'a'
        DB      6Eh             ; 'n'
        DB      75h             ; 'u'
        DB      66h             ; 'f'
        DB      61h             ; 'a'
        DB      63h             ; 'c'
        DB      74h             ; 't'
        DB      75h             ; 'u'
        DB      72h             ; 'r'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      73h             ; 's'
        DB      20h             ; ' '
        DB      6Fh             ; 'o'
        DB      66h             ; 'f'
        DB      20h             ; ' '
        DB      41h             ; 'A'
        DB      75h             ; 'u'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      72h             ; 'r'
        DB      61h             ; 'a'
        DB      6Ch             ; 'l'
        DB      69h             ; 'i'
        DB      61h             ; 'a'
        DB      27h             ; '''
        DB      73h             ; 's'
        DB      20h             ; ' '
        DB      6Fh             ; 'o'
        DB      77h             ; 'w'
        DB      6Eh             ; 'n'
        DB      20h             ; ' '
        DB      63h             ; 'c'
        DB      6Fh             ; 'o'
        DB      6Dh             ; 'm'
        DB      70h             ; 'p'
        DB      75h             ; 'u'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      85h
        DB      00h
        DB      0BEh
        DB      80h
        DB      86h
        DB      40h             ; '@'
        DB      0Ah
        DB      01h
        DB      00h
        DB      01h
        DB      02h
        DB      0Fh
        DB      81h
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      00h
        DB      84h
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      0E8h
        DB      0E1h
        DB      0E9h
        DB      0EAh
        DB      02h
        DB      0Bh
        DB      00h
        DB      84h
        DB      20h             ; ' '
        DB      53h             ; 'S'
        DB      65h             ; 'e'
        DB      6Ch             ; 'l'
        DB      66h             ; 'f'
        DB      20h             ; ' '
        DB      54h             ; 'T'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      20h             ; ' '
        DB      4Dh             ; 'M'
        DB      65h             ; 'e'
        DB      6Eh             ; 'n'
        DB      75h             ; 'u'
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      20h             ; ' '
        DB      0F4h
        DB      02h
        DB      0Fh
        DB      81h
        DB      81h
        DB      02h
        DB      07h
        DB      00h
        DB      84h
        DB      20h             ; ' '
        DB      02h
        DB      0Eh
        DB      20h             ; ' '
        DB      02h
        DB      07h
        DB      00h
        DB      90h
        DB      20h             ; ' '
        DB      0EBh
        DB      0EDh
        DB      0ECh
        DB      02h
        DB      02h
        DB      00h
        DB      0A6h
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      4Bh             ; 'K'
        DB      65h             ; 'e'
        DB      79h             ; 'y'
        DB      62h             ; 'b'
        DB      6Fh             ; 'o'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      64h             ; 'd'
        DB      02h
        DB      0Bh
        DB      00h
        DB      91h
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      50h             ; 'P'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      61h             ; 'a'
        DB      6Ch             ; 'l'
        DB      6Ch             ; 'l'
        DB      65h             ; 'e'
        DB      6Ch             ; 'l'
        DB      20h             ; ' '
        DB      50h             ; 'P'
        DB      72h             ; 'r'
        DB      69h             ; 'i'
        DB      6Eh             ; 'n'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      02h
        DB      0Bh
        DB      00h
        DB      89h
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      53h             ; 'S'
        DB      63h             ; 'c'
        DB      72h             ; 'r'
        DB      65h             ; 'e'
        DB      65h             ; 'e'
        DB      6Eh             ; 'n'
        DB      20h             ; ' '
        DB      52h             ; 'R'
        DB      41h             ; 'A'
        DB      4Dh             ; 'M'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Fh
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      53h             ; 'S'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      69h             ; 'i'
        DB      61h             ; 'a'
        DB      6Ch             ; 'l'
        DB      20h             ; ' '
        DB      50h             ; 'P'
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      74h             ; 't'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Eh
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      41h             ; 'A'
        DB      74h             ; 't'
        DB      74h             ; 't'
        DB      72h             ; 'r'
        DB      69h             ; 'i'
        DB      62h             ; 'b'
        DB      75h             ; 'u'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      20h             ; ' '
        DB      52h             ; 'R'
        DB      41h             ; 'A'
        DB      4Dh             ; 'M'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Ch
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      44h             ; 'D'
        DB      69h             ; 'i'
        DB      73h             ; 's'
        DB      6Bh             ; 'k'
        DB      20h             ; ' '
        DB      43h             ; 'C'
        DB      6Fh             ; 'o'
        DB      6Eh             ; 'n'
        DB      74h             ; 't'
        DB      72h             ; 'r'
        DB      6Fh             ; 'o'
        DB      6Ch             ; 'l'
        DB      6Ch             ; 'l'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Ah
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      43h             ; 'C'
        DB      6Fh             ; 'o'
        DB      6Ch             ; 'l'
        DB      6Fh             ; 'o'
        DB      75h             ; 'u'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      52h             ; 'R'
        DB      41h             ; 'A'
        DB      4Dh             ; 'M'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Fh
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      43h             ; 'C'
        DB      68h             ; 'h'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      61h             ; 'a'
        DB      63h             ; 'c'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      52h             ; 'R'
        DB      4Fh             ; 'O'
        DB      4Dh             ; 'M'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Ch
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      50h             ; 'P'
        DB      43h             ; 'C'
        DB      47h             ; 'G'
        DB      20h             ; ' '
        DB      42h             ; 'B'
        DB      61h             ; 'a'
        DB      6Eh             ; 'n'
        DB      6Bh             ; 'k'
        DB      02h
        DB      0Bh
        DB      00h
        DB      91h
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      53h             ; 'S'
        DB      79h             ; 'y'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      6Dh             ; 'm'
        DB      20h             ; ' '
        DB      52h             ; 'R'
        DB      4Fh             ; 'O'
        DB      4Dh             ; 'M'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Fh
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      4Dh             ; 'M'
        DB      65h             ; 'e'
        DB      6Dh             ; 'm'
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      79h             ; 'y'
        DB      20h             ; ' '
        DB      42h             ; 'B'
        DB      6Ch             ; 'l'
        DB      6Fh             ; 'o'
        DB      63h             ; 'c'
        DB      6Bh             ; 'k'
        DB      02h
        DB      0Bh
        DB      00h
        DB      8Dh
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      0Bh
        DB      49h             ; 'I'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      61h             ; 'a'
        DB      74h             ; 't'
        DB      69h             ; 'i'
        DB      6Fh             ; 'o'
        DB      6Eh             ; 'n'
        DB      20h             ; ' '
        DB      43h             ; 'C'
        DB      6Fh             ; 'o'
        DB      75h             ; 'u'
        DB      6Eh             ; 'n'
        DB      74h             ; 't'
        DB      3Ah             ; ':'
        DB      02h
        DB      0Fh
        DB      00h
        DB      8Fh
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      00h
        DB      0BEh
        DB      20h             ; ' '
        DB      81h
        DB      81h
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      45h             ; 'E'
        DB      53h             ; 'S'
        DB      43h             ; 'C'
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      62h             ; 'b'
        DB      79h             ; 'y'
        DB      70h             ; 'p'
        DB      61h             ; 'a'
        DB      73h             ; 's'
        DB      73h             ; 's'
        DB      20h             ; ' '
        DB      6Bh             ; 'k'
        DB      65h             ; 'e'
        DB      79h             ; 'y'
        DB      62h             ; 'b'
        DB      6Fh             ; 'o'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      64h             ; 'd'
        DB      20h             ; ' '
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      20h             ; ' '
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      02h
        DB      09h
        DB      42h             ; 'B'
        DB      52h             ; 'R'
        DB      4Bh             ; 'K'
        DB      02h
        DB      0Fh
        DB      20h             ; ' '
        DB      66h             ; 'f'
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      6Dh             ; 'm'
        DB      61h             ; 'a'
        DB      69h             ; 'i'
        DB      6Eh             ; 'n'
        DB      20h             ; ' '
        DB      6Dh             ; 'm'
        DB      65h             ; 'e'
        DB      6Eh             ; 'n'
        DB      75h             ; 'u'
        DB      00h
        DB      87h
        DB      20h             ; ' '
        DB      81h
        DB      01h
        DB      00h
        DB      80h
        DB      10h
        DB      75h             ; 'u'
        DB      00h
        DB      07h
        DB      0FFh
        DB      0FFh
        DB      00h
        DB      07h
        DB      00h
        DB      96h
        DB      38h             ; '8'
        DB      7Ch             ; '|'
        DB      0FFh
        DB      0FFh
        DB      7Ch             ; '|'
        DB      00h
        DB      86h
        DB      38h             ; '8'
        DB      00h
        DB      07h
        DB      1Fh
        DB      3Fh             ; '?'
        DB      3Ch             ; '<'
        DB      00h
        DB      86h
        DB      38h             ; '8'
        DB      00h
        DB      07h
        DB      0F0h
        DB      0F8h
        DB      78h             ; 'x'
        DB      00h
        DB      8Ch
        DB      38h             ; '8'
        DB      3Ch             ; '<'
        DB      3Fh             ; '?'
        DB      1Fh
        DB      00h
        DB      07h
        DB      00h
        DB      86h
        DB      38h             ; '8'
        DB      78h             ; 'x'
        DB      0F8h
        DB      0F0h
        DB      00h
        DB      0Eh
        DB      0FFh
        DB      0FFh
        DB      7Ch             ; '|'
        DB      00h
        DB      8Ch
        DB      38h             ; '8'
        DB      7Ch             ; '|'
        DB      0FFh
        DB      0FFh
        DB      00h
        DB      07h
        DB      00h
        DB      86h
        DB      38h             ; '8'
        DB      3Ch             ; '<'
        DB      3Fh             ; '?'
        DB      3Fh             ; '?'
        DB      3Ch             ; '<'
        DB      00h
        DB      8Ch
        DB      38h             ; '8'
        DB      78h             ; 'x'
        DB      0F8h
        DB      0F8h
        DB      78h             ; 'x'
        DB      00h
        DB      86h
        DB      38h             ; '8'
        DB      00h
        DB      08h
        DB      0FFh
        DB      80h
        DB      00h
        DB      03h
        DB      01h
        DB      07h
        DB      1Ch
        DB      00h
        DB      08h
        DB      80h
        DB      0FCh
        DB      06h
        DB      0Fh
        DB      78h             ; 'x'
        DB      0C0h
        DB      00h
        DB      0Bh
        DB      1Fh
        DB      70h             ; 'p'
        DB      0C0h
        DB      00h
        DB      0Dh
        DB      07h
        DB      0FCh
        DB      80h
        DB      00h
        DB      0Dh
        DB      0FFh
        DB      00h
        DB      0Fh
        DB      80h
        DB      0F8h
        DB      0Fh
        DB      01h
        DB      00h
        DB      0Eh
        DB      01h
        DB      07h
        DB      0Ch
        DB      18h
        DB      18h
        DB      00h
        DB      0Ch
        DB      80h
        DB      0C0h
        DB      60h             ; '`'
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      18h
        DB      18h
        DB      0Ch
        DB      07h
        DB      01h
        DB      00h
        DB      02h
        DB      01h
        DB      07h
        DB      0Ch
        DB      00h
        DB      84h
        DB      18h
        DB      30h             ; '0'
        DB      60h             ; '`'
        DB      60h             ; '`'
        DB      00h
        DB      84h
        DB      0C0h
        DB      60h             ; '`'
        DB      0F0h
        DB      3Ch             ; '<'
        DB      67h             ; 'g'
        DB      0CFh
        DB      9Fh
        DB      3Fh             ; '?'
        DB      7Fh             ; ''
        DB      0FFh
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      60h             ; '`'
        DB      60h             ; '`'
        DB      0C0h
        DB      80h
        DB      00h
        DB      03h
        DB      0C0h
        DB      0F0h
        DB      0D8h
        DB      0ACh
        DB      54h             ; 'T'
        DB      0ACh
        DB      00h
        DB      06h
        DB      0C0h
        DB      78h             ; 'x'
        DB      3Fh             ; '?'
        DB      0E0h
        DB      00h
        DB      02h
        DB      01h
        DB      03h
        DB      06h
        DB      0Ch
        DB      00h
        DB      06h
        DB      03h
        DB      0Eh
        DB      3Ch             ; '<'
        DB      0F7h
        DB      0AFh
        DB      5Fh             ; '_'
        DB      0BFh
        DB      7Fh             ; ''
        DB      0FFh
        DB      0FEh
        DB      00h
        DB      09h
        DB      01h
        DB      1Fh
        DB      0F5h
        DB      0EAh
        DB      0D5h
        DB      0AAh
        DB      55h             ; 'U'
        DB      00h
        DB      0Bh
        DB      0F0h
        DB      0FFh
        DB      0EAh
        DB      0D5h
        DB      0AAh
        DB      00h
        DB      0Bh
        DB      03h
        DB      0FFh
        DB      0BFh
        DB      7Fh             ; ''
        DB      0FFh
        DB      0Ch
        DB      07h
        DB      01h
        DB      00h
        DB      0Dh
        DB      19h
        DB      33h             ; '3'
        DB      0E7h
        DB      0Fh
        DB      07h
        DB      01h
        DB      00h
        DB      0Ah
        DB      0FFh
        DB      0FEh
        DB      0FDh
        DB      0FAh
        DB      0F5h
        DB      0EAh
        DB      3Dh             ; '='
        DB      03h
        DB      00h
        DB      08h
        DB      55h             ; 'U'
        DB      0ABh
        DB      57h             ; 'W'
        DB      0AFh
        DB      5Fh             ; '_'
        DB      0BFh
        DB      7Fh             ; ''
        DB      0FFh
        DB      0Fh
        DB      00h
        DB      07h
        DB      0FEh
        DB      0FDh
        DB      0FAh
        DB      0F5h
        DB      0EAh
        DB      0D5h
        DB      0AAh
        DB      55h             ; 'U'
        DB      0FFh
        DB      00h
        DB      07h
        DB      0ABh
        DB      57h             ; 'W'
        DB      0AFh
        DB      5Fh             ; '_'
        DB      0BFh
        DB      7Fh             ; ''
        DB      0FFh
        DB      0FFh
        DB      0F0h
        DB      00h
        DB      07h
        DB      0FDh
        DB      0FAh
        DB      0F5h
        DB      0EAh
        DB      0D5h
        DB      0AFh
        DB      7Ch             ; '|'
        DB      0C0h
        DB      00h
        DB      08h
        DB      54h             ; 'T'
        DB      0ACh
        DB      58h             ; 'X'
        DB      0B0h
        DB      0E0h
        DB      80h
        DB      00h
        DB      15h
        DB      3Fh             ; '?'
        DB      00h
        DB      84h
        DB      1Fh
        DB      00h
        DB      0Bh
        DB      00h
        DB      85h
        DB      0C0h
        DB      00h
        DB      0Ch
        DB      03h
        DB      0Ch
        DB      13h
        DB      12h
        DB      00h
        DB      0Ch
        DB      0C0h
        DB      30h             ; '0'
        DB      88h
        DB      48h             ; 'H'
        DB      00h
        DB      0Fh
        DB      1Eh
        DB      3Fh             ; '?'
        DB      3Fh             ; '?'
        DB      1Eh
        DB      00h
        DB      02h
        DB      0FFh
        DB      00h
        DB      8Ah
        DB      7Fh             ; ''
        DB      00h
        DB      8Ch
        DB      1Fh
        DB      00h
        DB      84h
        DB      9Fh
        DB      00h
        DB      85h
        DB      0C0h
        DB      0DFh
        DB      0FFh
        DB      0F9h
        DB      0E0h
        DB      0E0h
        DB      00h
        DB      86h
        DB      0C0h
        DB      13h
        DB      12h
        DB      0Ch
        DB      03h
        DB      00h
        DB      01h
        DB      80h
        DB      0F0h
        DB      0F8h
        DB      7Ch             ; '|'
        DB      7Eh             ; '~'
        DB      00h
        DB      84h
        DB      3Fh             ; '?'
        DB      0FFh
        DB      00h
        DB      01h
        DB      88h
        DB      48h             ; 'H'
        DB      30h             ; '0'
        DB      0C0h
        DB      00h
        DB      08h
        DB      80h
        DB      80h
        DB      80h
        DB      00h
        DB      06h
        DB      3Fh             ; '?'
        DB      00h
        DB      8Ah
        DB      1Fh
        DB      00h
        DB      05h
        DB      0C3h
        DB      0CFh
        DB      0DFh
        DB      0FFh
        DB      0E1h
        DB      00h
        DB      86h
        DB      0C0h
        DB      00h
        DB      05h
        DB      0E0h
        DB      0F8h
        DB      0FCh
        DB      0FEh
        DB      0FFh
        DB      0FFh
        DB      00h
        DB      85h
        DB      7Fh             ; ''
        DB      00h
        DB      05h
        DB      0Fh
        DB      3Fh             ; '?'
        DB      7Fh             ; ''
        DB      0FFh
        DB      87h
        DB      03h
        DB      00h
        DB      85h
        DB      01h
        DB      00h
        DB      05h
        DB      80h
        DB      0E0h
        DB      0F0h
        DB      0F8h
        DB      0F8h
        DB      00h
        DB      86h
        DB      0FCh
        DB      00h
        DB      05h
        DB      1Fh
        DB      7Fh             ; ''
        DB      0F8h
        DB      0E0h
        DB      0E0h
        DB      00h
        DB      86h
        DB      0C0h
        DB      00h
        DB      05h
        DB      0C0h
        DB      0F8h
        DB      7Ch             ; '|'
        DB      3Eh             ; '>'
        DB      3Fh             ; '?'
        DB      3Fh             ; '?'
        DB      3Fh             ; '?'
        DB      1Eh
        DB      00h
        DB      05h
        DB      04h
        DB      0Ch
        DB      1Ch
        DB      3Ch             ; '<'
        DB      0DCh
        DB      00h
        DB      89h
        DB      1Ch
        DB      00h
        DB      05h
        DB      0C1h
        DB      0CFh
        DB      0FFh
        DB      0F1h
        DB      0E0h
        DB      00h
        DB      86h
        DB      0C0h
        DB      00h
        DB      05h
        DB      0C0h
        DB      0F0h
        DB      0F9h
        DB      0FBh
        DB      0F7h
        DB      0Fh
        DB      0Fh
        DB      00h
        DB      84h
        DB      1Fh
        DB      00h
        DB      05h
        DB      1Fh
        DB      0FFh
        DB      0F9h
        DB      0E0h
        DB      0E0h
        DB      00h
        DB      86h
        DB      0C0h
        DB      00h
        DB      05h
        DB      80h
        DB      0F0h
        DB      0F8h
        DB      7Ch             ; '|'
        DB      7Eh             ; '~'
        DB      00h
        DB      86h
        DB      3Fh             ; '?'
        DB      00h
        DB      02h
        DB      07h
        DB      18h
        DB      20h             ; ' '
        DB      30h             ; '0'
        DB      78h             ; 'x'
        DB      78h             ; 'x'
        DB      30h             ; '0'
        DB      00h
        DB      05h
        DB      03h
        DB      0Ch
        DB      00h
        DB      05h
        DB      1Fh
        DB      0FFh
        DB      0F9h
        DB      0E0h
        DB      0E0h
        DB      00h
        DB      84h
        DB      0C0h
        DB      0FFh
        DB      0C0h
        DB      00h
        DB      05h
        DB      80h
        DB      0F0h
        DB      0F8h
        DB      7Ch             ; '|'
        DB      7Eh             ; '~'
        DB      00h
        DB      84h
        DB      3Fh             ; '?'
        DB      0FFh
        DB      00h
        DB      03h
        DB      0F0h
        DB      1Ch
        DB      0Eh
        DB      00h
        DB      84h
        DB      07h
        DB      0Eh
        DB      0Eh
        DB      1Ch
        DB      30h             ; '0'
        DB      0C0h
        DB      00h
        DB      09h
        DB      01h
        DB      03h
        DB      07h
        DB      0Fh
        DB      0Fh
        DB      00h
        DB      84h
        DB      1Fh
        DB      00h
        DB      07h
        DB      01h
        DB      03h
        DB      07h
        DB      0Fh
        DB      0Fh
        DB      00h
        DB      84h
        DB      9Fh
        DB      00h
        DB      07h
        DB      01h
        DB      03h
        DB      07h
        DB      0Fh
        DB      0Fh
        DB      9Fh
        DB      9Fh
        DB      9Fh
        DB      00h
        DB      88h
        DB      1Fh
        DB      3Fh             ; '?'
        DB      00h
        DB      08h
        DB      00h
        DB      87h
        DB      0C0h
        DB      0E0h
        DB      00h
        DB      08h
        DB      00h
        DB      87h
        DB      7Fh             ; ''
        DB      0FFh
        DB      00h
        DB      08h
        DB      00h
        DB      87h
        DB      01h
        DB      83h
        DB      00h
        DB      08h
        DB      00h
        DB      87h
        DB      0FCh
        DB      0FEh
        DB      00h
        DB      0Ah
        DB      7Fh             ; ''
        DB      0C1h
        DB      81h
        DB      00h
        DB      84h
        DB      80h
        DB      0C0h
        DB      0C1h
        DB      7Fh             ; ''
        DB      0C0h
        DB      80h
        DB      00h
        DB      02h
        DB      1Fh
        DB      0Fh
        DB      0Fh
        DB      07h
        DB      03h
        DB      01h
        DB      00h
        DB      01h
        DB      80h
        DB      00h
        DB      08h
        DB      0C0h
        DB      0C0h
        DB      0E0h
        DB      0F0h
        DB      0F8h
        DB      0FFh
        DB      0FFh
        DB      1Fh
        DB      00h
        DB      0Ah
        DB      0FFh
        DB      3Eh             ; '>'
        DB      00h
        DB      88h
        DB      1Ch
        DB      1Dh
        DB      1Eh
        DB      1Ch
        DB      1Ch
        DB      00h
        DB      02h
        DB      87h
        DB      00h
        DB      01h
        DB      01h
        DB      02h
        DB      04h
        DB      08h
        DB      10h
        DB      20h             ; ' '
        DB      40h             ; '@'
        DB      0A0h
        DB      0E0h
        DB      70h             ; 'p'
        DB      70h             ; 'p'
        DB      38h             ; '8'
        DB      1Fh
        DB      0Fh
        DB      0Fh
        DB      07h
        DB      03h
        DB      01h
        DB      00h
        DB      0Ah
        DB      0C0h
        DB      0C0h
        DB      0C0h
        DB      0E0h
        DB      0E0h
        DB      0F9h
        DB      0FFh
        DB      1Fh
        DB      00h
        DB      08h
        DB      3Fh             ; '?'
        DB      3Fh             ; '?'
        DB      3Fh             ; '?'
        DB      7Eh             ; '~'
        DB      7Ch             ; '|'
        DB      0F8h
        DB      0F0h
        DB      80h
        DB      00h
        DB      08h
        DB      9Fh
        DB      00h
        DB      85h
        DB      1Fh
        DB      1Ch
        DB      10h
        DB      00h
        DB      0Ah
        DB      0F0h
        DB      0C0h
        DB      00h
        DB      0Fh
        DB      01h
        DB      00h
        DB      85h
        DB      03h
        DB      01h
        DB      01h
        DB      00h
        DB      01h
        DB      01h
        DB      03h
        DB      07h
        DB      07h
        DB      9Fh
        DB      0Fh
        DB      0Fh
        DB      07h
        DB      03h
        DB      01h
        DB      00h
        DB      0Ah
        DB      0C0h
        DB      0E0h
        DB      0E0h
        DB      0F0h
        DB      0F8h
        DB      0FFh
        DB      0FFh
        DB      1Fh
        DB      00h
        DB      0Bh
        DB      0C0h
        DB      0C0h
        DB      00h
        DB      85h
        DB      0E0h
        DB      0C0h
        DB      00h
        DB      01h
        DB      0C0h
        DB      0E0h
        DB      60h             ; '`'
        DB      70h             ; 'p'
        DB      00h
        DB      86h
        DB      1Ch
        DB      3Eh             ; '>'
        DB      0FFh
        DB      00h
        DB      09h
        DB      01h
        DB      03h
        DB      06h
        DB      1Ch
        DB      0F8h
        DB      0F0h
        DB      80h
        DB      00h
        DB      08h
        DB      10h
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      40h             ; '@'
        DB      7Eh             ; '~'
        DB      47h             ; 'G'
        DB      41h             ; 'A'
        DB      40h             ; '@'
        DB      00h
        DB      08h
        DB      00h
        DB      84h
        DB      07h
        DB      03h
        DB      03h
        DB      01h
        DB      00h
        DB      09h
        DB      00h
        DB      85h
        DB      70h             ; 'p'
        DB      0E0h
        DB      0C0h
        DB      00h
        DB      09h
        DB      77h             ; 'w'
        DB      0FDh
        DB      0F7h
        DB      0FFh
        DB      0F5h
        DB      0FFh
        DB      0F7h
        DB      0FDh
        DB      0F7h
        DB      0FFh
        DB      0F5h
        DB      0FAh
        DB      00h
        DB      84h
        DB      0FFh
        DB      1Ch
        DB      1Ch
        DB      0Eh
        DB      0Dh
        DB      07h
        DB      03h
        DB      03h
        DB      8Fh
        DB      00h
        DB      0Ah
        DB      01h
        DB      01h
        DB      03h
        DB      0FFh
        DB      0FEh
        DB      7Ch             ; '|'
        DB      00h
        DB      0Dh
        DB      80h
        DB      81h
        DB      7Fh             ; ''
        DB      00h
        DB      0Dh
        DB      80h
        DB      0C0h
        DB      0F0h
        DB      00h
        DB      0Fh
        DB      01h
        DB      00h
        DB      0Fh
        DB      0C0h
        DB      00h
        DB      08h
        DB      0FFh
        DB      55h             ; 'U'
        DB      0FFh
        DB      0FFh
        DB      55h             ; 'U'
        DB      0FFh
        DB      0FFh
        DB      55h             ; 'U'
        DB      0FFh
        DB      0FFh
        DB      55h             ; 'U'
        DB      0AAh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      80h
        DB      0FFh
        DB      55h             ; 'U'
        DB      0FFh
        DB      0FFh
        DB      55h             ; 'U'
        DB      0FFh
        DB      0FFh
        DB      55h             ; 'U'
        DB      0FFh
        DB      0FFh
        DB      55h             ; 'U'
        DB      0AAh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      00h
        DB      01h
        DB      3Fh             ; '?'
        DB      00h
        DB      0Bh
        DB      87h
        DB      4Fh             ; 'O'
        DB      7Eh             ; '~'
        DB      3Bh             ; ';'
        DB      0DCh
        DB      7Eh             ; '~'
        DB      0D2h
        DB      0F2h
        DB      5Eh             ; '^'
        DB      0FEh
        DB      0DEh
        DB      7Eh             ; '~'
        DB      0DEh
        DB      0FEh
        DB      5Eh             ; '^'
        DB      0BEh
        DB      00h
        DB      84h
        DB      0FEh
        DB      00h
        DB      85h
        DB      0FFh
        DB      7Fh             ; ''
        DB      3Fh             ; '?'
        DB      1Eh
        DB      00h
        DB      08h
        DB      7Fh             ; ''
        DB      00h
        DB      86h
        DB      43h             ; 'C'
        DB      7Fh             ; ''
        DB      00h
        DB      08h
        DB      00h
        DB      88h
        DB      0FFh
        DB      00h
        DB      08h
        DB      0C0h
        DB      00h
        DB      86h
        DB      0E0h
        DB      0EFh
        DB      00h
        DB      08h
        DB      00h
        DB      87h
        DB      7Eh             ; '~'
        DB      7Ch             ; '|'
        DB      00h
        DB      09h
        DB      7Ch             ; '|'
        DB      80h
        DB      80h
        DB      80h
        DB      40h             ; '@'
        DB      40h             ; '@'
        DB      20h             ; ' '
        DB      10h
        DB      08h
        DB      04h
        DB      02h
        DB      01h
        DB      00h
        DB      04h
        DB      80h
        DB      40h             ; '@'
        DB      21h             ; '!'
        DB      21h             ; '!'
        DB      00h
        DB      84h
        DB      20h             ; ' '
        DB      40h             ; '@'
        DB      0C0h
        DB      80h
        DB      80h
        DB      00h
        DB      04h
        DB      38h             ; '8'
        DB      44h             ; 'D'
        DB      0C4h
        DB      0C4h
        DB      0E4h
        DB      0D8h
        DB      0C0h
        DB      0C0h
        DB      0E0h
        DB      0E0h
        DB      60h             ; '`'
        DB      70h             ; 'p'
        DB      70h             ; 'p'
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      03h
        DB      01h
        DB      00h
        DB      0Eh
        DB      70h             ; 'p'
        DB      60h             ; '`'
        DB      0C0h
        DB      0C0h
        DB      80h
        DB      00h
        DB      0Ch
        DB      80h
        DB      0C0h
        DB      0C0h
        DB      61h             ; 'a'
        DB      3Fh             ; '?'
        DB      1Eh
        DB      00h
        DB      09h
        DB      7Fh             ; ''
        DB      0C0h
        DB      0AAh
        DB      0AAh
        DB      0AEh
        DB      0AAh
        DB      0ABh
        DB      0AAh
        DB      0AEh
        DB      0AAh
        DB      0AAh
        DB      0C0h
        DB      7Fh             ; ''
        DB      0C0h
        DB      0AAh
        DB      0AAh
        DB      0F7h
        DB      1Ch
        DB      0AAh
        DB      0AAh
        DB      0EAh
        DB      0AAh
        DB      0AAh
        DB      0AAh
        DB      0EAh
        DB      0AAh
        DB      0AAh
        DB      1Ch
        DB      0F7h
        DB      1Ch
        DB      0AAh
        DB      0AAh
        DB      0FEh
        DB      03h
        DB      00h
        DB      89h
        DB      0A9h
        DB      03h
        DB      0FEh
        DB      03h
        DB      0A9h
        DB      0A9h
        DB      00h
        DB      87h
        DB      0AAh
        DB      0C0h
        DB      7Fh             ; ''
        DB      00h
        DB      07h
        DB      00h
        DB      87h
        DB      0AAh
        DB      1Ch
        DB      0F7h
        DB      00h
        DB      07h
        DB      00h
        DB      87h
        DB      0A9h
        DB      03h
        DB      0FEh
        DB      00h
        DB      07h
        DB      00h
        DB      90h
        DB      0FFh
        DB      0F5h
        DB      00h

        ; --- START PROC L8DF5 ---
L8DF5:  LD      A,0Dh
        LD      (0F1DDh),A
        LD      HL,8E62h
L8DFD:  PUSH    HL
        INC     HL
        CALL    L8E41
        POP     HL
        LD      A,(HL)
        CP      0FFh
        JR      NZ,L8E0C
        LD      A,06h
        JR      L8E2F

L8E0C:  CALL    L8282
        CP      (HL)
        JR      NZ,L8E1A
        INC     HL
L8E13:  BIT     7,(HL)
        INC     HL
        JR      Z,L8E13
        JR      L8DFD

L8E1A:  CP      30h             ; '0'
        JR      Z,L8E2D
        CP      36h             ; '6'
        JR      NZ,L8E26
        POP     HL
        JP      L81B1

L8E26:  PUSH    HL
        CALL    L8479
        POP     HL
        JR      L8E0C

L8E2D:  LD      A,78h           ; 'x'
L8E2F:  LD      (0F1DCh),A
        LD      A,20h           ; ' '
        LD      (0F1DDh),A
        LD      HL,92D3h
        LD      DE,0382h
        CALL    L82B3
        RET

        ; --- START PROC L8E41 ---
L8E41:  LD      DE,0F1DCh
        LD      B,09h
        LD      A,20h           ; ' '
        CALL    L8E5D
L8E4B:  LD      A,(HL)
        LD      B,A
        AND     7Fh             ; ''
        CP      20h             ; ' '
        JR      NC,L8E55
        OR      80h
L8E55:  LD      (DE),A
        BIT     7,B
        RET     NZ
        INC     DE
        INC     HL
        JR      L8E4B

        ; --- START PROC L8E5D ---
L8E5D:  DEC     DE
        LD      (DE),A
        DJNZ    L8E5D
        RET

L8E62:  DB      30h             ; '0'
        DB      45h             ; 'E'
        DB      53h             ; 'S'
        DB      0C3h
        DB      21h             ; '!'
        DB      0B1h
        DB      22h             ; '"'
        DB      0B2h
        DB      23h             ; '#'
        DB      0B3h
        DB      24h             ; '$'
        DB      0B4h
        DB      25h             ; '%'
        DB      0B5h
        DB      26h             ; '&'
        DB      0B6h
        DB      27h             ; '''
        DB      0B7h
        DB      28h             ; '('
        DB      0B8h
        DB      29h             ; ')'
        DB      0B9h
        DB      20h             ; ' '
        DB      0B0h
        DB      2Ah             ; '*'
        DB      0BAh
        DB      2Dh             ; '-'
        DB      0ADh
        DB      1Eh
        DB      0DEh
        DB      31h             ; '1'
        DB      42h             ; 'B'
        DB      0D3h
        DB      32h             ; '2'
        DB      54h             ; 'T'
        DB      41h             ; 'A'
        DB      0C2h
        DB      11h
        DB      0D1h
        DB      17h
        DB      0D7h
        DB      05h
        DB      0C5h
        DB      12h
        DB      0D2h
        DB      14h
        DB      0D4h
        DB      19h
        DB      0D9h
        DB      15h
        DB      0D5h
        DB      09h
        DB      0C9h
        DB      0Fh
        DB      0CFh
        DB      10h
        DB      0D0h
        DB      1Bh
        DB      0DBh
        DB      1Dh
        DB      0DDh
        DB      33h             ; '3'
        DB      4Ch             ; 'L'
        DB      0C6h
        DB      34h             ; '4'
        DB      52h             ; 'R'
        DB      45h             ; 'E'
        DB      0D4h
        DB      39h             ; '9'
        DB      43h             ; 'C'
        DB      54h             ; 'T'
        DB      52h             ; 'R'
        DB      0CCh
        DB      35h             ; '5'
        DB      4Ch             ; 'L'
        DB      4Fh             ; 'O'
        DB      43h             ; 'C'
        DB      0CBh
        DB      01h
        DB      0C1h
        DB      13h
        DB      0D3h
        DB      04h
        DB      0C4h
        DB      06h
        DB      0C6h
        DB      07h
        DB      0C7h
        DB      08h
        DB      0C8h
        DB      0Ah
        DB      0CAh
        DB      0Bh
        DB      0CBh
        DB      0Ch
        DB      0CCh
        DB      2Bh             ; '+'
        DB      0BBh
        DB      00h
        DB      0C0h
        DB      1Ch
        DB      0DCh
        DB      1Fh
        DB      44h             ; 'D'
        DB      45h             ; 'E'
        DB      0CCh
        DB      36h             ; '6'
        DB      42h             ; 'B'
        DB      52h             ; 'R'
        DB      0CBh
        DB      3Fh             ; '?'
        DB      53h             ; 'S'
        DB      48h             ; 'H'
        DB      49h             ; 'I'
        DB      46h             ; 'F'
        DB      0D4h
        DB      1Ah
        DB      0DAh
        DB      18h
        DB      0D8h
        DB      03h
        DB      0C3h
        DB      16h
        DB      0D6h
        DB      02h
        DB      0C2h
        DB      0Eh
        DB      0CEh
        DB      0Dh
        DB      0CDh
        DB      2Ch             ; ','
        DB      0ACh
        DB      2Eh             ; '.'
        DB      0AEh
        DB      2Fh             ; '/'
        DB      0AFh
        DB      3Fh             ; '?'
        DB      53h             ; 'S'
        DB      48h             ; 'H'
        DB      49h             ; 'I'
        DB      46h             ; 'F'
        DB      0D4h
        DB      38h             ; '8'
        DB      55h             ; 'U'
        DB      0D0h
        DB      3Ah             ; ':'
        DB      44h             ; 'D'
        DB      4Fh             ; 'O'
        DB      57h             ; 'W'
        DB      0CEh
        DB      37h             ; '7'
        DB      53h             ; 'S'
        DB      50h             ; 'P'
        DB      41h             ; 'A'
        DB      43h             ; 'C'
        DB      0C5h
        DB      3Bh             ; ';'
        DB      4Ch             ; 'L'
        DB      45h             ; 'E'
        DB      46h             ; 'F'
        DB      0D4h
        DB      3Eh             ; '>'
        DB      52h             ; 'R'
        DB      49h             ; 'I'
        DB      47h             ; 'G'
        DB      48h             ; 'H'
        DB      0D4h
        DB      0FFh
        DB      0A0h
        DB      3Ah             ; ':'
        DB      32h             ; '2'
        DB      01h
        DB      0CBh
        DB      4Fh             ; 'O'
        DB      0C8h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      0F9h
        DB      0F1h
        DB      3Eh             ; '>'
        DB      0FFh
        DB      32h             ; '2'
        DB      31h             ; '1'
        DB      01h
        DB      21h             ; '!'
        DB      9Dh
        DB      8Fh
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      0B7h
        DB      20h             ; ' '
        DB      10h
        DB      21h             ; '!'
        DB      88h
        DB      8Fh
        DB      0CDh
        DB      61h             ; 'a'
        DB      8Fh
        DB      3Ah             ; ':'
        DB      32h             ; '2'
        DB      01h
        DB      20h             ; ' '
        DB      0Dh
        DB      3Ah             ; ':'
        DB      32h             ; '2'
        DB      01h
        DB      18h
        DB      1Dh
        DB      0CDh
        DB      61h             ; 'a'
        DB      8Fh
        DB      3Ah             ; ':'
        DB      32h             ; '2'
        DB      01h
        DB      28h             ; '('
        DB      15h
        DB      0CBh
        DB      8Fh
        DB      32h             ; '2'
        DB      32h             ; '2'
        DB      01h
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      0F9h
        DB      0F1h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      18h
        DB      0Ch
        DB      0CBh
        DB      0CFh
        DB      32h             ; '2'
        DB      32h             ; '2'
        DB      01h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      0F9h
        DB      0F1h
        DB      3Eh             ; '>'
        DB      06h
        DB      32h             ; '2'
        DB      0F8h
        DB      0F1h
        DB      0C9h
        DB      0FBh
        DB      3Eh             ; '>'
        DB      0FFh
        DB      32h             ; '2'
        DB      31h             ; '1'
        DB      01h
        DB      7Eh             ; '~'
        DB      0B7h
        DB      0C8h
        DB      0D3h
        DB      00h
        DB      23h             ; '#'
        DB      0E5h
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      3Ah             ; ':'
        DB      31h             ; '1'
        DB      01h
        DB      0B7h
        DB      28h             ; '('
        DB      09h
        DB      2Bh             ; '+'
        DB      7Ch             ; '|'
        DB      0B5h
        DB      20h             ; ' '
        DB      0F5h
        DB      0E1h
        DB      0F6h
        DB      0FFh
        DB      0C9h
        DB      0E1h
        DB      18h
        DB      0DEh
        DB      03h
        DB      01h
        DB      2Eh             ; '.'
        DB      4Fh             ; 'O'
        DB      83h
        DB      07h
        DB      31h             ; '1'
        DB      32h             ; '2'
        DB      38h             ; '8'
        DB      6Bh             ; 'k'
        DB      20h             ; ' '
        DB      50h             ; 'P'
        DB      72h             ; 'r'
        DB      69h             ; 'i'
        DB      6Eh             ; 'n'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      54h             ; 'T'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      0Dh
        DB      0Ah
        DB      00h
        DB      0Dh
        DB      0Dh
        DB      0Dh
        DB      0Dh
        DB      0Dh
        DB      0Dh
        DB      00h
        DB      0E5h
        DB      21h             ; '!'
        DB      18h
        DB      0F3h
        DB      34h             ; '4'
        DB      7Eh             ; '~'
        DB      0FEh
        DB      3Ah             ; ':'
        DB      20h             ; ' '
        DB      05h
        DB      36h             ; '6'
        DB      30h             ; '0'
        DB      2Bh             ; '+'
        DB      18h
        DB      0F5h
        DB      0E1h
        DB      0C9h
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      30h             ; '0'
        DB      6Bh             ; 'k'
        DB      3Ah             ; ':'
        DB      1Ch
        DB      0F3h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      1Dh
        DB      0F3h
        DB      21h             ; '!'
        DB      16h
        DB      0F3h
        DB      22h             ; '"'
        DB      36h             ; '6'
        DB      01h
        DB      11h
        DB      16h
        DB      0F3h
        DB      21h             ; '!'
        DB      0B5h
        DB      8Fh
        DB      01h
        DB      04h
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0AFh
        DB      4Fh             ; 'O'
        DB      0CDh
        DB      60h             ; '`'
        DB      90h
        DB      0C2h
        DB      3Ch             ; '<'
        DB      90h
        DB      79h             ; 'y'
        DB      0C6h
        DB      30h             ; '0'
        DB      32h             ; '2'
        DB      13h
        DB      0F3h
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      06h
        DB      20h             ; ' '
        DB      0C5h
        DB      01h
        DB      00h
        DB      04h
        DB      0CDh
        DB      8Dh
        DB      90h
        DB      20h             ; ' '
        DB      58h             ; 'X'
        DB      0CDh
        DB      0A4h
        DB      8Fh
        DB      0AFh
        DB      0CDh
        DB      00h
        DB      85h
        DB      0CAh
        DB      29h             ; ')'
        DB      90h
        DB      3Ch             ; '<'
        DB      0FEh
        DB      40h             ; '@'
        DB      20h             ; ' '
        DB      0F5h
        DB      0C1h
        DB      10h
        DB      0E5h
        DB      79h             ; 'y'
        DB      3Ch             ; '<'
        DB      0FEh
        DB      04h
        DB      20h             ; ' '
        DB      0CDh
        DB      0AFh
        DB      0D3h
        DB      50h             ; 'P'
        DB      3Eh             ; '>'
        DB      06h
        DB      32h             ; '2'
        DB      1Ch
        DB      0F3h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      1Dh
        DB      0F3h
        DB      0C9h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      1Ch
        DB      0F3h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      1Dh
        DB      0F3h
        DB      06h
        DB      09h
        DB      11h
        DB      1Ch
        DB      0F3h
        DB      0C3h
        DB      5Dh             ; ']'
        DB      8Eh
        DB      0C1h
        DB      0AFh
        DB      0D3h
        DB      50h             ; 'P'
        DB      0CDh
        DB      17h
        DB      90h
        DB      21h             ; '!'
        DB      4Bh             ; 'K'
        DB      65h             ; 'e'
        DB      22h             ; '"'
        DB      16h
        DB      0F3h
        DB      3Eh             ; '>'
        DB      79h             ; 'y'
        DB      32h             ; '2'
        DB      18h
        DB      0F3h
        DB      0C9h
        DB      0AFh
        DB      0D3h
        DB      50h             ; 'P'
        DB      0CDh
        DB      17h
        DB      90h
        DB      21h             ; '!'
        DB      53h             ; 'S'
        DB      57h             ; 'W'
        DB      22h             ; '"'
        DB      16h
        DB      0F3h
        DB      0C9h
        DB      0F1h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      1Ch
        DB      0F3h
        DB      0AFh
        DB      0D3h
        DB      50h             ; 'P'
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      1Dh
        DB      0F3h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      0EDh
        DB      7Bh             ; '{'
        DB      80h
        DB      0F4h
        DB      0C9h
        DB      0E1h
        DB      0CDh
        DB      85h
        DB      90h
        DB      0D3h
        DB      50h             ; 'P'
        DB      0B7h
        DB      28h             ; '('
        DB      1Bh
        DB      47h             ; 'G'
        DB      3Eh             ; '>'
        DB      55h             ; 'U'
        DB      32h             ; '2'
        DB      00h
        DB      00h
        DB      79h             ; 'y'
        DB      3Dh             ; '='
        DB      0CDh
        DB      85h
        DB      90h
        DB      0D3h
        DB      50h             ; 'P'
        DB      3Eh             ; '>'
        DB      0AAh
        DB      32h             ; '2'
        DB      00h
        DB      00h
        DB      78h             ; 'x'
        DB      0D3h
        DB      50h             ; 'P'
        DB      3Ah             ; ':'
        DB      00h
        DB      00h
        DB      0EEh
        DB      0AAh
        DB      3Ch             ; '<'
        DB      0E9h
        DB      1Fh
        DB      30h             ; '0'
        DB      02h
        DB      0CBh
        DB      0CFh
        DB      0E6h
        DB      03h
        DB      0C9h
        DB      78h             ; 'x'
        DB      0B1h
        DB      0C8h
        DB      0Bh
        DB      7Eh             ; '~'
        DB      5Fh             ; '_'
        DB      2Fh             ; '/'
        DB      77h             ; 'w'
        DB      0BEh
        DB      20h             ; ' '
        DB      10h
        DB      16h
        DB      08h
        DB      3Eh             ; '>'
        DB      01h
        DB      77h             ; 'w'
        DB      0BEh
        DB      20h             ; ' '
        DB      08h
        DB      07h
        DB      15h
        DB      20h             ; ' '
        DB      0F8h
        DB      73h             ; 's'
        DB      23h             ; '#'
        DB      18h
        DB      0E5h
        DB      73h             ; 's'
        DB      0AFh
        DB      0D3h
        DB      08h
        DB      3Eh             ; '>'
        DB      1Fh
        DB      0D3h
        DB      0Ch
        DB      3Eh             ; '>'
        DB      80h
        DB      0D3h
        DB      1Ch
        DB      3Eh             ; '>'
        DB      00h
        DB      0D3h
        DB      50h             ; 'P'
        DB      0CDh
        DB      96h
        DB      84h
        DB      0F6h
        DB      0FFh
        DB      0C9h
        DB      3Ah             ; ':'
        DB      1Ch
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      21h             ; '!'
        DB      16h
        DB      0F2h
        DB      22h             ; '"'
        DB      36h             ; '6'
        DB      01h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      1Dh
        DB      0F2h
        DB      0CDh
        DB      0EDh
        DB      90h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      1Dh
        DB      0F2h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      1Dh
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      1Ch
        DB      0F2h
        DB      0C9h
        DB      26h             ; '&'
        DB      0F0h
        DB      01h
        DB      00h
        DB      08h
        DB      69h             ; 'i'
        DB      18h
        DB      98h
        DB      3Ah             ; ':'
        DB      5Ch             ; '\'
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      21h             ; '!'
        DB      56h             ; 'V'
        DB      0F2h
        DB      22h             ; '"'
        DB      36h             ; '6'
        DB      01h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      5Dh             ; ']'
        DB      0F2h
        DB      0CDh
        DB      24h             ; '$'
        DB      91h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      5Dh             ; ']'
        DB      0F2h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      5Dh             ; ']'
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      5Ch             ; '\'
        DB      0F2h
        DB      0C9h
        DB      3Eh             ; '>'
        DB      90h
        DB      0D3h
        DB      1Ch
        DB      0CDh
        DB      0EDh
        DB      90h
        DB      3Eh             ; '>'
        DB      80h
        DB      0D3h
        DB      1Ch
        DB      0C9h
        DB      26h             ; '&'
        DB      0F8h
        DB      18h
        DB      0BBh
        DB      3Ah             ; ':'
        DB      0DCh
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      21h             ; '!'
        DB      0D6h
        DB      0F2h
        DB      22h             ; '"'
        DB      36h             ; '6'
        DB      01h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      0DDh
        DB      0F2h
        DB      0CDh
        DB      63h             ; 'c'
        DB      91h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      0DDh
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      0DCh
        DB      0F2h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      0DDh
        DB      0F2h
        DB      0C9h
        DB      06h
        DB      80h
        DB      21h             ; '!'
        DB      0D3h
        DB      0F2h
        DB      0CBh
        DB      58h             ; 'X'
        DB      20h             ; ' '
        DB      0Fh
        DB      78h             ; 'x'
        DB      0D3h
        DB      1Ch
        DB      0C6h
        DB      0B0h
        DB      77h             ; 'w'
        DB      0C5h
        DB      0CDh
        DB      30h             ; '0'
        DB      91h
        DB      0C1h
        DB      0C0h
        DB      04h
        DB      18h
        DB      0EAh
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      3Eh             ; '>'
        DB      80h
        DB      0D3h
        DB      1Ch
        DB      0AFh
        DB      0C9h
        DB      3Ah             ; ':'
        DB      9Ch
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      21h             ; '!'
        DB      96h
        DB      0F2h
        DB      22h             ; '"'
        DB      36h             ; '6'
        DB      01h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      9Dh
        DB      0F2h
        DB      0CDh
        DB      0B2h
        DB      91h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      9Dh
        DB      0F2h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      9Dh
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      9Ch
        DB      0F2h
        DB      0C9h
        DB      21h             ; '!'
        DB      00h
        DB      0F8h
        DB      7Eh             ; '~'
        DB      2Fh             ; '/'
        DB      47h             ; 'G'
        DB      3Eh             ; '>'
        DB      40h             ; '@'
        DB      0D3h
        DB      08h
        DB      56h             ; 'V'
        DB      70h             ; 'p'
        DB      0AFh
        DB      0D3h
        DB      08h
        DB      78h             ; 'x'
        DB      2Fh             ; '/'
        DB      0BEh
        DB      77h             ; 'w'
        DB      0C0h
        DB      3Eh             ; '>'
        DB      40h             ; '@'
        DB      0D3h
        DB      08h
        DB      72h             ; 'r'
        DB      0CDh
        DB      30h             ; '0'
        DB      91h
        DB      3Eh             ; '>'
        DB      00h
        DB      0D3h
        DB      08h
        DB      0C9h
        DB      3Ah             ; ':'
        DB      78h             ; 'x'
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      0CDh
        DB      0F2h
        DB      91h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      79h             ; 'y'
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      78h             ; 'x'
        DB      0F2h
        DB      0C9h

        ; --- START PROC L91F2 ---
L91F2:  IN      A,(46h)         ; 'F'
        CPL
        OUT     (46h),A         ; 'F'
        LD      B,A
        EX      (SP),HL
        EX      (SP),HL
        EX      (SP),HL
        EX      (SP),HL
        IN      A,(46h)         ; 'F'
        CP      B
        RET

L9200:  DB      3Ah             ; ':'
        DB      38h             ; '8'
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      0CDh
        DB      1Fh
        DB      92h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      39h             ; '9'
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      38h             ; '8'
        DB      0F2h
        DB      0C9h
        DB      0DBh
        DB      02h
        DB      4Fh             ; 'O'
        DB      3Eh             ; '>'
        DB      04h
        DB      0D3h
        DB      02h
        DB      06h
        DB      00h
        DB      10h
        DB      0FEh
        DB      0DBh
        DB      02h
        DB      0E6h
        DB      18h
        DB      0FEh
        DB      18h
        DB      20h             ; ' '
        DB      0Ah
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      0D3h
        DB      02h
        DB      10h
        DB      0FEh
        DB      0DBh
        DB      02h
        DB      0E6h
        DB      18h
        DB      79h             ; 'y'
        DB      0D3h
        DB      02h
        DB      0C9h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      0F9h
        DB      0F2h
        DB      21h             ; '!'
        DB      00h
        DB      80h
        DB      01h
        DB      00h
        DB      20h             ; ' '
        DB      0CDh
        DB      5Eh             ; '^'
        DB      92h
        DB      0B7h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      02h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      0F8h
        DB      0F2h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      0F9h
        DB      0F2h
        DB      0C9h
        DB      1Eh
        DB      00h
        DB      7Eh             ; '~'
        DB      83h
        DB      5Fh             ; '_'
        DB      23h             ; '#'
        DB      0Bh
        DB      78h             ; 'x'
        DB      0B1h
        DB      20h             ; ' '
        DB      0F7h
        DB      7Bh             ; '{'
        DB      0C9h
        DB      3Ah             ; ':'
        DB      0B8h
        DB      0F2h
        DB      0FEh
        DB      78h             ; 'x'
        DB      0C8h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      32h             ; '2'
        DB      0B9h
        DB      0F2h
        DB      0CDh
        DB      94h
        DB      92h
        DB      3Eh             ; '>'
        DB      06h
        DB      28h             ; '('
        DB      0Eh
        DB      3Ah             ; ':'
        DB      34h             ; '4'
        DB      01h
        DB      21h             ; '!'
        DB      0B9h
        DB      0F2h
        DB      0CDh
        DB      0A8h
        DB      92h
        DB      3Eh             ; '>'
        DB      78h             ; 'x'
        DB      0CDh
        DB      79h             ; 'y'
        DB      84h
        DB      32h             ; '2'
        DB      0B8h
        DB      0F2h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      0B9h
        DB      0F2h
        DB      0C9h
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      01h
        DB      00h
        DB      08h
        DB      0CDh
        DB      5Eh             ; '^'
        DB      92h
        DB      0FEh
        DB      61h             ; 'a'
        DB      3Eh             ; '>'
        DB      00h
        DB      0D3h
        DB      0Bh
        DB      0C9h
        DB      0E5h
        DB      36h             ; '6'
        DB      30h             ; '0'
        DB      0FEh
        DB      64h             ; 'd'
        DB      38h             ; '8'
        DB      05h
        DB      0D6h
        DB      64h             ; 'd'
        DB      34h             ; '4'
        DB      18h
        DB      0F7h
        DB      23h             ; '#'
        DB      36h             ; '6'
        DB      30h             ; '0'
        DB      0FEh
        DB      0Ah
        DB      38h             ; '8'
        DB      05h
        DB      0D6h
        DB      0Ah
        DB      34h             ; '4'
        DB      18h
        DB      0F7h
        DB      23h             ; '#'
        DB      0C6h
        DB      30h             ; '0'
        DB      77h             ; 'w'
        DB      0E1h
        DB      7Eh             ; '~'
        DB      0FEh
        DB      30h             ; '0'
        DB      0C0h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      7Eh             ; '~'
        DB      0FEh
        DB      30h             ; '0'
        DB      0C0h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      0C9h
        DB      3Ch             ; '<'
        DB      01h
        DB      01h
        DB      00h
        DB      01h
        DB      02h
        DB      0Fh
        DB      50h             ; 'P'
        DB      72h             ; 'r'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      73h             ; 's'
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      45h             ; 'E'
        DB      53h             ; 'S'
        DB      43h             ; 'C'
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      72h             ; 'r'
        DB      65h             ; 'e'
        DB      74h             ; 't'
        DB      75h             ; 'u'
        DB      72h             ; 'r'
        DB      6Eh             ; 'n'
        DB      20h             ; ' '
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      4Bh             ; 'K'
        DB      65h             ; 'e'
        DB      72h             ; 'r'
        DB      6Eh             ; 'n'
        DB      65h             ; 'e'
        DB      6Ch             ; 'l'
        DB      20h             ; ' '
        DB      4Dh             ; 'M'
        DB      65h             ; 'e'
        DB      6Eh             ; 'n'
        DB      75h             ; 'u'
        DB      20h             ; ' '
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      02h
        DB      09h
        DB      20h             ; ' '
        DB      53h             ; 'S'
        DB      50h             ; 'P'
        DB      41h             ; 'A'
        DB      43h             ; 'C'
        DB      45h             ; 'E'
        DB      20h             ; ' '
        DB      02h
        DB      0Fh
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      72h             ; 'r'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      74h             ; 't'
        DB      20h             ; ' '
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      73h             ; 's'


                                        ; Entry Point
                                        ; --- START PROC L931E ---

;;;   This code is relocated to 0x100 to act as interrupt service routine

L931E:  PUSH    AF                      ; Interrupt service routine
        XOR     A
        LD      (0131h),A
        POP     AF
        EI
        RETI

        ; Entry Point
        ; --- START PROC L9327 ---
L9327:  PUSH    HL
        PUSH    BC
        LD      HL,011Eh                ; This actually points to 0x933c - after relocation to 0x0100
L932C:  LD      A,(HL)
        OR      A
        JR      Z,L9338
        LD      B,A
        INC     HL
        LD      C,(HL)
        INC     HL
        OTIR
        JR      L932C
L9338:  EI
        POP     BC
        POP     HL
        RET
L933C:  DB      03h     ; Number of port writes
        DB      01h     ; The target port - PIO Port A Control Port
        DB      2Eh     ; 1
        DB      0Fh     ; 2
        DB      83h     ; 3

        DB      04h     ; Number of port writes
        DB      03h     ; Target port - PIO Port B Control Port
        DB      0FFh    ; 1
        DB      1Ah     ; 2
        DB      37h     ; 3
        DB      0FDh    ; 4

        DB      01h     ; Number of port writes
        DB      02h     ; Target port - PIO Port B Data Port
        DB      20h     ; 1

        DB      00h     ; End of table


        DB      00h
        DB      00h
        DB      01h
        DB      00h
        DB      00h
        DB      0FFh
        DB      0FFh
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h

        DB      01h
        DB      02h
        DB      0Fh
        DB      50h             ; 'P'
        DB      72h             ; 'r'
        DB      65h             ; 'e'
        DB      73h             ; 's'
        DB      73h             ; 's'
        DB      02h
        DB      0C3h
        DB      06h
        DB      0EBh
        DB      0C3h
        DB      48h             ; 'H'
        DB      0ECh
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      3Ah             ; ':'
        DB      84h
        DB      0DFh
        DB      0FEh
        DB      0FFh
        DB      28h             ; '('
        DB      35h             ; '5'
        DB      06h
        DB      4Bh             ; 'K'
        DB      0CDh
        DB      49h             ; 'I'
        DB      0ECh
        DB      28h             ; '('
        DB      0Ah
        DB      10h
        DB      0F9h
        DB      3Eh             ; '>'
        DB      0FFh
        DB      32h             ; '2'
        DB      84h
        DB      0DFh
        DB      0C3h
        DB      4Ch             ; 'L'
        DB      0EBh
        DB      21h             ; '!'
        DB      89h
        DB      0DFh
        DB      0DBh
        DB      0Ch
        DB      0E6h
        DB      20h             ; ' '
        DB      0BEh
        DB      0CAh
        DB      22h             ; '"'
        DB      0ECh
        DB      77h             ; 'w'
        DB      2Ah             ; '*'
        DB      87h
        DB      0DFh
        DB      2Bh             ; '+'
        DB      22h             ; '"'
        DB      87h
        DB      0DFh
        DB      7Ch             ; '|'
        DB      0B5h
        DB      0C2h
        DB      22h             ; '"'
        DB      0ECh
        DB      21h             ; '!'
        DB      0Ah
        DB      00h
        DB      22h             ; '"'
        DB      87h
        DB      0DFh
        DB      3Ah             ; ':'
        DB      85h
        DB      0DFh
        DB      0C3h
        DB      0Fh
        DB      0ECh
        DB      0DBh
        DB      0Ch
        DB      0CBh
        DB      77h             ; 'w'
        DB      0CAh
        DB      22h             ; '"'
        DB      0ECh
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      3Eh             ; '>'
        DB      11h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      0Eh
        DB      0Ch
        DB      11h
        DB      13h
        DB      1Fh
        DB      21h             ; '!'
        DB      70h             ; 'p'
        DB      03h
        DB      3Eh             ; '>'
        DB      12h
        DB      0D3h
        DB      0Ch
        DB      7Ch             ; '|'
        DB      0D3h
        DB      0Dh
        DB      7Dh             ; '}'
        DB      0E5h
        DB      26h             ; '&'
        DB      10h
        DB      0CDh
        DB      26h             ; '&'
        DB      0ECh
        DB      0E1h
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      13h
        DB      25h             ; '%'
        DB      0F2h
        DB      5Eh             ; '^'
        DB      0EBh
        DB      06h
        DB      07h
        DB      3Eh             ; '>'
        DB      38h             ; '8'
        DB      0CDh
        DB      49h             ; 'I'
        DB      0ECh
        DB      28h             ; '('
        DB      0Dh
        DB      3Ch             ; '<'
        DB      10h
        DB      0F8h
        DB      0C3h
        DB      22h             ; '"'
        DB      0ECh
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      7Ch             ; '|'
        DB      0E6h
        DB      3Fh             ; '?'
        DB      0FEh
        DB      39h             ; '9'
        DB      0CAh
        DB      22h             ; '"'
        DB      0ECh
        DB      32h             ; '2'
        DB      84h
        DB      0DFh
        DB      21h             ; '!'
        DB      64h             ; 'd'
        DB      00h
        DB      22h             ; '"'
        DB      87h
        DB      0DFh
        DB      0FEh
        DB      20h             ; ' '
        DB      38h             ; '8'
        DB      1Ch
        DB      0FEh
        DB      30h             ; '0'
        DB      38h             ; '8'
        DB      42h             ; 'B'
        DB      0FEh
        DB      38h             ; '8'
        DB      38h             ; '8'
        DB      51h             ; 'Q'
        DB      0D6h
        DB      38h             ; '8'
        DB      0FEh
        DB      06h
        DB      20h             ; ' '
        DB      02h
        DB      3Eh             ; '>'
        DB      01h
        DB      0CDh
        DB      3Eh             ; '>'
        DB      0ECh
        DB      20h             ; ' '
        DB      02h
        DB      0F6h
        DB      04h
        DB      21h             ; '!'
        DB      8Fh
        DB      0ECh
        DB      18h
        DB      40h             ; '@'
        DB      0CDh
        DB      43h             ; 'C'
        DB      0ECh
        DB      28h             ; '('
        DB      52h             ; 'R'
        DB      0C6h
        DB      60h             ; '`'
        DB      0FEh
        DB      60h             ; '`'
        DB      28h             ; '('
        DB      04h
        DB      0FEh
        DB      7Bh             ; '{'
        DB      38h             ; '8'
        DB      08h
        DB      0FEh
        DB      7Fh             ; ''
        DB      28h             ; '('
        DB      0Eh
        DB      0CBh
        DB      0AFh
        DB      18h
        DB      0Ah
        DB      47h             ; 'G'
        DB      3Ah             ; ':'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0B7h
        DB      78h             ; 'x'
        DB      28h             ; '('
        DB      02h
        DB      0EEh
        DB      20h             ; ' '
        DB      0CDh
        DB      3Eh             ; '>'
        DB      0ECh
        DB      20h             ; ' '
        DB      31h             ; '1'
        DB      0EEh
        DB      20h             ; ' '
        DB      18h
        DB      2Dh             ; '-'
        DB      0FEh
        DB      2Ch             ; ','
        DB      38h             ; '8'
        DB      02h
        DB      0CBh
        DB      0E7h
        DB      0FEh
        DB      20h             ; ' '
        DB      28h             ; '('
        DB      05h
        DB      0CDh
        DB      3Eh             ; '>'
        DB      0ECh
        DB      28h             ; '('
        DB      1Eh
        DB      0EEh
        DB      10h
        DB      18h
        DB      1Ah
        DB      21h             ; '!'
        DB      57h             ; 'W'
        DB      0ECh
        DB      4Fh             ; 'O'
        DB      06h
        DB      00h
        DB      09h
        DB      7Eh             ; '~'
        DB      0B7h
        DB      20h             ; ' '
        DB      0Fh
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      22h             ; '"'
        DB      87h
        DB      0DFh
        DB      21h             ; '!'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      01h
        DB      0AEh
        DB      77h             ; 'w'
        DB      18h
        DB      13h
        DB      0BFh
        DB      32h             ; '2'
        DB      85h
        DB      0DFh
        DB      0F5h
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      0F1h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0C9h
        DB      0F6h
        DB      0FFh
        DB      18h
        DB      0EDh
        DB      0EDh
        DB      59h             ; 'Y'
        DB      0D3h
        DB      0Dh
        DB      0EDh
        DB      51h             ; 'Q'
        DB      0D3h
        DB      0Dh
        DB      0EDh
        DB      40h             ; '@'
        DB      0F2h
        DB      2Eh             ; '.'
        DB      0ECh
        DB      0EDh
        DB      40h             ; '@'
        DB      0CBh
        DB      70h             ; 'p'
        DB      0C0h
        DB      94h
        DB      0D2h
        DB      26h             ; '&'
        DB      0ECh
        DB      0BFh
        DB      0C9h
        DB      0C5h
        DB      06h
        DB      3Fh             ; '?'
        DB      18h
        DB      08h
        DB      0C5h
        DB      06h
        DB      39h             ; '9'
        DB      18h
        DB      03h
        DB      4Fh             ; 'O'
        DB      0C5h
        DB      47h             ; 'G'
        DB      4Fh             ; 'O'
        DB      3Eh             ; '>'
        DB      12h
        DB      0D3h
        DB      0Ch
        DB      78h             ; 'x'
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      47h             ; 'G'
        DB      0D3h
        DB      0Dh
        DB      3Eh             ; '>'
        DB      13h
        DB      0D3h
        DB      0Ch
        DB      78h             ; 'x'
        DB      0D3h
        DB      0Dh
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      3Eh             ; '>'
        DB      1Fh
        DB      0D3h
        DB      0Ch
        DB      0D3h
        DB      0Dh
        DB      0DBh
        DB      0Ch
        DB      0CBh
        DB      7Fh             ; ''
        DB      28h             ; '('
        DB      0FAh
        DB      0DBh
        DB      0Ch
        DB      2Fh             ; '/'
        DB      47h             ; 'G'
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      0CBh
        DB      70h             ; 'p'
        DB      79h             ; 'y'
        DB      0C1h
        DB      0C9h
        DB      1Bh
        DB      08h
        DB      09h
        DB      0Ah
        DB      0Dh
        DB      00h
        DB      18h
        DB      20h             ; ' '
        DB      05h
        DB      04h
        DB      18h
        DB      13h
        DB      12h
        DB      06h
        DB      03h
        DB      01h
        DB      0C3h
        DB      61h             ; 'a'
        DB      0E2h
        DB      0C3h
        DB      0E2h
        DB      0E3h
        DB      0C3h
        DB      0DBh
        DB      0E2h
        DB      0C3h
        DB      98h
        DB      0E0h
        DB      0C3h
        DB      56h             ; 'V'
        DB      0E1h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      68h             ; 'h'
        DB      0E0h
        DB      0C3h
        DB      4Fh             ; 'O'
        DB      0E8h
        DB      0C3h
        DB      6Bh             ; 'k'
        DB      0E0h
        DB      0C3h
        DB      5Ah             ; 'Z'
        DB      0E0h
        DB      0C3h
        DB      44h             ; 'D'
        DB      0E2h
        DB      0C3h
        DB      15h
        DB      0E3h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      0C3h
        DB      0E2h
        DB      0AFh
        DB      00h
        DB      0C9h
        DB      0C3h
        DB      0FAh
        DB      0E9h
        DB      0C3h
        DB      6Ch             ; 'l'
        DB      0EAh
        DB      0C3h
        DB      1Eh
        DB      0E9h
        DB      0C3h
        DB      59h             ; 'Y'
        DB      0E9h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      81h
        DB      0E0h
        DB      0C3h
        DB      0EFh
        DB      0E2h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E0h
        DB      0C3h
        DB      10h
        DB      0E3h
        DB      0C5h
        DB      0E5h
        DB      7Eh             ; '~'
        DB      0B7h
        DB      28h             ; '('
        DB      1Eh
        DB      47h             ; 'G'
        DB      23h             ; '#'
        DB      4Eh             ; 'N'
        DB      23h             ; '#'
        DB      0EDh
        DB      0B3h
        DB      18h
        DB      0F4h
        DB      21h             ; '!'
        DB      0BBh
        DB      0E3h
        DB      0C5h
        DB      0E5h
        DB      06h
        DB      10h
        DB      78h             ; 'x'
        DB      3Dh             ; '='
        DB      0D3h
        DB      0Ch
        DB      7Eh             ; '~'
        DB      0D3h
        DB      0Dh
        DB      2Bh             ; '+'
        DB      10h
        DB      0F6h
        DB      06h
        DB      4Bh             ; 'K'
        DB      0CDh
        DB      0C6h
        DB      0E9h
        DB      0E1h
        DB      0C1h
        DB      0C9h
        DB      0E5h
        DB      21h             ; '!'
        DB      60h             ; '`'
        DB      0DFh
        DB      7Eh             ; '~'
        DB      3Ch             ; '<'
        DB      28h             ; '('
        DB      04h
        DB      0F6h
        DB      0FFh
        DB      0E1h
        DB      0C9h
        DB      0CDh
        DB      00h
        DB      0EBh
        DB      20h             ; ' '
        DB      03h
        DB      77h             ; 'w'
        DB      18h
        DB      0F4h
        DB      0AFh
        DB      18h
        DB      0F3h
        DB      0CDh
        DB      81h
        DB      0E0h
        DB      0C8h
        DB      0E5h
        DB      21h             ; '!'
        DB      60h             ; '`'
        DB      0DFh
        DB      7Eh             ; '~'
        DB      36h             ; '6'
        DB      0FFh
        DB      0E1h
        DB      0C9h
        DB      0Fh
        DB      0E6h
        DB      80h
        DB      32h             ; '2'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0C3h
        DB      3Ch             ; '<'
        DB      0E1h
        DB      0CDh
        DB      1Bh
        DB      0E2h
        DB      0E5h
        DB      0EBh
        DB      21h             ; '!'
        DB      7Fh             ; ''
        DB      0F7h
        DB      0E5h
        DB      0A7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0D1h
        DB      21h             ; '!'
        DB      2Fh             ; '/'
        DB      0F7h
        DB      0EDh
        DB      0B8h
        DB      0E1h
        DB      0CDh
        DB      25h             ; '%'
        DB      0E2h
        DB      18h
        DB      74h             ; 't'
        DB      0CDh
        DB      1Bh
        DB      0E2h
        DB      0E5h
        DB      0E5h
        DB      01h
        DB      50h             ; 'P'
        DB      00h
        DB      09h
        DB      0E5h
        DB      0EBh
        DB      21h             ; '!'
        DB      81h
        DB      0F7h
        DB      0A7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0E1h
        DB      0D1h
        DB      0EDh
        DB      0B0h
        DB      0CDh
        DB      22h             ; '"'
        DB      0E2h
        DB      0E1h
        DB      18h
        DB      57h             ; 'W'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      38h             ; '8'
        DB      3Dh             ; '='
        DB      79h             ; 'y'
        DB      28h             ; '('
        DB      53h             ; 'S'
        DB      0FEh
        DB      29h             ; ')'
        DB      28h             ; '('
        DB      0B5h
        DB      0FEh
        DB      28h             ; '('
        DB      28h             ; '('
        DB      0B1h
        DB      0FEh
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      24h             ; '$'
        DB      0CBh
        DB      0AFh
        DB      0FEh
        DB      45h             ; 'E'
        DB      28h             ; '('
        DB      0B0h
        DB      0FEh
        DB      52h             ; 'R'
        DB      28h             ; '('
        DB      0C6h
        DB      0FEh
        DB      54h             ; 'T'
        DB      28h             ; '('
        DB      0BDh
        DB      0FEh
        DB      59h             ; 'Y'
        DB      28h             ; '('
        DB      0Dh
        DB      0AFh
        DB      32h             ; '2'
        DB      5Fh             ; '_'
        DB      0DFh
        DB      79h             ; 'y'
        DB      0FEh
        DB      5Ah             ; 'Z'
        DB      38h             ; '8'
        DB      29h             ; ')'
        DB      0Eh
        DB      20h             ; ' '
        DB      18h
        DB      57h             ; 'W'
        DB      0CCh
        DB      31h             ; '1'
        DB      0E2h
        DB      18h
        DB      20h             ; ' '
        DB      3Eh             ; '>'
        DB      02h
        DB      18h
        DB      2Ah             ; '*'
        DB      79h             ; 'y'
        DB      0D6h
        DB      20h             ; ' '
        DB      47h             ; 'G'
        DB      2Ah             ; '*'
        DB      5Dh             ; ']'
        DB      0DFh
        DB      26h             ; '&'
        DB      00h
        DB      54h             ; 'T'
        DB      5Dh             ; ']'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      19h
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      5Fh             ; '_'
        DB      19h
        DB      7Ch             ; '|'
        DB      0E6h
        DB      07h
        DB      67h             ; 'g'
        DB      11h
        DB      00h
        DB      0F0h
        DB      19h
        DB      0AFh
        DB      18h
        DB      0Bh
        DB      0D6h
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      5Dh             ; ']'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      01h
        DB      18h
        DB      02h
        DB      3Eh             ; '>'
        DB      03h
        DB      32h             ; '2'
        DB      5Fh             ; '_'
        DB      0DFh
        DB      18h
        DB      76h             ; 'v'
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      06h
        DB      00h
        DB      18h
        DB      0C1h
        DB      0F5h
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      2Ah             ; '*'
        DB      5Bh             ; '['
        DB      0DFh
        DB      0CDh
        DB      3Fh             ; '?'
        DB      0E2h
        DB      0CDh
        DB      45h             ; 'E'
        DB      0DFh
        DB      3Ah             ; ':'
        DB      5Eh             ; '^'
        DB      0DFh
        DB      47h             ; 'G'
        DB      3Ah             ; ':'
        DB      5Fh             ; '_'
        DB      0DFh
        DB      0B7h
        DB      0C2h
        DB      0E5h
        DB      0E0h
        DB      79h             ; 'y'
        DB      0FEh
        DB      20h             ; ' '
        DB      38h             ; '8'
        DB      2Fh             ; '/'
        DB      3Ah             ; ':'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0B1h
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      04h
        DB      78h             ; 'x'
        DB      0D6h
        DB      50h             ; 'P'
        DB      20h             ; ' '
        DB      01h
        DB      47h             ; 'G'
        DB      0EBh
        DB      21h             ; '!'
        DB      7Fh             ; ''
        DB      0F7h
        DB      0B7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      0EBh
        DB      30h             ; '0'
        DB      3Bh             ; ';'
        DB      0C5h
        DB      0E5h
        DB      01h
        DB      30h             ; '0'
        DB      07h
        DB      21h             ; '!'
        DB      50h             ; 'P'
        DB      0F0h
        DB      11h
        DB      00h
        DB      0F0h
        DB      0EDh
        DB      0B0h
        DB      0CDh
        DB      22h             ; '"'
        DB      0E2h
        DB      0E1h
        DB      0C1h
        DB      11h
        DB      0B0h
        DB      0FFh
        DB      19h
        DB      18h
        DB      23h             ; '#'
        DB      0D6h
        DB      07h
        DB      28h             ; '('
        DB      62h             ; 'b'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      40h             ; '@'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      4Ch             ; 'L'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      2Eh             ; '.'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      22h             ; '"'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      0C3h
        DB      0D6h
        DB      0Eh
        DB      28h             ; '('
        DB      96h
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      8Ch
        DB      0D6h
        DB      03h
        DB      28h             ; '('
        DB      23h             ; '#'
        DB      0FEh
        DB      0EFh
        DB      0CCh
        DB      1Bh
        DB      0E2h
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      5Eh             ; '^'
        DB      0DFh
        DB      22h             ; '"'
        DB      5Bh             ; '['
        DB      0DFh
        DB      0CDh
        DB      3Fh             ; '?'
        DB      0E2h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0F1h
        DB      0C9h
        DB      11h
        DB      0B0h
        DB      0FFh
        DB      19h
        DB      7Ch             ; '|'
        DB      0FEh
        DB      0F0h
        DB      30h             ; '0'
        DB      0ECh
        DB      11h
        DB      50h             ; 'P'
        DB      00h
        DB      19h
        DB      18h
        DB      9Dh
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      0AFh
        DB      18h
        DB      0DDh
        DB      2Bh             ; '+'
        DB      05h
        DB      7Ch             ; '|'
        DB      0FEh
        DB      0EFh
        DB      28h             ; '('
        DB      0F3h
        DB      0CBh
        DB      78h             ; 'x'
        DB      28h             ; '('
        DB      0D1h
        DB      06h
        DB      4Fh             ; 'O'
        DB      18h
        DB      0CDh
        DB      3Ah             ; ':'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0F6h
        DB      20h             ; ' '
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      04h
        DB      78h             ; 'x'
        DB      0E6h
        DB      07h
        DB      20h             ; ' '
        DB      0F3h
        DB      0C3h
        DB      7Ah             ; 'z'
        DB      0E1h
        DB      0D3h
        DB      09h
        DB      0Eh
        DB      0C8h
        DB      0DBh
        DB      02h
        DB      0EEh
        DB      40h             ; '@'
        DB      0D3h
        DB      02h
        DB      06h
        DB      0A4h
        DB      10h
        DB      0FEh
        DB      0Dh
        DB      20h             ; ' '
        DB      0F5h
        DB      18h
        DB      0AEh
        DB      78h             ; 'x'
        DB      0B7h
        DB      0C8h
        DB      2Bh             ; '+'
        DB      10h
        DB      0FDh
        DB      0C9h
        DB      21h             ; '!'
        DB      30h             ; '0'
        DB      0F7h
        DB      3Eh             ; '>'
        DB      50h             ; 'P'
        DB      90h
        DB      0E5h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      3Dh             ; '='
        DB      20h             ; ' '
        DB      0FAh
        DB      0E1h
        DB      0C9h
        DB      0E5h
        DB      0EBh
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      12h
        DB      13h
        DB      21h             ; '!'
        DB      7Fh             ; ''
        DB      08h
        DB      19h
        DB      30h             ; '0'
        DB      0F8h
        DB      0E1h
        DB      0C9h
        DB      7Eh             ; '~'
        DB      0EEh
        DB      80h
        DB      77h             ; 'w'
        DB      0C9h
        DB      0F5h
        DB      0D5h
        DB      0E5h
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      11h
        DB      00h
        DB      0F8h
        DB      7Eh             ; '~'
        DB      2Fh             ; '/'
        DB      12h
        DB      23h             ; '#'
        DB      13h
        DB      0CBh
        DB      5Ch             ; '\'
        DB      28h             ; '('
        DB      0F7h
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      0E1h
        DB      0D1h
        DB      0F1h
        DB      0C9h
        DB      0F3h
        DB      0AFh
        DB      0D3h
        DB      1Ch
        DB      31h             ; '1'
        DB      0FEh
        DB      0F7h
        DB      0CDh
        DB      40h             ; '@'
        DB      0E3h
        DB      0Eh
        DB      1Ah
        DB      0CDh
        DB      56h             ; 'V'
        DB      0E1h
        DB      0EDh
        DB      5Eh             ; '^'
        DB      3Eh             ; '>'
        DB      0DFh
        DB      0EDh
        DB      47h             ; 'G'
        DB      3Eh             ; '>'
        DB      0Dh
        DB      0CDh
        DB      03h
        DB      0EBh
        DB      0CAh
        DB      0E2h
        DB      0E3h
        DB      3Eh             ; '>'
        DB      02h
        DB      0CDh
        DB      03h
        DB      0EBh
        DB      28h             ; '('
        DB      0Fh
        DB      2Ah             ; '*'
        DB      7Bh             ; '{'
        DB      0DFh
        DB      11h
        DB      55h             ; 'U'
        DB      0AAh
        DB      0B7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      20h             ; ' '
        DB      04h
        DB      2Ah             ; '*'
        DB      7Dh             ; '}'
        DB      0DFh
        DB      0E9h
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      0DBh
        DB      46h             ; 'F'
        DB      2Fh             ; '/'
        DB      0D3h
        DB      46h             ; 'F'
        DB      0E3h
        DB      0E3h
        DB      0E3h
        DB      0E3h
        DB      47h             ; 'G'
        DB      0DBh
        DB      46h             ; 'F'
        DB      0B8h
        DB      0CAh
        DB      0D3h
        DB      0E9h
        DB      0C3h
        DB      0E2h
        DB      0E3h
        DB      0E5h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      11h
        DB      80h
        DB      0F7h
        DB      01h
        DB      50h             ; 'P'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0E1h
        DB      11h
        DB      00h
        DB      0F0h
        DB      7Eh             ; '~'
        DB      0EEh
        DB      80h
        DB      0C8h
        DB      12h
        DB      13h
        DB      23h             ; '#'
        DB      18h
        DB      0F7h
        DB      0CDh
        DB      0AAh
        DB      0E2h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      28h             ; '('
        DB      0FBh
        DB      0FEh
        DB      0Dh
        DB      20h             ; ' '
        DB      0F7h
        DB      21h             ; '!'
        DB      80h
        DB      0F7h
        DB      11h
        DB      00h
        DB      0F0h
        DB      01h
        DB      50h             ; 'P'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0C9h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      28h             ; '('
        DB      0FBh
        DB      0C9h
        DB      32h             ; '2'
        DB      7Fh             ; ''
        DB      0DFh
        DB      3Eh             ; '>'
        DB      00h
        DB      32h             ; '2'
        DB      64h             ; 'd'
        DB      0DFh
        DB      3Ah             ; ':'
        DB      7Fh             ; ''
        DB      0DFh
        DB      0FBh
        DB      0EDh
        DB      4Dh             ; 'M'
        DB      0E5h
        DB      21h             ; '!'
        DB      64h             ; 'd'
        DB      0DFh
        DB      0CBh
        DB      46h             ; 'F'
        DB      20h             ; ' '
        DB      0FCh
        DB      36h             ; '6'
        DB      0FFh
        DB      0D3h
        DB      00h
        DB      0E1h
        DB      0C9h
        DB      21h             ; '!'
        DB      6Ch             ; 'l'
        DB      0E3h
        DB      11h
        DB      45h             ; 'E'
        DB      0DFh
        DB      01h
        DB      30h             ; '0'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      21h             ; '!'
        DB      84h
        DB      0DFh
        DB      06h
        DB      0Dh
        DB      0C3h
        DB      0E0h
        DB      0E7h
        DB      3Ah             ; ':'
        DB      64h             ; 'd'
        DB      0DFh
        DB      2Fh             ; '/'
        DB      0C9h
        DB      0F5h
        DB      0C5h
        DB      0E5h
        DB      0DDh
        DB      0E5h
        DB      0FDh
        DB      0E5h
        DB      0Eh
        DB      0Ah
        DB      0F3h
        DB      7Ch             ; '|'
        DB      0B5h
        DB      28h             ; '('
        DB      11h
        DB      0EDh
        DB      51h             ; 'Q'
        DB      0DDh
        DB      7Eh             ; '~'
        DB      00h
        DB      0EDh
        DB      59h             ; 'Y'
        DB      0FDh
        DB      77h             ; 'w'
        DB      00h
        DB      0DDh
        DB      23h             ; '#'
        DB      0FDh
        DB      23h             ; '#'
        DB      2Bh             ; '+'
        DB      18h
        DB      0EBh
        DB      0AFh
        DB      0D3h
        DB      0Ah
        DB      0FBh
        DB      0FDh
        DB      0E1h
        DB      0DDh
        DB      0E1h
        DB      0E1h
        DB      0C1h
        DB      0F1h
        DB      0C9h
        DB      0CDh
        DB      68h             ; 'h'
        DB      0E0h
        DB      21h             ; '!'
        DB      9Ch
        DB      0E3h
        DB      0CDh
        DB      5Ah             ; 'Z'
        DB      0E0h
        DB      0CDh
        DB      0FDh
        DB      0E2h
        DB      21h             ; '!'
        DB      00h
        DB      0DFh
        DB      06h
        DB      42h             ; 'B'
        DB      0CDh
        DB      0E0h
        DB      0E7h
        DB      0CDh
        DB      90h
        DB      0E4h
        DB      3Eh             ; '>'
        DB      40h             ; '@'
        DB      0D3h
        DB      08h
        DB      21h             ; '!'
        DB      00h
        DB      0F8h
        DB      36h             ; '6'
        DB      0Eh
        DB      23h             ; '#'
        DB      0CBh
        DB      7Ch             ; '|'
        DB      20h             ; ' '
        DB      0F9h
        DB      0AFh
        DB      0D3h
        DB      08h
        DB      0CDh
        DB      44h             ; 'D'
        DB      0E2h
        DB      0C9h
        DB      0C9h
        DB      00h
        DB      00h
        DB      0E1h
        DB      0E2h
        DB      0ECh
        DB      0E2h
        DB      03h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      04h
        DB      00h
        DB      0F0h
        DB      00h
        DB      00h
        DB      00h
        DB      0FFh
        DB      00h
        DB      00h
        DB      0F0h
        DB      00h
        DB      00h
        DB      08h
        DB      00h
        DB      00h
        DB      00h
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      08h
        DB      01h
        DB      24h             ; '$'
        DB      28h             ; '('
        DB      04h
        DB      03h
        DB      01h
        DB      48h             ; 'H'
        DB      0Fh
        DB      83h
        DB      05h
        DB      03h
        DB      4Ah             ; 'J'
        DB      0FFh
        DB      9Bh
        DB      0B7h
        DB      0EFh
        DB      01h
        DB      02h
        DB      20h             ; ' '
        DB      00h
        DB      6Bh             ; 'k'
        DB      40h             ; '@'
        DB      51h             ; 'Q'
        DB      37h             ; '7'
        DB      12h
        DB      09h
        DB      10h
        DB      12h
        DB      48h             ; 'H'
        DB      0Fh
        DB      2Fh             ; '/'
        DB      0Fh
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      6Bh             ; 'k'
        DB      50h             ; 'P'
        DB      58h             ; 'X'
        DB      37h             ; '7'
        DB      1Bh
        DB      05h
        DB      18h
        DB      1Ah
        DB      48h             ; 'H'
        DB      0Ah
        DB      2Ah             ; '*'
        DB      0Ah
        DB      20h             ; ' '
        DB      00h
        DB      00h
        DB      00h
        DB      0CDh
        DB      0D1h
        DB      0E3h
        DB      18h
        DB      08h
        DB      0CDh
        DB      0DBh
        DB      0E2h
        DB      0FEh
        DB      1Bh
        DB      0C0h
        DB      18h
        DB      36h             ; '6'
        DB      0FEh
        DB      61h             ; 'a'
        DB      0D8h
        DB      0FEh
        DB      7Bh             ; '{'
        DB      0D0h
        DB      0CBh
        DB      0AFh
        DB      0C9h
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      0FBh
        DB      0AFh
        DB      32h             ; '2'
        DB      7Bh             ; '{'
        DB      0DFh
        DB      0D3h
        DB      44h             ; 'D'
        DB      0D3h
        DB      1Ch
        DB      0CDh
        DB      40h             ; '@'
        DB      0E3h
        DB      3Eh             ; '>'
        DB      40h             ; '@'
        DB      0D3h
        DB      08h
        DB      47h             ; 'G'
        DB      21h             ; '!'
        DB      40h             ; '@'
        DB      0F8h
        DB      36h             ; '6'
        DB      0CBh
        DB      23h             ; '#'
        DB      10h
        DB      0FBh
        DB      0AFh
        DB      0D3h
        DB      08h
        DB      01h
        DB      14h
        DB      00h
        DB      11h
        DB      16h
        DB      0F0h
        DB      21h             ; '!'
        DB      0EBh
        DB      0E6h
        DB      0EDh
        DB      0B0h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      0AFh
        DB      32h             ; '2'
        DB      08h
        DB      0DFh
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      0CDh
        DB      9Dh
        DB      0E4h
        DB      21h             ; '!'
        DB      41h             ; 'A'
        DB      0F0h
        DB      0CBh
        DB      0FEh
        DB      0CDh
        DB      0CCh
        DB      0E3h
        DB      0CBh
        DB      0BEh
        DB      0FEh
        DB      0Dh
        DB      28h             ; '('
        DB      34h             ; '4'
        DB      0FEh
        DB      0Ah
        DB      28h             ; '('
        DB      33h             ; '3'
        DB      0FEh
        DB      13h
        DB      28h             ; '('
        DB      27h             ; '''
        DB      0FEh
        DB      04h
        DB      28h             ; '('
        DB      0Dh
        DB      0FEh
        DB      7Fh             ; ''
        DB      28h             ; '('
        DB      18h
        DB      0FEh
        DB      08h
        DB      28h             ; '('
        DB      1Bh
        DB      0FEh
        DB      20h             ; ' '
        DB      38h             ; '8'
        DB      0DDh
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      3Eh             ; '>'
        DB      5Fh             ; '_'
        DB      0BDh
        DB      30h             ; '0'
        DB      0D6h
        DB      2Bh             ; '+'
        DB      18h
        DB      0D3h
        DB      3Eh             ; '>'
        DB      41h             ; 'A'
        DB      0BDh
        DB      0C8h
        DB      2Bh             ; '+'
        DB      0C9h
        DB      0CDh
        DB      49h             ; 'I'
        DB      0E4h
        DB      36h             ; '6'
        DB      0A0h
        DB      18h
        DB      0C6h
        DB      0CDh
        DB      49h             ; 'I'
        DB      0E4h
        DB      18h
        DB      0C1h
        DB      0CDh
        DB      0A3h
        DB      0E4h
        DB      11h
        DB      41h             ; 'A'
        DB      0F0h
        DB      1Ah
        DB      0D6h
        DB      41h             ; 'A'
        DB      0FEh
        DB      1Ah
        DB      30h             ; '0'
        DB      12h
        DB      21h             ; '!'
        DB      0Fh
        DB      0E4h
        DB      0E5h
        DB      07h
        DB      21h             ; '!'
        DB      0FFh
        DB      0E6h
        DB      85h
        DB      6Fh             ; 'o'
        DB      30h             ; '0'
        DB      01h
        DB      24h             ; '$'
        DB      7Eh             ; '~'
        DB      23h             ; '#'
        DB      66h             ; 'f'
        DB      6Fh             ; 'o'
        DB      0E9h
        DB      06h
        DB      3Fh             ; '?'
        DB      0FBh
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      21h             ; '!'
        DB      60h             ; '`'
        DB      0F0h
        DB      70h             ; 'p'
        DB      0EBh
        DB      0CBh
        DB      0FEh
        DB      0CDh
        DB      0CCh
        DB      0E3h
        DB      0EBh
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      0EBh
        DB      18h
        DB      91h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      06h
        DB      0F4h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      7Ch             ; '|'
        DB      0B8h
        DB      20h             ; ' '
        DB      0F9h
        DB      0C9h
        DB      21h             ; '!'
        DB      40h             ; '@'
        DB      0F0h
        DB      36h             ; '6'
        DB      3Eh             ; '>'
        DB      23h             ; '#'
        DB      06h
        DB      40h             ; '@'
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      10h
        DB      0FBh
        DB      0C9h
        DB      0EBh
        DB      22h             ; '"'
        DB      01h
        DB      0DFh
        DB      0E5h
        DB      3Eh             ; '>'
        DB      0C0h
        DB      0A5h
        DB      6Fh             ; 'o'
        DB      01h
        DB      0F0h
        DB      0FFh
        DB      09h
        DB      11h
        DB      0C0h
        DB      0F0h
        DB      0CDh
        DB      0Ch
        DB      0E6h
        DB      13h
        DB      7Ah             ; 'z'
        DB      0FEh
        DB      0F2h
        DB      20h             ; ' '
        DB      0F7h
        DB      7Bh             ; '{'
        DB      0FEh
        DB      40h             ; '@'
        DB      20h             ; ' '
        DB      0F2h
        DB      0E1h
        DB      11h
        DB      81h
        DB      0F0h
        DB      0CDh
        DB      35h             ; '5'
        DB      0E6h
        DB      13h
        DB      7Eh             ; '~'
        DB      32h             ; '2'
        DB      8Ah
        DB      0F0h
        DB      0CDh
        DB      45h             ; 'E'
        DB      0E5h
        DB      0EBh
        DB      0C9h
        DB      0CDh
        DB      0EAh
        DB      0E4h
        DB      0DAh
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      20h             ; ' '
        DB      0F8h
        DB      0CDh
        DB      0EAh
        DB      0E4h
        DB      0D8h
        DB      28h             ; '('
        DB      0FAh
        DB      1Bh
        DB      0C9h
        DB      7Bh             ; '{'
        DB      0FEh
        DB      5Fh             ; '_'
        DB      38h             ; '8'
        DB      02h
        DB      37h             ; '7'
        DB      0C9h
        DB      1Ah
        DB      13h
        DB      0FEh
        DB      20h             ; ' '
        DB      0C9h
        DB      0CDh
        DB      0DAh
        DB      0E4h
        DB      0DAh
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      0C9h
        DB      1Ah
        DB      0CDh
        DB      0Bh
        DB      0E5h
        DB      0D2h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      0C9h
        DB      21h             ; '!'
        DB      04h
        DB      0DFh
        DB      0EDh
        DB      6Fh             ; 'o'
        DB      0C9h
        DB      0D6h
        DB      30h             ; '0'
        DB      0FEh
        DB      0Ah
        DB      0D8h
        DB      0D6h
        DB      11h
        DB      0FEh
        DB      06h
        DB      0D0h
        DB      0C6h
        DB      0Ah
        DB      3Fh             ; '?'
        DB      0C9h
        DB      0CDh
        DB      0F6h
        DB      0E4h
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      22h             ; '"'
        DB      04h
        DB      0DFh
        DB      0CDh
        DB      0FDh
        DB      0E4h
        DB      0CDh
        DB      05h
        DB      0E5h
        DB      23h             ; '#'
        DB      0EDh
        DB      6Fh             ; 'o'
        DB      13h
        DB      7Bh             ; '{'
        DB      0FEh
        DB      5Fh             ; '_'
        DB      0D2h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      1Ah
        DB      0FEh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      0EBh
        DB      2Ah             ; '*'
        DB      04h
        DB      0DFh
        DB      0C9h
        DB      0CDh
        DB      0F6h
        DB      0E4h
        DB      0E5h
        DB      0CDh
        DB      1Ch
        DB      0E5h
        DB      7Dh             ; '}'
        DB      0E1h
        DB      0C9h
        DB      0C5h
        DB      47h             ; 'G'
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      0CDh
        DB      54h             ; 'T'
        DB      0E5h
        DB      78h             ; 'x'
        DB      0CDh
        DB      54h             ; 'T'
        DB      0E5h
        DB      0C1h
        DB      0C9h
        DB      0E6h
        DB      0Fh
        DB      0B7h
        DB      27h             ; '''
        DB      0C6h
        DB      0F0h
        DB      0CEh
        DB      40h             ; '@'
        DB      12h
        DB      13h
        DB      0C9h
        DB      0AFh
        DB      18h
        DB      02h
        DB      3Eh             ; '>'
        DB      80h
        DB      32h             ; '2'
        DB      06h
        DB      0DFh
        DB      32h             ; '2'
        DB      07h
        DB      0DFh
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0EBh
        DB      21h             ; '!'
        DB      06h
        DB      0DFh
        DB      0CBh
        DB      2Eh             ; '.'
        DB      0CDh
        DB      41h             ; 'A'
        DB      0E6h
        DB      0CDh
        DB      0ABh
        DB      0E4h
        DB      0CDh
        DB      0D1h
        DB      0E3h
        DB      0CDh
        DB      41h             ; 'A'
        DB      0E6h
        DB      0CDh
        DB      0B8h
        DB      0E5h
        DB      21h             ; '!'
        DB      06h
        DB      0DFh
        DB      0CBh
        DB      76h             ; 'v'
        DB      20h             ; ' '
        DB      0F0h
        DB      47h             ; 'G'
        DB      21h             ; '!'
        DB      07h
        DB      0DFh
        DB      0CBh
        DB      46h             ; 'F'
        DB      20h             ; ' '
        DB      1Fh
        DB      0CDh
        DB      0D9h
        DB      0E3h
        DB      47h             ; 'G'
        DB      0CDh
        DB      0Bh
        DB      0E5h
        DB      30h             ; '0'
        DB      0DFh
        DB      0CDh
        DB      05h
        DB      0E5h
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      8Dh
        DB      0F0h
        DB      0CDh
        DB      0CCh
        DB      0E3h
        DB      0CDh
        DB      0B8h
        DB      0E5h
        DB      0CDh
        DB      0Bh
        DB      0E5h
        DB      30h             ; '0'
        DB      0CDh
        DB      0CDh
        DB      05h
        DB      0E5h
        DB      7Eh             ; '~'
        DB      12h
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      8Eh
        DB      0F0h
        DB      13h
        DB      18h
        DB      0BEh
        DB      47h             ; 'G'
        DB      0FEh
        DB      13h
        DB      20h             ; ' '
        DB      03h
        DB      1Bh
        DB      18h
        DB      0AEh
        DB      0FEh
        DB      04h
        DB      20h             ; ' '
        DB      03h
        DB      13h
        DB      18h
        DB      0A7h
        DB      0FEh
        DB      05h
        DB      20h             ; ' '
        DB      07h
        DB      21h             ; '!'
        DB      0F0h
        DB      0FFh
        DB      19h
        DB      0EBh
        DB      18h
        DB      9Ch
        DB      0FEh
        DB      18h
        DB      20h             ; ' '
        DB      05h
        DB      21h             ; '!'
        DB      10h
        DB      00h
        DB      18h
        DB      0F3h
        DB      0FEh
        DB      12h
        DB      20h             ; ' '
        DB      05h
        DB      21h             ; '!'
        DB      0C0h
        DB      0FFh
        DB      18h
        DB      0EAh
        DB      0FEh
        DB      03h
        DB      20h             ; ' '
        DB      11h
        DB      21h             ; '!'
        DB      40h             ; '@'
        DB      00h
        DB      18h
        DB      0E1h
        DB      0FEh
        DB      01h
        DB      0C0h
        DB      21h             ; '!'
        DB      07h
        DB      0DFh
        DB      7Eh             ; '~'
        DB      2Fh             ; '/'
        DB      77h             ; 'w'
        DB      0C3h
        DB      73h             ; 's'
        DB      0E5h
        DB      0FEh
        DB      4Dh             ; 'M'
        DB      28h             ; '('
        DB      04h
        DB      0FEh
        DB      6Dh             ; 'm'
        DB      20h             ; ' '
        DB      0ECh
        DB      21h             ; '!'
        DB      06h
        DB      0DFh
        DB      0CBh
        DB      76h             ; 'v'
        DB      0C8h
        DB      0CBh
        DB      0B6h
        DB      0C3h
        DB      73h             ; 's'
        DB      0E5h
        DB      0CDh
        DB      35h             ; '5'
        DB      0E6h
        DB      13h
        DB      13h
        DB      06h
        DB      04h
        DB      48h             ; 'H'
        DB      0CDh
        DB      89h
        DB      0E6h
        DB      41h             ; 'A'
        DB      10h
        DB      0F9h
        DB      13h
        DB      01h
        DB      0F0h
        DB      0FFh
        DB      09h
        DB      06h
        DB      10h
        DB      7Eh             ; '~'
        DB      0C5h
        DB      0EDh
        DB      4Bh             ; 'K'
        DB      01h
        DB      0DFh
        DB      0CDh
        DB      0B1h
        DB      0E6h
        DB      0C1h
        DB      20h             ; ' '
        DB      02h
        DB      0EEh
        DB      80h
        DB      12h
        DB      23h             ; '#'
        DB      13h
        DB      10h
        DB      0EDh
        DB      0C9h
        DB      7Ch             ; '|'
        DB      0CDh
        DB      45h             ; 'E'
        DB      0E5h
        DB      7Dh             ; '}'
        DB      0C3h
        DB      45h             ; 'E'
        DB      0E5h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0E9h
        DB      21h             ; '!'
        DB      8Ch
        DB      0F0h
        DB      06h
        DB      04h
        DB      0CDh
        DB      0A5h
        DB      0E4h
        DB      0F5h
        DB      0E5h
        DB      21h             ; '!'
        DB      0C5h
        DB      0D8h
        DB      22h             ; '"'
        DB      7Ch             ; '|'
        DB      0F0h
        DB      3Ah             ; ':'
        DB      07h
        DB      0DFh
        DB      0E6h
        DB      01h
        DB      21h             ; '!'
        DB      20h             ; ' '
        DB      0C8h
        DB      28h             ; '('
        DB      03h
        DB      21h             ; '!'
        DB      0D4h
        DB      0D4h
        DB      7Ch             ; '|'
        DB      32h             ; '2'
        DB      7Bh             ; '{'
        DB      0F0h
        DB      7Dh             ; '}'
        DB      32h             ; '2'
        DB      7Eh             ; '~'
        DB      0F0h
        DB      0E1h
        DB      0F1h
        DB      0C9h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0E5h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0E5h
        DB      0CDh
        DB      7Fh             ; ''
        DB      0E6h
        DB      0C1h
        DB      0E1h
        DB      5Fh             ; '_'
        DB      73h             ; 's'
        DB      0CDh
        DB      0B1h
        DB      0E6h
        DB      23h             ; '#'
        DB      38h             ; '8'
        DB      0F9h
        DB      0C9h
        DB      0CDh
        DB      0DAh
        DB      0E4h
        DB      3Eh             ; '>'
        DB      00h
        DB      0D8h
        DB      0CDh
        DB      3Eh             ; '>'
        DB      0E5h
        DB      0C9h
        DB      0CDh
        DB      8Ch
        DB      0E6h
        DB      06h
        DB      02h
        DB      7Eh             ; '~'
        DB      0CDh
        DB      45h             ; 'E'
        DB      0E5h
        DB      0C5h
        DB      0EDh
        DB      4Bh             ; 'K'
        DB      01h
        DB      0DFh
        DB      0CDh
        DB      0B1h
        DB      0E6h
        DB      0C1h
        DB      0CCh
        DB      0A6h
        DB      0E6h
        DB      23h             ; '#'
        DB      10h
        DB      0EDh
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      12h
        DB      13h
        DB      0C9h
        DB      0D5h
        DB      0EBh
        DB      2Bh             ; '+'
        DB      0CBh
        DB      0FEh
        DB      2Bh             ; '+'
        DB      0CBh
        DB      0FEh
        DB      0EBh
        DB      0D1h
        DB      0C9h
        DB      0A7h
        DB      0E5h
        DB      0EDh
        DB      42h             ; 'B'
        DB      0E1h
        DB      0C9h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0EDh
        DB      69h             ; 'i'
        DB      0C9h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0EDh
        DB      78h             ; 'x'
        DB      11h
        DB      03h
        DB      0F0h
        DB      0C3h
        DB      45h             ; 'E'
        DB      0E5h
        DB      21h             ; '!'
        DB      40h             ; '@'
        DB      0F2h
        DB      0E5h
        DB      0CDh
        DB      93h
        DB      0E4h
        DB      0E1h
        DB      22h             ; '"'
        DB      37h             ; '7'
        DB      0DFh
        DB      0C9h
        DB      23h             ; '#'
        DB      0AFh
        DB      0BEh
        DB      0C8h
        DB      78h             ; 'x'
        DB      0BEh
        DB      23h             ; '#'
        DB      23h             ; '#'
        DB      20h             ; ' '
        DB      0F6h
        DB      46h             ; 'F'
        DB      2Bh             ; '+'
        DB      6Eh             ; 'n'
        DB      60h             ; '`'
        DB      0E3h
        DB      0C9h
        DB      6Dh             ; 'm'
        DB      69h             ; 'i'
        DB      63h             ; 'c'
        DB      72h             ; 'r'
        DB      6Fh             ; 'o'
        DB      62h             ; 'b'
        DB      65h             ; 'e'
        DB      65h             ; 'e'
        DB      20h             ; ' '
        DB      6Dh             ; 'm'
        DB      6Fh             ; 'o'
        DB      6Eh             ; 'n'
        DB      69h             ; 'i'
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      63h             ; 'c'
        DB      38h             ; '8'
        DB      37h             ; '7'
        DB      5Fh             ; '_'
        DB      0E5h
        DB      0E6h
        DB      0E7h
        DB      58h             ; 'X'
        DB      0E7h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      62h             ; 'b'
        DB      0E5h
        DB      69h             ; 'i'
        DB      0E6h
        DB      3Dh             ; '='
        DB      0E6h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      0C2h
        DB      0E6h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      09h
        DB      0E8h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      42h             ; 'B'
        DB      0E7h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      0B7h
        DB      0E6h
        DB      90h
        DB      0E4h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      84h
        DB      0E7h
        DB      19h
        DB      0E8h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      7Ah             ; 'z'
        DB      0E4h
        DB      00h
        DB      00h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0E5h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0E5h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0D1h
        DB      0E3h
        DB      0C1h
        DB      0C9h
        DB      0CDh
        DB      33h             ; '3'
        DB      0E7h
        DB      0E5h
        DB      0B7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      0E1h
        DB      38h             ; '8'
        DB      03h
        DB      0EDh
        DB      0B0h
        DB      0C9h
        DB      09h
        DB      2Bh             ; '+'
        DB      0EBh
        DB      09h
        DB      2Bh             ; '+'
        DB      0EBh
        DB      0EDh
        DB      0B8h
        DB      0C9h
        DB      0CDh
        DB      0CFh
        DB      0E6h
        DB      0CDh
        DB      33h             ; '3'
        DB      0E7h
        DB      1Ah
        DB      0BEh
        DB      0C4h
        DB      6Bh             ; 'k'
        DB      0E7h
        DB      23h             ; '#'
        DB      13h
        DB      0Bh
        DB      78h             ; 'x'
        DB      0B1h
        DB      20h             ; ' '
        DB      0F4h
        DB      0C9h
        DB      0D5h
        DB      0CDh
        DB      0C2h
        DB      0E7h
        DB      1Bh
        DB      7Eh             ; '~'
        DB      0CDh
        DB      45h             ; 'E'
        DB      0E5h
        DB      13h
        DB      0E3h
        DB      7Eh             ; '~'
        DB      0CDh
        DB      45h             ; 'E'
        DB      0E5h
        DB      13h
        DB      13h
        DB      13h
        DB      13h
        DB      0EBh
        DB      22h             ; '"'
        DB      37h             ; '7'
        DB      0DFh
        DB      0E1h
        DB      0C9h
        DB      0CDh
        DB      0CFh
        DB      0E6h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      0E5h
        DB      0CDh
        DB      19h
        DB      0E5h
        DB      22h             ; '"'
        DB      35h             ; '5'
        DB      0DFh
        DB      21h             ; '!'
        DB      3Bh             ; ';'
        DB      0DFh
        DB      06h
        DB      00h
        DB      0CDh
        DB      0F6h
        DB      0E4h
        DB      0CDh
        DB      3Eh             ; '>'
        DB      0E5h
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      04h
        DB      0CDh
        DB      0DAh
        DB      0E4h
        DB      30h             ; '0'
        DB      0F5h
        DB      0E1h
        DB      0EDh
        DB      43h             ; 'C'
        DB      39h             ; '9'
        DB      0DFh
        DB      11h
        DB      3Ah             ; ':'
        DB      0DFh
        DB      1Ah
        DB      13h
        DB      47h             ; 'G'
        DB      0E5h
        DB      0CDh
        DB      0D8h
        DB      0E7h
        DB      0E1h
        DB      0CCh
        DB      0C2h
        DB      0E7h
        DB      0EDh
        DB      4Bh             ; 'K'
        DB      35h             ; '5'
        DB      0DFh
        DB      23h             ; '#'
        DB      0CDh
        DB      0B1h
        DB      0E6h
        DB      20h             ; ' '
        DB      0E8h
        DB      0C9h
        DB      0EDh
        DB      5Bh             ; '['
        DB      37h             ; '7'
        DB      0DFh
        DB      7Ah             ; 'z'
        DB      0FEh
        DB      0F4h
        DB      0D2h
        DB      0Fh
        DB      0E4h
        DB      0CDh
        DB      35h             ; '5'
        DB      0E6h
        DB      13h
        DB      13h
        DB      13h
        DB      13h
        DB      0EDh
        DB      53h             ; 'S'
        DB      37h             ; '7'
        DB      0DFh
        DB      0C9h
        DB      1Ah
        DB      0BEh
        DB      0C0h
        DB      23h             ; '#'
        DB      13h
        DB      10h
        DB      0F9h
        DB      0C9h
        DB      36h             ; '6'
        DB      00h
        DB      23h             ; '#'
        DB      10h
        DB      0FBh
        DB      0C9h
        DB      0CDh
        DB      0DAh
        DB      0E4h
        DB      38h             ; '8'
        DB      09h
        DB      0CDh
        DB      3Eh             ; '>'
        DB      0E5h
        DB      32h             ; '2'
        DB      38h             ; '8'
        DB      00h
        DB      0C3h
        DB      61h             ; 'a'
        DB      0E2h
        DB      0CDh
        DB      0FDh
        DB      0E7h
        DB      21h             ; '!'
        DB      00h
        DB      80h
        DB      0C3h
        DB      0F8h
        DB      0FFh
        DB      21h             ; '!'
        DB      15h
        DB      0E8h
        DB      11h
        DB      0F8h
        DB      0FFh
        DB      01h
        DB      07h
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0C9h
        DB      0CDh
        DB      0FDh
        DB      0E7h
        DB      31h             ; '1'
        DB      00h
        DB      0FFh
        DB      21h             ; '!'
        DB      09h
        DB      80h
        DB      0C3h
        DB      0F8h
        DB      0FFh
        DB      0AFh
        DB      0D3h
        DB      50h             ; 'P'
        DB      0E9h
        DB      0Eh
        DB      1Ah
        DB      0CDh
        DB      56h             ; 'V'
        DB      0E1h
        DB      3Eh             ; '>'
        DB      40h             ; '@'
        DB      0D3h
        DB      08h
        DB      21h             ; '!'
        DB      00h
        DB      0F8h
        DB      36h             ; '6'
        DB      0Fh
        DB      23h             ; '#'
        DB      0CBh
        DB      7Ch             ; '|'
        DB      20h             ; ' '
        DB      0F9h
        DB      0AFh
        DB      0D3h
        DB      08h
        DB      21h             ; '!'
        DB      0CBh
        DB      0E3h
        DB      0CDh
        DB      6Bh             ; 'k'
        DB      0E0h
        DB      0CDh
        DB      44h             ; 'D'
        DB      0E2h
        DB      0CDh
        DB      0DBh
        DB      0E2h
        DB      4Fh             ; 'O'
        DB      0FEh
        DB      1Bh
        DB      20h             ; ' '
        DB      0Ah
        DB      3Eh             ; '>'
        DB      39h             ; '9'
        DB      0CDh
        DB      03h
        DB      0EBh
        DB      0CAh
        DB      09h
        DB      0E8h
        DB      0Eh
        DB      1Bh
        DB      0CDh
        DB      56h             ; 'V'
        DB      0E1h
        DB      18h
        DB      0E9h
        DB      0C5h
        DB      32h             ; '2'
        DB      4Ch             ; 'L'
        DB      0DFh
        DB      4Fh             ; 'O'
        DB      3Ah             ; ':'
        DB      66h             ; 'f'
        DB      0DFh
        DB      0B1h
        DB      0D3h
        DB      48h             ; 'H'
        DB      0CDh
        DB      0B4h
        DB      0E9h
        DB      0CBh
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      09h
        DB      0DBh
        DB      45h             ; 'E'
        DB      0D3h
        DB      47h             ; 'G'
        DB      3Eh             ; '>'
        DB      1Bh
        DB      0CDh
        DB      0BAh
        DB      0E9h
        DB      0CBh
        DB      4Fh             ; 'O'
        DB      28h             ; '('
        DB      0Bh
        DB      06h
        DB      64h             ; 'd'
        DB      0CDh
        DB      0C6h
        DB      0E9h
        DB      0DBh
        DB      44h             ; 'D'
        DB      0CBh
        DB      4Fh             ; 'O'
        DB      20h             ; ' '
        DB      0Bh
        DB      0CDh
        DB      86h
        DB      0E8h
        DB      28h             ; '('
        DB      06h
        DB      0CDh
        DB      0B8h
        DB      0E9h
        DB      0CDh
        DB      86h
        DB      0E8h
        DB      0C1h
        DB      0C9h
        DB      0C5h
        DB      06h
        DB      04h
        DB      0CDh
        DB      0A3h
        DB      0E8h
        DB      28h             ; '('
        DB      13h
        DB      0E5h
        DB      21h             ; '!'
        DB      66h             ; 'f'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      08h
        DB      0AEh
        DB      77h             ; 'w'
        DB      3Ah             ; ':'
        DB      4Ch             ; 'L'
        DB      0DFh
        DB      0B6h
        DB      0D3h
        DB      48h             ; 'H'
        DB      0E1h
        DB      0F6h
        DB      0FFh
        DB      10h
        DB      0E8h
        DB      0C1h
        DB      0C9h
        DB      0C5h
        DB      0D5h
        DB      0F3h
        DB      0D3h
        DB      09h
        DB      3Eh             ; '>'
        DB      0C0h
        DB      0CDh
        DB      0ACh
        DB      0E9h
        DB      0Eh
        DB      48h             ; 'H'
        DB      0EDh
        DB      78h             ; 'x'
        DB      0F2h
        DB      0AFh
        DB      0E8h
        DB      0DBh
        DB      47h             ; 'G'
        DB      57h             ; 'W'
        DB      06h
        DB      03h
        DB      0EDh
        DB      78h             ; 'x'
        DB      0F2h
        DB      0B9h
        DB      0E8h
        DB      0DBh
        DB      47h             ; 'G'
        DB      10h
        DB      0F7h
        DB      5Fh             ; '_'
        DB      0CDh
        DB      0BFh
        DB      0E9h
        DB      0FBh
        DB      0E6h
        DB      98h
        DB      20h             ; ' '
        DB      12h
        DB      7Ah             ; 'z'
        DB      0D3h
        DB      45h             ; 'E'
        DB      7Bh             ; '{'
        DB      32h             ; '2'
        DB      4Dh             ; 'M'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      17h
        DB      1Dh
        DB      0F2h
        DB      0D4h
        DB      0E8h
        DB      32h             ; '2'
        DB      4Eh             ; 'N'
        DB      0DFh
        DB      0BFh
        DB      0D1h
        DB      0C1h
        DB      0C9h
        DB      0D3h
        DB      09h
        DB      0D5h
        DB      3Ah             ; ':'
        DB      4Ch             ; 'L'
        DB      0DFh
        DB      5Fh             ; '_'
        DB      3Ah             ; ':'
        DB      66h             ; 'f'
        DB      0DFh
        DB      0B3h
        DB      5Fh             ; '_'
        DB      7Ah             ; 'z'
        DB      0FEh
        DB      28h             ; '('
        DB      38h             ; '8'
        DB      06h
        DB      3Eh             ; '>'
        DB      4Fh             ; 'O'
        DB      92h
        DB      57h             ; 'W'
        DB      0CBh
        DB      0D3h
        DB      7Bh             ; '{'
        DB      0D3h
        DB      48h             ; 'H'
        DB      0DBh
        DB      45h             ; 'E'
        DB      0BAh
        DB      28h             ; '('
        DB      14h
        DB      7Ah             ; 'z'
        DB      0D3h
        DB      47h             ; 'G'
        DB      3Ah             ; ':'
        DB      67h             ; 'g'
        DB      0DFh
        DB      0F6h
        DB      1Ch
        DB      0CDh
        DB      0BAh
        DB      0E9h
        DB      06h
        DB      0Ah
        DB      0CDh
        DB      0C6h
        DB      0E9h
        DB      0DBh
        DB      44h             ; 'D'
        DB      0E6h
        DB      18h
        DB      3Ah             ; ':'
        DB      4Eh             ; 'N'
        DB      0DFh
        DB      47h             ; 'G'
        DB      0Eh
        DB      48h             ; 'H'
        DB      0D1h
        DB      7Bh             ; '{'
        DB      0D3h
        DB      46h             ; 'F'
        DB      0C9h
        DB      0C5h
        DB      06h
        DB      32h             ; '2'
        DB      0E5h
        DB      0C5h
        DB      0CDh
        DB      0E0h
        DB      0E8h
        DB      20h             ; ' '
        DB      26h             ; '&'
        DB      0F3h
        DB      3Eh             ; '>'
        DB      88h
        DB      0CDh
        DB      0ACh
        DB      0E9h
        DB      0EDh
        DB      78h             ; 'x'
        DB      0F2h
        DB      2Eh             ; '.'
        DB      0E9h
        DB      0DBh
        DB      47h             ; 'G'
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      0EDh
        DB      78h             ; 'x'
        DB      0F2h
        DB      37h             ; '7'
        DB      0E9h
        DB      0DBh
        DB      47h             ; 'G'
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      10h
        DB      0ECh
        DB      0FBh
        DB      0CDh
        DB      0BFh
        DB      0E9h
        DB      0E6h
        DB      9Ch
        DB      20h             ; ' '
        DB      04h
        DB      0C1h
        DB      0C1h
        DB      0C1h
        DB      0C9h
        DB      0C1h
        DB      0E1h
        DB      0CDh
        DB      96h
        DB      0E9h
        DB      10h
        DB      0CCh
        DB      0C1h
        DB      0AFh
        DB      3Ch             ; '<'
        DB      0C9h
        DB      0C5h
        DB      06h
        DB      32h             ; '2'
        DB      0E5h
        DB      0C5h
        DB      0CDh
        DB      0E0h
        DB      0E8h
        DB      20h             ; ' '
        DB      28h             ; '('
        DB      0F3h
        DB      0D5h
        DB      3Eh             ; '>'
        DB      0A8h
        DB      0CDh
        DB      0ACh
        DB      0E9h
        DB      7Eh             ; '~'
        DB      0EDh
        DB      50h             ; 'P'
        DB      0F2h
        DB      6Bh             ; 'k'
        DB      0E9h
        DB      0D3h
        DB      47h             ; 'G'
        DB      23h             ; '#'
        DB      7Eh             ; '~'
        DB      0EDh
        DB      50h             ; 'P'
        DB      0F2h
        DB      74h             ; 't'
        DB      0E9h
        DB      0D3h
        DB      47h             ; 'G'
        DB      23h             ; '#'
        DB      10h
        DB      0ECh
        DB      0FBh
        DB      0D1h
        DB      0CDh
        DB      0BFh
        DB      0E9h
        DB      0E6h
        DB      0FDh
        DB      20h             ; ' '
        DB      04h
        DB      0C1h
        DB      0C1h
        DB      0C1h
        DB      0C9h
        DB      0C1h
        DB      0E1h
        DB      0CDh
        DB      96h
        DB      0E9h
        DB      10h
        DB      0CAh
        DB      0C1h
        DB      0AFh
        DB      3Ch             ; '<'
        DB      0C9h
        DB      0F5h
        DB      0CDh
        DB      0A3h
        DB      0E8h
        DB      3Eh             ; '>'
        DB      07h
        DB      0A0h
        DB      0CCh
        DB      0B8h
        DB      0E9h
        DB      0CDh
        DB      0B4h
        DB      0E9h
        DB      3Ah             ; ':'
        DB      4Fh             ; 'O'
        DB      0DFh
        DB      3Ch             ; '<'
        DB      32h             ; '2'
        DB      4Fh             ; 'O'
        DB      0DFh
        DB      0F1h
        DB      0C9h
        DB      0D3h
        DB      44h             ; 'D'
        DB      3Eh             ; '>'
        DB      10h
        DB      3Dh             ; '='
        DB      20h             ; ' '
        DB      0FDh
        DB      0C9h
        DB      3Eh             ; '>'
        DB      0D0h
        DB      18h
        DB      02h
        DB      3Eh             ; '>'
        DB      0Bh
        DB      0D3h
        DB      44h             ; 'D'
        DB      0CDh
        DB      0AEh
        DB      0E9h
        DB      0DBh
        DB      44h             ; 'D'
        DB      0CBh
        DB      47h             ; 'G'
        DB      20h             ; ' '
        DB      0FAh
        DB      0C9h
        DB      0E5h
        DB      21h             ; '!'
        DB      7Ah             ; 'z'
        DB      00h
        DB      2Bh             ; '+'
        DB      7Ch             ; '|'
        DB      0B5h
        DB      20h             ; ' '
        DB      0FBh
        DB      10h
        DB      0F6h
        DB      0E1h
        DB      0C9h
        DB      3Ah             ; ':'
        DB      38h             ; '8'
        DB      00h
        DB      0CDh
        DB      4Fh             ; 'O'
        DB      0E8h
        DB      11h
        DB      01h
        DB      00h
        DB      21h             ; '!'
        DB      80h
        DB      00h
        DB      0CCh
        DB      1Eh
        DB      0E9h
        DB      20h             ; ' '
        DB      08h
        DB      3Ah             ; ':'
        DB      80h
        DB      00h
        DB      0FEh
        DB      0E5h
        DB      0C2h
        DB      80h
        DB      00h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      28h             ; '('
        DB      0E2h
        DB      0CBh
        DB      0AFh
        DB      0FEh
        DB      4Dh             ; 'M'
        DB      0CAh
        DB      0E2h
        DB      0E3h
        DB      18h
        DB      0D9h
        DB      0DDh
        DB      0E5h
        DB      0FDh
        DB      0E5h
        DB      0E5h
        DB      0DDh
        DB      0E1h
        DB      0DDh
        DB      09h
        DB      0CDh
        DB      90h
        DB      0EAh
        DB      06h
        DB      05h
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      0CDh
        DB      0E0h
        DB      0E8h
        DB      20h             ; ' '
        DB      45h             ; 'E'
        DB      0F3h
        DB      3Eh             ; '>'
        DB      98h
        DB      0CDh
        DB      0ACh
        DB      0E9h
        DB      3Ah             ; ':'
        DB      4Eh             ; 'N'
        DB      0DFh
        DB      47h             ; 'G'
        DB      0Eh
        DB      48h             ; 'H'
        DB      0EDh
        DB      78h             ; 'x'
        DB      0F2h
        DB      1Ch
        DB      0EAh
        DB      0DBh
        DB      47h             ; 'G'
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      0EDh
        DB      78h             ; 'x'
        DB      0F2h
        DB      25h             ; '%'
        DB      0EAh
        DB      0DBh
        DB      47h             ; 'G'
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      10h
        DB      0ECh
        DB      0DDh
        DB      0E5h
        DB      0C1h
        DB      0E5h
        DB      0A7h
        DB      0EDh
        DB      42h             ; 'B'
        DB      0E1h
        DB      30h             ; '0'
        DB      2Ch             ; ','
        DB      7Bh             ; '{'
        DB      1Ch
        DB      0FDh
        DB      0BEh
        DB      00h
        DB      20h             ; ' '
        DB      0D5h
        DB      06h
        DB      03h
        DB      0CDh
        DB      0C6h
        DB      0E9h
        DB      0DBh
        DB      44h             ; 'D'
        DB      2Fh             ; '/'
        DB      0CBh
        DB      47h             ; 'G'
        DB      20h             ; ' '
        DB      08h
        DB      0CDh
        DB      0B4h
        DB      0E9h
        DB      1Eh
        DB      01h
        DB      14h
        DB      18h
        DB      0B6h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      10h
        DB      0AEh
        DB      0FBh
        DB      0FDh
        DB      0E1h
        DB      0DDh
        DB      0E1h
        DB      0C0h
        DB      0CDh
        DB      0B4h
        DB      0E9h
        DB      0E6h
        DB      9Ch
        DB      0C9h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0AFh
        DB      18h
        DB      0EEh
        DB      0FDh
        DB      0E5h
        DB      0E5h
        DB      09h
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0CDh
        DB      90h
        DB      0EAh
        DB      0E1h
        DB      0CDh
        DB      59h             ; 'Y'
        DB      0E9h
        DB      20h             ; ' '
        DB      12h
        DB      7Bh             ; '{'
        DB      1Ch
        DB      0FDh
        DB      0BEh
        DB      00h
        DB      38h             ; '8'
        DB      03h
        DB      14h
        DB      1Eh
        DB      01h
        DB      0E5h
        DB      0A7h
        DB      0EDh
        DB      42h             ; 'B'
        DB      0E1h
        DB      38h             ; '8'
        DB      0EAh
        DB      0BFh
        DB      0FDh
        DB      0E1h
        DB      0C9h
        DB      0E5h
        DB      21h             ; '!'
        DB      66h             ; 'f'
        DB      0DFh
        DB      3Ah             ; ':'
        DB      4Dh             ; 'M'
        DB      0DFh
        DB      07h
        DB      0CBh
        DB      5Eh             ; '^'
        DB      0E1h
        DB      28h             ; '('
        DB      01h
        DB      3Dh             ; '='
        DB      0FDh
        DB      21h             ; '!'
        DB      0D5h
        DB      0EAh
        DB      0F8h
        DB      0CBh
        DB      57h             ; 'W'
        DB      0C0h
        DB      0D5h
        DB      16h
        DB      00h
        DB      5Fh             ; '_'
        DB      0FDh
        DB      19h
        DB      0D1h
        DB      0C9h
        DB      1Ah
        DB      0D6h
        DB      58h             ; 'X'
        DB      0CDh
        DB      4Fh             ; 'O'
        DB      0E8h
        DB      13h
        DB      1Ah
        DB      0F5h
        DB      0CDh
        DB      33h             ; '3'
        DB      0E7h
        DB      0EBh
        DB      0F1h
        DB      0FEh
        DB      52h             ; 'R'
        DB      28h             ; '('
        DB      09h
        DB      0FEh
        DB      57h             ; 'W'
        DB      20h             ; ' '
        DB      09h
        DB      0CDh
        DB      6Ch             ; 'l'
        DB      0EAh
        DB      18h
        DB      03h
        DB      0CDh
        DB      0FAh
        DB      0E9h
        DB      0C8h
        DB      06h
        DB      2Ah             ; '*'
        DB      11h
        DB      41h             ; 'A'
        DB      0F0h
        DB      0C3h
        DB      7Ch             ; '|'
        DB      0E4h
        DB      12h
        DB      12h
        DB      0Ah
        DB      0Ah
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      0B4h

        ; --- START PROC LA000 ---
LA000:  DI
        LD      DE,6000h
        LD      HL,0A100h
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        LD      BC,1000h
        LDIR
        LD      HL,0A04Bh
        LD      DE,0FFFBh
        LD      BC,0005h
        LDIR
        LD      A,04h
        JP      0FFFBh

LA04B:  DB      0D3h
        DB      50h             ; 'P'
        DB      0C3h
        DB      00h
        DB      0E0h
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0C3h
        DB      0C7h
        DB      0E5h
        DB      0C3h
        DB      36h             ; '6'
        DB      0E7h
        DB      0C3h
        DB      79h             ; 'y'
        DB      0E6h
        DB      0C3h
        DB      98h
        DB      0E0h
        DB      0C3h
        DB      0B9h
        DB      0E2h
        DB      0C3h
        DB      1Ch
        DB      0ECh
        DB      0C3h
        DB      0DFh
        DB      0E9h
        DB      0C3h
        DB      0BEh
        DB      0E9h
        DB      0C3h
        DB      60h             ; '`'
        DB      0EAh
        DB      0C3h
        DB      51h             ; 'Q'
        DB      0EAh
        DB      0C3h
        DB      6Dh             ; 'm'
        DB      0E0h
        DB      0C3h
        DB      1Ah
        DB      0EDh
        DB      0C3h
        DB      70h             ; 'p'
        DB      0E0h
        DB      0C3h
        DB      5Ch             ; '\'
        DB      0E0h
        DB      0C3h
        DB      0ADh
        DB      0E3h
        DB      0C3h
        DB      9Bh
        DB      0E6h
        DB      0C3h
        DB      9Bh
        DB      0E5h
        DB      0C3h
        DB      61h             ; 'a'
        DB      0E6h
        DB      0C3h
        DB      40h             ; '@'
        DB      0E4h
        DB      0C3h
        DB      53h             ; 'S'
        DB      0EEh
        DB      0C3h
        DB      78h             ; 'x'
        DB      0EEh
        DB      0C3h
        DB      52h             ; 'R'
        DB      0EDh
        DB      0C3h
        DB      7Ch             ; '|'
        DB      0EDh
        DB      0C3h
        DB      07h
        DB      0E4h
        DB      0C3h
        DB      15h
        DB      0E4h
        DB      0C3h
        DB      87h
        DB      0E4h
        DB      0C3h
        DB      81h
        DB      0E0h
        DB      0C3h
        DB      8Dh
        DB      0E6h
        DB      0C3h
        DB      0BFh
        DB      0E5h
        DB      3Ah             ; ':'
        DB      64h             ; 'd'
        DB      0DFh
        DB      2Fh             ; '/'
        DB      0C9h
        DB      0E5h
        DB      0C5h
        DB      7Eh             ; '~'
        DB      0B7h
        DB      28h             ; '('
        DB      08h
        DB      47h             ; 'G'
        DB      23h             ; '#'
        DB      4Eh             ; 'N'
        DB      23h             ; '#'
        DB      0EDh
        DB      0B3h
        DB      18h
        DB      0F4h
        DB      0C1h
        DB      0E1h
        DB      0C9h
        DB      21h             ; '!'
        DB      15h
        DB      0E7h
        DB      0C5h
        DB      0E5h
        DB      06h
        DB      10h
        DB      78h             ; 'x'
        DB      3Dh             ; '='
        DB      0D3h
        DB      0Ch
        DB      7Eh             ; '~'
        DB      0D3h
        DB      0Dh
        DB      2Bh             ; '+'
        DB      10h
        DB      0F6h
        DB      0E1h
        DB      0C1h
        DB      0C9h
        DB      0E5h
        DB      21h             ; '!'
        DB      60h             ; '`'
        DB      0DFh
        DB      7Eh             ; '~'
        DB      3Ch             ; '<'
        DB      28h             ; '('
        DB      04h
        DB      0F6h
        DB      0FFh
        DB      0E1h
        DB      0C9h
        DB      0CDh
        DB      0A5h
        DB      0E0h
        DB      20h             ; ' '
        DB      03h
        DB      77h             ; 'w'
        DB      18h
        DB      0F4h
        DB      0AFh
        DB      18h
        DB      0F3h
        DB      0CDh
        DB      81h
        DB      0E0h
        DB      0C8h
        DB      0E5h
        DB      21h             ; '!'
        DB      60h             ; '`'
        DB      0DFh
        DB      7Eh             ; '~'
        DB      36h             ; '6'
        DB      0FFh
        DB      0E1h
        DB      0C9h
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      3Ah             ; ':'
        DB      83h
        DB      0DFh
        DB      0FEh
        DB      0FFh
        DB      28h             ; '('
        DB      34h             ; '4'
        DB      06h
        DB      3Ch             ; '<'
        DB      0CDh
        DB      0C2h
        DB      0E1h
        DB      28h             ; '('
        DB      09h
        DB      10h
        DB      0F9h
        DB      3Eh             ; '>'
        DB      0FFh
        DB      32h             ; '2'
        DB      83h
        DB      0DFh
        DB      18h
        DB      2Bh             ; '+'
        DB      21h             ; '!'
        DB      87h
        DB      0DFh
        DB      0DBh
        DB      0Ch
        DB      0E6h
        DB      20h             ; ' '
        DB      0BEh
        DB      0CAh
        DB      9Dh
        DB      0E1h
        DB      77h             ; 'w'
        DB      2Ah             ; '*'
        DB      85h
        DB      0DFh
        DB      2Bh             ; '+'
        DB      22h             ; '"'
        DB      85h
        DB      0DFh
        DB      7Ch             ; '|'
        DB      0B5h
        DB      0C2h
        DB      9Dh
        DB      0E1h
        DB      21h             ; '!'
        DB      0Ah
        DB      00h
        DB      22h             ; '"'
        DB      85h
        DB      0DFh
        DB      3Ah             ; ':'
        DB      84h
        DB      0DFh
        DB      0C3h
        DB      8Ah
        DB      0E1h
        DB      0DBh
        DB      0Ch
        DB      0CBh
        DB      77h             ; 'w'
        DB      0CAh
        DB      9Dh
        DB      0E1h
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      3Eh             ; '>'
        DB      11h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      0Eh
        DB      0Ch
        DB      11h
        DB      13h
        DB      1Fh
        DB      21h             ; '!'
        DB      70h             ; 'p'
        DB      03h
        DB      3Eh             ; '>'
        DB      12h
        DB      0D3h
        DB      0Ch
        DB      7Ch             ; '|'
        DB      0D3h
        DB      0Dh
        DB      7Dh             ; '}'
        DB      0E5h
        DB      26h             ; '&'
        DB      10h
        DB      0CDh
        DB      0A1h
        DB      0E1h
        DB      0E1h
        DB      6Fh             ; 'o'
        DB      20h             ; ' '
        DB      07h
        DB      25h             ; '%'
        DB      0F2h
        DB      0FCh
        DB      0E0h
        DB      0C3h
        DB      9Dh
        DB      0E1h
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      7Ch             ; '|'
        DB      0E6h
        DB      3Fh             ; '?'
        DB      32h             ; '2'
        DB      83h
        DB      0DFh
        DB      21h             ; '!'
        DB      64h             ; 'd'
        DB      00h
        DB      22h             ; '"'
        DB      85h
        DB      0DFh
        DB      0FEh
        DB      20h             ; ' '
        DB      38h             ; '8'
        DB      0Ah
        DB      0FEh
        DB      30h             ; '0'
        DB      38h             ; '8'
        DB      30h             ; '0'
        DB      0FEh
        DB      38h             ; '8'
        DB      38h             ; '8'
        DB      3Fh             ; '?'
        DB      18h
        DB      6Ah             ; 'j'
        DB      0CDh
        DB      0BDh
        DB      0E1h
        DB      28h             ; '('
        DB      52h             ; 'R'
        DB      0C6h
        DB      60h             ; '`'
        DB      0FEh
        DB      60h             ; '`'
        DB      28h             ; '('
        DB      04h
        DB      0FEh
        DB      7Bh             ; '{'
        DB      38h             ; '8'
        DB      08h
        DB      0FEh
        DB      7Fh             ; ''
        DB      28h             ; '('
        DB      0Eh
        DB      0CBh
        DB      0AFh
        DB      18h
        DB      0Ah
        DB      47h             ; 'G'
        DB      3Ah             ; ':'
        DB      58h             ; 'X'
        DB      0DFh
        DB      0B7h
        DB      78h             ; 'x'
        DB      28h             ; '('
        DB      02h
        DB      0EEh
        DB      20h             ; ' '
        DB      0CDh
        DB      0B8h
        DB      0E1h
        DB      20h             ; ' '
        DB      31h             ; '1'
        DB      0EEh
        DB      20h             ; ' '
        DB      18h
        DB      2Dh             ; '-'
        DB      0FEh
        DB      2Ch             ; ','
        DB      38h             ; '8'
        DB      02h
        DB      0CBh
        DB      0E7h
        DB      0FEh
        DB      20h             ; ' '
        DB      28h             ; '('
        DB      05h
        DB      0CDh
        DB      0B8h
        DB      0E1h
        DB      28h             ; '('
        DB      1Eh
        DB      0EEh
        DB      10h
        DB      18h
        DB      1Ah
        DB      21h             ; '!'
        DB      0D0h
        DB      0E1h
        DB      4Fh             ; 'O'
        DB      06h
        DB      00h
        DB      09h
        DB      7Eh             ; '~'
        DB      0B7h
        DB      20h             ; ' '
        DB      0Fh
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      22h             ; '"'
        DB      85h
        DB      0DFh
        DB      21h             ; '!'
        DB      58h             ; 'X'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      01h
        DB      0AEh
        DB      77h             ; 'w'
        DB      18h
        DB      13h
        DB      0BFh
        DB      32h             ; '2'
        DB      84h
        DB      0DFh
        DB      0F5h
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      0F1h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0C9h
        DB      0F6h
        DB      0FFh
        DB      18h
        DB      0EDh
        DB      0EDh
        DB      59h             ; 'Y'
        DB      0D3h
        DB      0Dh
        DB      0EDh
        DB      51h             ; 'Q'
        DB      0D3h
        DB      0Dh
        DB      0EDh
        DB      40h             ; '@'
        DB      0F2h
        DB      0A9h
        DB      0E1h
        DB      0EDh
        DB      40h             ; '@'
        DB      0CBh
        DB      70h             ; 'p'
        DB      0C0h
        DB      94h
        DB      30h             ; '0'
        DB      0EBh
        DB      0BFh
        DB      0C9h
        DB      0C5h
        DB      06h
        DB      3Fh             ; '?'
        DB      18h
        DB      07h
        DB      0C5h
        DB      06h
        DB      39h             ; '9'
        DB      18h
        DB      02h
        DB      0C5h
        DB      47h             ; 'G'
        DB      4Fh             ; 'O'
        DB      3Eh             ; '>'
        DB      12h
        DB      0D3h
        DB      0Ch
        DB      78h             ; 'x'
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      47h             ; 'G'
        DB      0D3h
        DB      0Dh
        DB      3Eh             ; '>'
        DB      13h
        DB      0D3h
        DB      0Ch
        DB      78h             ; 'x'
        DB      0D3h
        DB      0Dh
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      3Eh             ; '>'
        DB      1Fh
        DB      0D3h
        DB      0Ch
        DB      0D3h
        DB      0Dh
        DB      0DBh
        DB      0Ch
        DB      0CBh
        DB      7Fh             ; ''
        DB      28h             ; '('
        DB      0FAh
        DB      0DBh
        DB      0Ch
        DB      2Fh             ; '/'
        DB      47h             ; 'G'
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      0Ch
        DB      0DBh
        DB      0Dh
        DB      0CBh
        DB      70h             ; 'p'
        DB      79h             ; 'y'
        DB      0C1h
        DB      0C9h
        DB      1Bh
        DB      08h
        DB      09h
        DB      0Ah
        DB      0Dh
        DB      00h
        DB      18h
        DB      20h             ; ' '
        DB      0Fh
        DB      0E6h
        DB      80h
        DB      32h             ; '2'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0C3h
        DB      9Fh
        DB      0E2h
        DB      0CDh
        DB      84h
        DB      0E3h
        DB      0E5h
        DB      0EBh
        DB      21h             ; '!'
        DB      7Fh             ; ''
        DB      0F7h
        DB      0E5h
        DB      0A7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0D1h
        DB      21h             ; '!'
        DB      2Fh             ; '/'
        DB      0F7h
        DB      0EDh
        DB      0B8h
        DB      0E1h
        DB      0CDh
        DB      8Eh
        DB      0E3h
        DB      18h
        DB      74h             ; 't'
        DB      0CDh
        DB      84h
        DB      0E3h
        DB      0E5h
        DB      0E5h
        DB      01h
        DB      50h             ; 'P'
        DB      00h
        DB      09h
        DB      0E5h
        DB      0EBh
        DB      21h             ; '!'
        DB      81h
        DB      0F7h
        DB      0A7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0E1h
        DB      0D1h
        DB      0EDh
        DB      0B0h
        DB      0CDh
        DB      8Bh
        DB      0E3h
        DB      0E1h
        DB      18h
        DB      57h             ; 'W'
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      38h             ; '8'
        DB      3Dh             ; '='
        DB      79h             ; 'y'
        DB      28h             ; '('
        DB      53h             ; 'S'
        DB      0FEh
        DB      29h             ; ')'
        DB      28h             ; '('
        DB      0B5h
        DB      0FEh
        DB      28h             ; '('
        DB      28h             ; '('
        DB      0B1h
        DB      0FEh
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      24h             ; '$'
        DB      0CBh
        DB      0AFh
        DB      0FEh
        DB      45h             ; 'E'
        DB      28h             ; '('
        DB      0B0h
        DB      0FEh
        DB      52h             ; 'R'
        DB      28h             ; '('
        DB      0C6h
        DB      0FEh
        DB      54h             ; 'T'
        DB      28h             ; '('
        DB      0BDh
        DB      0FEh
        DB      59h             ; 'Y'
        DB      28h             ; '('
        DB      0Dh
        DB      0AFh
        DB      32h             ; '2'
        DB      5Fh             ; '_'
        DB      0DFh
        DB      79h             ; 'y'
        DB      0FEh
        DB      5Ah             ; 'Z'
        DB      38h             ; '8'
        DB      29h             ; ')'
        DB      0Eh
        DB      20h             ; ' '
        DB      18h
        DB      57h             ; 'W'
        DB      0CCh
        DB      9Ah
        DB      0E3h
        DB      18h
        DB      20h             ; ' '
        DB      3Eh             ; '>'
        DB      02h
        DB      18h
        DB      2Ah             ; '*'
        DB      79h             ; 'y'
        DB      0D6h
        DB      20h             ; ' '
        DB      47h             ; 'G'
        DB      2Ah             ; '*'
        DB      5Dh             ; ']'
        DB      0DFh
        DB      26h             ; '&'
        DB      00h
        DB      54h             ; 'T'
        DB      5Dh             ; ']'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      19h
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      29h             ; ')'
        DB      5Fh             ; '_'
        DB      19h
        DB      7Ch             ; '|'
        DB      0E6h
        DB      07h
        DB      67h             ; 'g'
        DB      11h
        DB      00h
        DB      0F0h
        DB      19h
        DB      0AFh
        DB      18h
        DB      0Bh
        DB      0D6h
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      5Dh             ; ']'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      01h
        DB      18h
        DB      02h
        DB      3Eh             ; '>'
        DB      03h
        DB      32h             ; '2'
        DB      5Fh             ; '_'
        DB      0DFh
        DB      18h
        DB      7Ch             ; '|'
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      06h
        DB      00h
        DB      18h
        DB      0C1h
        DB      0F5h
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      2Ah             ; '*'
        DB      5Bh             ; '['
        DB      0DFh
        DB      0CDh
        DB      0A8h
        DB      0E3h
        DB      0CDh
        DB      45h             ; 'E'
        DB      0DFh
        DB      3Ah             ; ':'
        DB      5Eh             ; '^'
        DB      0DFh
        DB      47h             ; 'G'
        DB      3Ah             ; ':'
        DB      5Fh             ; '_'
        DB      0DFh
        DB      0B7h
        DB      0C2h
        DB      48h             ; 'H'
        DB      0E2h
        DB      79h             ; 'y'
        DB      0FEh
        DB      20h             ; ' '
        DB      38h             ; '8'
        DB      2Fh             ; '/'
        DB      3Ah             ; ':'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0B1h
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      04h
        DB      78h             ; 'x'
        DB      0D6h
        DB      50h             ; 'P'
        DB      20h             ; ' '
        DB      01h
        DB      47h             ; 'G'
        DB      0EBh
        DB      21h             ; '!'
        DB      7Fh             ; ''
        DB      0F7h
        DB      0B7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      0EBh
        DB      30h             ; '0'
        DB      41h             ; 'A'
        DB      0C5h
        DB      0E5h
        DB      01h
        DB      30h             ; '0'
        DB      07h
        DB      21h             ; '!'
        DB      50h             ; 'P'
        DB      0F0h
        DB      11h
        DB      00h
        DB      0F0h
        DB      0EDh
        DB      0B0h
        DB      0CDh
        DB      8Bh
        DB      0E3h
        DB      0E1h
        DB      0C1h
        DB      11h
        DB      0B0h
        DB      0FFh
        DB      19h
        DB      18h
        DB      29h             ; ')'
        DB      0FEh
        DB      1Eh
        DB      28h             ; '('
        DB      43h             ; 'C'
        DB      0FEh
        DB      1Bh
        DB      28h             ; '('
        DB      9Eh
        DB      0FEh
        DB      1Ah
        DB      28h             ; '('
        DB      0A1h
        DB      0FEh
        DB      09h
        DB      28h             ; '('
        DB      4Ch             ; 'L'
        DB      0FEh
        DB      08h
        DB      28h             ; '('
        DB      39h             ; '9'
        DB      0FEh
        DB      0Ah
        DB      28h             ; '('
        DB      29h             ; ')'
        DB      0FEh
        DB      0Bh
        DB      28h             ; '('
        DB      1Ch
        DB      0FEh
        DB      0Ch
        DB      28h             ; '('
        DB      0B6h
        DB      0FEh
        DB      07h
        DB      28h             ; '('
        DB      48h             ; 'H'
        DB      0FEh
        DB      0Dh
        DB      0CCh
        DB      84h
        DB      0E3h
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      5Eh             ; '^'
        DB      0DFh
        DB      22h             ; '"'
        DB      5Bh             ; '['
        DB      0DFh
        DB      0CDh
        DB      0A8h
        DB      0E3h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0F1h
        DB      0C9h
        DB      11h
        DB      0B0h
        DB      0FFh
        DB      19h
        DB      7Ch             ; '|'
        DB      0FEh
        DB      0F0h
        DB      30h             ; '0'
        DB      0ECh
        DB      11h
        DB      50h             ; 'P'
        DB      00h
        DB      19h
        DB      18h
        DB      97h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      0AFh
        DB      18h
        DB      0DDh
        DB      2Bh             ; '+'
        DB      05h
        DB      7Ch             ; '|'
        DB      0FEh
        DB      0EFh
        DB      28h             ; '('
        DB      0F3h
        DB      0CBh
        DB      78h             ; 'x'
        DB      28h             ; '('
        DB      0D1h
        DB      06h
        DB      4Fh             ; 'O'
        DB      18h
        DB      0CDh
        DB      3Ah             ; ':'
        DB      59h             ; 'Y'
        DB      0DFh
        DB      0F6h
        DB      20h             ; ' '
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      04h
        DB      78h             ; 'x'
        DB      0E6h
        DB      07h
        DB      20h             ; ' '
        DB      0F3h
        DB      0C3h
        DB      0DDh
        DB      0E2h
        DB      0D3h
        DB      09h
        DB      0Eh
        DB      0C8h
        DB      0DBh
        DB      02h
        DB      0EEh
        DB      40h             ; '@'
        DB      0D3h
        DB      02h
        DB      06h
        DB      0A4h
        DB      10h
        DB      0FEh
        DB      0Dh
        DB      20h             ; ' '
        DB      0F5h
        DB      18h
        DB      0AEh
        DB      78h             ; 'x'
        DB      0B7h
        DB      0C8h
        DB      2Bh             ; '+'
        DB      10h
        DB      0FDh
        DB      0C9h
        DB      21h             ; '!'
        DB      30h             ; '0'
        DB      0F7h
        DB      3Eh             ; '>'
        DB      50h             ; 'P'
        DB      90h
        DB      0E5h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      3Dh             ; '='
        DB      20h             ; ' '
        DB      0FAh
        DB      0E1h
        DB      0C9h
        DB      0E5h
        DB      0EBh
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      12h
        DB      13h
        DB      21h             ; '!'
        DB      7Fh             ; ''
        DB      08h
        DB      19h
        DB      30h             ; '0'
        DB      0F8h
        DB      0E1h
        DB      0C9h
        DB      7Eh             ; '~'
        DB      0EEh
        DB      80h
        DB      77h             ; 'w'
        DB      0C9h
        DB      0F5h
        DB      0D5h
        DB      0E5h
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      0Bh
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      11h
        DB      00h
        DB      0F8h
        DB      7Eh             ; '~'
        DB      2Fh             ; '/'
        DB      12h
        DB      23h             ; '#'
        DB      13h
        DB      0CBh
        DB      5Ch             ; '\'
        DB      28h             ; '('
        DB      0F7h
        DB      0AFh
        DB      0D3h
        DB      0Bh
        DB      0E1h
        DB      0D1h
        DB      0F1h
        DB      0C9h
        DB      0CDh
        DB      07h
        DB      0E4h
        DB      18h
        DB      03h
        DB      0CDh
        DB      15h
        DB      0E4h
        DB      21h             ; '!'
        DB      25h             ; '%'
        DB      0E7h
        DB      0CDh
        DB      70h             ; 'p'
        DB      0E0h
        DB      0CDh
        DB      0ADh
        DB      0E3h
        DB      13h
        DB      1Ah
        DB      0Eh
        DB      1Ah
        DB      0CDh
        DB      0B9h
        DB      0E2h
        DB      0FEh
        DB      48h             ; 'H'
        DB      28h             ; '('
        DB      08h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      0CDh
        DB      0FAh
        DB      0E3h
        DB      18h
        DB      0F8h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      4Fh             ; 'O'
        DB      0C4h
        DB      0B9h
        DB      0E2h
        DB      0CDh
        DB      0FAh
        DB      0E3h
        DB      18h
        DB      0F4h
        DB      0C4h
        DB      87h
        DB      0E4h
        DB      0CDh
        DB      9Bh
        DB      0E5h
        DB      4Fh             ; 'O'
        DB      0CBh
        DB      0B9h
        DB      0CCh
        DB      0B9h
        DB      0E2h
        DB      0C9h
        DB      0E5h
        DB      21h             ; '!'
        DB      48h             ; 'H'
        DB      02h
        DB      0E5h
        DB      21h             ; '!'
        DB      0B9h
        DB      03h
        DB      0E5h
        DB      21h             ; '!'
        DB      22h             ; '"'
        DB      0E5h
        DB      18h
        DB      0Ch
        DB      0E5h
        DB      21h             ; '!'
        DB      41h             ; 'A'
        DB      01h
        DB      0E5h
        DB      21h             ; '!'
        DB      0ABh
        DB      01h
        DB      0E5h
        DB      21h             ; '!'
        DB      33h             ; '3'
        DB      0E5h
        DB      22h             ; '"'
        DB      79h             ; 'y'
        DB      0DFh
        DB      0E1h
        DB      22h             ; '"'
        DB      75h             ; 'u'
        DB      0DFh
        DB      0E1h
        DB      22h             ; '"'
        DB      77h             ; 'w'
        DB      0DFh
        DB      0E1h
        DB      0C9h
        DB      0F5h
        DB      1Bh
        DB      7Ah             ; 'z'
        DB      0B3h
        DB      20h             ; ' '
        DB      04h
        DB      0EDh
        DB      5Bh             ; '['
        DB      6Eh             ; 'n'
        DB      0DFh
        DB      0DDh
        DB      2Ah             ; '*'
        DB      6Ch             ; 'l'
        DB      0DFh
        DB      0DDh
        DB      19h
        DB      0F1h
        DB      0C9h
        DB      7Ah             ; 'z'
        DB      0B7h
        DB      28h             ; '('
        DB      25h             ; '%'
        DB      0E6h
        DB      03h
        DB      20h             ; ' '
        DB      1Ah
        DB      29h             ; ')'
        DB      7Ch             ; '|'
        DB      0E6h
        DB      20h             ; ' '
        DB      0B0h
        DB      0D3h
        DB      02h
        DB      15h
        DB      7Bh             ; '{'
        DB      0B7h
        DB      28h             ; '('
        DB      1Fh
        DB      0E6h
        DB      03h
        DB      20h             ; ' '
        DB      15h
        DB      0DBh
        DB      02h
        DB      0E6h
        DB      10h
        DB      0D6h
        DB      01h
        DB      0CBh
        DB      19h
        DB      1Dh
        DB      0C9h
        DB      0B7h
        DB      0B7h
        DB      0B7h
        DB      0B7h
        DB      0B7h
        DB      18h
        DB      0E6h
        DB      0E3h
        DB      0E3h
        DB      18h
        DB      0E3h
        DB      0B7h
        DB      0B7h
        DB      0B7h
        DB      0B7h
        DB      18h
        DB      0EDh
        DB      0DBh
        DB      02h
        DB      0CBh
        DB      67h             ; 'g'
        DB      28h             ; '('
        DB      09h
        DB      3Ah             ; ':'
        DB      61h             ; 'a'
        DB      0DFh
        DB      5Fh             ; '_'
        DB      0AFh
        DB      32h             ; '2'
        DB      61h             ; 'a'
        DB      0DFh
        DB      0C9h
        DB      3Eh             ; '>'
        DB      00h
        DB      0C3h
        DB      61h             ; 'a'
        DB      0E4h
        DB      0F5h
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      0DDh
        DB      0E5h
        DB      0DDh
        DB      21h             ; '!'
        DB      77h             ; 'w'
        DB      0DFh
        DB      2Eh             ; '.'
        DB      00h
        DB      0DDh
        DB      46h             ; 'F'
        DB      0F9h
        DB      0CBh
        DB      40h             ; '@'
        DB      28h             ; '('
        DB      02h
        DB      0CBh
        DB      0BFh
        DB      0Fh
        DB      0EDh
        DB      6Ah             ; 'j'
        DB      10h
        DB      0FBh
        DB      0DDh
        DB      46h             ; 'F'
        DB      0FAh
        DB      05h
        DB      28h             ; '('
        DB      10h
        DB      05h
        DB      28h             ; '('
        DB      07h
        DB      0B7h
        DB      0EAh
        DB      0B5h
        DB      0E4h
        DB      37h             ; '7'
        DB      18h
        DB      04h
        DB      0B7h
        DB      0EAh
        DB      0AEh
        DB      0E4h
        DB      0EDh
        DB      6Ah             ; 'j'
        DB      0DDh
        DB      46h             ; 'F'
        DB      0FDh
        DB      37h             ; '7'
        DB      0EDh
        DB      6Ah             ; 'j'
        DB      10h
        DB      0FBh
        DB      3Ah             ; ':'
        DB      72h             ; 'r'
        DB      0DFh
        DB      32h             ; '2'
        DB      61h             ; 'a'
        DB      0DFh
        DB      0DDh
        DB      56h             ; 'V'
        DB      0FCh
        DB      0DBh
        DB      02h
        DB      47h             ; 'G'
        DB      0CBh
        DB      0A8h
        DB      1Eh
        DB      00h
        DB      0DDh
        DB      2Ah             ; '*'
        DB      79h             ; 'y'
        DB      0DFh
        DB      0DBh
        DB      02h
        DB      0CBh
        DB      5Fh             ; '_'
        DB      28h             ; '('
        DB      0FAh
        DB      0D3h
        DB      09h
        DB      0F3h
        DB      0CDh
        DB      20h             ; ' '
        DB      0E5h
        DB      3Ah             ; ':'
        DB      61h             ; 'a'
        DB      0DFh
        DB      0B7h
        DB      0CCh
        DB      0EEh
        DB      0E4h
        DB      0FBh
        DB      0DDh
        DB      0E1h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0F1h
        DB      0C9h
        DB      0DBh
        DB      02h
        DB      0CBh
        DB      67h             ; 'g'
        DB      28h             ; '('
        DB      09h
        DB      2Ah             ; '*'
        DB      75h             ; 'u'
        DB      0DFh
        DB      2Dh             ; '-'
        DB      20h             ; ' '
        DB      0FDh
        DB      25h             ; '%'
        DB      20h             ; ' '
        DB      0FAh
        DB      3Ah             ; ':'
        DB      70h             ; 'p'
        DB      0DFh
        DB      0FEh
        DB      07h
        DB      20h             ; ' '
        DB      02h
        DB      0CBh
        DB      39h             ; '9'
        DB      0CDh
        DB      12h
        DB      0E5h
        DB      0C8h
        DB      0EDh
        DB      53h             ; 'S'
        DB      6Ah             ; 'j'
        DB      0DFh
        DB      0DDh
        DB      71h             ; 'q'
        DB      00h
        DB      0C9h
        DB      2Ah             ; '*'
        DB      68h             ; 'h'
        DB      0DFh
        DB      0EDh
        DB      5Bh             ; '['
        DB      6Ah             ; 'j'
        DB      0DFh
        DB      0CDh
        DB      2Eh             ; '.'
        DB      0E4h
        DB      0A7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      0C9h
        DB      0DDh
        DB      0E9h
        DB      0CDh
        DB      36h             ; '6'
        DB      0E0h
        DB      3Eh             ; '>'
        DB      0A3h
        DB      3Dh             ; '='
        DB      20h             ; ' '
        DB      0FDh
        DB      00h
        DB      00h
        DB      00h
        DB      7Ah             ; 'z'
        DB      0B3h
        DB      0C2h
        DB      22h             ; '"'
        DB      0E5h
        DB      0C9h
        DB      0CDh
        DB      36h             ; '6'
        DB      0E0h
        DB      3Eh             ; '>'
        DB      1Fh
        DB      3Dh             ; '='
        DB      20h             ; ' '
        DB      0FDh
        DB      2Bh             ; '+'
        DB      23h             ; '#'
        DB      7Ah             ; 'z'
        DB      0B3h
        DB      0C2h
        DB      33h             ; '3'
        DB      0E5h
        DB      0C9h
        DB      0EDh
        DB      73h             ; 's'
        DB      7Fh             ; ''
        DB      0DFh
        DB      31h             ; '1'
        DB      0FEh
        DB      0DEh
        DB      0F5h
        DB      0C5h
        DB      0D5h
        DB      0E5h
        DB      0DDh
        DB      0E5h
        DB      0DBh
        DB      02h
        DB      0E6h
        DB      10h
        DB      0C4h
        DB      12h
        DB      0E5h
        DB      28h             ; '('
        DB      35h             ; '5'
        DB      0D3h
        DB      09h
        DB      2Ah             ; '*'
        DB      77h             ; 'w'
        DB      0DFh
        DB      2Dh             ; '-'
        DB      20h             ; ' '
        DB      0FDh
        DB      25h             ; '%'
        DB      20h             ; ' '
        DB      0FAh
        DB      3Ah             ; ':'
        DB      70h             ; 'p'
        DB      0DFh
        DB      5Fh             ; '_'
        DB      2Ah             ; '*'
        DB      75h             ; 'u'
        DB      0DFh
        DB      2Dh             ; '-'
        DB      20h             ; ' '
        DB      0FDh
        DB      25h             ; '%'
        DB      20h             ; ' '
        DB      0FAh
        DB      0DBh
        DB      02h
        DB      0E6h
        DB      10h
        DB      0D6h
        DB      01h
        DB      0CBh
        DB      19h
        DB      1Dh
        DB      20h             ; ' '
        DB      0ECh
        DB      3Ah             ; ':'
        DB      71h             ; 'q'
        DB      0DFh
        DB      3Dh             ; '='
        DB      28h             ; '('
        DB      09h
        DB      2Ah             ; '*'
        DB      75h             ; 'u'
        DB      0DFh
        DB      2Dh             ; '-'
        DB      20h             ; ' '
        DB      0FDh
        DB      25h             ; '%'
        DB      20h             ; ' '
        DB      0FAh
        DB      0CDh
        DB      0EEh
        DB      0E4h
        DB      0DDh
        DB      0E1h
        DB      0E1h
        DB      0D1h
        DB      0C1h
        DB      0F1h
        DB      0EDh
        DB      7Bh             ; '{'
        DB      7Fh             ; ''
        DB      0DFh
        DB      0FBh
        DB      0EDh
        DB      4Dh             ; 'M'
        DB      0D5h
        DB      0E5h
        DB      0DDh
        DB      0E5h
        DB      2Ah             ; '*'
        DB      6Ah             ; 'j'
        DB      0DFh
        DB      0EDh
        DB      5Bh             ; '['
        DB      68h             ; 'h'
        DB      0DFh
        DB      0B7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      20h             ; ' '
        DB      07h
        DB      0F6h
        DB      0FFh
        DB      0DDh
        DB      0E1h
        DB      0E1h
        DB      0D1h
        DB      0C9h
        DB      0CDh
        DB      2Eh             ; '.'
        DB      0E4h
        DB      0DDh
        DB      7Eh             ; '~'
        DB      00h
        DB      0EDh
        DB      53h             ; 'S'
        DB      68h             ; 'h'
        DB      0DFh
        DB      0BFh
        DB      18h
        DB      0EEh
        DB      0DBh
        DB      02h
        DB      0E6h
        DB      08h
        DB      0C8h
        DB      0F6h
        DB      0FFh
        DB      0C9h
        DB      0F3h
        DB      0AFh
        DB      0D3h
        DB      0Ah
        DB      0D3h
        DB      0Bh
        DB      21h             ; '!'
        DB      00h
        DB      80h
        DB      7Eh             ; '~'
        DB      2Fh             ; '/'
        DB      77h             ; 'w'
        DB      0BEh
        DB      2Fh             ; '/'
        DB      77h             ; 'w'
        DB      0C2h
        DB      00h
        DB      80h
        DB      31h             ; '1'
        DB      0FEh
        DB      0F7h
        DB      21h             ; '!'
        DB      0F6h
        DB      0E6h
        DB      0CDh
        DB      5Ch             ; '\'
        DB      0E0h
        DB      0CDh
        DB      6Dh             ; 'm'
        DB      0E0h
        DB      3Eh             ; '>'
        DB      40h             ; '@'
        DB      0D3h
        DB      08h
        DB      21h             ; '!'
        DB      00h
        DB      0F8h
        DB      36h             ; '6'
        DB      02h
        DB      23h             ; '#'
        DB      7Ch             ; '|'
        DB      0B7h
        DB      20h             ; ' '
        DB      0F9h
        DB      0D3h
        DB      08h
        DB      0CDh
        DB      0ADh
        DB      0E3h
        DB      0CDh
        DB      15h
        DB      0E4h
        DB      0CDh
        DB      99h
        DB      0E5h
        DB      21h             ; '!'
        DB      0C6h
        DB      0E6h
        DB      11h
        DB      45h             ; 'E'
        DB      0DFh
        DB      01h
        DB      30h             ; '0'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0Eh
        DB      1Ah
        DB      0CDh
        DB      0B9h
        DB      0E2h
        DB      0EDh
        DB      5Eh             ; '^'
        DB      3Eh             ; '>'
        DB      0DFh
        DB      0EDh
        DB      47h             ; 'G'
        DB      3Eh             ; '>'
        DB      0Dh
        DB      0CDh
        DB      0C2h
        DB      0E1h
        DB      0CAh
        DB      36h             ; '6'
        DB      0E7h
        DB      3Eh             ; '>'
        DB      02h
        DB      0CDh
        DB      0C2h
        DB      0E1h
        DB      28h             ; '('
        DB      1Bh
        DB      3Eh             ; '>'
        DB      36h             ; '6'
        DB      0CDh
        DB      0C2h
        DB      0E1h
        DB      0CAh
        DB      00h
        DB      80h
        DB      06h
        DB      55h             ; 'U'
        DB      3Ah             ; ':'
        DB      7Bh             ; '{'
        DB      0DFh
        DB      0B8h
        DB      20h             ; ' '
        DB      0Bh
        DB      3Ah             ; ':'
        DB      7Ch             ; '|'
        DB      0DFh
        DB      2Fh             ; '/'
        DB      0B8h
        DB      2Ah             ; '*'
        DB      7Dh             ; '}'
        DB      0DFh
        DB      20h             ; ' '
        DB      01h
        DB      0E9h
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      0AFh
        DB      32h             ; '2'
        DB      7Bh             ; '{'
        DB      0DFh
        DB      0C3h
        DB      0E6h
        DB      0EDh
        DB      0E5h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      11h
        DB      80h
        DB      0F7h
        DB      01h
        DB      50h             ; 'P'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0E1h
        DB      11h
        DB      00h
        DB      0F0h
        DB      7Eh             ; '~'
        DB      0EEh
        DB      80h
        DB      0C8h
        DB      12h
        DB      13h
        DB      23h             ; '#'
        DB      18h
        DB      0F7h
        DB      0CDh
        DB      48h             ; 'H'
        DB      0E6h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      28h             ; '('
        DB      0FBh
        DB      0FEh
        DB      0Dh
        DB      20h             ; ' '
        DB      0F7h
        DB      21h             ; '!'
        DB      80h
        DB      0F7h
        DB      11h
        DB      00h
        DB      0F0h
        DB      01h
        DB      50h             ; 'P'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0C9h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      28h             ; '('
        DB      0FBh
        DB      0C9h
        DB      32h             ; '2'
        DB      7Fh             ; ''
        DB      0DFh
        DB      3Eh             ; '>'
        DB      00h
        DB      32h             ; '2'
        DB      64h             ; 'd'
        DB      0DFh
        DB      3Ah             ; ':'
        DB      7Fh             ; ''
        DB      0DFh
        DB      0FBh
        DB      0EDh
        DB      4Dh             ; 'M'
        DB      0E5h
        DB      21h             ; '!'
        DB      64h             ; 'd'
        DB      0DFh
        DB      0CBh
        DB      46h             ; 'F'
        DB      20h             ; ' '
        DB      0FCh
        DB      36h             ; '6'
        DB      0FFh
        DB      0D3h
        DB      00h
        DB      0E1h
        DB      0C9h
        DB      0F5h
        DB      0C5h
        DB      0E5h
        DB      0DDh
        DB      0E5h
        DB      0FDh
        DB      0E5h
        DB      0Eh
        DB      0Ah
        DB      0F3h
        DB      7Ch             ; '|'
        DB      0B5h
        DB      28h             ; '('
        DB      11h
        DB      0EDh
        DB      51h             ; 'Q'
        DB      0DDh
        DB      7Eh             ; '~'
        DB      00h
        DB      0EDh
        DB      59h             ; 'Y'
        DB      0FDh
        DB      77h             ; 'w'
        DB      00h
        DB      0DDh
        DB      23h             ; '#'
        DB      0FDh
        DB      23h             ; '#'
        DB      2Bh             ; '+'
        DB      18h
        DB      0EBh
        DB      0AFh
        DB      0D3h
        DB      0Ah
        DB      0FBh
        DB      0FDh
        DB      0E1h
        DB      0DDh
        DB      0E1h
        DB      0E1h
        DB      0C1h
        DB      0F1h
        DB      0C9h
        DB      0C9h
        DB      00h
        DB      00h
        DB      7Fh             ; ''
        DB      0E6h
        DB      43h             ; 'C'
        DB      0E5h
        DB      03h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      04h
        DB      00h
        DB      0F0h
        DB      00h
        DB      00h
        DB      00h
        DB      0FFh
        DB      00h
        DB      00h
        DB      0F0h
        DB      00h
        DB      00h
        DB      08h
        DB      00h
        DB      75h             ; 'u'
        DB      00h
        DB      75h             ; 'u'
        DB      00h
        DB      8Ah
        DB      0DFh
        DB      75h             ; 'u'
        DB      00h
        DB      08h
        DB      01h
        DB      24h             ; '$'
        DB      28h             ; '('
        DB      04h
        DB      03h
        DB      01h
        DB      48h             ; 'H'
        DB      0Fh
        DB      83h
        DB      05h
        DB      03h
        DB      4Ah             ; 'J'
        DB      0FFh
        DB      99h
        DB      0B7h
        DB      0EFh
        DB      01h
        DB      02h
        DB      20h             ; ' '
        DB      00h
        DB      6Bh             ; 'k'
        DB      40h             ; '@'
        DB      51h             ; 'Q'
        DB      37h             ; '7'
        DB      12h
        DB      09h
        DB      10h
        DB      12h
        DB      48h             ; 'H'
        DB      0Fh
        DB      2Fh             ; '/'
        DB      0Fh
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      6Bh             ; 'k'
        DB      50h             ; 'P'
        DB      58h             ; 'X'
        DB      37h             ; '7'
        DB      1Bh
        DB      05h
        DB      18h
        DB      1Ah
        DB      48h             ; 'H'
        DB      0Ah
        DB      2Ah             ; '*'
        DB      0Ah
        DB      20h             ; ' '
        DB      00h
        DB      00h
        DB      00h
        DB      0CDh
        DB      79h             ; 'y'
        DB      0E6h
        DB      0FEh
        DB      1Bh
        DB      28h             ; '('
        DB      30h             ; '0'
        DB      0FEh
        DB      61h             ; 'a'
        DB      0D8h
        DB      0FEh
        DB      7Bh             ; '{'
        DB      0D0h
        DB      0CBh
        DB      0AFh
        DB      0C9h
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      0FBh
        DB      0AFh
        DB      32h             ; '2'
        DB      7Bh             ; '{'
        DB      0DFh
        DB      0CDh
        DB      6Dh             ; 'm'
        DB      0E0h
        DB      0CDh
        DB      0ADh
        DB      0E3h
        DB      21h             ; '!'
        DB      00h
        DB      0DFh
        DB      06h
        DB      42h             ; 'B'
        DB      0CDh
        DB      52h             ; 'R'
        DB      0EBh
        DB      0CDh
        DB      0DEh
        DB      0E7h
        DB      01h
        DB      16h
        DB      00h
        DB      11h
        DB      15h
        DB      0F0h
        DB      21h             ; '!'
        DB      0B3h
        DB      0EAh
        DB      0EDh
        DB      0B0h
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      0AFh
        DB      32h             ; '2'
        DB      08h
        DB      0DFh
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      0CDh
        DB      0EBh
        DB      0E7h
        DB      21h             ; '!'
        DB      41h             ; 'A'
        DB      0F0h
        DB      0CBh
        DB      0FEh
        DB      0CDh
        DB      26h             ; '&'
        DB      0E7h
        DB      0CBh
        DB      0BEh
        DB      0FEh
        DB      0Dh
        DB      28h             ; '('
        DB      34h             ; '4'
        DB      0FEh
        DB      0Ah
        DB      28h             ; '('
        DB      33h             ; '3'
        DB      0FEh
        DB      01h
        DB      28h             ; '('
        DB      27h             ; '''
        DB      0FEh
        DB      13h
        DB      28h             ; '('
        DB      0Dh
        DB      0FEh
        DB      7Fh             ; ''
        DB      28h             ; '('
        DB      18h
        DB      0FEh
        DB      08h
        DB      28h             ; '('
        DB      1Bh
        DB      0FEh
        DB      20h             ; ' '
        DB      38h             ; '8'
        DB      0DDh
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      3Eh             ; '>'
        DB      5Fh             ; '_'
        DB      0BDh
        DB      30h             ; '0'
        DB      0D6h
        DB      2Bh             ; '+'
        DB      18h
        DB      0D3h
        DB      3Eh             ; '>'
        DB      41h             ; 'A'
        DB      0BDh
        DB      0C8h
        DB      2Bh             ; '+'
        DB      0C9h
        DB      0CDh
        DB      97h
        DB      0E7h
        DB      36h             ; '6'
        DB      0A0h
        DB      18h
        DB      0C6h
        DB      0CDh
        DB      97h
        DB      0E7h
        DB      18h
        DB      0C1h
        DB      0CDh
        DB      0F1h
        DB      0E7h
        DB      11h
        DB      41h             ; 'A'
        DB      0F0h
        DB      1Ah
        DB      0D6h
        DB      41h             ; 'A'
        DB      0FEh
        DB      1Ah
        DB      30h             ; '0'
        DB      12h
        DB      21h             ; '!'
        DB      5Dh             ; ']'
        DB      0E7h
        DB      0E5h
        DB      07h
        DB      21h             ; '!'
        DB      0C9h
        DB      0EAh
        DB      85h
        DB      6Fh             ; 'o'
        DB      30h             ; '0'
        DB      01h
        DB      24h             ; '$'
        DB      7Eh             ; '~'
        DB      23h             ; '#'
        DB      66h             ; 'f'
        DB      6Fh             ; 'o'
        DB      0E9h
        DB      06h
        DB      3Fh             ; '?'
        DB      0FBh
        DB      31h             ; '1'
        DB      0D0h
        DB      0DEh
        DB      21h             ; '!'
        DB      60h             ; '`'
        DB      0F0h
        DB      70h             ; 'p'
        DB      0EBh
        DB      0CBh
        DB      0FEh
        DB      0CDh
        DB      26h             ; '&'
        DB      0E7h
        DB      0EBh
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      0EBh
        DB      18h
        DB      91h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      06h
        DB      0F4h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      7Ch             ; '|'
        DB      0B8h
        DB      20h             ; ' '
        DB      0F9h
        DB      0C9h
        DB      21h             ; '!'
        DB      40h             ; '@'
        DB      0F0h
        DB      36h             ; '6'
        DB      3Eh             ; '>'
        DB      23h             ; '#'
        DB      06h
        DB      40h             ; '@'
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      23h             ; '#'
        DB      10h
        DB      0FBh
        DB      0C9h
        DB      0EBh
        DB      22h             ; '"'
        DB      01h
        DB      0DFh
        DB      0E5h
        DB      3Eh             ; '>'
        DB      0C0h
        DB      0A5h
        DB      6Fh             ; 'o'
        DB      01h
        DB      0F0h
        DB      0FFh
        DB      09h
        DB      11h
        DB      0C0h
        DB      0F0h
        DB      0CDh
        DB      31h             ; '1'
        DB      0E9h
        DB      1Bh
        DB      0CDh
        DB      44h             ; 'D'
        DB      0E9h
        DB      7Ah             ; 'z'
        DB      0FEh
        DB      0F2h
        DB      20h             ; ' '
        DB      0F4h
        DB      7Bh             ; '{'
        DB      0FEh
        DB      40h             ; '@'
        DB      20h             ; ' '
        DB      0EFh
        DB      0E1h
        DB      11h
        DB      81h
        DB      0F0h
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E9h
        DB      13h
        DB      7Eh             ; '~'
        DB      32h             ; '2'
        DB      8Ah
        DB      0F0h
        DB      0CDh
        DB      92h
        DB      0E8h
        DB      0EBh
        DB      0C9h
        DB      0CDh
        DB      3Ah             ; ':'
        DB      0E8h
        DB      38h             ; '8'
        DB      98h
        DB      20h             ; ' '
        DB      0F9h
        DB      0CDh
        DB      3Ah             ; ':'
        DB      0E8h
        DB      0D8h
        DB      28h             ; '('
        DB      0FAh
        DB      1Bh
        DB      0C9h
        DB      7Bh             ; '{'
        DB      0FEh
        DB      5Fh             ; '_'
        DB      38h             ; '8'
        DB      02h
        DB      37h             ; '7'
        DB      0C9h
        DB      1Ah
        DB      13h
        DB      0FEh
        DB      20h             ; ' '
        DB      0C9h
        DB      0CDh
        DB      2Bh             ; '+'
        DB      0E8h
        DB      0DAh
        DB      0C8h
        DB      0E7h
        DB      0C9h
        DB      1Ah
        DB      0CDh
        DB      5Bh             ; '['
        DB      0E8h
        DB      0D2h
        DB      0C8h
        DB      0E7h
        DB      0C9h
        DB      21h             ; '!'
        DB      04h
        DB      0DFh
        DB      0EDh
        DB      6Fh             ; 'o'
        DB      0C9h
        DB      0D6h
        DB      30h             ; '0'
        DB      0FEh
        DB      0Ah
        DB      0D8h
        DB      0D6h
        DB      11h
        DB      0FEh
        DB      06h
        DB      0D0h
        DB      0C6h
        DB      0Ah
        DB      3Fh             ; '?'
        DB      0C9h
        DB      0CDh
        DB      46h             ; 'F'
        DB      0E8h
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      22h             ; '"'
        DB      04h
        DB      0DFh
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E8h
        DB      0CDh
        DB      55h             ; 'U'
        DB      0E8h
        DB      23h             ; '#'
        DB      0EDh
        DB      6Fh             ; 'o'
        DB      13h
        DB      7Bh             ; '{'
        DB      0FEh
        DB      5Fh             ; '_'
        DB      0D2h
        DB      0C8h
        DB      0E7h
        DB      1Ah
        DB      0FEh
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      0EBh
        DB      2Ah             ; '*'
        DB      04h
        DB      0DFh
        DB      0C9h
        DB      0E5h
        DB      0CDh
        DB      6Ch             ; 'l'
        DB      0E8h
        DB      7Dh             ; '}'
        DB      0E1h
        DB      0C9h
        DB      0C5h
        DB      47h             ; 'G'
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      0Fh
        DB      0CDh
        DB      0A1h
        DB      0E8h
        DB      78h             ; 'x'
        DB      0CDh
        DB      0A1h
        DB      0E8h
        DB      0C1h
        DB      0C9h
        DB      0E6h
        DB      0Fh
        DB      0B7h
        DB      27h             ; '''
        DB      0C6h
        DB      0F0h
        DB      0CEh
        DB      40h             ; '@'
        DB      12h
        DB      13h
        DB      0C9h
        DB      0AFh
        DB      18h
        DB      02h
        DB      3Eh             ; '>'
        DB      80h
        DB      32h             ; '2'
        DB      06h
        DB      0DFh
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0EBh
        DB      21h             ; '!'
        DB      06h
        DB      0DFh
        DB      0CBh
        DB      2Eh             ; '.'
        DB      0CDh
        DB      59h             ; 'Y'
        DB      0E9h
        DB      0CDh
        DB      0F9h
        DB      0E7h
        DB      0CDh
        DB      26h             ; '&'
        DB      0E7h
        DB      0CDh
        DB      59h             ; 'Y'
        DB      0E9h
        DB      0CDh
        DB      0ECh
        DB      0E8h
        DB      21h             ; '!'
        DB      06h
        DB      0DFh
        DB      0CBh
        DB      76h             ; 'v'
        DB      20h             ; ' '
        DB      0F0h
        DB      0CDh
        DB      55h             ; 'U'
        DB      0E8h
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      8Dh
        DB      0F0h
        DB      0CDh
        DB      26h             ; '&'
        DB      0E7h
        DB      0CDh
        DB      0ECh
        DB      0E8h
        DB      0CDh
        DB      55h             ; 'U'
        DB      0E8h
        DB      7Eh             ; '~'
        DB      12h
        DB      78h             ; 'x'
        DB      32h             ; '2'
        DB      8Eh
        DB      0F0h
        DB      13h
        DB      18h
        DB      0D4h
        DB      0E1h
        DB      47h             ; 'G'
        DB      0FEh
        DB      01h
        DB      20h             ; ' '
        DB      03h
        DB      1Bh
        DB      18h
        DB      0C3h
        DB      0FEh
        DB      13h
        DB      20h             ; ' '
        DB      03h
        DB      13h
        DB      18h
        DB      0BCh
        DB      0FEh
        DB      17h
        DB      20h             ; ' '
        DB      07h
        DB      21h             ; '!'
        DB      0F0h
        DB      0FFh
        DB      19h
        DB      0EBh
        DB      18h
        DB      0B1h
        DB      0FEh
        DB      1Ah
        DB      20h             ; ' '
        DB      05h
        DB      21h             ; '!'
        DB      10h
        DB      00h
        DB      18h
        DB      0F3h
        DB      0FEh
        DB      4Dh             ; 'M'
        DB      20h             ; ' '
        DB      07h
        DB      21h             ; '!'
        DB      06h
        DB      0DFh
        DB      0CBh
        DB      0B6h
        DB      18h
        DB      0A2h
        DB      0FEh
        DB      52h             ; 'R'
        DB      20h             ; ' '
        DB      0Ch
        DB      1Ah
        DB      3Ch             ; '<'
        DB      6Fh             ; 'o'
        DB      26h             ; '&'
        DB      00h
        DB      0F2h
        DB      03h
        DB      0E9h
        DB      25h             ; '%'
        DB      6Fh             ; 'o'
        DB      18h
        DB      0D8h
        DB      0CDh
        DB      5Bh             ; '['
        DB      0E8h
        DB      30h             ; '0'
        DB      93h
        DB      0E9h
        DB      0CDh
        DB      44h             ; 'D'
        DB      0E9h
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E9h
        DB      0CDh
        DB      44h             ; 'D'
        DB      0E9h
        DB      06h
        DB      04h
        DB      48h             ; 'H'
        DB      0CDh
        DB      81h
        DB      0E9h
        DB      41h             ; 'A'
        DB      10h
        DB      0F9h
        DB      0C9h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      12h
        DB      13h
        DB      12h
        DB      13h
        DB      12h
        DB      13h
        DB      0C9h
        DB      7Ch             ; '|'
        DB      0CDh
        DB      92h
        DB      0E8h
        DB      7Dh             ; '}'
        DB      0C3h
        DB      92h
        DB      0E8h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E9h
        DB      21h             ; '!'
        DB      8Ch
        DB      0F0h
        DB      06h
        DB      04h
        DB      0C3h
        DB      0F3h
        DB      0E7h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0CDh
        DB      77h             ; 'w'
        DB      0E9h
        DB      0C1h
        DB      0E1h
        DB      5Fh             ; '_'
        DB      73h             ; 's'
        DB      0CDh
        DB      0A0h
        DB      0E9h
        DB      23h             ; '#'
        DB      38h             ; '8'
        DB      0F9h
        DB      0C9h
        DB      0CDh
        DB      2Bh             ; '+'
        DB      0E8h
        DB      3Eh             ; '>'
        DB      00h
        DB      0D8h
        DB      0CDh
        DB      8Bh
        DB      0E8h
        DB      0C9h
        DB      06h
        DB      04h
        DB      7Eh             ; '~'
        DB      0CDh
        DB      92h
        DB      0E8h
        DB      0C5h
        DB      0EDh
        DB      4Bh             ; 'K'
        DB      01h
        DB      0DFh
        DB      0CDh
        DB      0A0h
        DB      0E9h
        DB      0C1h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      20h             ; ' '
        DB      02h
        DB      3Eh             ; '>'
        DB      8Dh
        DB      12h
        DB      13h
        DB      23h             ; '#'
        DB      10h
        DB      0E8h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      12h
        DB      13h
        DB      0C9h
        DB      0A7h
        DB      0E5h
        DB      0EDh
        DB      42h             ; 'B'
        DB      0E1h
        DB      0C9h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0EDh
        DB      69h             ; 'i'
        DB      0C9h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      44h             ; 'D'
        DB      4Dh             ; 'M'
        DB      0EDh
        DB      78h             ; 'x'
        DB      11h
        DB      03h
        DB      0F0h
        DB      0C3h
        DB      92h
        DB      0E8h
        DB      0Eh
        DB      00h
        DB      0CDh
        DB      0DFh
        DB      0E9h
        DB      77h             ; 'w'
        DB      1Bh
        DB      23h             ; '#'
        DB      91h
        DB      2Fh             ; '/'
        DB      4Fh             ; 'O'
        DB      10h
        DB      0F5h
        DB      0CDh
        DB      0DFh
        DB      0E9h
        DB      47h             ; 'G'
        DB      3Ah             ; ':'
        DB      07h
        DB      0DFh
        DB      0B7h
        DB      0C0h
        DB      78h             ; 'x'
        DB      0B9h
        DB      0C8h
        DB      06h
        DB      43h             ; 'C'
        DB      11h
        DB      41h             ; 'A'
        DB      0F0h
        DB      0C3h
        DB      0CAh
        DB      0E7h
        DB      0D3h
        DB      09h
        DB      0C5h
        DB      0CDh
        DB      3Dh             ; '='
        DB      0EAh
        DB      0CDh
        DB      3Dh             ; '='
        DB      0EAh
        DB      0FEh
        DB      1Ch
        DB      38h             ; '8'
        DB      0F9h
        DB      3Ah             ; ':'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      47h             ; 'G'
        DB      0CBh
        DB      20h             ; ' '
        DB      05h
        DB      0CDh
        DB      3Dh             ; '='
        DB      0EAh
        DB      10h
        DB      0FBh
        DB      0AFh
        DB      06h
        DB      08h
        DB      0Fh
        DB      0CDh
        DB      07h
        DB      0EAh
        DB      30h             ; '0'
        DB      02h
        DB      0CBh
        DB      0FFh
        DB      10h
        DB      0F6h
        DB      0C1h
        DB      0C9h
        DB      0E5h
        DB      0C5h
        DB      0F5h
        DB      21h             ; '!'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      46h             ; 'F'
        DB      0Eh
        DB      00h
        DB      0CDh
        DB      3Dh             ; '='
        DB      0EAh
        DB      0CDh
        DB      3Dh             ; '='
        DB      0EAh
        DB      81h
        DB      4Fh             ; 'O'
        DB      10h
        DB      0F9h
        DB      46h             ; 'F'
        DB      0CBh
        DB      40h             ; '@'
        DB      20h             ; ' '
        DB      06h
        DB      0CBh
        DB      3Fh             ; '?'
        DB      0CBh
        DB      38h             ; '8'
        DB      18h
        DB      0F6h
        DB      0FEh
        DB      1Ch
        DB      0F5h
        DB      7Eh             ; '~'
        DB      30h             ; '0'
        DB      01h
        DB      07h
        DB      07h
        DB      96h
        DB      3Dh             ; '='
        DB      47h             ; 'G'
        DB      28h             ; '('
        DB      05h
        DB      0CDh
        DB      3Dh             ; '='
        DB      0EAh
        DB      10h
        DB      0FBh
        DB      0F1h
        DB      0C1h
        DB      78h             ; 'x'
        DB      0C1h
        DB      0E1h
        DB      0C9h
        DB      0C5h
        DB      0F5h
        DB      0DBh
        DB      02h
        DB      4Fh             ; 'O'
        DB      06h
        DB      00h
        DB      04h
        DB      0DBh
        DB      02h
        DB      0A9h
        DB      0E6h
        DB      01h
        DB      0CAh
        DB      44h             ; 'D'
        DB      0EAh
        DB      0F1h
        DB      78h             ; 'x'
        DB      0C1h
        DB      0C9h
        DB      0Eh
        DB      00h
        DB      7Eh             ; '~'
        DB      91h
        DB      2Fh             ; '/'
        DB      4Fh             ; 'O'
        DB      7Eh             ; '~'
        DB      0CDh
        DB      60h             ; '`'
        DB      0EAh
        DB      23h             ; '#'
        DB      1Bh
        DB      10h
        DB      0F4h
        DB      79h             ; 'y'
        DB      0D3h
        DB      09h
        DB      0C5h
        DB      0CDh
        DB      9Dh
        DB      0EAh
        DB      06h
        DB      08h
        DB      0CBh
        DB      47h             ; 'G'
        DB      0CCh
        DB      9Dh
        DB      0EAh
        DB      0C4h
        DB      7Bh             ; '{'
        DB      0EAh
        DB      0Fh
        DB      10h
        DB      0F5h
        DB      0CDh
        DB      7Bh             ; '{'
        DB      0EAh
        DB      0CDh
        DB      7Bh             ; '{'
        DB      0EAh
        DB      0C1h
        DB      0C9h
        DB      0F5h
        DB      0C5h
        DB      06h
        DB      32h             ; '2'
        DB      3Ah             ; ':'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      0CBh
        DB      27h             ; '''
        DB      4Fh             ; 'O'
        DB      0C5h
        DB      10h
        DB      0FEh
        DB      0C1h
        DB      0DBh
        DB      02h
        DB      0CBh
        DB      8Fh
        DB      0D3h
        DB      02h
        DB      0C5h
        DB      10h
        DB      0FEh
        DB      0C1h
        DB      0CBh
        DB      0CFh
        DB      0D3h
        DB      02h
        DB      0Dh
        DB      20h             ; ' '
        DB      0EBh
        DB      0C1h
        DB      0F1h
        DB      0C9h
        DB      0F5h
        DB      0C5h
        DB      06h
        DB      68h             ; 'h'
        DB      3Ah             ; ':'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      4Fh             ; 'O'
        DB      18h
        DB      0DEh
        DB      21h             ; '!'
        DB      40h             ; '@'
        DB      0F2h
        DB      0E5h
        DB      0CDh
        DB      0E1h
        DB      0E7h
        DB      0E1h
        DB      22h             ; '"'
        DB      37h             ; '7'
        DB      0DFh
        DB      0C9h
        DB      48h             ; 'H'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      64h             ; 'd'
        DB      20h             ; ' '
        DB      44h             ; 'D'
        DB      69h             ; 'i'
        DB      73h             ; 's'
        DB      6Bh             ; 'k'
        DB      20h             ; ' '
        DB      4Dh             ; 'M'
        DB      6Fh             ; 'o'
        DB      6Eh             ; 'n'
        DB      69h             ; 'i'
        DB      74h             ; 't'
        DB      6Fh             ; 'o'
        DB      72h             ; 'r'
        DB      20h             ; ' '
        DB      76h             ; 'v'
        DB      31h             ; '1'
        DB      2Eh             ; '.'
        DB      30h             ; '0'
        DB      0ACh
        DB      0E8h
        DB      00h
        DB      0E0h
        DB      9Ah
        DB      0ECh
        DB      0EAh
        DB      0EBh
        DB      0AFh
        DB      0E8h
        DB      61h             ; 'a'
        DB      0E9h
        DB      55h             ; 'U'
        DB      0E9h
        DB      00h
        DB      0E0h
        DB      0B1h
        DB      0E9h
        DB      0C8h
        DB      0E7h
        DB      0C8h
        DB      0E7h
        DB      0C8h
        DB      0E7h
        DB      84h
        DB      0ECh
        DB      0C8h
        DB      0E7h
        DB      0A6h
        DB      0E9h
        DB      0DEh
        DB      0E7h
        DB      0C8h
        DB      0E7h
        DB      0FDh
        DB      0EAh
        DB      0C6h
        DB      0ECh
        DB      0CAh
        DB      0E3h
        DB      0CFh
        DB      0E3h
        DB      0C8h
        DB      0E7h
        DB      0F4h
        DB      0EBh
        DB      9Dh
        DB      0EEh
        DB      9Dh
        DB      0EEh
        DB      9Dh
        DB      0EEh
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0EBh
        DB      0CDh
        DB      2Bh             ; '+'
        DB      0E8h
        DB      38h             ; '8'
        DB      09h
        DB      32h             ; '2'
        DB      0Ch
        DB      0DFh
        DB      21h             ; '!'
        DB      0Dh
        DB      0DFh
        DB      0CDh
        DB      58h             ; 'X'
        DB      0EBh
        DB      0CDh
        DB      1Ch
        DB      0ECh
        DB      0F3h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0EBh
        DB      11h
        DB      63h             ; 'c'
        DB      0F0h
        DB      0CDh
        DB      84h
        DB      0EBh
        DB      3Ah             ; ':'
        DB      0Ch
        DB      0DFh
        DB      0B7h
        DB      28h             ; '('
        DB      05h
        DB      0CDh
        DB      0C9h
        DB      0EBh
        DB      20h             ; ' '
        DB      0ECh
        DB      2Ah             ; '*'
        DB      20h             ; ' '
        DB      0DFh
        DB      3Ah             ; ':'
        DB      0Bh
        DB      0DFh
        DB      0B7h
        DB      28h             ; '('
        DB      03h
        DB      2Ah             ; '*'
        DB      09h
        DB      0DFh
        DB      0EDh
        DB      5Bh             ; '['
        DB      1Eh
        DB      0DFh
        DB      3Ah             ; ':'
        DB      24h             ; '$'
        DB      0DFh
        DB      0B7h
        DB      28h             ; '('
        DB      05h
        DB      3Eh             ; '>'
        DB      01h
        DB      32h             ; '2'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      0CDh
        DB      0D9h
        DB      0EBh
        DB      28h             ; '('
        DB      05h
        DB      0CDh
        DB      0BEh
        DB      0E9h
        DB      18h
        DB      0F6h
        DB      0FBh
        DB      0C9h
        DB      21h             ; '!'
        DB      09h
        DB      0DFh
        DB      06h
        DB      2Ah             ; '*'
        DB      36h             ; '6'
        DB      00h
        DB      23h             ; '#'
        DB      10h
        DB      0FBh
        DB      0C9h
        DB      0CDh
        DB      0B1h
        DB      0EBh
        DB      0CDh
        DB      2Bh             ; '+'
        DB      0E8h
        DB      0D8h
        DB      32h             ; '2'
        DB      0Bh
        DB      0DFh
        DB      0CDh
        DB      6Ch             ; 'l'
        DB      0E8h
        DB      22h             ; '"'
        DB      09h
        DB      0DFh
        DB      0C9h
        DB      06h
        DB      10h
        DB      0CDh
        DB      0DFh
        DB      0E9h
        DB      0B7h
        DB      20h             ; ' '
        DB      0F8h
        DB      10h
        DB      0F8h
        DB      0CDh
        DB      0DFh
        DB      0E9h
        DB      0B7h
        DB      28h             ; '('
        DB      0FAh
        DB      3Dh             ; '='
        DB      20h             ; ' '
        DB      0EDh
        DB      06h
        DB      10h
        DB      21h             ; '!'
        DB      17h
        DB      0DFh
        DB      0C3h
        DB      0BEh
        DB      0E9h
        DB      21h             ; '!'
        DB      17h
        DB      0DFh
        DB      0CDh
        DB      0A2h
        DB      0EBh
        DB      7Eh             ; '~'
        DB      0E6h
        DB      7Fh             ; ''
        DB      13h
        DB      12h
        DB      13h
        DB      13h
        DB      2Ah             ; '*'
        DB      20h             ; ' '
        DB      0DFh
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E9h
        DB      13h
        DB      13h
        DB      2Ah             ; '*'
        DB      1Eh
        DB      0DFh
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E9h
        DB      0C3h
        DB      44h             ; 'D'
        DB      0E9h
        DB      3Eh             ; '>'
        DB      06h
        DB      47h             ; 'G'
        DB      7Eh             ; '~'
        DB      0B7h
        DB      20h             ; ' '
        DB      02h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      12h
        DB      23h             ; '#'
        DB      13h
        DB      10h
        DB      0F5h
        DB      0C9h
        DB      0FEh
        DB      22h             ; '"'
        DB      0C2h
        DB      0C8h
        DB      0E7h
        DB      06h
        DB      06h
        DB      13h
        DB      1Ah
        DB      0FEh
        DB      22h             ; '"'
        DB      0C8h
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      10h
        DB      0F7h
        DB      13h
        DB      1Ah
        DB      0FEh
        DB      22h             ; '"'
        DB      0C2h
        DB      0C8h
        DB      0E7h
        DB      0C9h
        DB      21h             ; '!'
        DB      0Dh
        DB      0DFh
        DB      11h
        DB      17h
        DB      0DFh
        DB      06h
        DB      06h
        DB      1Ah
        DB      0BEh
        DB      23h             ; '#'
        DB      13h
        DB      0C0h
        DB      10h
        DB      0F9h
        DB      0C9h
        DB      0E5h
        DB      0EBh
        DB      11h
        DB      78h             ; 'x'
        DB      0F0h
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E9h
        DB      0EBh
        DB      0E1h
        DB      0AFh
        DB      47h             ; 'G'
        DB      0BAh
        DB      0C0h
        DB      0BBh
        DB      43h             ; 'C'
        DB      0C9h
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0EBh
        DB      3Eh             ; '>'
        DB      01h
        DB      32h             ; '2'
        DB      24h             ; '$'
        DB      0DFh
        DB      18h
        DB      03h
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0EBh
        DB      0CDh
        DB      22h             ; '"'
        DB      0ECh
        DB      0CDh
        DB      13h
        DB      0ECh
        DB      0F3h
        DB      0CDh
        DB      57h             ; 'W'
        DB      0ECh
        DB      2Ah             ; '*'
        DB      20h             ; ' '
        DB      0DFh
        DB      0EDh
        DB      5Bh             ; '['
        DB      1Eh
        DB      0DFh
        DB      0CDh
        DB      0D9h
        DB      0EBh
        DB      0CAh
        DB      4Bh             ; 'K'
        DB      0EBh
        DB      0CDh
        DB      51h             ; 'Q'
        DB      0EAh
        DB      18h
        DB      0F5h
        DB      06h
        DB      03h
        DB      2Bh             ; '+'
        DB      7Ch             ; '|'
        DB      0B5h
        DB      20h             ; ' '
        DB      0FBh
        DB      10h
        DB      0F9h
        DB      3Eh             ; '>'
        DB      04h
        DB      32h             ; '2'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      0C9h
        DB      0CDh
        DB      46h             ; 'F'
        DB      0E8h
        DB      21h             ; '!'
        DB      17h
        DB      0DFh
        DB      0CDh
        DB      0B1h
        DB      0EBh
        DB      0CDh
        DB      46h             ; 'F'
        DB      0E8h
        DB      1Ah
        DB      32h             ; '2'
        DB      1Dh
        DB      0DFh
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      22h             ; '"'
        DB      20h             ; ' '
        DB      0DFh
        DB      0E5h
        DB      22h             ; '"'
        DB      22h             ; '"'
        DB      0DFh
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0C1h
        DB      0B7h
        DB      0EDh
        DB      42h             ; 'B'
        DB      23h             ; '#'
        DB      22h             ; '"'
        DB      1Eh
        DB      0DFh
        DB      0CDh
        DB      2Bh             ; '+'
        DB      0E8h
        DB      0D8h
        DB      0CDh
        DB      6Ch             ; 'l'
        DB      0E8h
        DB      22h             ; '"'
        DB      22h             ; '"'
        DB      0DFh
        DB      3Eh             ; '>'
        DB      0FFh
        DB      32h             ; '2'
        DB      25h             ; '%'
        DB      0DFh
        DB      0C9h
        DB      06h
        DB      18h
        DB      0AFh
        DB      0CDh
        DB      60h             ; '`'
        DB      0EAh
        DB      10h
        DB      0FAh
        DB      3Eh             ; '>'
        DB      01h
        DB      0CDh
        DB      60h             ; '`'
        DB      0EAh
        DB      21h             ; '!'
        DB      17h
        DB      0DFh
        DB      06h
        DB      10h
        DB      0CDh
        DB      51h             ; 'Q'
        DB      0EAh
        DB      3Ah             ; ':'
        DB      24h             ; '$'
        DB      0DFh
        DB      0B7h
        DB      0C8h
        DB      32h             ; '2'
        DB      5Ah             ; 'Z'
        DB      0DFh
        DB      0C9h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0D1h
        DB      0E3h
        DB      0C1h
        DB      0C9h
        DB      0CDh
        DB      75h             ; 'u'
        DB      0ECh
        DB      0E5h
        DB      0B7h
        DB      0EDh
        DB      52h             ; 'R'
        DB      0E1h
        DB      38h             ; '8'
        DB      03h
        DB      0EDh
        DB      0B0h
        DB      0C9h
        DB      09h
        DB      2Bh             ; '+'
        DB      0EBh
        DB      09h
        DB      2Bh             ; '+'
        DB      0EBh
        DB      0EDh
        DB      0B8h
        DB      0C9h
        DB      0CDh
        DB      0A7h
        DB      0EAh
        DB      0CDh
        DB      75h             ; 'u'
        DB      0ECh
        DB      1Ah
        DB      0BEh
        DB      0C4h
        DB      0ADh
        DB      0ECh
        DB      23h             ; '#'
        DB      13h
        DB      0Bh
        DB      78h             ; 'x'
        DB      0B1h
        DB      20h             ; ' '
        DB      0F4h
        DB      0C9h
        DB      0D5h
        DB      0CDh
        DB      04h
        DB      0EDh
        DB      1Bh
        DB      7Eh             ; '~'
        DB      0CDh
        DB      92h
        DB      0E8h
        DB      13h
        DB      0E3h
        DB      7Eh             ; '~'
        DB      0CDh
        DB      92h
        DB      0E8h
        DB      13h
        DB      13h
        DB      13h
        DB      13h
        DB      0EBh
        DB      22h             ; '"'
        DB      37h             ; '7'
        DB      0DFh
        DB      0E1h
        DB      0C9h
        DB      0CDh
        DB      0A7h
        DB      0EAh
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      22h             ; '"'
        DB      35h             ; '5'
        DB      0DFh
        DB      21h             ; '!'
        DB      3Bh             ; ';'
        DB      0DFh
        DB      06h
        DB      00h
        DB      0CDh
        DB      46h             ; 'F'
        DB      0E8h
        DB      0CDh
        DB      8Bh
        DB      0E8h
        DB      77h             ; 'w'
        DB      23h             ; '#'
        DB      04h
        DB      0CDh
        DB      2Bh             ; '+'
        DB      0E8h
        DB      30h             ; '0'
        DB      0F5h
        DB      0E1h
        DB      0EDh
        DB      43h             ; 'C'
        DB      39h             ; '9'
        DB      0DFh
        DB      11h
        DB      3Ah             ; ':'
        DB      0DFh
        DB      1Ah
        DB      13h
        DB      47h             ; 'G'
        DB      0E5h
        DB      0CDh
        DB      0D1h
        DB      0EBh
        DB      0E1h
        DB      0CCh
        DB      04h
        DB      0EDh
        DB      0EDh
        DB      4Bh             ; 'K'
        DB      35h             ; '5'
        DB      0DFh
        DB      23h             ; '#'
        DB      0CDh
        DB      0A0h
        DB      0E9h
        DB      20h             ; ' '
        DB      0E8h
        DB      0C9h
        DB      0EDh
        DB      5Bh             ; '['
        DB      37h             ; '7'
        DB      0DFh
        DB      7Ah             ; 'z'
        DB      0FEh
        DB      0F4h
        DB      0D2h
        DB      5Dh             ; ']'
        DB      0E7h
        DB      0CDh
        DB      4Dh             ; 'M'
        DB      0E9h
        DB      13h
        DB      13h
        DB      13h
        DB      13h
        DB      0EDh
        DB      53h             ; 'S'
        DB      37h             ; '7'
        DB      0DFh
        DB      0C9h
        DB      0F5h
        DB      0CDh
        DB      3Bh             ; ';'
        DB      0EDh
        DB      0F1h
        DB      0FEh
        DB      04h
        DB      30h             ; '0'
        DB      1Fh
        DB      0CBh
        DB      27h             ; '''
        DB      0F6h
        DB      38h             ; '8'
        DB      0D3h
        DB      46h             ; 'F'
        DB      00h
        DB      00h
        DB      00h
        DB      00h
        DB      0DBh
        DB      46h             ; 'F'
        DB      0E6h
        DB      18h
        DB      0FEh
        DB      18h
        DB      3Eh             ; '>'
        DB      16h
        DB      28h             ; '('
        DB      02h
        DB      3Eh             ; '>'
        DB      10h
        DB      0D3h
        DB      47h             ; 'G'
        DB      0DBh
        DB      47h             ; 'G'
        DB      0CBh
        DB      7Fh             ; ''
        DB      20h             ; ' '
        DB      0FAh
        DB      0C9h
        DB      0CBh
        DB      27h             ; '''
        DB      0CBh
        DB      27h             ; '''
        DB      0CBh
        DB      27h             ; '''
        DB      0F6h
        DB      80h
        DB      0F5h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      0D3h
        DB      41h             ; 'A'
        DB      0F1h
        DB      18h
        DB      0D5h
        DB      0C5h
        DB      0D5h
        DB      06h
        DB      03h
        DB      0E5h
        DB      0C5h
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      0CDh
        DB      0A2h
        DB      0EDh
        DB      0CDh
        DB      3Bh             ; ';'
        DB      0EDh
        DB      01h
        DB      40h             ; '@'
        DB      00h
        DB      0EDh
        DB      0B2h
        DB      0EDh
        DB      0B2h
        DB      0CBh
        DB      47h             ; 'G'
        DB      0C1h
        DB      0FBh
        DB      3Eh             ; '>'
        DB      00h
        DB      28h             ; '('
        DB      08h
        DB      0E1h
        DB      0E5h
        DB      0CDh
        DB      29h             ; ')'
        DB      0EDh
        DB      10h
        DB      0E1h
        DB      3Ch             ; '<'
        DB      0D1h
        DB      0D1h
        DB      0C1h
        DB      0B7h
        DB      0C9h
        DB      0C5h
        DB      0D5h
        DB      06h
        DB      0Ah
        DB      0E5h
        DB      0C5h
        DB      3Eh             ; '>'
        DB      30h             ; '0'
        DB      0CDh
        DB      0A2h
        DB      0EDh
        DB      01h
        DB      40h             ; '@'
        DB      00h
        DB      0EDh
        DB      0B3h
        DB      0EDh
        DB      0B3h
        DB      0CDh
        DB      3Bh             ; ';'
        DB      0EDh
        DB      0CBh
        DB      47h             ; 'G'
        DB      0C1h
        DB      0FBh
        DB      3Eh             ; '>'
        DB      00h
        DB      28h             ; '('
        DB      0DEh
        DB      0E1h
        DB      0E5h
        DB      0CDh
        DB      29h             ; ')'
        DB      0EDh
        DB      10h
        DB      0E1h
        DB      18h
        DB      0D4h
        DB      0F3h
        DB      0D5h
        DB      0F5h
        DB      7Bh             ; '{'
        DB      0D3h
        DB      43h             ; 'C'
        DB      7Ah             ; 'z'
        DB      0D3h
        DB      48h             ; 'H'
        DB      0DBh
        DB      46h             ; 'F'
        DB      0E6h
        DB      18h
        DB      0FEh
        DB      18h
        DB      28h             ; '('
        DB      07h
        DB      0DBh
        DB      46h             ; 'F'
        DB      0E6h
        DB      0F8h
        DB      0B2h
        DB      0D3h
        DB      46h             ; 'F'
        DB      0DDh
        DB      0E5h
        DB      0D1h
        DB      7Bh             ; '{'
        DB      0D3h
        DB      44h             ; 'D'
        DB      7Ah             ; 'z'
        DB      0D3h
        DB      45h             ; 'E'
        DB      3Eh             ; '>'
        DB      01h
        DB      0D3h
        DB      42h             ; 'B'
        DB      0F1h
        DB      0D3h
        DB      47h             ; 'G'
        DB      0D1h
        DB      0C9h
        DB      4Dh             ; 'M'
        DB      69h             ; 'i'
        DB      63h             ; 'c'
        DB      72h             ; 'r'
        DB      6Fh             ; 'o'
        DB      42h             ; 'B'
        DB      65h             ; 'e'
        DB      65h             ; 'e'
        DB      20h             ; ' '
        DB      48h             ; 'H'
        DB      61h             ; 'a'
        DB      72h             ; 'r'
        DB      64h             ; 'd'
        DB      20h             ; ' '
        DB      44h             ; 'D'
        DB      69h             ; 'i'
        DB      73h             ; 's'
        DB      6Bh             ; 'k'
        DB      20h             ; ' '
        DB      53h             ; 'S'
        DB      79h             ; 'y'
        DB      73h             ; 's'
        DB      74h             ; 't'
        DB      65h             ; 'e'
        DB      6Dh             ; 'm'
        DB      2Eh             ; '.'
        DB      3Eh             ; '>'
        DB      20h             ; ' '
        DB      32h             ; '2'
        DB      00h
        DB      0F0h
        DB      21h             ; '!'
        DB      0CCh
        DB      0EDh
        DB      11h
        DB      13h
        DB      0F0h
        DB      01h
        DB      1Ah
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      3Eh             ; '>'
        DB      0Dh
        DB      0CDh
        DB      0C2h
        DB      0E1h
        DB      0CAh
        DB      36h             ; '6'
        DB      0E7h
        DB      3Eh             ; '>'
        DB      06h
        DB      0CDh
        DB      0C2h
        DB      0E1h
        DB      0C2h
        DB      22h             ; '"'
        DB      0EEh
        DB      0CDh
        DB      98h
        DB      0E0h
        DB      0DBh
        DB      47h             ; 'G'
        DB      0CBh
        DB      7Fh             ; ''
        DB      20h             ; ' '
        DB      0FAh
        DB      0AFh
        DB      0CDh
        DB      1Ah
        DB      0EDh
        DB      0DDh
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      11h
        DB      01h
        DB      00h
        DB      21h             ; '!'
        DB      80h
        DB      00h
        DB      0CDh
        DB      52h             ; 'R'
        DB      0EDh
        DB      28h             ; '('
        DB      1Ah
        DB      0DBh
        DB      47h             ; 'G'
        DB      0CBh
        DB      7Fh             ; ''
        DB      20h             ; ' '
        DB      0FAh
        DB      3Eh             ; '>'
        DB      05h
        DB      0CDh
        DB      1Ah
        DB      0EDh
        DB      0DDh
        DB      21h             ; '!'
        DB      00h
        DB      00h
        DB      11h
        DB      01h
        DB      00h
        DB      21h             ; '!'
        DB      80h
        DB      00h
        DB      0CDh
        DB      52h             ; 'R'
        DB      0EDh
        DB      20h             ; ' '
        DB      0AAh
        DB      3Ah             ; ':'
        DB      80h
        DB      00h
        DB      0FEh
        DB      31h             ; '1'
        DB      20h             ; ' '
        DB      0A3h
        DB      21h             ; '!'
        DB      00h
        DB      0F0h
        DB      36h             ; '6'
        DB      20h             ; ' '
        DB      11h
        DB      01h
        DB      0F0h
        DB      01h
        DB      3Fh             ; '?'
        DB      00h
        DB      0EDh
        DB      0B0h
        DB      0C3h
        DB      80h
        DB      00h
        DB      78h             ; 'x'
        DB      0B1h
        DB      0C8h
        DB      0CDh
        DB      52h             ; 'R'
        DB      0EDh
        DB      0C0h
        DB      05h
        DB      0C8h
        DB      05h
        DB      0C8h
        DB      1Ch
        DB      0DBh
        DB      46h             ; 'F'
        DB      0E6h
        DB      18h
        DB      0FEh
        DB      18h
        DB      7Bh             ; '{'
        DB      20h             ; ' '
        DB      06h
        DB      0FEh
        DB      0Bh
        DB      20h             ; ' '
        DB      0EAh
        DB      18h
        DB      04h
        DB      0FEh
        DB      12h
        DB      20h             ; ' '
        DB      0E4h
        DB      0DDh
        DB      23h             ; '#'
        DB      1Eh
        DB      01h
        DB      18h
        DB      0DEh
        DB      78h             ; 'x'
        DB      0B1h
        DB      0C8h
        DB      0CDh
        DB      7Ch             ; '|'
        DB      0EDh
        DB      0C0h
        DB      05h
        DB      0C8h
        DB      05h
        DB      0C8h
        DB      1Ch
        DB      0DBh
        DB      46h             ; 'F'
        DB      0E6h
        DB      18h
        DB      0FEh
        DB      18h
        DB      7Bh             ; '{'
        DB      20h             ; ' '
        DB      06h
        DB      0FEh
        DB      0Bh
        DB      20h             ; ' '
        DB      0EAh
        DB      18h
        DB      04h
        DB      0FEh
        DB      12h
        DB      20h             ; ' '
        DB      0E4h
        DB      0DDh
        DB      23h             ; '#'
        DB      1Eh
        DB      01h
        DB      18h
        DB      0DEh
        DB      13h
        DB      1Ah
        DB      0F5h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      7Dh             ; '}'
        DB      0E6h
        DB      0Fh
        DB      0CDh
        DB      1Ah
        DB      0EDh
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0DDh
        DB      0E1h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0E5h
        DB      0C1h
        DB      0CDh
        DB      69h             ; 'i'
        DB      0E8h
        DB      0C5h
        DB      0E3h
        DB      0C1h
        DB      0D1h
        DB      0F1h
        DB      0FEh
        DB      52h             ; 'R'
        DB      28h             ; '('
        DB      09h
        DB      0FEh
        DB      57h             ; 'W'
        DB      20h             ; ' '
        DB      09h
        DB      0CDh
        DB      78h             ; 'x'
        DB      0EEh
        DB      18h
        DB      03h
        DB      0CDh
        DB      53h             ; 'S'
        DB      0EEh
        DB      0C8h
        DB      06h
        DB      2Ah             ; '*'
        DB      11h
        DB      41h             ; 'A'
        DB      0F0h
        DB      0C3h
        DB      0CAh
        DB      0E7h
        DB      0C0h
        DB      05h
        DB      0C8h
        DB      05h
        DB      0C8h
        DB      1Ch
        DB      0DBh
        DB      46h             ; 'F'
        DB      0E6h
        DB      18h
        DB      0FEh
        DB      18h
        DB      7Bh             ; '{'
        DB      20h             ; ' '
        DB      06h
        DB      0FEh
        DB      0Bh
        DB      20h             ; ' '
        DB      0EAh
        DB      18h
        DB      04h
        DB      0FEh
        DB      12h
        DB      20h             ; ' '
        DB      0E4h
        DB      0DDh
        DB      23h             ; '#'
        DB      1Eh
        DB      01h
        DB      18h
        DB      0DEh
        DB      78h             ; 'x'
        DB      0B1h
        DB      0C8h
        DB      0CDh
        DB      7Ch             ; '|'
        DB      0EDh
        DB      0C0h
        DB      05h
        DB      0E8h
        DB      80h
        DB      0DBh
        DB      0AAh
        DB      76h             ; 'v'
        DB      4Bh             ; 'K'
        DB      0DFh
        DB      0FBh
        DB      2Ch             ; ','
        DB      60h             ; '`'
        DB      0CFh
        DB      0A3h
        DB      6Fh             ; 'o'
        DB      0FCh
        DB      0B1h
        DB      99h
        DB      0CFh
        DB      62h             ; 'b'
        DB      0FFh
        DB      0CDh
        DB      7Dh             ; '}'
        DB      0F3h
        DB      3Fh             ; '?'
        DB      0FAh
        DB      0B5h
        DB      60h             ; '`'
        DB      7Fh             ; ''
        DB      0FFh
        DB      1Bh
        DB      0FFh
        DB      0FFh
        DB      8Eh
        DB      77h             ; 'w'
        DB      04h
        DB      0BFh
        DB      2Ah             ; '*'
        DB      55h             ; 'U'
        DB      3Fh             ; '?'
        DB      3Bh             ; ';'
        DB      0BFh
        DB      29h             ; ')'
        DB      12h
        DB      0FDh
        DB      79h             ; 'y'
        DB      0DBh
        DB      76h             ; 'v'
        DB      0FAh
        DB      0FDh
        DB      0B3h
        DB      28h             ; '('
        DB      7Fh             ; ''
        DB      0D7h
        DB      0BCh
        DB      7Fh             ; ''
        DB      3Fh             ; '?'
        DB      23h             ; '#'
        DB      27h             ; '''
        DB      14h
        DB      0FFh
        DB      0CFh
        DB      64h             ; 'd'
        DB      73h             ; 's'
        DB      0BBh
        DB      0EBh
        DB      3Ah             ; ':'
        DB      10h
        DB      3Bh             ; ';'
        DB      0EFh
        DB      0CEh
        DB      75h             ; 'u'
        DB      0F9h
        DB      0F3h
        DB      0B3h
        DB      0B3h
        DB      0EFh
        DB      1Dh
        DB      0FBh
        DB      9Ah
        DB      0EFh
        DB      0E7h
        DB      9Fh
        DB      08h
        DB      0F7h
        DB      0F2h
        DB      0FDh
        DB      2Fh             ; '/'
        DB      0F7h
        DB      6Ah             ; 'j'
        DB      0F9h
        DB      01h
        DB      2Bh             ; '+'
        DB      0B9h
        DB      0FFh
        DB      7Ah             ; 'z'
        DB      7Fh             ; ''
        DB      0FBh
        DB      7Dh             ; '}'
        DB      27h             ; '''
        DB      0BFh
        DB      27h             ; '''
        DB      0FFh
        DB      0D5h
        DB      0F9h
        DB      0F1h
        DB      3Fh             ; '?'
        DB      0C0h
        DB      0F3h
        DB      0EFh
        DB      0FFh
        DB      0DFh
        DB      0FBh
        DB      0BBh
        DB      4Bh             ; 'K'
        DB      00h
        DB      9Bh
        DB      0D7h
        DB      0BFh
        DB      76h             ; 'v'
        DB      0BAh
        DB      7Fh             ; ''
        DB      0DEh
        DB      4Eh             ; 'N'
        DB      0FAh
        DB      3Fh             ; '?'
        DB      0D9h
        DB      0C7h
        DB      0E7h
        DB      4Eh             ; 'N'
        DB      0D7h
        DB      0C8h
        DB      0F7h
        DB      2Eh             ; '.'
        DB      0AEh
        DB      6Dh             ; 'm'
        DB      2Dh             ; '-'
        DB      0F2h
        DB      0FFh
        DB      20h             ; ' '
        DB      79h             ; 'y'
        DB      0F7h
        DB      0FBh
        DB      0FDh
        DB      0FBh
        DB      0F7h
        DB      2Ch             ; ','
        DB      11h
        DB      0FFh
        DB      0ACh
        DB      0E0h
        DB      3Fh             ; '?'
        DB      9Bh
        DB      0F1h
        DB      97h
        DB      10h
        DB      67h             ; 'g'
        DB      0BFh
        DB      0FBh
        DB      0FFh
        DB      0BFh
        DB      4Fh             ; 'O'
        DB      9Bh
        DB      46h             ; 'F'
        DB      0FFh
        DB      0F5h
        DB      36h             ; '6'
        DB      0F9h
        DB      0D1h
        DB      0D9h
        DB      0ABh
        DB      81h
        DB      0FBh
        DB      7Dh             ; '}'
        DB      5Eh             ; '^'
        DB      99h
        DB      7Eh             ; '~'
        DB      0DBh
        DB      00h
        DB      80h
        DB      0BFh
        DB      0DCh
        DB      0AEh
        DB      1Ah
        DB      9Eh
        DB      0AFh
        DB      4Ah             ; 'J'
        DB      44h             ; 'D'
        DB      0FFh
        DB      7Ch             ; '|'
        DB      9Fh
        DB      0F5h
        DB      9Fh
        DB      2Dh             ; '-'
        DB      7Bh             ; '{'
        DB      98h
        DB      0DEh
        DB      0C5h
        DB      0E7h
        DB      0CFh
        DB      39h             ; '9'
        DB      0ABh
        DB      0EFh
        DB      00h
        DB      0DBh
        DB      0DDh
        DB      0FFh
        DB      0CFh
        DB      0FEh
        DB      6Fh             ; 'o'
        DB      3Ah             ; ':'
        DB      4Ah             ; 'J'
        DB      6Fh             ; 'o'
        DB      0BBh
        DB      7Fh             ; ''
        DB      0FBh
        DB      0DDh
        DB      0E7h
        DB      03h
        DB      01h
        DB      0F7h
        DB      0ABh
        DB      0F7h
        DB      79h             ; 'y'
        DB      0F5h
        DB      1Eh
        DB      0FBh
        DB      28h             ; '('
        DB      0FBh
        DB      0EBh
        DB      0BBh
        DB      0DAh
        DB      7Bh             ; '{'
        DB      36h             ; '6'
        DB      0FEh
        DB      26h             ; '&'
        DB      0BFh
        DB      0EDh
        DB      7Eh             ; '~'
        DB      0FDh
        DB      0B9h
        DB      0DBh
        DB      0FFh
        DB      00h
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0EFh
        DB      0FFh
        DB      0FFh
        DB      38h             ; '8'
        DB      00h
        DB      0FFh
        DB      0DEh
        DB      0FFh
        DB      0F7h
        DB      0FEh
        DB      0FDh

        ; --- START PROC LB100 ---
LB100:  LD      A,0Bh
        CALL    L8500
        LD      HL,(5F7Ah)
        JP      Z,L8074
        LD      A,01h
        OUT     (58h),A         ; 'X'
        JP      LA000

LB112:  DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh
        DB      0FFh


hack:
        LD      DE,0xF040
        LD      HL,0xb100
        LD      B,16

hack1:
        LD      A,(HL)
        CALL    prt_hex_byte
        INC     HL
        INC     DE
        DJNZ    hack1
        JR      $


                ; print hex byte in A to DE
prt_hex_byte:
                PUSH    AF
                SRL             A
                SRL             A
                SRL             A
                SRL             A
                CALL    prt_hex_nib
                POP             AF
                ;; fall through


                ; print low nibble of A to DE
prt_hex_nib:
                and     0xF
                cp      0xA
                jr      c,lt10
                add             'A' - 0xA;
                ld              (de),a
                inc             de
                ret
lt10:
                add             '0'
                ld              (de),a
                inc             de
                ret;


