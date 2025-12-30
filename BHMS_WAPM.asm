.MODEL SMALL
.STACK 100H

; =============================================================
; MACRO DEFINITIONS
; =============================================================

; Macro to print a string ending in '$'
PRINT_MSG MACRO MSG_ADDR
    LEA DX, MSG_ADDR
    MOV AH, 09H
    INT 21H
ENDM

; Macro to print a newline
PRINT_NL MACRO
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
ENDM

; Macro to read a single character into AL
READ_CHAR MACRO
    MOV AH, 01H
    INT 21H
ENDM

; Macro to display a single character from AL
PRINT_CHAR MACRO CHAR
    MOV DL, CHAR
    MOV AH, 02H
    INT 21H
ENDM

; Macro to calculate array offset
; Input: INDEX (Register or Variable)
; Output: DI contains the offset (INDEX * 20)
CALC_OFFSET MACRO INDEX
    MOV AX, INDEX
    MOV BL, 20      ; STR_SIZE
    MUL BL
    MOV DI, AX
ENDM

; =============================================================
; DATA SEGMENT
; =============================================================
.DATA
    ; --- SYSTEM MESSAGES ---
    START_MSG       DB 0dh, 0ah, "================================================================================" 
                    DB           "=========================                           ============================"
                    DB           "=========================   HOSPITAL LOGIN SYSTEM   ============================"
                    DB           "=========================                           ============================"
                    DB           "================================================================================" 
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "===========|   Register New User  |====|"
                    DB           "   Login   |===|"
                    DB           "   Exit   |=============" 
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "<<<<<< Select >>>>>>   $"

    REG_USER_MSG    DB 0dh, 0ah, "================================================================================"
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "=========================                           ============================"
                    DB           "=========================   NEW USER REGISTRATION   ============================"  
                    DB           "=========================                           ============================"
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "================================================================================"
    LOGIN_MSG       DB 0Ah, 0Dh, "=========================        LOGIN PAGE         ============================"   
                    DB           "================================================================================"
                    DB           "================================================================================ $"
    
    ASK_USER        DB 0Ah, 0Dh, "<<<<<< Username >>>>>>   $" 
                    DB           "================================================================================"
                    DB           "================================================================================$"
    ASK_PASS        DB 0Ah, 0Dh, "<<<<<< Password >>>>>>   $" 
                    DB           "================================================================================"
                    DB           "================================================================================$"
    ASK_ROLE        DB 0Ah, 0Dh, "<<<<<< [A=Admin, P=Patient] >>>>>>   $"
                    DB           "================================================================================"
                    DB           "================================================================================"
    
    ERR_LOGIN       DB 0Ah, 0Dh, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
                    DB           "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                    DB           "================================================================================" 
                    DB           "@~@~@~@~@~@~@~@~@~@~@~@                                  @~@~@~@~@~@~@~@~@~@~@~@"
                    DB           "=======================   INVALID USERNAME OR PASSWORD   ======================="
                    DB           "@~@~@~@~@~@~@~@~@~@~@~@                                  @~@~@~@~@~@~@~@~@~@~@~@"
                    DB           "================================================================================" 
                    DB           "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                    DB           "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", 0Ah, 0Dh, "$"
    
    ; --- ERROR MESSAGE FOR 2ND ADMIN ---
    ERR_ADMIN_EXIST DB 0Ah, 0Dh, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                    DB 0Ah, 0Dh, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                    DB 0Ah, 0Dh, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                    DB 0Ah, 0Dh, "***************         ERROR: Admin is already assigned!         **************"
                    DB 0Ah, 0Dh, "***************    Only 1 Admin allowed. Registration Aborted.    **************"  
                    DB 0Ah, 0Dh, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                    DB 0Ah, 0Dh, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0Ah, 0Dh, "$"

    SUCCESS_REG     DB 0dh, 0ah, "================================================================================"
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "============================|                    |=============================="
                    DB           "================================================================================"
                    DB           "=================                                           ===================="
                    DB           "=================   ACCOUNT HAS BEEN CREATED SUCCESSFULLY   ===================="  
                    DB           "=================                                           ===================="
                    DB           "================================================================================"
                    DB           "============================|                    |=============================="
                    DB           "================================================================================$", 0DH, 0AH
    
    ; --- NOTIFICATION MESSAGES ---
    NOTIFY_CONFIRM  DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                   ALERT: Admin has confirmed your appointment!                 "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////", 0Ah, 0Dh, "$"

    NOTIFY_REJECT   DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                 ALERT: Your appointment not accepted, Try Again!               "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////", 0Ah, 0Dh, "$"

    ; --- ADMIN MENU ---
    ADMIN_MENU      DB 0DH, 0AH, "================================================================================" 
                    DB           "=========================                           ============================"
                    DB           "=========================      ADMIN DASHBOARD      ============================"
                    DB           "=========================                           ============================"
                    DB           "================================================================================" 
                    
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [1] Register a patient to BRACU HOSPITAL                                " 
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [2] Serve a patient to the doctor                                       "
                    DB           "________________________________________________________________________________" 
                    DB           ">>>>>>> [3] Cancel all the remaining appointments                               "
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [4] Reverse the line                                                    "  
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [5] View all the existing patient                                       "
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [6] Logout                                                              "
                    DB           "________________________________________________________________________________" 
                    
                    DB           "<<<<<<< Select >>>>>>   $"

    ; --- PATIENT MENU ---
    PATIENT_MENU    DB 0dh, 0ah, "================================================================================" 
                    DB           "=========================                            ==========================="
                    DB           "=========================     PATIENT DASHBOARD      ==========================="
                    DB           "=========================                            ==========================="
                    DB           "================================================================================" 
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [1] See your waiting position                                           " 
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [2] Request for an appoinment                                           "
                    DB           "________________________________________________________________________________"
                    DB           ">>>>>>> [3] Logout                                                              "
                    DB           "________________________________________________________________________________" 
                    DB           "================================================================================"
                    DB           "================================================================================"
                    DB           "================================================================================"  
                    DB           "================================================================================"
                    
                    DB           "<<<<<<< Select >>>>>>   $"

    ; --- WRM MESSAGES ---
    ID_PROMPT       DB 0Ah, 0Dh, "<<<<<<< Enter Patient ID >>>>>>>   $"
    NAME_PROMPT     DB 0Ah, 0Dh, "<<<<<<< Enter Username to Register >>>>>>>   $"
    
    ASK_APPT_DT     DB 0Ah, 0Dh, "<<<<<<< Enter Preferred Date/Time (e.g., 12-OCT 10AM) >>>>>>>   $"
    MSG_APPT_SAVED  DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                   REQUEST SAVED! WAIT FOR THE ADMIN APPROVAL                   "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"

    SHOW_REQ_DT     DB 0Ah, 0Dh, "<<<<<<< Patient Requested Time >>>>>>>   $"
    ASK_AVAIL       DB 0Ah, 0Dh, "<<<<<<< Is this time available? (Y/N) >>>>>>>   $"
    MSG_REJECTED    DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                   THE APPOINTMENT HAS BEEN REJECTED SUCCESSFULLY               "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    MSG_ADDED       DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                          ONE PATIENT REGISTERED SUCCESSFULLY                   "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"

    SERVED_MSG      DB 0Ah, 0Dh, "[SUCCESS] Patient Served! Info: $"
    EMPTY_MSG       DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                            WAITING ROOM IS CURRENTLY EMPTY                     "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    FULL_MSG        DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                            WAITING ROOM IS CURRENTLY FULL                      "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    USER_NOT_FOUND  DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                            USER NOT FOUND IN THE DATABASE                      "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    
    DOC_HOME_YES    DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                          You are the first patient till now                    "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    DOC_HOME_NO     DB 0Ah, 0Dh, "[NO] Your serial number is: $"
    CANCEL_MSG      DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                           ALL THE APPOINTMENT ARE CANCELLED                    "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    REVERSE_MSG     DB 0Ah, 0Dh, "////////////////////////////////////////////////////////////////////////////////" 
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "                               LINE REVERSED SUCCESSFULLY                       "
                    DB           "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
                    DB           "////////////////////////////////////////////////////////////////////////////////$"
    NEWLINE         DB 0Ah, 0Dh, "$"
    SEPARATOR       DB " | $"

    ; --- DATA CONFIG ---
    STR_SIZE        EQU 20           ; Max chars per string
    MAX_USERS       EQU 5
    MAX_PATIENTS    EQU 5

    ; --- AUTH ARRAYS ---
    AUTH_NAMES      DB 100 DUP('$') 
    AUTH_PASS       DB 100 DUP('$')
    AUTH_ROLES      DB 100 DUP('$') ; 'A' or 'P'
    AUTH_NOTIFY     DB 100 DUP(0)   ; 0=None, 1=Confirmed, 2=Rejected
    AUTH_APPT_DT    DB 100 DUP('$') ; Stores requested date
    
    USER_COUNT      DW 0
    CURRENT_USER_IDX DW 0           

    ; --- WRM ARRAYS ---
    PAT_IDS         DB 100 DUP('$') 
    PAT_NAMES       DB 100 DUP('$')
    
    HEAD            DW 0            
    TAIL            DW 0            
    PAT_COUNT       DW 0            

    ; --- BUFFERS ---
    IN_BUF          DB 20, ?, 20 DUP('$') 
    TEMP_USER       DB 20 DUP('$')        
    TEMP_PASS       DB 20 DUP('$')        
    REG_ROLE_TEMP   DB ?                  

