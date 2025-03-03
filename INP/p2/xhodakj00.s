; Autor reseni: Jan Stefan Hodak, xhodakj00

; Projekt 2 - INP 2024
; Vigenerova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "janstefanhodak" ; sem doplnte vase "jmenoprijmeni"

cipher:         .space  31  ; misto pro zapis zasifrovaneho textu
                            ; zde si muzete nadefinovat vlastni promenne ci konstanty,
                            ; napr. hodnoty posuvu pro jednotlive znaky sifrovacho klice

key:            .asciiz "hod"

params_sys5:    .space  8 ; misto pro ulozeni adresy pocatku
                          ; retezce pro vypis pomoci syscall 5
                          ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text


main:
    add r1,r0,r0
    addi $a3, r0,key
    addi $t1, r0, 96  ;potreba odecist od ascii hodnoty klice pro veliokost posunu
    
    lb   $a1, 0($a3)
    lb   $a2, 1($a3)
    lb   $a3, 2($a3)
    
    sub  $a1, $a1, $t1
    sub  $a2, $a2, $t1   ;v a123 hodnoty klice pro zasifrovani
    sub  $a3, $a3, $t1


addi    r1, r0, 0   ;r1 = position in msg
addi    r2, r0, 0   ;r2 = position in key
addi    r3, r0, 1   ; r3 1=add, 0=sub
addi    r10, r0, 1   ; r10 = 1 (constant)
addi    r9, r0, 3 
start_encryption:

    lb      r8, msg(r1)
    
    beq     r8, r0, end ; pokud jsem na konci zpravy skoc na konec
    
    beq     r3, r0,  key1_sub;if r3!=0
    
key1_add:
    bne     r2, r0, key2_add
    add     r8, r8, $a1
    b       store_to_memory
key2_add:
    bne     r2, r10, key3_add
    add     r8, r8, $a2
    b       store_to_memory
key3_add:
    add     r8, r8, $a3
    b       store_to_memory

key1_sub:
    bne     r2, r0, key2_sub
    sub     r8, r8, $a1
    b       store_to_memory
key2_sub:
    bne     r2, r10, key3_sub
    sub     r8, r8, $a2
    b       store_to_memory
key3_sub:
    sub     r8, r8, $a3

store_to_memory:
    
    slti r4, r8, 97  ;if r8<97 then r4 =1, 
    beq r4, r0, not_under_a
    addi r8, r8, 26   ;vraceni zpet na abecedu
not_under_a:
    slti r4, r8, 123  ;if r8<123 then r4 = 1, 
    bne r4, r0, not_over_z
    addi r8, r8, -26  ;vraceni zpet na abecedu
not_over_z:

sb      r8, cipher(r1)

next_index:
    
    addi    r2, r2, 1
    addi    r1, r1, 1
    
    ;r9 =3
    bne     r9, r2, skip_modulo
    addi    r2, r2, -3
skip_modulo:

    beq     r3, r0, r3_to_1
    addi    r3,r3,-1
    j       skip_r3_to_1
r3_to_1:
    addi    r3,r3,1
skip_r3_to_1:

    j       start_encryption

end:
    sb      r0, cipher(r1)

    daddi   r4, r0, cipher ; vozrovy vypis: adresa msg do r4
    jal     print_string ; vypis pomoci print_string - viz nize

; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
