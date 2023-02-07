// Coded by Nutterbutter, sprite by InsightfulParasite, abnormality submitted by Secretary Succubus.
/mob/living/simple_animal/hostile/abnormality/eris
	name = "Eris"
	desc = "A tall woman of stark complexion, with a distinctly predatory air."
	icon = 'ModularTegustation/Teguicons/48x48.dmi'
	icon_state = "eris_contained"
	icon_living = "eris_contained"
	del_on_death = TRUE

	maxHealth = 600
	health = 600
	move_to_delay = 4
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 1.2, WHITE_DAMAGE = 0.8, BLACK_DAMAGE = 0.5, PALE_DAMAGE = 2)
	melee_damage_lower = 6
	melee_damage_upper = 10 // Attacking isn't really her main deal while she's out, but she should be able to LIGHTLY threaten people other than her main target.
	melee_damage_type = BLACK_DAMAGE
	armortype = BLACK_DAMAGE
	stat_attack = HARD_CRIT
	can_breach = TRUE

	work_damage_amount = 5
	work_damage_type = BLACK_DAMAGE
	start_qliphoth = 2
	work_chances = list(
		ABNORMALITY_WORK_INSTINCT = 10, // Her main want and need is... you know. Not quite material.
		ABNORMALITY_WORK_INSIGHT = 60, // Basically just making it nice.
		ABNORMALITY_WORK_ATTACHMENT = 70, // Now we're cooking.
		ABNORMALITY_WORK_REPRESSION = 10, // If it were really just violence, this would be high, but...
		"####" = 50, // The sex work. It is sex.
		"Hire" = 100 // she follows you out of the cell, of course she's happy.
	)

	var/beloved = ""

/mob/living/simple_animal/hostile/abnormality/eris/WorkChance(mob/living/carbon/human/user, chance)
	var/area/A = get_area(src)
	for(var/obj/structure/bed/comfytown in A.contents) // gee why could she possibly like you having a bed
		chance += 20
		break
	return chance

/mob/living/simple_animal/hostile/abnormality/eris/proc/TargetSelect() // jacked from Silent Girl, gives Eris a random target.
	for(var/mob/living/carbon/human/potential in GLOB.player_list)
		if(potential.z != src.z)
			continue
		if(potential.stat >= HARD_CRIT)
			continue
		if(potential.sanity_lost)
			continue
		return potential

// Eris essentially does a "reverse patrol". If the target is out of sight, she jumps to the department closest to her target before approaching.
/mob/living/simple_animal/hostile/abnormality/eris/proc/DepartmentApproach(mob/living/carbon/human/schmeat)
	var/turf/target_center
	var/smallest_distance = 100
	for(var/turf/pos_targ in GLOB.department_centers)
		var/possible_center_distance = get_dist(schmeat, pos_targ)
		if(possible_center_distance < smallest_distance)
			smallest_distance = possible_center_distance
			target_center = pos_targ
	if(!target_center) // Holy shit, your target doesn't have a department center within a hundred tiles??
		target_center = get_turf(schmeat) // Fuck it. Just jump on top of them. I'm sure this won't break anything.
	animate(src, alpha = 0, time = 5)
	addtimer(CALLBACK(src, .proc/DepartmentArrive, schmeat, target_center), 5)

/mob/living/simple_animal/hostile/abnormality/eris/proc/DepartmentArrive(mob/living/carbon/human/schmeat, turf/teleport_destination)
	animate(src, alpha = 255, time = 5)
	forceMove(teleport_destination)
	var/turf/target_location = get_turf(schmeat)
	PathToTarget(schmeat, target_location)

/mob/living/simple_animal/hostile/abnormality/eris/proc/PathToTarget(mob/living/carbon/human/schmeat, turf/target_location)
	var/list/target_path = list()
	target_path = get_path_to(src, target_location, /turf/proc/Distance_cardinal, 0, 200)
	PathWalk(target_path, target_location)

/mob/living/simple_animal/hostile/abnormality/eris/proc/PathWalk(list/target_path, turf/dest) // Jacked from patrol.
	if(client || target || status_flags & GODMODE)
		return FALSE
	if(!dest || !target_path || !target_path.len) //A-star failed or a path/destination was not set.
		return FALSE
	stop_automated_movement = 1
	var/turf/last_node = get_turf(target_path[target_path.len]) //This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(src) == dest) //We have arrived, no need to move again.
		return TRUE
	else if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		patrol_reset()
		return FALSE
	if(patrol_tries < 5)
		patrol_step(dest)
	else
		patrol_reset()
		return FALSE
	addtimer(CALLBACK(src, .proc/patrol_move, dest), move_to_delay)
	return TRUE

/mob/living/simple_animal/hostile/abnormality/eris/proc/PathToHome()
	return TRUE
