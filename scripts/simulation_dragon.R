
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

wx = 51000000
basic_dodge = 560
basic_unarmed = 532
basic_parry = 537

dragonsteps = 420
dragonfights = seq(742,800,5) # seq(0,800,50) #seq(100,800,50)
attack_enableds = 713 #c(0,171,200,300,400,500,seq(714,800,10))# c(171,400,713,760) #c(171,309,344,408, 713, 760) #c(171,300,400,700,800)
special_parrys = c(0,171,414,seq(714,800,10))
#defined in the loop special_dodges


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
            for (special_parry in special_parrys) {
                for (special_dodge in c(0, 171, dragonstep, 769)) {
                    
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
#### hotfish
wx = 50700000
basic_dodge = 560
basic_unarmed = 532
basic_parry = 537

dragonstep = 420
dragonfight = 770
attack_enabled = 713
special_parry = 408
special_dodge  = 770
compute_expectation(print_or_not = 1)

#hand wuxing 30?
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

xlxy #wuxing about 20
wx = 8854672
# ??  ????ʶ?? (literate)                - ѧ???Ž?  192/      0??
# ???????????????????????????????????????ܣ?????  9 ??????????????????????????????????
# ??  ?̱??? (dagger)                    - ?????뻯  202/    107??
# ??  ?????Ṧ (dodge)                   - ???ն???  297/  18857??
# ??  ?ڹ??ķ? (force)                   - ??ɲ?  301/      0??
# ??  ?????淨 (fork)                    - ??ɲ?  301/      1??
# ??  ????ж��֮?? (parry)               - ????????  271/   4735??
# ??  ???? (spells)                      - ???ǻ???  220/   3493??
# ??  ???????? (stick)                   - ??ɲ?  301/      0??
# ??  ???????? (sword)                   - ?????ž?   29/    468??
# ??  ?˻?????֮?? (unarmed)             - һ????ʦ  260/   9052??
# ???????????????????????????????????⼼?ܣ????? 15 ??????????????????????????????????
# ??  ?????? (cuixin-zhang)              - ?????뻯  203/   8575??
# ??  ?��??ɷ? (dao)                     - ?????뻯  203/      0??
# ?????????ķ? (dragonforce)             - ??ɲ?  301/   2135??
# ?????粨ʮ???? (fengbo-cha)            - ????????  270/    613??
# ??????Ӱ???? (ghost-steps)             - ????????  270/    165??
# ??  ?һ??? (hellfire-whip)             - ?????似  180/      0??
# ??  ?????? (jinghun-zhang)             - ??֪һ??   47/      0??
# ?????ݹǵ? (kugu-blade)                - ????????   70/   1652??
# ??????ɥ?? (kusang-bang)               - һ????ʦ  269/      8??
# ????��?ǽ??? (liangyi-sword)           - ??Ȼ????  146/  19525??
# ??  ǧ?????? (qianjun-bang)            - һ????ʦ  269/    479??
# ?????̺???ͨ (seashentong)             - ????????  176/   1040??
# ??  ̫???ɷ? (taiyi)                   - ?????Ѿ?  111/      0??
# ??  ?????? (tonsillit)                 - ????????  150/      0??
# ??  ׷?꽣 (zhuihun-sword)             - ???���??   81/   1855??
# ??????????????????????????????????????????????????????????????????????????????????????????????

dygz # seems to have 10 wuxing only too
wx = 28739573
# ???ɴ??? (dengxian-dafa)                 - ??ɲ?  326/    0
# ?????Ṧ (dodge)                         - ???ն???  494/   11
# ???β??? (dragonfight)                   - ??ɲ?  326/  702
# ???????ķ? (dragonforce)                   - ??ɲ?  491/ 4455
# ???粨ʮ???? (fengbo-cha)                  - ??ɲ?  626/222751
# ?ڹ??ķ? (force)                         - ??ɲ?  512/238807
# ???һ??? (hellfire-whip)                   - ??ɲ?  312/ 1849
# ???ݹǵ? (kugu-blade)                      - ????????  176/ 4665
# ????ɥ?? (kusang-bang)                     - ??ɲ?  626/ 2751
# ??��?ǽ??? (liangyi-sword)                 - ??ɲ?  333/52439
# ????????ʽ (lingfu-steps)                  - ??ɲ?  626/ 9531
# ????ʶ?? (literate)                      - ѧ???Ž?  328/    0
# ????ж��֮?? (parry)                     - ??ɲ?  494/    5
# ǧ?????? (qianjun-bang)                  - ??ɲ?  626/   16
# ???̺???ͨ (seashentong)                   - ??ɲ?  340/    0
# ???? (spells)                            - ??��?ޱ?  362/35679
# ???????? (stick)                         - ??ɲ?  495/    0
# ̫???ɷ? (taiyi)                         - ????????  154/    0
# ?˻?????֮?? (unarmed)                   - ??ɲ?  326/  132
# ???? (yaofa)                             - ??Ȼ????  135/    0
# ??׷?꽣 (zhuihun-sword)                   - ??ɲ?  336/ 6149

faisceau
wx = 15292944
# ????????Ϊ??ʮ????????????Ϊ??ʮ?ߡ???????????Ϊ??ʮ????????????Ϊʮ??
# ???????? (baguazhou)                       - ??ɲ?  510/848850
# ?????Ṧ (dodge)                         - ???ն???  493/109502
# ???????ķ? (dragonforce)                   - ??ɲ?  517/45147
# ???粨ʮ???? (fengbo-cha)                  - ??ɲ?  470/155106
# ?ڹ??ķ? (force)                         - ??ɲ?  517/119989
# ??��?ǽ??? (liangyi-sword)                 - ??ɲ?  470/154587
# ??????ʽ (lingfu-steps)                  - ??ɲ?  488/10290
# ????ʶ?? (literate)                      - ѧ???Ž?  251/ 2125
# ????ж��֮?? (parry)                     - ??ɲ?  471/119339
# ??ǧ?????? (qianjun-bang)                  - ??ɲ?  471/154624
# ??ǧ?? (qianshou)                          -  ǧ ??    487/74157
# ???? (spells)                            - ??��?ޱ?  497/ 6730
# ?˻?????֮?? (unarmed)                   - ??ɲ?  480/72576
# ???? (yaofa)                             - ??????˫  246/ 5920


nyone # seems to have 10 wuxing too?
wx = 14605833
# ???????? (baguazhou)                       - ??ɲ?  954/ 3132
# ?????񽣷? (bainiao-jian)                  - ??ɲ?  470/184473
# ???ɴ??? (dengxian-dafa)                 - ????????  282/34691
# ?????Ṧ (dodge)                         - ???ն???  523/   73
# ???β??? (dragonfight)                   - ??ɲ?  499/218570
# ???????ķ? (dragonforce)                   - ??ɲ?  512/  392
# ???粨ʮ???? (fengbo-cha)                  - ??ɲ?  515/   86
# ?ڹ??ķ? (force)                         - ??ɲ?  523/    0
# ?????淨 (fork)                          - ??ɲ?  334/ 3716
# ��?ǽ??? (liangyi-sword)                 - ??ɲ?  466/119523
# ??????ʽ (lingfu-steps)                  - ??ɲ?  517/    0
# ????ʶ?? (literate)                      - ѧ???Ž?  369/ 6317
# ??????Ѫ?? (ningxie-force)               - ?ڰ??ء?  270/10290
# ????ж��֮?? (parry)                     - ??ɲ?  523/   63
# ǧ?????? (qianjun-bang)                  - ??ɲ?  518/ 6123
# ?̺???ͨ (seashentong)                   - ?????뻯  207/ 8200
# ???? (spells)                            - ??��?ޱ?  604/  988
# ???????? (stick)                         - ??ɲ?  419/    2
# ̫???ɷ? (taiyi)                         - ?????似  185/ 3032
# ?˻?????֮?? (unarmed)                   - ??ɲ?  518/    0
# ???? (yaofa)                             - ?????似  188/ 3112
##### nyfour
basic_dodge = 183
basic_unarmed = 541
basic_parry = 223
wx = 1824624

dragonstep = 1
dragonfight = 13
attack_enabled =  111
special_parry = 50
special_dodge  = 200

compute_expectation(print_or_not = 1)


# 八卦咒 (baguazhou)                       - 渐入佳境  105/    0
# □登仙大法 (dengxian-dafa)                 - 深不可测  998/    0
# 基本轻功 (dodge)                         - 移形换影  183/  184
# 龙形搏击 (dragonfight)                   - 初学乍练   13/    0
# □龙神心法 (dragonforce)                   - 神乎其技  194/33605
# □风波十二叉 (fengbo-cha)                  - 略知一二   51/    0
# 内功心法 (force)                         - 深不可测  230/    1
# □鬼影迷踪 (ghost-steps)                   - 心领神会  167/ 5624
# □烈火鞭 (hellfire-whip)                   - 出类拔萃  159/ 7552
# 哭丧棒 (kusang-bang)                     - 神乎其技  184/ 6840
# □两仪剑法 (liangyi-sword)                 - 渐入佳境  111/ 2610
# 读书识字 (literate)                      - 学贯古今  293/    0
# 拆招卸力之法 (parry)                     - 豁然贯通  223/    0
# □千钧棒法 (qianjun-bang)                  - 豁然贯通  223/    0
# □千手 (qianshou)                          -  六百手   201/   12
# 碧海神通 (seashentong)                   - 心领神会  174/30627
# 法术 (spells)                            - 负海担山  204/  445
# 基本棍法 (stick)                         - 初学乍练    2/    5
# 摄气诀 (tonsillit)                       - 出神入化  204/   32
# 扑击格斗之技 (unarmed)                   - 深不可测  541/15959
# □追魂剑 (zhuihun-sword)                   - 出类拔萃  162/ 3456

###### reference#####
#var path_from_fight_to_reset {#2 sw;#3 se;s}
#var path_from_reset_to_fight {n;#3 nw;#2 ne}

#var path_from_fight_to_eat {sw;sw;e}
#var path_from_eat_to_fight {w;ne;ne}

#var path_from_fight_to_master {ne}
#var path_from_master_to_fight {sw}
