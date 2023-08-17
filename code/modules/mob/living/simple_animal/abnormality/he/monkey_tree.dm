/mob/living/simple_animal/hostile/abnormality/monkeytree
	name = "Monkey Tree"
	desc = "A withered, starved-looking tree."
	icon = 'ModularTegustation/Teguicons/64x64.dmi'
	icon_state = "monkeytree_passive"
	pixel_x = -16
	base_pixel_x = -16
	maxHealth = 300
	health = 300
	threat_level = HE_LEVEL
	work_chances = list(
		ABNORMALITY_WORK_INSTINCT = 70, // Watering can be considered both instinct and insight work... but insight is slightly preferred.
		ABNORMALITY_WORK_INSIGHT = 80,
		ABNORMALITY_WORK_ATTACHMENT = 10,
		ABNORMALITY_WORK_REPRESSION = 25
		)
	work_damage_amount = 8
	work_damage_type = BLACK_DAMAGE

	ego_list = list(
		/datum/ego_datum/weapon/fury,
		/datum/ego_datum/armor/fury
		)
	gift_type = /datum/ego_gifts/fury
	abnormality_origin = ABNORMALITY_ORIGIN_LIMBUS

	var/meltdown_repeats = 0
	var/required_repeats = 0
	var/max_scream_damage = 100
	var/min_work_delay = 5
	var/is_melting = FALSE

/mob/living/simple_animal/hostile/abnormality/monkeytree/MeltdownStart()
	is_melting = TRUE
	required_repeats = rand(1,20)
	return ..()

/mob/living/simple_animal/hostile/abnormality/monkeytree/WorkChance(mob/living/carbon/human/user, chance, work_type)
	if(is_melting && work_type == ABNORMALITY_WORK_INSTINCT || ABNORMALITY_WORK_INSIGHT)
		chance += meltdown_repeats * 2 // Work goes smoother if you're watering repeatedly
	return chance

/mob/living/simple_animal/hostile/abnormality/monkeytree/SpeedWorktickOverride(mob/living/carbon/human/user, work_speed, init_work_speed, work_type)
	return max(init_work_speed - meltdown_repeats, min_work_delay) // Work goes faster if you're watering repeatedly

/mob/living/simple_animal/hostile/abnormality/monkeytree/PostWorkEffect(mob/living/carbon/human/user, work_type, pe, work_time, canceled)
	if(is_melting)
		if(work_type == ABNORMALITY_WORK_REPRESSION)
			BranchSnapped()
			return
		meltdown_repeats += 1
		if(required_repeats > meltdown_repeats)
			addtimer(CALLBACK (datum_reference.console, .obj/machinery/computer/abnormality/proc/start_meltdown), 10)
			return
		is_melting = FALSE
		required_repeats = 0
		meltdown_repeats = 0
	return

/mob/living/simple_animal/hostile/abnormality/monkeytree/ZeroQliphoth(mob/living/carbon/human/user)
	// Hit a few random players currently in main rooms with lightning.
	return

/mob/living/simple_animal/hostile/abnormality/monkeytree/proc/BranchSnapped(mob/living/carbon/human/user)
	// Deals more white damage the closer you were to satisfying it
	user.apply_damage(max_scream_damage * (meltdown_repeats / required_repeats), WHITE_DAMAGE, null, user.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE)
	required_repeats = 0
	meltdown_repeats = 0
	is_melting = FALSE
	return