; =============================================================
; CODE SEGMENT
; =============================================================
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

START_SCREEN:
    PRINT_MSG START_MSG

    READ_CHAR
    SUB AL, 30H
    
    CMP AL, 1
    JE GO_REGISTER
    CMP AL, 2
    JE GO_LOGIN
    CMP AL, 3
    JE EXIT_PROG
    JMP START_SCREEN

GO_REGISTER:
    CALL SYS_REGISTER
    JMP START_SCREEN
    
GO_LOGIN:
    CALL SYS_LOGIN
    JMP START_SCREEN

EXIT_PROG:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; =============================================================
; SYSTEM REGISTRATION
; =============================================================
SYS_REGISTER PROC
    PRINT_MSG REG_USER_MSG
    
    MOV AX, USER_COUNT
    CMP AX, MAX_USERS
    JAE REG_RET_FAR

    ; 1. ASK USERNAME
    PRINT_MSG ASK_USER
    CALL GET_STRING
    LEA SI, IN_BUF + 2
    
    CALC_OFFSET USER_COUNT ; Macro sets DI
    
    LEA BX, AUTH_NAMES
    ADD BX, DI
    CALL STR_COPY

    ; 2. ASK PASSWORD
    PRINT_MSG ASK_PASS
    CALL GET_STRING
    LEA SI, IN_BUF + 2
    LEA BX, AUTH_PASS
    ADD BX, DI
    CALL STR_COPY

    ; 3. ASK ROLE
    PRINT_MSG ASK_ROLE
    READ_CHAR
    MOV REG_ROLE_TEMP, AL
    
    ; --- CHECK: ONE ADMIN CONSTRAINT ---
    CMP AL, 'A'
    JE CHECK_IF_ADMIN_EXISTS
    CMP AL, 'a'
    JE CHECK_IF_ADMIN_EXISTS
    JMP SAVE_FINAL

