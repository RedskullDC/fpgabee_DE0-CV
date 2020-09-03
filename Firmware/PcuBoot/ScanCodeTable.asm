
VK_BACKTICK: EQU 0x01
VK_LSHIFT: EQU 0x02
VK_RSHIFT: EQU 0x03
VK_LCTRL: EQU 0x04
VK_RCTRL: EQU 0x05
VK_LMENU: EQU 0x06
VK_RMENU: EQU 0x07
VK_BACKSPACE: EQU 0x08
VK_TAB: EQU 0x09
VK_COMMA: EQU 0x0A
VK_PERIOD: EQU 0x0B
VK_HYPHEN: EQU 0x0C
VK_ENTER: EQU 0x0D
VK_SEMICOLON: EQU 0x0E
VK_EQUALS: EQU 0x0F
VK_ESCAPE: EQU 0x10
VK_F1: EQU 0x11
VK_F2: EQU 0x12
VK_F3: EQU 0x13
VK_F4: EQU 0x14
VK_F5: EQU 0x15
VK_F6: EQU 0x16
VK_F7: EQU 0x17
VK_F8: EQU 0x18
VK_F9: EQU 0x19
VK_F10: EQU 0x1a
VK_F11: EQU 0x1b
VK_F12: EQU 0x1c
VK_LSQUARE: EQU 0x1d
VK_RSQUARE: EQU 0x1e
VK_QUOTE: EQU 0x1f
VK_SPACE: EQU 0x20
VK_LEFT: EQU 0x21
VK_RIGHT: EQU 0x22
VK_UP: EQU 0x23
VK_DOWN: EQU 0x24
VK_HOME: EQU 0x25
VK_END: EQU 0x26
VK_NEXT: EQU 0x27
VK_PRIOR: EQU 0x28
VK_INSERT: EQU 0x29
VK_DELETE: EQU 0x2a
VK_SLASH: EQU 0x2b
; unused 2c
; unused 2d
; unused 2e
; unused 2f
; = 0x30 = = 0x39 = 0 - 9
VK_BACKSLASH: EQU 0x3a
VK_CAPITAL: EQU 0x3b
VK_NUMENTER: EQU 0x3c
; unused 3d
; unused 3e
; unused 3f
; unused 40
; = 0x41 - = 0x5A = A - Z
VK_SUBTRACT: EQU 0x5b
VK_MULTIPLY: EQU 0x5c
VK_DIVIDE: EQU 0x5d
VK_ADD: EQU 0x5e
VK_DECIMAL: EQU 0x5F
VK_NUM0: EQU 0x60
VK_NUM1: EQU 0x61
VK_NUM2: EQU 0x62
VK_NUM3: EQU 0x63
VK_NUM4: EQU 0x64
VK_NUM5: EQU 0x65
VK_NUM6: EQU 0x66
VK_NUM7: EQU 0x67
VK_NUM8: EQU 0x68
VK_NUM9: EQU 0x69

