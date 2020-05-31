data segment       
    
    deux          dw      2 
    tab2          dd      5 dup(?)        
    choix         db      "Appuyer sur 'H' pour lire un nombre en hexadecimal",0ah,0dh,"Ou sur une autre lettre pour lire un nombre en Decimal",0ah,0dh,"$"
    nombre        db      0ah,0dh,"Entrez un nombre: $"
    buffer        db      9 dup('$')
    erreur1       db      0ah,0dh,"Erreur: le numero doit etre inferieur a a 10 000$" 
    results       db      0ah,0dh,"voici vos resultats: ",0ah,0dh,"$"
    erreurFormat  db      0ah,0dh,"Erreur: Format invalide $"  
    seize         db      10h
    dix           dw      10
    plus          db      " + $"
    espace          db      " + $"
    egale         db      " = $"
    Fligne        db      0ah,0dh,"$"
    Intab1        db      0ah,0dh,"Initialisation du talbeau 1: ",0ah,0dh,"$"  
    Intab2        db      0ah,0dh,0ah,0dh,"Initialisation du talbeau 2: ",0ah,0dh,"$"
    tab1          dd      5 dup(?)
       
    dFligne       db     0ah,0dh," ", 0ah,0dh,"$"

    
    
    data ends  


stack segment
    
    dw 128h dup (?)
    
    stack ends  


pile_utilisateur segment
    
    dw 128h dup (?)
    
    pile_utilisateur ends



code segment                
    
    assume cs: code,ds: data, ss: stack, ss:pile_utilisateur
    
    main:
    
    mov ax, data
    mov ds, ax
    
    mov ax, stack
    mov ss, ax 
    

    ;initialisation tableau 1
    
    lea dx, Intab1
    call Message
    
    lea  bx, tab1
    push bx
     
    call InitTab 
    add sp, 2
    
    ;initialisation tableau 2
    
    lea dx, Intab2
    call Message
    
    lea  bx, tab2
    push bx
     
    call InitTab 
    add sp, 2  
    
    ;somme
    xor di, di 
    
    ;****************************************************************
    
    push dx
    lea dx, Fligne   ;;;;;;;;;;;affiche " fin de ligne "
    call Message                    
    pop dx
    
    ;**********************************************************************************
    
    
    
    BoucleSomme:

    
    
    mov ax, tab1[di]
    mov dx, tab1[di+2]
    
    push ax     ;poids faible nb1
    push dx     ;poids fort nb1
    
    
    ;**************************  affiche premier nombre   **************************************
    push ax
    push dx
    call affdec ;;;;;;;;;;;
    add sp, 4
    ;**************************************************************** 
    
    
    
    
    push dx
    lea dx, plus
    call Message ;;;;;;;;;;;affiche " + "
    pop dx
    
    
    
    mov ax, tab2[di]
    mov dx, tab2[di+2]   
    push ax     ;poids faible nb2
    push dx     ;poids fort nb2
    
                        
   ;**************************  affiche premier nombre   **************************************
    push ax
    push dx
    call affdec ;;;;;;;;;;;
    add sp, 4
    ;**************************************************************** 
    
    push dx
    lea dx, egale   ;;;;;;;;;;;affiche " = "
    call Message                    
    pop dx                    
    
    
    sub sp, 6   ;sortie
    
    
                        
    call somNB1NB2 
    
    pop dx
    pop ax
    pop cx
    add sp,8  
    
   ;**************************************************************************************
    mov bx, pile_utilisateur
    mov ss, bx 
    
    push ax
    push dx
    
      
    mov bx, stack
    mov ss, bx
    
     
   ;**************************  affiche resultat nombre   **************************************
    push ax
    push dx
    call affdec ;;;;;;;;;;;
    add sp, 4
    ;****************************************************************
    
    push dx
    lea dx, Fligne   ;;;;;;;;;;;affiche " fin de ligne "
    call Message                    
    pop dx
    
 
   ;**************************  affiche psw   **************************************
    push cx
    xor dx, dx
    push dx
    call affbin ;;;;;;;;;;;
    add sp, 4    
    
    push dx
    lea dx, Fligne   ;;;;;;;;;;;affiche " fin de ligne "
    call Message                    
    pop dx
    
    
    
    ;****************************************************************

    add di, 4
    cmp di, 20
    jb BoucleSomme 
     
     
     
     
    push dx
    lea dx, results
    call Message ;;;;;;;;;;;affiche " "
    pop dx 
    ;///////////////////   afficher resultats.     /////////////
     
    mov ax, pile_utilisateur
    mov ss, ax
    
    dboucle:
    
    pop dx
    pop ax
    
    call affdec
    
    push dx
    lea dx, results
    call Message ;;;;;;;;;;;affiche "un espace "
    pop dx
    
    
    cmp sp, bp
    jne dboucle 
     
    finprog:
    mov ah, 4Ch
    int 21h     
    