CHECK_IF_ADMIN_EXISTS:
    MOV CX, USER_COUNT
    CMP CX, 0
    JE SAVE_FINAL
    
    LEA SI, AUTH_ROLES
SEARCH_ADMIN_LOOP:
    MOV BL, [SI]
    CMP BL, 'A'
    JE ADMIN_DENIED
    CMP BL, 'a'
    JE ADMIN_DENIED
    INC SI
    LOOP SEARCH_ADMIN_LOOP
    JMP SAVE_FINAL

ADMIN_DENIED:
    PRINT_MSG ERR_ADMIN_EXIST
    RET             ; Abort

SAVE_FINAL:
    ; Commit Role
    LEA BX, AUTH_ROLES
    ADD BX, USER_COUNT 
    MOV AL, REG_ROLE_TEMP
    MOV [BX], AL
    
    ; Init Notify Flag to 0
    LEA BX, AUTH_NOTIFY
    ADD BX, USER_COUNT
    MOV BYTE PTR [BX], 0

    ; Init Date String to Empty
    CALC_OFFSET USER_COUNT
    LEA BX, AUTH_APPT_DT
    ADD BX, DI
    MOV BYTE PTR [BX], '$'

    INC USER_COUNT
    PRINT_MSG SUCCESS_REG

REG_RET_FAR:
    RET
SYS_REGISTER ENDP

; =============================================================
; SYSTEM LOGIN
; =============================================================
SYS_LOGIN PROC
    PRINT_MSG LOGIN_MSG

    ; 1. Get Username
    PRINT_MSG ASK_USER
    CALL GET_STRING
    LEA SI, IN_BUF + 2
    LEA BX, TEMP_USER
    CALL STR_COPY_DIRECT

    ; 2. Get Password
    PRINT_MSG ASK_PASS
    CALL GET_STRING
    LEA SI, IN_BUF + 2
    LEA BX, TEMP_PASS
    CALL STR_COPY_DIRECT

    ; 3. Validate
    MOV CX, USER_COUNT
    CMP CX, 0
    JE LOGIN_FAIL
    MOV SI, 0           ; User Index

CHECK_USER_LOOP:
    PUSH CX
    PUSH SI

    CALC_OFFSET SI      ; Macro sets DI
    
    LEA BX, AUTH_NAMES
    ADD BX, DI          
    LEA DX, TEMP_USER   
    CALL STR_COMPARE    
    JNE NEXT_ITER       

    LEA BX, AUTH_PASS
    ADD BX, DI          
    LEA DX, TEMP_PASS
    CALL STR_COMPARE
    JNE NEXT_ITER

    ; MATCH FOUND
    POP SI              
    POP CX 
    MOV CURRENT_USER_IDX, SI
    JMP LOGIN_SUCCESS

NEXT_ITER:
    POP SI
    POP CX
    INC SI
    LOOP CHECK_USER_LOOP

LOGIN_FAIL:
    PRINT_MSG ERR_LOGIN
    RET                 

LOGIN_SUCCESS:
    LEA BX, AUTH_ROLES
    ADD BX, SI
    MOV AL, [BX]
    
    CMP AL, 'A'
    JE GO_ADMIN_DASH
    CMP AL, 'a'
    JE GO_ADMIN_DASH
    
    CMP AL, 'P'
    JE GO_PATIENT_DASH
    CMP AL, 'p'
    JE GO_PATIENT_DASH
    JMP LOGIN_FAIL      

GO_ADMIN_DASH:
    CALL ADMIN_LOOP
    RET                 
GO_PATIENT_DASH:
    CALL PATIENT_LOOP
    RET
SYS_LOGIN ENDP

; =============================================================
; ADMIN DASHBOARD
; =============================================================
ADMIN_LOOP PROC
ADMIN_START:
    PRINT_MSG ADMIN_MENU

    READ_CHAR
    SUB AL, 30H

    CMP AL, 1
    JE A_REG_PAT
    CMP AL, 2
    JE A_SERVE
    CMP AL, 3
    JE A_CANCEL
    CMP AL, 4
    JE A_REVERSE
    CMP AL, 5
    JE A_SHOW
    CMP AL, 6
    JE A_LOGOUT
    JMP ADMIN_START

A_REG_PAT:
    CALL WRM_REGISTER
    JMP ADMIN_START
A_SERVE:
    CALL WRM_SERVE
    JMP ADMIN_START
A_CANCEL:
    CALL WRM_CANCEL
    JMP ADMIN_START
A_REVERSE:
    CALL WRM_REVERSE
    JMP ADMIN_START
A_SHOW:
    CALL WRM_SHOW
    JMP ADMIN_START
A_LOGOUT:
    RET                 
ADMIN_LOOP ENDP

; =============================================================
; PATIENT DASHBOARD
; =============================================================
PATIENT_LOOP PROC
PATIENT_START:

    ; Check Notification
    LEA BX, AUTH_NOTIFY
    ADD BX, CURRENT_USER_IDX
    MOV AL, [BX]
    
    CMP AL, 1
    JE SHOW_CONFIRM
    CMP AL, 2
    JE SHOW_REJECT
    JMP SHOW_P_MENU

SHOW_CONFIRM:
    PRINT_MSG NOTIFY_CONFIRM
    MOV BYTE PTR [BX], 0
    JMP SHOW_P_MENU

SHOW_REJECT:
    PRINT_MSG NOTIFY_REJECT
    MOV BYTE PTR [BX], 0
    
SHOW_P_MENU:
    PRINT_MSG PATIENT_MENU

    READ_CHAR
    SUB AL, 30H

    CMP AL, 1
    JE P_DOC_HOME
    CMP AL, 2
    JE P_BOOK_APPT
    CMP AL, 3
    JE P_LOGOUT
    JMP PATIENT_START