; This keycode table maps ps2 scan code and extended scan codes to a 
; simpler "key number".  This can then be mapped to characters using
; the character table below
SCANCODE_TO_VK_TABLE:
        ; 0x0?
        db     0,0
        db     VK_F9,0            
        db     0,0
        db     VK_F5,0            
        db     VK_F3,0            
        db     VK_F1,0            
        db     VK_F2,0            
        db     VK_F12,0
        db     0,0
        db     VK_F10,0           
        db     VK_F8,0            
        db     VK_F6,0            
        db     VK_F4,0            
        db     VK_TAB,0            
        db     VK_BACKTICK,0         
        db     0,0

        ; 0x10
        db     0,0
        db     VK_LMENU,VK_RMENU     
        db     VK_LSHIFT,0 
        db     0,0
        db     VK_LCTRL,VK_RCTRL  
        db     'Q', 0
        db     '1',0       
        db     0,0
        db     0,0
        db     0,0
        db     'Z', 0
        db     'S', 0
        db     'A', 0
        db     'W', 0
        db     '2',0       
        db     0,0

        ; 0x2?
        db     0,0
        db     'C', 0
        db     'X', 0
        db     'D', 0
        db     'E', 0
        db     '4', 0
        db     '3', 0      
        db     0,0
        db     0,0
        db     VK_SPACE, 0 
        db     'V', 0
        db     'F', 0
        db     'T', 0
        db     'R', 0
        db     '5', 0
        db     0,0

        ; 0x3?
        db     0,0
        db     'N', 0
        db     'B', 0
        db     'H', 0
        db     'G', 0
        db     'Y', 0
        db     '6', 0         
        db     0,0
        db     0,0
        db     0,0
        db     'M', 0
        db     'J', 0
        db     'U', 0
        db     '7',0          
        db     '8',0          
        db     0,0

        ; 0x4?
        db     0,0
        db     VK_COMMA, 0    
        db     'K', 0
        db     'I', 0
        db     'O', 0
        db     '0', 0         
        db     '9', 0         
        db     0,0
        db     0,0
        db     VK_PERIOD, 0    
        db     VK_SLASH,VK_DIVIDE     
        db     'L', 0
        db     VK_SEMICOLON, 0 
        db     'P', 0
        db     VK_HYPHEN, 0  
        db     0, 0

        ; 0x5?
        db     0,0
        db     0,0
        db     VK_QUOTE,0      
        db     0,0
        db     VK_LSQUARE, 0   
        db     VK_EQUALS, 0    
        db     0,0
        db     0,0
        db     VK_CAPITAL,0    
        db     VK_RSHIFT,0
        db     VK_ENTER,VK_NUMENTER      
        db     VK_RSQUARE, 0   
        db     0,0
        db     VK_BACKSLASH,0  
        db     0,0
        db     0,0

        ; 0x6?
        db     0,0
        db     0,0
        db     0,0
        db     0,0
        db     0,0
        db     0,0
        db     VK_BACKSPACE,0  
        db     0,0
        db     0,0
        db     VK_NUM1,VK_END  
        db     0,0
        db     VK_NUM4,VK_LEFT 
        db     VK_NUM7,VK_HOME 
        db     0,0
        db     0,0
        db     0,0

        ; 0x7?
        db     VK_NUM0,VK_INSERT   
        db     VK_DECIMAL,VK_DELETE
        db     VK_NUM2,VK_DOWN    
        db     VK_NUM5,0          
        db     VK_NUM6,VK_RIGHT   
        db     VK_NUM8,VK_UP      
        db     VK_ESCAPE,0        
        db     0,0
        db     VK_F11,0           
        db     VK_ADD,0              
        db     VK_NUM3,VK_NEXT       
        db     VK_SUBTRACT,0         
        db     VK_MULTIPLY,0         
        db     VK_NUM9,VK_PRIOR      
        db     0,0
        db     0,0

        ; 0x8?
        db     0,0
        db     0,0
        db     0,0
        db     VK_F7,0       
SCANCODE_TO_VK_TABLE_END:


VK_TO_ASCII_TABLE:

        db     0,0             ; null
        db     '`', '~'        ; VK_BACKTICK     0x01
        db     0,0             ; VK_LSHIFT       0x02
        db     0,0             ; VK_RSHIFT       0x03
        db     0,0             ; VK_LCTRL        0x04
        db     0,0             ; VK_RCTRL        0x05
        db     0,0             ; VK_LMENU        0x06
        db     0,0             ; VK_RMENU        0x07
        db     8,8             ; VK_BACKSPACE    0x08
        db     9,9             ; VK_TAB          0x09
        db     ',','<'         ; VK_COMMA        0x0A
        db     '.','>'         ; VK_PERIOD       0x0B
        db     '-','_'         ; VK_HYPHEN       0x0C
        db     0x0A,0x0A       ; VK_ENTER        0x0D
        db     ';',':'         ; VK_SEMICOLON    0x0E
        db     '=','+'         ; VK_EQUALS       0x0F
        db     0,0             ; VK_ESCAPE       0x10
        db     0,0             ; VK_F1           0x11
        db     0,0             ; VK_F2           0x12
        db     0,0             ; VK_F3           0x13
        db     0,0             ; VK_F4           0x14
        db     0,0             ; VK_F5           0x15
        db     0,0             ; VK_F6           0x16
        db     0,0             ; VK_F7           0x17
        db     0,0             ; VK_F8           0x18
        db     0,0             ; VK_F9           0x19
        db     0,0             ; VK_F10          0x1a
        db     0,0             ; VK_F11          0x1b
        db     0,0             ; VK_F12          0x1c
        db     '[', '{'        ; VK_LSQUARE      0x1d
        db     ']', '}'        ; VK_RSQUARE      0x1e
        db     0x27, '"'       ; VK_QUOTE        0x1f
        db     ' ', ' '        ; VK_SPACE        0x20
        db     0,0             ; VK_LEFT         0x21
        db     0,0             ; VK_RIGHT        0x22
        db     0,0             ; VK_UP           0x23
        db     0,0             ; VK_DOWN         0x24
        db     0,0             ; VK_HOME         0x25
        db     0,0             ; VK_END          0x26
        db     0,0             ; VK_NEXT         0x27
        db     0,0             ; VK_PRIOR        0x28
        db     0,0             ; VK_INSERT       0x29
        db     0,0             ; VK_DELETE       0x2a
        db     '/','?'         ; VK_SLASH        0x2b
        db     0,0             ; unused          0x2c
        db     0,0             ; unused          0x2d
        db     0,0             ; unused          0x2e
        db     0,0             ; unusued         0x2f
        db     '0',')'
        db     '1','!'
        db     '2','@'
        db     '3','#'
        db     '4','$'
        db     '5','%'
        db     '6','^'
        db     '7','&'
        db     '8','*'
        db     '9','('
        db     0x5c,'|'        ; VK_BACKSLASH    0x3a
        db     0,0             ; VK_CAPITAL      0x3b
        db     0x0d,0x0d       ; VK_NUMENTER     0x3c
        db     0,0             ;  unused 3d
        db     0,0             ;  unused 3e
        db     0,0             ;  unused 3f
        db     0,0             ;  unused 40
        db     'a','A'
        db     'b','B'
        db     'c','C'
        db     'd','D'
        db     'e','E'
        db     'f','F'
        db     'g','G'
        db     'h','H'
        db     'i','I'
        db     'j','J'
        db     'k','K'
        db     'l','L'
        db     'm','M'
        db     'n','N'
        db     'o','O'
        db     'p','P'
        db     'q','Q'
        db     'r','R'
        db     's','S'
        db     't','T'
        db     'u','U'
        db     'v','V'
        db     'w','W'
        db     'x','X'
        db     'y','Y'
        db     'z','Z'
        db     '-','-'         ; VK_SUBTRACT     0x5b
        db     '*','*'         ; VK_MULTIPLY     0x5c
        db     '/','/'         ; VK_DIVIDE       0x5d
        db     '+','+'         ; VK_ADD          0x5e
        db     '.','.'         ; VK_DECIMAL      0x5F
        db     '0','0'         ; VK_NUM0         0x60
        db     '1','1'         ; VK_NUM1         0x61
        db     '2','2'         ; VK_NUM2         0x62
        db     '3','3'         ; VK_NUM3         0x63
        db     '4','4'         ; VK_NUM4         0x64
        db     '5','5'         ; VK_NUM5         0x65
        db     '6','6'         ; VK_NUM6         0x66
        db     '7','7'         ; VK_NUM7         0x67
        db     '8','8'         ; VK_NUM8         0x68
        db     '9','9'         ; VK_NUM9         0x69
VK_TO_ASCII_TABLE_END: