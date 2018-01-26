#
# Ces fonctions s'occupent de l'affichage et des entrÃ©es clavier.
# Il n'est pas obligatoire de comprendre ce qu'elles font.

.data

# Tampon d'affichage du jeu 256*256 de maniÃ¨re linÃ©aire.

frameBuffer: .word 0 : 1024  # Frame buffer

# Code couleur pour l'affichage
# Codage des couleurs 0xwwxxyyzz oÃ¹
#   ww = 00
#   00 <= xx <= ff est la couleur rouge en hexadÃ©cimal
#   00 <= yy <= ff est la couleur verte en hexadÃ©cimal
#   00 <= zz <= ff est la couleur bleue en hexadÃ©cimal

colors: .word 0x00000000, 0x00ff0000, 0xff00ff00, 0x00396239, 0x00ff00ff
.eqv black 0
.eqv red   4
.eqv green 8
.eqv greenV2  12
.eqv rose  16

colors2: .word 0x00ffff00, 0x003399ff, 0x00ff0000, 0x0000ffff, 0x00f8000, 0x00396239, 0x0099004c
.eqv jaune 0
.eqv bleuclair 4
.eqv red2   8
.eqv magenta 12
.eqv orange 16
.eqv greenV3 20
.eqv jaunevert 24
# DerniÃ¨re position connue de la queue du serpent.

lastSnakePiece: .word 0, 0


.text
j main

############################# printColorAtPosition #############################
# ParamÃ¨tres: $a0 La valeur de la couleur
#             $a1 La position en X
#             $a2 La position en Y
# Retour: Aucun
# Effet de bord: Modifie l'affichage du jeu
################################################################################

printColorAtPosition:
lw $t0 tailleGrille
mul $t0 $a1 $t0
add $t0 $t0 $a2
sll $t0 $t0 2
sw $a0 frameBuffer($t0)
jr $ra

################################ resetAffichage ################################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: RÃ©initialise tout l'affichage avec la couleur noir
################################################################################

resetAffichage:
lw $t1 tailleGrille
mul $t1 $t1 $t1
sll $t1 $t1 2
la $t0 frameBuffer
addu $t1 $t0 $t1
lw $t3 colors + black

RALoop2: bge $t0 $t1 endRALoop2
  sw $t3 0($t0)
  add $t0 $t0 4
  j RALoop2
endRALoop2:
jr $ra

################################## printSnake ##################################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement ou se
#                trouve le serpent et sauvegarde la derniÃ¨re position connue de
#                la queue du serpent.
################################################################################

printSnake:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 tailleSnake
sll $s0 $s0 2
li $s1 0

lw $a0 colors + greenV2
lw $a1 snakePosX($s1)
lw $a2 snakePosY($s1)
jal printColorAtPosition
li $s1 8
li $s2 0
li $s3 28

PSLoop:
bge $s1 $s0 endPSLoop
  
  beq $s2 $s3 rie

  lw $a0 colors2($s2)
  lw $a1 snakePosX($s1)
  lw $a2 snakePosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  addu $s2 $s2 4
  j PSLoop
  rie:
  li $s2 0
  j PSLoop
endPSLoop:


subu $s0 $s0 4
lw $t0 snakePosX($s0)
lw $t1 snakePosY($s0)
sw $t0 lastSnakePiece
sw $t1 lastSnakePiece + 4

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################ printObstacles ################################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement des obstacles.
################################################################################

printObstacles:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 numObstacles
sll $s0 $s0 2
li $s1 0

POLoop:
bge $s1 $s0 endPOLoop
  lw $a0 colors + red
  lw $a1 obstaclesPosX($s1)
  lw $a2 obstaclesPosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  j POLoop
endPOLoop:

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################## printCandy ##################################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage Ã  l'emplacement du bonbon.
################################################################################

printCandy:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + rose
lw $a1 candy
lw $a2 candy + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

eraseLastSnakePiece:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + black
lw $a1 lastSnakePiece
lw $a2 lastSnakePiece + 4
jal printColorAtPosition


lw $ra ($sp)
addu $sp $sp 4
jr $ra

################################## printGame ###################################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: Effectue l'affichage de la totalitÃ© des Ã©lÃ©ments du jeu.
################################################################################

printGame:
subu $sp $sp 4
sw $ra 0($sp)

