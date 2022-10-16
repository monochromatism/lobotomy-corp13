/mob/living/simple_animal/hostile/abnormality/burrowing_heaven
	name = "The Burrowing Heaven"
	desc = "A thorny creature with its lean, bloody wings stretched skyward.  \
	Its eyes track yours as you observe it."
	icon = 'ModularTegustation/Teguicons/96x96.dmi'
	icon_state = "burrowingheaven_contained"
	icon_living = "burrowingheaven_breached"
	faction = list("hostile")
	speak_emote = list("creaks")

	pixel_x = -32
	base_pixel_x = -32

	ranged = TRUE
	maxHealth = 2000
	health = 2000
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0, WHITE_DAMAGE = 1.2, BLACK_DAMAGE = 0.5, PALE_DAMAGE = 1.5)

	threat_level = WAW_LEVEL
	can_breach = TRUE
	start_qliphoth = 3
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 0,
						ABNORMALITY_WORK_INSIGHT = list(0, 0, 35, 40, 45),
						ABNORMALITY_WORK_ATTACHMENT = list(50, 50, 50, 55, 55),
						ABNORMALITY_WORK_REPRESSION = list(0, 0, 45, 50, 55)
						)
	work_damage_amount = 9
	work_damage_type = BLACK_DAMAGE

	ego_list = list()

	var/observe_delay = 5 SECONDS
	var/focus = FALSE
	var/observe_time = 0 SECONDS
	var/room_counter = 6
	var/max_thorns = 3
	var/list/thorns = list()

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/attempt_work(mob/living/carbon/human/user, work_type)
	observe_time = world.time + observe_delay
	focus = TRUE // Look at me
	return ..()

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/Life()
	if(focus & (world.time > observe_time))
		if(status_flags & GODMODE)
			datum_reference.qliphoth_change(-1)
		else
			room_counter -= 1
		observe_time = world.time + observe_delay
	return ..()

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/work_complete(mob/living/carbon/human/user, work_type, pe)
	focus = FALSE // You can stop
	return ..()

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/success_effect(mob/living/carbon/human/user, work_type, pe)
	datum_reference.qliphoth_change(+1)
	return ..()

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/Move()
	return FALSE

/obj/living/simple_animal/hostile/abnormality/burrowing_heaven/examine(mob/user)
	observe_time = world.time + observe_delay
	return ..()

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/breach_effect(mob/living/carbon/human/user)
	..()
	focus = TRUE
	var/turf/T = pick(GLOB.department_centers)
	forceMove(T)
	for(i = 0, i < max_thorns, i++)
		var/mob/living/simple_animal/hostile/heavens_thorn/N = new(T)
		thorns += N
	focus = TRUE
	return

/mob/living/simple_animal/hostile/abnormality/burrowing_heaven/proc/MoveThorns()
	var/list/pref3 = get_area(src).contents
	var/list/pref2 = list()
	var/list/pref1 = list()
	var/turf/randpick
	for(var/turf/T in pref3)
		pref2 += T
	for(var/mob/living/carbon/L in pref3)
		pref1 += L.loc
		pref2 -= L.loc
	pref2 -= src.loc
	for(var/mob/living/simple_animal/hostile/heavens_thorn/H in thorns)
		if(LAZYLEN(pref1))
			randpick = pick(pref1)
			pref1 -= randpick
		else
			randpick = pick(pref2)
			pref2 -= randpick
		H.forceMove(randpick)

/* Heaven's Thorns */

/mob/living/simple_animal/hostile/heavens_thorn
	name = "heaven's thorn"
	desc = "A single sharp branch protruding from the floor. You feel it looking back at you."
	icon = 'ModularTegustation/Teguicons/32x32.dmi'
	icon_state = "burrowingheaven_minion"
	icon_living = "burrowingheaven_minion"
	health = 500
	maxHealth = 500
	melee_damage_type = BLACK_DAMAGE
	armortype = BLACK_DAMAGE
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.2, WHITE_DAMAGE = 1.4, BLACK_DAMAGE = 0.7, PALE_DAMAGE = 1.7)
	melee_damage_lower = 10
	melee_damage_upper = 15
	rapid_melee = 2
	obj_damage = 250
	robust_searching = FALSE
	stat_attack = HARD_CRIT
	del_on_death = TRUE
	deathsound = ''
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	attack_sound = ''
	speak_emote = list("creaks")
	density = FALSE
	anchored = TRUE

/mob/living/simple_animal/hostile/heavens_thorn/CanAttack(atom/the_target)
	return FALSE

/mob/living/simple_animal/hostile/heavens_thorn/Move()
	return FALSE

/mob/living/simple_animal/hostile/heavens_thorn/Moved()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		L.apply_damage(30, BLACK_DAMAGE, null, L.run_armor_check(null, BLACK_DAMAGE), spread_damage = TRUE)
		visible_message("<span class='boldwarning'>[src] stabs up through [L]!</span>")
		to_chat(L, "<span class='userdanger'>[src] pierces through you!</span>")
	return ..()

/mob/living/simple_animal/hostile/heavens_thorn/Initialize()

	return ..()

/mob/living/simple_animal/hostile/heavens_thorn/Destroy()

