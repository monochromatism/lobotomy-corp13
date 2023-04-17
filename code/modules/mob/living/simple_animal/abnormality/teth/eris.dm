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
	melee_damage_lower = 2
	melee_damage_upper = 6 // Her "attack" does very, very light damage, since she gets her damage elsewhere.
	melee_damage_type = BLACK_DAMAGE
	armortype = BLACK_DAMAGE
	stat_attack = HARD_CRIT
	can_breach = TRUE
	move_resist = MOVE_FORCE_VERY_STRONG // Don't want anyone else to be able to drag her prey away.
	pull_force = MOVE_FORCE_VERY_STRONG

	work_damage_amount = 5
	work_damage_type = BLACK_DAMAGE
	start_qliphoth = 2
	work_chances = list(
		ABNORMALITY_WORK_INSTINCT = 10, // Her main want and need is... you know. Not quite material.
		ABNORMALITY_WORK_INSIGHT = 60, // Basically just making it nice.
		ABNORMALITY_WORK_ATTACHMENT = 70, // Now we're cooking.
		ABNORMALITY_WORK_REPRESSION = 10, // If it were really just violence, this would be high, but...
		"Hire" = 100 // she follows you out of the cell, of course she's happy.
	)

	var/bind_mult = 0 // Multiplier of binding
	var/base_bind_chance = 3 // Base chance for someone to be bound
	var/mob/living/carbon/human/last_target
	var/mob/living/carbon/human/beloved // Storage variable for her friendlybreach target.
	var/dragging_target = FALSE // Does she currently have someone in her clutches?
	var/mock_PE = 100
	var/follow_teleport_timer = 0
	var/turf/return_here
	var/mock_work_default_length = 48

/mob/living/simple_animal/hostile/abnormality/eris/Initialize()
	..()
	return_here = get_turf(src)

/mob/living/simple_animal/hostile/abnormality/eris/WorkChance(mob/living/carbon/human/user, chance)
	var/area/A = get_area(src)
	var/obj/structure/bed/comfytown = locate() in A.contents
	if(comfytown)
		chance += 20
	return chance

/mob/living/simple_animal/hostile/abnormality/eris/PostWorkEffect(mob/living/carbon/human/user, work_type, pe, work_time, canceled)
	if(work_type == "Hire")
		beloved = user
		fear_level = ZAYIN_LEVEL
		BreachEffect(user)
	return

/mob/living/simple_animal/hostile/abnormality/eris/BreachEffect(mob/living/carbon/human/user)
	if(beloved)
		datum_reference.stored_boxes -= 5
	mock_PE = min(100, datum_reference.stored_boxes)
	return ..()

/mob/living/simple_animal/hostile/abnormality/eris/Life()
	if(mock_PE > 0)
		mock_PE -= 1
		datum_reference.stored_boxes -= 1
		for(var/mob/living/carbon/human/H in orange(3, get_turf(src)))
			H.adjustSanityLoss(-1)
	if(beloved && follow_teleport_timer <= world.time)
		follow_teleport_timer = world.time + 5 SECONDS
		if(!can_see(src, beloved, vision_range))
			FollowBeloved()
	if(beloved.stat == DEAD)
		beloved = FALSE
	return ..()

/mob/living/simple_animal/hostile/abnormality/eris/FindTarget()
	if((mock_PE > 0 && !beloved) || dragging_target)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/abnormality/eris/Found(atom/A)
	if(beloved)
		A = beloved
	return

/mob/living/simple_animal/hostile/abnormality/eris/AttackingTarget(atom/attacked_target)
	if(mock_PE > 0) // Here's the trick: While she's hired, she uses hostile AI but exclusively targets her beloved, with disabled attacks. Constant chasing!
		return
	if(ishuman(target))
		last_target = BindTarget(target, last_target)
	return ..()

/mob/living/simple_animal/hostile/abnormality/eris/proc/FollowBeloved() // Warp somewhere adjacent to the one you're following. Only happens when out of sight.
	var/list/potential_warps = list()
	for(var/turf/T in orange(1, get_turf(beloved)))
		if(T.is_blocked_turf(exclude_mobs = TRUE))
			continue
		potential_warps |= T
	var/turf/destination = pick(potential_warps)
	forceMove(destination)
	GiveTarget(beloved)

/mob/living/simple_animal/hostile/abnormality/eris/proc/BindTarget(mob/living/carbon/human/current_target, mob/living/carbon/human/previous_target)
	if(current_target != previous_target)
		bind_mult = 0
	if(prob(bind_mult * base_bind_chance))
		current_target.visible_message("<span class='warning'>[src] ensnares [beloved]!</span>","<span class='warning'>[src]'s tail has you!</span>")
		beloved = current_target
		LoseTarget()
		DragTarget()
		current_binding = 0
		return FALSE
	bind_mult +=
	current_target.visible_message("<span class='warning'>[src] trips up [beloved]!</span>","<span class='warning'>[src]'s tail lashes at your ankles!</span>")
	return current_target

/mob/living/simple_animal/hostile/abnormality/eris/proc/DragTarget()
	beloved.move_resist = MOVE_FORCE_VERY_STRONG // Don't want anyone else to be able to drag her prey away.
	beloved.pull_force = MOVE_FORCE_VERY_STRONG
	beloved.SetImmobilized(5)
	dragging_target = TRUE
	start_pulling(beloved)
	patrol_to(return_here)

/mob/living/simple_animal/hostile/abnormality/eris/patrol_reset()
	..()
	if(dragging_target)
		beloved.forceMove(return_here)
		src.forceMove(return_here)
		MockWork(beloved)
	return

/mob/living/simple_animal/hostile/abnormality/eris/Moved()
	..()
	if(!beloved)
		dragging_target = FALSE
	if(dragging_target)
		beloved.SetImmobilized(5)
		if(beloved.pulledby != src) // If you've somehow had your beloved taken from you...
			beloved.move_resist = MOVE_FORCE_NORMAL
			beloved.pull_force = MOVE_FORCE_NORMAL
			beloved = null
			dragging_target = FALSE
		for(var/mob/living/carbon/human/too_close in orange(2, src))
			if(too_close == beloved)
				continue
			too_close.apply_damage(work_damage_amount, work_damage_type, null, too_close.run_armor_check(null, work_damage_type), spread_damage = TRUE)
		if(get_turf(src) == return_here)
			var/intended_work_length = mock_work_default_length
			if(HAS_TRAIT(beloved, TRAIT_WORK_FORBIDDEN))
				intended_work_length /= 2
			MockWork(beloved, intended_work_length)

/mob/living/simple_animal/hostile/abnormality/eris/proc/MockWork(mob/living/carbon/human/schmeat, work_length = mock_work_default_length)
	beloved.move_resist = MOVE_FORCE_NORMAL
	beloved.pull_force = MOVE_FORCE_NORMAL
	beloved = null
	dragging_target = FALSE
	ForceReset()
	return
