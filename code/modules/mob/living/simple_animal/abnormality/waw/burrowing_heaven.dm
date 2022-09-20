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