P_DOC_HOME:
    CALL WRM_CHECK_HOME
    JMP PATIENT_START
    
P_BOOK_APPT:
    CALL WRM_PAT_BOOK
    JMP PATIENT_START
    
P_LOGOUT:
    RET
PATIENT_LOOP ENDP

; =============================================================
; WRM LOGIC
; =============================================================

WRM_PAT_BOOK PROC
    PRINT_MSG ASK_APPT_DT
    CALL GET_STRING
    
    CALC_OFFSET CURRENT_USER_IDX
    
    LEA SI, IN_BUF + 2
    LEA BX, AUTH_APPT_DT
    ADD BX, DI
    CALL STR_COPY
    
    PRINT_MSG MSG_APPT_SAVED
    RET
WRM_PAT_BOOK ENDP

WRM_REGISTER PROC
    MOV AX, PAT_COUNT
    CMP AX, MAX_PATIENTS
    JAE WRM_FULL_JMP

    PRINT_MSG NAME_PROMPT
    CALL GET_STRING
    
    ; Find user index
    MOV CX, USER_COUNT
    CMP CX, 0
    JE USER_NOT_FOUND_ERR
    MOV SI, 0

FIND_USER_LOOP:
    PUSH CX
    PUSH SI
    
    CALC_OFFSET SI
    
    LEA BX, AUTH_NAMES
    ADD BX, DI          
    LEA DX, IN_BUF + 2
    CALL STR_COMPARE
    JNE NEXT_SEARCH

    POP SI
    POP CX 
    JMP PROCESS_USER_REG

NEXT_SEARCH:
    POP SI
    POP CX
    INC SI
    LOOP FIND_USER_LOOP
    JMP USER_NOT_FOUND_ERR

PROCESS_USER_REG:
    ; SI = User Index, DI = Offset
    PRINT_MSG SHOW_REQ_DT
    
    LEA DX, AUTH_APPT_DT[DI]
    MOV AH, 09H
    INT 21H
    
    PRINT_MSG ASK_AVAIL
    READ_CHAR
    
    CMP AL, 'N'
    JE REJECT_APPT
    CMP AL, 'n'
    JE REJECT_APPT
    
    ; ACCEPT
    LEA BX, AUTH_NOTIFY
    ADD BX, SI
    MOV BYTE PTR [BX], 1
    
    CALC_OFFSET TAIL ; DI = Tail Offset

    LEA SI, IN_BUF + 2
    LEA BX, PAT_NAMES
    ADD BX, DI
    CALL STR_COPY
    
    PRINT_MSG ID_PROMPT
    CALL GET_STRING
    LEA SI, IN_BUF + 2
    LEA BX, PAT_IDS
    ADD BX, DI
    CALL STR_COPY
    
    INC TAIL
    INC PAT_COUNT
    
    PRINT_MSG MSG_ADDED
    RET

REJECT_APPT:
    LEA BX, AUTH_NOTIFY
    ADD BX, SI
    MOV BYTE PTR [BX], 2
    PRINT_MSG MSG_REJECTED
    RET

USER_NOT_FOUND_ERR:
    PRINT_MSG USER_NOT_FOUND
    RET

WRM_FULL_JMP:
    PRINT_MSG FULL_MSG
    RET
WRM_REGISTER ENDP

WRM_SERVE PROC
    CMP PAT_COUNT, 0
    JE WRM_EMPTY_ERR
    
    CALC_OFFSET HEAD

    PRINT_MSG SERVED_MSG
    LEA DX, PAT_NAMES[DI]
    MOV AH, 09H
    INT 21H
    
    INC HEAD
    DEC PAT_COUNT
    CMP PAT_COUNT, 0
    JNE SERVE_RET
    MOV HEAD, 0
    MOV TAIL, 0
SERVE_RET:
    RET
WRM_EMPTY_ERR:
    PRINT_MSG EMPTY_MSG
    RET
WRM_SERVE ENDP

WRM_CANCEL PROC
    MOV HEAD, 0
    MOV TAIL, 0
    MOV PAT_COUNT, 0
    PRINT_MSG CANCEL_MSG
    RET
WRM_CANCEL ENDP

WRM_REVERSE PROC
    CMP PAT_COUNT, 2
    JB REV_RET
    
    MOV SI, HEAD
    MOV DI, TAIL
    DEC DI