jal eraseLastSnakePiece
jal printSnake
jal printObstacles
jal printCandy

lw $ra 0($sp)
addu $sp $sp 4
jr $ra

############################## getRandomExcluding ##############################
# ParamÃ¨tres: $a0 Un entier x | 0 <= x < tailleGrille
# Retour: $v0 Un entier y | 0 <= y < tailleGrille, y != x
################################################################################

getRandomExcluding:
move $t0 $a0
lw $a1 tailleGrille
li $v0 42
syscall
beq $t0 $a0 getRandomExcluding
move $v0 $a0
jr $ra

########################### newRandomObjectPosition ############################
# Description: Renvoie une position alÃ©atoire sur un emplacement non utilisÃ©
#              qui ne se trouve pas devant le serpent.
# ParamÃ¨tres: Aucun
# Retour: $v0 Position X du nouvel objet
#         $v1 Position Y du nouvel objet
################################################################################

newRandomObjectPosition:
subu $sp $sp 4
sw $ra ($sp)

lw $t0 snakeDir
and $t0 0x1
bgtz $t0 horizontalMoving
li $v0 42
lw $a1 tailleGrille
syscall
move $t8 $a0
lw $a0 snakePosY
jal getRandomExcluding
move $t9 $v0
j endROPdir

horizontalMoving:
lw $a0 snakePosX
jal getRandomExcluding
move $t8 $v0
lw $a1 tailleGrille
li $v0 42
syscall
move $t9 $a0
endROPdir:

lw $t0 tailleSnake
sll $t0 $t0 2
la $t0 snakePosX($t0)
la $t1 snakePosX
la $t2 snakePosY
li $t4 0

ROPtestPos:
bge $t1 $t0 endROPtestPos
lw $t3 ($t1)
bne $t3 $t8 ROPtestPos2
lw $t3 ($t2)
beq $t3 $t9 replayROP
ROPtestPos2:
addu $t1 $t1 4
addu $t2 $t2 4
j ROPtestPos
endROPtestPos:

bnez $t4 endROP

lw $t0 numObstacles
sll $t0 $t0 2
la $t0 obstaclesPosX($t0)
la $t1 obstaclesPosX
la $t2 obstaclesPosY
li $t4 1
j ROPtestPos

endROP:
move $v0 $t8
move $v1 $t9
lw $ra ($sp)
addu $sp $sp 4
jr $ra

replayROP:
lw $ra ($sp)
addu $sp $sp 4
j newRandomObjectPosition

################################# getInputVal ##################################
# ParamÃ¨tres: Aucun
# Retour: $v0 La valeur 0 (haut), 1 (droite), 2 (bas), 3 (gauche), 4 erreur
################################################################################

getInputVal:
lw $t0 0xffff0004
li $t1 122
beq $t0 $t1 GIhaut
li $t1 115
beq $t0 $t1 GIbas
li $t1 113
beq $t0 $t1 GIgauche
li $t1 100
beq $t0 $t1 GIdroite
li $v0 4
j GIend

GIhaut:
li $v0 0
j GIend

GIdroite:
li $v0 1
j GIend

GIbas:
li $v0 2
j GIend

GIgauche:
li $v0 3

GIend:
jr $ra

################################ sleepMillisec #################################
# ParamÃ¨tres: $a0 Le temps en milli-secondes qu'il faut passer dans cette
#             fonction (approximatif)
# Retour: Aucun
################################################################################

sleepMillisec:
move $t0 $a0
li $v0 30
syscall
addu $t0 $t0 $a0

SMloop:
bgt $a0 $t0 endSMloop
li $v0 30
syscall
j SMloop

endSMloop:
jr $ra

##################################### main #####################################
# Description: Boucle principal du jeu
# ParamÃ¨tres: Aucun
# Retour: Aucun
################################################################################

main:

# Initialisation du jeu

jal resetAffichage
jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4

# Boucle de jeu

mainloop:

jal getInputVal
move $a0 $v0
jal majDirection
jal updateGameStatus
jal conditionFinJeu
bnez $v0 gameOver
jal printGame
li $a0 500
jal sleepMillisec
j mainloop

gameOver:
jal affichageFinJeu
li $v0 10
syscall

################################################################################
#                                Partie Projet                                 #
################################################################################

# Ã€ vous de jouer !

.data

# affichage du score
score : .asciiz " Votre score est : "
message : .asciiz "\n Peut mieux faire!"

tailleGrille:  .word 16        # Nombre de case du jeu dans une dimension.

# La tÃªte du serpent se trouve Ã  (snakePosX[0], snakePosY[0]) et la queue Ã 
# (snakePosX[tailleSnake - 1], snakePosY[tailleSnake - 1])
tailleSnake:   .word 2        # Taille actuelle du serpent.
snakePosX:     .word 0 : 1024  # CoordonnÃ©es X du serpent ordonnÃ© de la tÃªte Ã  la queue.
snakePosY:     .word 0 : 1024  # CoordonnÃ©es Y du serpent ordonnÃ© de la t.

# Les directions sont reprÃ©sentÃ©s sous forme d'entier allant de 0 Ã  3:
snakeDir:      .word 1         # Direction du serpent: 0 (haut), 1 (droite)
                               #                       2 (bas), 3 (gauche)
numObstacles:  .word 0         # Nombre actuel d'obstacle prÃ©sent dans le jeu.
obstaclesPosX: .word 0 : 1024  # CoordonnÃ©es X des obstacles
obstaclesPosY: .word 0 : 1024  # CoordonnÃ©es Y des obstacles
candy:         .word 0, 0      # Position du bonbon (X,Y)
scoreJeu:      .word 0         # Score obtenu par le joueur

.text

################################# majDirection #################################
# ParamÃ¨tres: $a0 La nouvelle position demandÃ©e par l'utilisateur. La valeur
#                 Ã©tant le retour de la fonction getInputVal.
# Retour: Aucun
# Effet de bord: La direction du serpent Ã  Ã©tÃ© mise Ã  jour.
# Post-condition: La valeur du serpent reste intacte si une commande illÃ©gale
#                 est demandÃ©e, i.e. le serpent ne peut pas faire de demi-tour
#                 en un unique tour de jeu. Cela s'apparente Ã  du cannibalisme
#                 et Ã  Ã©tÃ© proscrit par la loi dans les sociÃ©tÃ©s reptiliennes.
################################################################################

majDirection:
subu $sp $sp 16
sw $t1 12($sp)
sw $t2 8($sp)
sw $a1 4($sp)
sw $ra ($sp)

# En haut, ... en bas, ... Ã  gauche, ... Ã  droite, ... ces soirÃ©es lÃ  ... 

# Teste si le dÃ©placement entrÃ© est illÃ©gale
lw $t0 snakeDir
lw $t1 tailleSnake
subi $t1 $t1 1
li $t2 1

beq $t1 $t2 Mouvement 	    # Si la taille du serpent est de 1, le dÃ©placement ne peut pas Ãªtre illÃ©gale

li $t1 1		    # sinon on se dÃ©place dans une fonction oÃ¹ le demi-tour n'est pas possible (dÃ©terminÃ©e par la valeur de snakeDir)
beq $t0 $t1 testMouvementG
li $t1 3
beq $t0 $t1 testMouvementD
li $t1 0
beq $t0 $t1 testMouvementB
li $t1 2
beq $t0 $t1 testMouvementH

testMouvementG:
li $t1 1
beq $a0 $t1 droite
li $t1 0 
beq $a0 $t1 haut
li $t1 2
beq $a0 $t1 bas
li $t1 3 
beq $a0 $t1 findirect
j findirect

testMouvementD:
li $t1 1
beq $a0 $t1 findirect
li $t1 0 
beq $a0 $t1 haut
li $t1 2
beq $a0 $t1 bas
li $t1 3 
beq $a0 $t1 gauche
j findirect

testMouvementB:
li $t1 1
beq $a0 $t1 droite
li $t1 0 
beq $a0 $t1 haut
li $t1 2
beq $a0 $t1 findirect
li $t1 3 
beq $a0 $t1 gauche
j findirect

testMouvementH:
li $t1 1
beq $a0 $t1 droite
li $t1 0 
beq $a0 $t1 findirect
li $t1 2
beq $a0 $t1 bas
li $t1 3 
beq $a0 $t1 gauche
j findirect

Mouvement:
li $t1 1
beq $a0 $t1 droite
li $t1 0 
beq $a0 $t1 haut
li $t1 2
beq $a0 $t1 bas
li $t1 3 
beq $a0 $t1 gauche
j findirect


haut : 
la $t2 snakeDir
move $a1 $a0
sw $a1 0($t2)
j findirect 

droite : 
la $t2 snakeDir
move $a1 $a0
sw $a1 0($t2)
j findirect

bas : 
la $t2 snakeDir
move $a1 $a0
sw $a1 0($t2)
j findirect 

gauche : 
la $t2 snakeDir
move $a1 $a0
sw $a1 0($t2)
j findirect

findirect : 

lw $ra 0($sp)
lw $a1 4($sp)
lw $t2 8($sp)
lw $t1 12($sp)
addu $sp $sp 16
jr $ra

############################### updateGameStatus ###############################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: L'Ã©tat du jeu est mis Ã  jour d'un pas de temps. Il faut donc :
#                  - Faire bouger le serpent
#                  - Tester si le serpent Ã  manger le bonbon
#                    - Si oui dÃ©placer le bonbon et ajouter un nouvel obstacle
################################################################################

updateGameStatus:
# jal hiddenCheatFunctionDoingEverythingTheProjectDemandsWithoutHavingToWorkOnIt
subu $sp $sp 32
sw $s0 28($sp)
sw $s1 24($sp)
sw $t0 20($sp)
sw $t2 16($sp)
sw $t1 12($sp)
sw $t3 8($sp)
sw $t4 4($sp)
sw $ra ($sp)



evolue2: 

lw $t2 snakeDir
li $t1 1
beq $t2 $t1 RightMove
li $t1 0
beq $t2 $t1 UpMove
li $t1 2
beq $t2 $t1 DownMove
li $t1 3
beq $t2 $t1 LeftMove


RightMove:
lw $t1 snakePosY
addi $t4 $t1 1
lw $t2 candy + 4
beq $t2 $t4 test
sw $t4 snakePosY
J Decalage
test: 
lw $t3 candy
lw $t0 snakePosX
beq $t3 $t0 test2 
sw $t4 snakePosY
J Decalage
test2: 

sw $t1 snakePosY + 4
sw $t0 snakePosX + 4
sw $t3 snakePosX 
sw $t4 snakePosY


la $t3 tailleSnake

lw $t4 0($t3)
addi $t4 $t4 1
sw $t4 0($t3)

jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4

nouveauObstacle:
jal newRandomObjectPosition

la $t2 obstaclesPosX	# on charge l'adresse du premier obstacle
la $t3 obstaclesPosY


lw $t6 numObstacles 

mulu $t4 $t6 4  # on calcule l'adresse du nouveau obstacle
add $t4 $t4 $t2

mulu $t5 $t6 4 # on calcule l'adresse du nouveau obstacle
add $t5 $t5 $t3 

move $t0 $v0
move $t1 $v1
sw $t0 0($t4) # on sauvegarde les valeurs alÃ©atoires donnÃ©es par la fonction newRandomObjectPosition dans l'adresse du nouveau obstacle
sw $t1 0($t5)

#incrÃ©mentation du nombre d'obstacles
addi $t6 $t6 1
sw $t6 numObstacles

J Decalage




UpMove:
lw $t1 snakePosX
subi $t4 $t1 1
lw $t2 candy
beq $t2 $t4 test3
sw $t4 snakePosX
J Decalage
test3: 
lw $t3 candy + 4
lw $t0 snakePosY
beq $t3 $t0 test4
sw $t4 snakePosX
J Decalage
test4: 

sw $t1 snakePosX+ 4
sw $t0 snakePosY + 4
sw $t3 snakePosY
sw $t4 snakePosX

la $t3 tailleSnake

lw $t4 0($t3)
addi $t4 $t4 1
sw $t4 0($t3)

jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4


nouveauObstacle2:
jal newRandomObjectPosition

la $t2 obstaclesPosX	# on charge l'adresse du premier obstacle
la $t3 obstaclesPosY


lw $t6 numObstacles 

mulu $t4 $t6 4  # on calcule l'adresse du nouveau obstacle
add $t4 $t4 $t2

mulu $t5 $t6 4 # on calcule l'adresse du nouveau obstacle
add $t5 $t5 $t3 

move $t0 $v0
move $t1 $v1
sw $t0 0($t4) # on sauvegarde les valeurs alÃ©atoires donnÃ©es par la fonction newRandomObjectPosition dans l'adresse du nouveau obstacle
sw $t1 0($t5)

#incrÃ©mentation du nombre d'obstacles
addi $t6 $t6 1
sw $t6 numObstacles


J Decalage

DownMove:
lw $t1 snakePosX
addi $t4 $t1 1
lw $t2 candy
beq $t2 $t4 test5
sw $t4 snakePosX
J Decalage
test5: 
lw $t3 candy + 4
lw $t0 snakePosY
beq $t3 $t0 test6
sw $t4 snakePosX

J Decalage
test6: 

sw $t1 snakePosX + 4
sw $t0 snakePosY + 4
sw $t3 snakePosY
sw $t4 snakePosX

la $t3 tailleSnake

lw $t4 0($t3)
addi $t4 $t4 1
sw $t4 0($t3)

jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4



nouveauObstacle3:
jal newRandomObjectPosition

la $t2 obstaclesPosX	# on charge l'adresse du premier obstacle
la $t3 obstaclesPosY


lw $t6 numObstacles 

mulu $t4 $t6 4  # on calcule l'adresse du nouveau obstacle
add $t4 $t4 $t2

mulu $t5 $t6 4 # on calcule l'adresse du nouveau obstacle
add $t5 $t5 $t3 

move $t0 $v0
move $t1 $v1
sw $t0 0($t4) # on sauvegarde les valeurs alÃ©atoires donnÃ©es par la fonction newRandomObjectPosition dans l'adresse du nouveau obstacle
sw $t1 0($t5)

#incrÃ©mentation du nombre d'obstacles
addi $t6 $t6 1
sw $t6 numObstacles



J Decalage

LeftMove:

lw $t1 snakePosY
subi $t4 $t1 1
lw $t2 candy + 4
beq $t2 $t4 test7
sw $t4 snakePosY
J Decalage
test7: 
lw $t3 candy
lw $t0 snakePosX
beq $t3 $t0 test8
sw $t4 snakePosY
J Decalage
test8: 

sw $t1 snakePosY + 4
sw $t0 snakePosX + 4
sw $t3 snakePosX
sw $t4 snakePosY

la $t3 tailleSnake

lw $t4 0($t3)
addi $t4 $t4 1
sw $t4 0($t3)

jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4


nouveauObstacle4:
jal newRandomObjectPosition

la $t2 obstaclesPosX	# on charge l'adresse du premier obstacle
la $t3 obstaclesPosY


lw $t6 numObstacles 

mulu $t4 $t6 4  # on calcule l'adresse du nouveau obstacle
add $t4 $t4 $t2

mulu $t5 $t6 4 # on calcule l'adresse du nouveau obstacle
add $t5 $t5 $t3 

move $t0 $v0
move $t1 $v1
sw $t0 0($t4) # on sauvegarde les valeurs alÃ©atoires donnÃ©es par la fonction newRandomObjectPosition dans l'adresse du nouveau obstacle
sw $t1 0($t5)

#incrÃ©mentation du nombre d'obstacles
addi $t6 $t6 1
sw $t6 numObstacles


J Decalage









Decalage:
#prologue:

lw $t4 tailleSnake
la $t3 snakePosX
la $t2 snakePosY 

#corps de la fonction:
mulu $t0 $t4 4    
mulu $t1 $t4 4          # On calcul l'offset de l'entier suivant le tableau
addu $t0 $t3 $t0
addu $t1 $t2 $t1            # On calcul son adresse
loop_Decalage:
beq $t0 $t3 fin_Decalage    # Si on se trouve sur la premiÃƒÂ¨re case du tableau on ÃƒÂ  fini
lw $s1 -4($t0)              # Sinon on charge le contenu de la case prÃ©cÃ©dente
sw $s1 0($t0)  
lw $s1 -4($t1)
sw $s1 0($t1)
subu $t1 $t1 4             # Et on l'Ã©crit dans la case courante
subu $t0 $t0 4              # On se dÃ©cale sur la case prÃ©cÃ©dente
j loop_Decalage     


fin_Decalage: 
j finUpdateGame


TestMangeX:

lw $t3 candy
lw $t4 candy + 4 
lw $t2 snakePosX
lw $t1 snakePosY
beq $t2 $t3 TestMangeY
j finUpdateGame

TestMangeY:
beq $t1 $t4 CandyIsEaten
j finUpdateGame

CandyIsEaten: 

la $t3 tailleSnake
lw $t4 0($t3)
addi $t4 $t4 1
sw $t4 0($t3)

jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4


j finUpdateGame


finUpdateGame:
lw $ra ($sp)
lw $t4 4($sp)
lw $t3 8($sp)
lw $t1 12($sp)
lw $t2 16($sp)
lw $t0 20($sp)
lw $s1 24($sp)
lw $s0 32($sp) 
addu $sp $sp 32
jr $ra

############################### conditionFinJeu ################################
# ParamÃ¨tres: Aucun
# Retour: $v0 La valeur 0 si le jeu doit continuer ou toute autre valeur sinon.
################################################################################

conditionFinJeu:

# Aide: Remplacer cette instruction permet d'avancer dans le projet.

# Si la tÃªte du serpent rencontre un obstacle, le jeu s'arrÃªte
percuteObstacle:
lw $t0 tailleSnake
li $t1 1
beq $t0 $t1 Bordure

lw $t0 numObstacles	
li $t1 0
la $t2 obstaclesPosX	# On charge l'adresse du premier obstacle
la $t3 obstaclesPosY
lw $t4 snakePosX	# On charge le contenu de la tÃªte du serpent
lw $t5 snakePosY
lw $t6 tailleSnake


boucleNumObstacles:
beq $t0 $t1 Bordure	      # Quand on a testÃ© tous les obstacles, on se dÃ©place dans la prochaine fonction qui vÃ©rifie si le jeu s'arrÃªte
mulu $t6 $t1 4
add $t6 $t6 $t2
lw $t8 0($t6)
beq $t4 $t8 testObstaclesY    # Si l'obstacle est a la mÃªme position que la tete du serpent en X
addi $t1 $t1 1
j boucleNumObstacles

testObstaclesY:		      # on teste si l'obstacle est a la meme position que la tete du serpent en Y
mulu $t7 $t1 4
add $t7 $t7 $t3
lw $t9 0($t7)
beq $t5 $t9 gameOver	      # dans ce cas lÃ  le jeu s'arrÃªte
addi $t1 $t1 1
j boucleNumObstacles	      # sinon on retourne dans la boucle pour tester les prochains obstacles


# Si la tete du serpent depasse la bordure de la grille, le jeu s'arrÃªte
Bordure:		    
lw $t0 tailleGrille
beq $t4 -1 gameOver
beq $t4 $t0 gameOver

beq $t5 -1 gameOver
beq $t5 $t0 gameOver
j testMangeLuiMemeX


# Si la tÃªte du serpent touche sa queue, le jeu s'arrÃªte
testMangeLuiMemeX:
 
 
lw $t4 tailleSnake
subi $t4 $t4 1
ble $t4 2 finConditionJeu
la $t3 snakePosX
la $t2 snakePosY 

#corps de la fonction: A complÃ©ter
mulu $t0 $t4 4    
mulu $t1 $t4 4          # On calcul l'offset de l'entier suivant le tableau
addu $t0 $t3 $t0
addu $t1 $t2 $t1 
addu $t6 $t3 4

loop_Decalage2:
beq $t0 $t6  fin_Decalage2    # Si on se trouve sur la premiÃ¨re case du tableau on a fini
lw $s1 0($t3)
lw $s0 0($t0)              # Sinon on charge le contenu de la case prÃ©cÃ©dente
beq $s1 $s0 egalaX
subu $t1 $t1 4             # Et on l'Ã©crit dans la case courante
subu $t0 $t0 4   
j loop_Decalage2
egalaX:
lw $s1 0($t2)
lw $s0 0($t1)
beq $s1 $s0 gameOver
subu $t1 $t1 4
subu $t0 $t0 4
j loop_Decalage2

fin_Decalage2:
j finConditionJeu


finConditionJeu:
li $v0 0
jr $ra


############################### affichageFinJeu ################################
# ParamÃ¨tres: Aucun
# Retour: Aucun
# Effet de bord: Affiche le score du joueur dans le terminal suivi d'un petit
#                mot gentil (Exemple : Â«Quelle pitoyable prestation !Â»).
# Bonus: Afficher le score en surimpression du jeu.
################################################################################

affichageFinJeu:

la $a0 score
li $v0 4
syscall

lw $a0 tailleSnake # Le score commence Ã  1
subi $a0 $a0 1
li $v0 1
syscall

la $a0 message
li $v0 4
syscall

jr $ra
