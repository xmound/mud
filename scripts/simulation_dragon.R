
##### functions #####

eff_skill_level <- function(level, usage) {
    
    #just ignore the following stuff and return level..
    return(level)
#     if (usage == 'attack') {
#         return(level)
#     } else if (usage == 'defense') {
#         if (level > 300) {
#             level = level + 35 + (level-300)*2/5
#         } else if ( level > 200 ) {
#             level = level + 15 + (level-200)/5
#         } else if ( level > 100) {
#             level = level + 5 + (level-100)/10
#         } else {
#             level = level + level / 20
#         }
#         return(level)
#     } 
}

skill_power <- function (enabled_skill_level, usage, case) {    
    temp = eff_skill_level(enabled_skill_level, usage)
    adjustment = 0 # powerups, wuxue, etc
    level = adjustment + temp

    if (level == 0) {
        power = wx / 2
    } else {
        power = level * level * level / 10
        power = power + wx
    }
    
    if ( case == 'unarmed_attack_weapon') {#unarmed attacking weapon, then parry needs to get doubled
        power = power*2
    }
    
    if (case == 'weapon_attack_unarmed') {
        power = 0
    }
    
    return(power)
}

mod_adjustment <- function(sp, case, mod_val) {
    if( sp > 1000000 ) {
        sp = sp / 100 * (100 + mod_val)
    } else {
        sp = (100 + mod_val) * sp / 100
    }
    if (sp < 0) {
        sp = 0
    }
    return(sp)
}

compute_expectation <- function(print_or_not) {
    dragon_ap = skill_power( basic_unarmed / 2 + dragonfight + 20, "attack", "ap")
    dragon_ap_adjusted = dragon_ap
    
    dragon_dp = skill_power( basic_dodge/2 + dragonstep + 20, "defense", "dp") # player hit --> dragon dodge
    dragon_dp_adjusted = mod_adjustment(dragon_dp, "dodge", my_enable_dodge_mod)
        
    dragon_pp = skill_power( basic_unarmed / 2 + dragonfight + 20, "defense", "weapon_attack_unarmed")
    dragon_pp_adjusted = mod_adjustment(dragon_pp, "parry", my_enable_parry_mod)
    
    my_ap = skill_power( attack_enabled, "attack", "ap")
    my_ap_adjusted = my_ap
    
    my_dp = skill_power( basic_dodge / 2 + special_dodge, "defense", "dp")
    my_dp_adjusted = mod_adjustment( my_dp, "dodge", dragon_enable_dodge_mod) #dragon hit --> player dodge
    
    my_pp = skill_power( basic_parry / 2 + special_parry, "defense", "unarmed_attack_weapon")
    my_pp_adjusted = mod_adjustment(my_pp, "parry", dragon_enable_parry_mod)
    
    if (my_ap < dragon_dp || dragon_ap > min(my_dp, my_pp)) {
        my_dodge_prob <- min (1, my_dp_adjusted/(dragon_ap + my_dp))
        my_dodge_expectation <- ifelse(dragon_ap < my_dp, 0 , my_dodge_prob)
        
        my_parry_prob <- (1-my_dodge_prob) * min(1, my_pp_adjusted/(dragon_ap + my_pp))   
        my_parry_expectation <- ifelse(dragon_ap < my_pp, 0, my_parry_prob)
        
        dragon_dodge_prob <- min(1, dragon_dp_adjusted / (dragon_dp + my_ap))
        dragon_parry_prob <- min(1, dragon_pp_adjusted / (dragon_pp + my_ap))
        
        my_hit_prob <-  ( 1- dragon_dodge_prob) * ( 1 - dragon_parry_prob)
        my_hit_expectation <- ifelse(my_ap > dragon_dp, 0, my_hit_prob)
        
        expectation <- 4*(my_dodge_expectation + my_parry_expectation) + my_hit_expectation
        r <- c(dragonstep, dragonfight, attack_enabled, special_parry, special_dodge, expectation)
        
    } else {
        r <- c(0,0,0,0,0,0)
        my_dodge_prob = 0
        my_parry_prob = 0
        my_hit_prob = 0
        expectation = 0
    }
    
    if(print_or_not == 1) {
        print(paste("dragonstep" , dragonstep))
        print(paste("dragonfight" , dragonfight))
        print(paste("attack_enabled" , attack_enabled))
        print(paste("special_parry" , special_parry))
        print(paste("special_dodge", special_dodge))
        
        
        print(paste("my_ap" , my_ap))
        print(paste("dragon_dp" , dragon_dp))
        print(paste("dragon_pp" , dragon_pp))
        
        print(paste("dragon_ap" , dragon_ap))
        print(paste("my_dp" , my_dp))
        print(paste("my_pp" , my_pp))
        
        print(paste("my_dodge_prob", my_dodge_prob))
        print(paste("my_parry_prob", my_parry_prob))
        print(paste("my_hit_prob",my_hit_prob))
        
        print(paste("expectation",expectation))
        print("dragonstep|dragonfight|attack enable|special parry|special dodge")
        print(r)
    }
    return(r)
}



######################## define simulation values ##################
# mod_values: 
# #liangyi
# my_enable_dodge_mod = min(c(-20,-10, 10, 0)) #liangyi-sword, how much dodge does it affect target's dp, I would want a minimum dragon_dp,i.e. my maximum impact
# my_enable_parry_mod = min(c(-20,-10, 10, 0))  #liangyi-sword, similarly, I wan the maximum parry impact because that affects dragon's parry chance

# skyriver-rake
my_enable_dodge_mod = mean(c(-45,-15, -20, -40, -35, -25, -25, -35)) 
my_enable_parry_mod = mean(c(-15, -10, -20, -5, -25, -10, -25, -15)) 

#dragonfight
dragon_enable_dodge_mod = mean(c(10, -10, 10, -10, 0, 10)) # dragonfight, dragon's max impact to my dp
dragon_enable_parry_mod = mean(c(-10, -20, -20,-10,-20,-30)) #dragonfight, dragon's max impact to my pp


# wx = 51000000
# basic_dodge = 560
# basic_unarmed = 532
# basic_parry = 537
# 
# dragonsteps = 420
# dragonfights = seq(742,800,5) # seq(0,800,50) #seq(100,800,50)
# attack_enableds = 713 #c(0,171,200,300,400,500,seq(714,800,10))# c(171,400,713,760) #c(171,309,344,408, 713, 760) #c(171,300,400,700,800)
# special_parrys = c(0,171,414,seq(714,800,10))
#defined in the loop special_dodges

# #szxszh
# wx = 11852362
# basic_dodge = 413
# basic_unarmed = 319
# basic_parry = 413
# 
# dragonsteps = 290#seq(0,400,5)
# dragonfights = 319#seq(0,400,5) # seq(0,800,50) #seq(100,800,50)
# attack_enableds = 463 #seq(0,463,10)#seq(0,400,10) #c(0,171,200,300,400,500,seq(714,800,10))# c(171,400,713,760) #c(171,309,344,408, 713, 760) #c(171,300,400,700,800)
# special_parrys = c(0)


wx = 14615418
basic_dodge = 523
basic_unarmed = 518
basic_parry = 523

dragonsteps = 0
dragonfights = 499
attack_enableds = 466
special_parrys = 0
special_dodges = c(0)


######################## start simulation ##################

max_expectation <- 0
max_expectation_2nd <- 0
max_expectation_3rd <- 0
max_expectation_4th <- 0
max_par_4th <- rep(0,6)
max_par_3rd <- rep(0,6)
max_par_2nd <- rep(0,6)
max_pars <- rep(0,6)

i <- 0

#start computation
for ( dragonstep in dragonsteps) {
    for ( dragonfight in dragonfights) {
        for (attack_enabled in attack_enableds) {
            for (special_parry in c(special_parrys)) {
                for (special_dodge in c(special_dodges, dragonstep)) {
                    
                    if (i %% 1000 == 0) print(i)
                    i = i+1
                    
                    r <- compute_expectation(print_or_not = 0)
                    expectation <- r[6]
                    pars <- r[1:6]
                    if (expectation > max_expectation) {
                        
                        max_expectation_4th <- max_expectation_3rd
                        max_expectation_3rd <- max_expectation_2nd
                        max_expectation_2nd <- max_expectation
                        max_expectation <- expectation
                        
                        
                        max_par_4th <- max_par_3rd
                        max_par_3rd <- max_par_2nd
                        max_par_2nd <- max_pars
                        max_pars <- pars 
                    } 
               } 
            }
        }
    }
}

print('dragonstep | dragonfight | attack enable | special parry | special dodge')
max_pars
max_par_2nd
max_par_3rd
max_par_4th


###### max situation #######
par = max_pars
dragonstep = par[1]
dragonfight = par[2]
attack_enabled = par[3]
special_parry = par[4]
special_dodge = par[5]

compute_expectation(print_or_not = 1)

########################### tests  ####################
wx = 5120000
basic_dodge = 561
basic_unarmed = 533
basic_parry = 538

dragonstep = 421
dragonfight = 771
attack_enabled = 714
special_parry = 420 #409
special_dodge  = 771
compute_expectation(print_or_not = 1)

wx = 12000000
#wx = 13000000
basic_dodge = 413
basic_unarmed = 342
basic_parry = 413

dragonstep = 290#seq(0,400,5)
dragonfight = 342#seq(0,400,5) # seq(0,800,50) #seq(100,800,50)
attack_enabled = 410 #c(0,171,200,300,400,500,seq(714,800,10))# c(171,400,713,760) #c(171,309,344,408, 713, 760) #c(171,300,400,700,800)
special_parry = 0
special_dodge  = 290
compute_expectation(print_or_not = 1)

#### wuxing 30?
wx = 8781331
basic_dodge = 417
basic_unarmed = 325
basic_parry = 411

dragonstep = 410
dragonfight = 410
attack_enabled = 292 + 274/2
special_parry = 0
special_dodge  = 0

compute_expectation(print_or_not = 1)