;///////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////
;//////////////  P   R   O   C   E   D   U   R    E    S  //////////////
;///////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////    
    
    ;Affiche message///////////////////////////////
    
    Message proc  
        push ax
        push si
        push di
        
        mov ah, 09h
        int 21h
        
        pop di
        pop si
        pop ax
        ret
    Message endp
    
    ;Lire une chaine de caractere//////////////////////
    
    LireChaine proc 
        
        
        lea dx, nombre
        call Message
        
        lea dx, buffer
        mov ah, 0ah
        int 21h
     
        ret
    LireChaine endp 
    
    ;Convertir la chaine en nombre//////////////////
    
    ConvertirChaineNum proc
        
        push bx
        push cx
        push si 
        push bp
        mov bp, sp

        xor ax, ax
        xor dx, dx 
        xor cx, cx
        
        lea bx, buffer
        
        xor ch, ch
        mov si, 2
        
        looop:
        
        mul dix
        mov cx, [bx+si] 
        sub cx, 30h 
        xor ch, ch
        add ax, cx
        adc dx, 0      
         
        inc si 
        
        mov cx, [bx+1]
        xor ch, ch  
        add cl, 2
        cmp si, cx
        jne looop
        
        mov [bp+10], ax 
        mov [bp+12], dx
        
        pop bp
        pop si
        pop cx
        pop bx

        ret
    ConvertirChaineNum endp
    
    ;Lire Chaine en Decimale////////////////////////    
    
    LireChaineDecimale proc
        
        push bx
        push si
        push cx
        push bp
        mov bp, sp
        
        call LireChaine
        mov bx, dx
        
        cmp [bx+1], 5   ;On teste si le nombre a n=5 chiffres
        jbe followCHD
        
        lea dx, erreur1
        call Message
        jmp finprog 
        
        followCHD:
        
        
        mov cx, [bx+1]
        xor ch, ch
        add cx, 2
     
        
        
        mov si, 2
        
        boucleCHD:
        
        cmp [bx+si], '0'
        jb erreurFD
        cmp [bx+si], '9'
        ja erreurFD 
        
        inc si
        
        
        cmp si, cx
        jb boucleCHD
        
        jmp NonErreurFD
        
        erreurFD:   ;si il'y a une erreur on le signale
        
        lea dx, erreurFormat
        call Message 
        
        jmp finprog
        
        NonErreurFD: 
        
        
        
        
        
        finCHD: 
        
         pop bp
         pop cx
         pop si
         pop bx
         
         
         ret
    LireChaineDecimale endp     
    
  ;//////////////////////////////////////////////////////////////  
    affdec proc
        
        push ax
        push dx
        push bp
        mov bp, sp
        
        mov ax, [bp+10]
        mov dx, [bp+8]
     
        boucleAff: 
        
        div dix
        push dx
        xor dx, dx       
        cmp ax, dix
        jae boucleAff
        
        push ax
        
        boucldeu:
        
        pop ax     
        add al, 30h 
        mov dl, al
        mov ah, 02h
        int 21h  
        
        cmp bp, sp
        jne boucldeu:
         
        pop bp
        pop dx
        pop ax
         

        ret
    affdec endp
    ;/////////////////////////////////////////////////////////
         affbin proc
        
        push ax
        push dx
        push bp
        mov bp, sp
        
        mov ax, [bp+10]
        mov dx, [bp+8]
     
        boucleAffb: 
        
        div deux
        push dx
        xor dx, dx       
        cmp ax, 1 
        jae boucleAffb
        
        push ax
        
        boucldeub:
        
        pop ax     
        add al, 30h 
        mov dl, al
        mov ah, 02h
        int 21h  
        
        
        cmp bp, sp
        jne boucldeub:
         
        pop bp
        pop dx
        pop ax
         

        ret
    affbin endp
     
    ;////////////////////////////////////////////////////////
   
      InitTab proc  
       
       push bp
       mov bp, sp
       mov bx, [bp+4]
       
       
       mov cx, 5
       mov si, 0
        
       loopInit:
       
       
       
       call LireChaineDecimale  ;offset dans bx a la fin de cette instruction  
       sub sp ,4
       call ConvertirChaineNum  ;resultat dans dx:ax  
       pop ax
       pop dx    
        

       
       
        
 
       mov [bx+si], ax
       mov [bx+si+2], dx   
       add si,4
       
       loop loopInit    

       
       pop bp
     
        ret
     InitTab endp   
    
    ;/////////////////////////////////////////////////////////
    
    somNB1NB2 proc
        push cx
        push ax
        push dx          
        push bp
        mov bp, sp
        
        mov dx, [bp+16]
        mov ax, [bp+18]
        add dx, [bp+20]
        add ax, [bp+22]
        pushf 
        pop cx 
        adc dx, 0 
        
        
        
        mov [bp+10], dx
        mov [bp+12], ax  
        mov [bp+14], cx
        
                  
        
        pop bp
        pop dx
        pop ax
        pop cx
        ret
    somNB1NB2 endp
    
  
    ;/////////////////////////////////////////////////////////
     affhex proc
        
        push ax
        push dx
        push bp
        mov bp, sp
        
        mov ax, [bp+10]
        mov dx, [bp+8]
     
        hboucleAff: 
        
        div seize
        push dx
        xor dx, dx       
        cmp ax, 10h
        jae hboucleAff
        
        push ax
        
        hboucldeu:
        
        pop ax     
        add al, 30h 
        mov dl, al
        mov ah, 02h
        int 21h  
        
        cmp bp, sp
        jne hboucldeu:
         
        pop bp
        pop dx
        pop ax
         

        ret
    affhex endp
     
     
     
     
    code ends
end main