REV_LOOP:
    CMP SI, DI
    JAE REV_SUCCESS
    
    PUSH SI
    PUSH DI
    LEA BX, PAT_IDS
    CALL SWAP_STRINGS
    POP DI
    POP SI
    
    PUSH SI
    PUSH DI
    LEA BX, PAT_NAMES
    CALL SWAP_STRINGS
    POP DI
    POP SI

    INC SI
    DEC DI
    JMP REV_LOOP
REV_SUCCESS:
    PRINT_MSG REVERSE_MSG
REV_RET:
    RET
WRM_REVERSE ENDP

WRM_SHOW PROC
    CMP PAT_COUNT, 0
    JE WRM_EMPTY_ERR
    MOV CX, PAT_COUNT
    MOV SI, HEAD
SHOW_L:
    PUSH CX
    CALC_OFFSET SI
    
    PRINT_MSG NEWLINE
    LEA DX, PAT_IDS[DI]
    MOV AH, 09H
    INT 21H
    PRINT_MSG SEPARATOR
    LEA DX, PAT_NAMES[DI]
    MOV AH, 09H
    INT 21H
    
    INC SI
    POP CX
    LOOP SHOW_L
    RET
WRM_SHOW ENDP

WRM_CHECK_HOME PROC
    CMP PAT_COUNT, 0
    JNE DOC_STAY
    PRINT_MSG DOC_HOME_YES
    RET
DOC_STAY:
    PRINT_MSG DOC_HOME_NO
    MOV AX, PAT_COUNT
    ADD AL, 30H
    PRINT_CHAR AL
    RET
WRM_CHECK_HOME ENDP

; =============================================================
; UTILITIES (Procedures kept for complexity management)
; =============================================================

GET_STRING PROC
    LEA DX, IN_BUF
    MOV AH, 0AH
    INT 21H
    MOV BL, IN_BUF[1]
    MOV BH, 0
    MOV IN_BUF[BX+2], '$'
    RET
GET_STRING ENDP

STR_COPY PROC
    MOV CL, IN_BUF[1]
    MOV CH, 0
    CMP CX, 0
    JE CPY_DONE
CPY_L:
    MOV AL, [SI]
    MOV [BX], AL
    INC SI
    INC BX
    LOOP CPY_L
    MOV BYTE PTR [BX], '$'
CPY_DONE:
    RET
STR_COPY ENDP

STR_COPY_DIRECT PROC
    PUSH AX
CPY_DIR_L:
    MOV AL, [SI]
    CMP AL, '$'
    JE CPY_DIR_DONE
    MOV [BX], AL
    INC SI
    INC BX
    JMP CPY_DIR_L
CPY_DIR_DONE:
    MOV BYTE PTR [BX], '$'
    POP AX
    RET
STR_COPY_DIRECT ENDP

STR_COMPARE PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX
    PUSH DX
    
    MOV SI, BX ; Str1
    MOV DI, DX ; Str2
    
CMP_LOOP:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, '$'
    JE CHECK_END
    CMP AL, AH
    JNE CMP_FAIL
    INC SI
    INC DI
    JMP CMP_LOOP

CHECK_END:
    CMP AH, '$'
    JNE CMP_FAIL
    POP DX
    POP BX
    POP CX
    POP DI
    POP SI
    CMP AL, AL ; ZF=1
    RET

CMP_FAIL:
    POP DX
    POP BX
    POP CX
    POP DI
    POP SI
    OR AL, 1 ; ZF=0
    RET
STR_COMPARE ENDP

SWAP_STRINGS PROC
    MOV AX, SI
    PUSH BX
    MOV BL, STR_SIZE
    MUL BL
    MOV CX, AX ; Offset 1
    POP BX
    
    MOV AX, DI
    PUSH BX
    MOV BL, STR_SIZE
    MUL BL
    MOV DX, AX ; Offset 2
    POP BX
    
    PUSH SI
    PUSH DI
    
    MOV SI, BX
    ADD SI, CX
    MOV DI, BX
    ADD DI, DX
    
    MOV CX, STR_SIZE
SWAP_L:
    MOV AL, [SI]
    MOV AH, [DI]
    MOV [SI], AH
    MOV [DI], AL
    INC SI
    INC DI
    LOOP SWAP_L
    
    POP DI
    POP SI
    RET
SWAP_STRINGS ENDP

END MAIN