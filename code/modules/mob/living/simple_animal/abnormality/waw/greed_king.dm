//This abnormality does like one thing. I hope no one gets to play as it.
/mob/living/simple_animal/hostile/abnormality/greed_king
	name = "King of Greed"
	desc = "A girl trapped in a magical crystal."
	icon = 'ModularTegustation/Teguicons/64x64.dmi'
	icon_state = "kog"
	icon_living = "kog"
	pixel_x = -16
	base_pixel_x = -16
	maxHealth = 3200
	health = 3200
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomps"
	faction = list("hostile")
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0, WHITE_DAMAGE = 0.5, BLACK_DAMAGE = 1.2, PALE_DAMAGE = 1.5)
	speak_emote = list("states")
	vision_range = 14
	aggro_vision_range = 20
	stat_attack = HARD_CRIT
	melee_damage_lower = 60	//Shouldn't really attack unless a player in controlling it, I guess.
	melee_damage_upper = 80
	can_breach = TRUE
	threat_level = WAW_LEVEL
	start_qliphoth = 1
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = list(25, 25, 50, 50, 55),
						ABNORMALITY_WORK_INSIGHT = 0,
						ABNORMALITY_WORK_ATTACHMENT = list(0, 0, 50, 50, 55),
						ABNORMALITY_WORK_REPRESSION = list(0, 0, 40, 40, 40)
						)
	work_damage_amount = 10
	work_damage_type = RED_DAMAGE
	//Some Variables cannibalized from helper
	var/charge_check_time = 1 SECONDS
	var/charge_check_cooldown
	var/charging = FALSE
	var/dash_num = 50	//Mostly a safeguard
	var/list/been_hit = list()
	var/busy = FALSE

	ego_list = list(
		/datum/ego_datum/weapon/goldrush,
		/datum/ego_datum/armor/goldrush
		)
	gift_type =  /datum/ego_gifts/goldrush



/mob/living/simple_animal/hostile/abnormality/greed_king/AttackingTarget()
	if(charging)
		return

/mob/living/simple_animal/hostile/abnormality/greed_king/Move()
	return FALSE

/mob/living/simple_animal/hostile/abnormality/greed_king/breach_effect(mob/living/carbon/human/user)
	..()
	icon = 'ModularTegustation/Teguicons/64x48.dmi'
	//Center it on a hallway
	pixel_y = -8
	base_pixel_y = -8

	teleport()	//Let's Spaghettioodle out of here

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/teleport()
	if(charging || busy)
		return

	//set busy, animate and teleport
	busy = TRUE
	var/turf/T = pick(GLOB.xeno_spawn)
	animate(src, alpha = 0, time = 5)
	SLEEP_CHECK_DEATH(5)
	animate(src, alpha = 255, time = 5)
	forceMove(T)

	//Clear lists
	been_hit = list()
	charge_check()
	if(!charging)
		SLEEP_CHECK_DEATH(5 SECONDS)
		busy = FALSE
		teleport()

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/charge_check()
	//targeting
	var/mob/living/carbon/human/target
	if(charging && !busy)
		return
	busy = TRUE
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in view(20, src))
		possible_targets += H
	if(!LAZYLEN(possible_targets))
		return
	if(!charging && !target)
		target = pick(possible_targets)
	//Start charge
	SLEEP_CHECK_DEATH(2 SECONDS)
	if(ishuman(target)&& !charging)
		var/dir_to_target = get_cardinal_dir(get_turf(src), get_turf(target))
		if(dir_to_target in list(NORTH, SOUTH, WEST, EAST))
			charge(dir_to_target, 0, target)
			return

/mob/living/simple_animal/hostile/abnormality/greed_king/proc/charge(move_dir, times_ran, target)
	setDir(move_dir)
	var/stop_charge = FALSE
	if(times_ran >= dash_num)
		stop_charge = TRUE
	var/turf/T = get_step(get_turf(src), move_dir)
	if(!T)
		charging = FALSE
		return
	if(T.density)
		stop_charge = TRUE
	for(var/obj/structure/window/W in T.contents)
		W.obj_destruction()
	for(var/obj/machinery/door/D in T.contents)
		if(D.density)
			stop_charge = TRUE
	for(var/mob/living/simple_animal/hostile/abnormality/D in T.contents)	//This caused issues earlier
		if(D.density)
			stop_charge = TRUE

	//Stop charging
	if(stop_charge)
		SLEEP_CHECK_DEATH(7 SECONDS)
		charging = FALSE
		busy = FALSE
		teleport()
		return
	forceMove(T)
	charging = TRUE

	//Hiteffect stuff
	for(var/mob/living/L in orange(1, T))
		if(L in been_hit || L == src)
			continue
		been_hit+=L
		visible_message("<span class='boldwarning'>[src] crunches [L]!</span>")
		to_chat(L, "<span class='userdanger'>[src] rends you with it's teeth!</span>")
		playsound(L, attack_sound, 75, 1)
		var/turf/LT = get_turf(L)
		new /obj/effect/temp_visual/kinetic_blast(LT)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.apply_damage(800, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
		else
			L.adjustRedLoss(80)
			if(L.stat != DEAD)	//If they're not dead and not a person, stop charge.
				stop_charge = TRUE
		if(L.stat >= HARD_CRIT)
			L.gib()
			continue

	playsound(src,'sound/effects/bamf.ogg', 70, TRUE, 20)
	for(var/turf/open/R in range(1, src))
		new /obj/effect/temp_visual/small_smoke/halfsecond(R)
	addtimer(CALLBACK(src, .proc/charge, move_dir, (times_ran + 1)), 2)


/* Work effects */
/mob/living/simple_animal/hostile/abnormality/greed_king/neutral_effect(mob/living/carbon/human/user, work_type, pe)
	if(prob(40))
		datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/greed_king/failure_effect(mob/living/carbon/human/user, work_type, pe)
	if(prob(80))
		datum_reference.qliphoth_change(-1)
	return



