/datum/reagent/abnormality // The base abnormality chemical, with several "easy" modular traits that people can enable and disable with variables.
	name = "Raw Enkephalin" // If you don't change anything else, CHANGE THIS.
	description = "You don't think you should be seeing this." // And this too.
	reagent_state = LIQUID // For logic's sake, change this.
	color = "#6baf65" // For presentation purposes, change this.
	metabolization_rate = 0.5 * REAGENTS_METABOLISM // Change at your own peril!
	taste_mult = 0
	var/harvestPhrase = "You harvest... something, and put it in"
	var/harvestPhraseThirdPerson = "harvests ... something, and put it in"
	var/list/specialProperties = list() // Describe your custom-made properties as you want them to appear when analyzed. One string per line.
	var/healthRestore = 0 // % of health restored per tick. For reference, Salicylic Acid is 4. Set to negative and it'll hurt!
	var/sanityRestore = 0 // % of sanity restored per tick. For reference, Mental Stabilizator is 5. Set to negative and it'll hurt!
	var/list/statChanges = list(0, 0, 0, 0) // Fortitude, Justice, Prudence, Temperance, in order. Positive and negative both work.
	var/list/armorMods = list(0, 0, 0, 0) // Red, white, black, pale, in order. 10 = I, 50 = V, 100 = X. Applies additively. (Or subtractively, if negative.) USE SPARINGLY!
	var/list/damageMods = list(1, 1, 1, 1) // Same order as armorMods, but multiplicative. Applied after armor. Knight of Despair's blessed has 0.5, 0.5, 0.5, 2.0, for reference.

/datum/reagent/abnormality/on_mob_life(mob/living/L)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(healthRestore != 0)
		H.adjustBruteLoss(-healthRestore*REM)
	if(sanityRestore != 0)
		H.adjustSanityLoss(sanityRestore*REM)
	return ..()

/datum/reagent/abnormality/on_mob_metabolize(mob/living/L)
	if(!ishuman(L)) // I don't know why you're trying to give a simple mob armor or stats via a chem, but Please Don't Do That.
		return
	var/mob/living/carbon/human/H = L
	if((statChanges[1] || statChanges[2] || statChanges[3] || statChanges[4]) != 0)
		H.adjust_attribute_buff(FORTITUDE_ATTRIBUTE, statChanges[1])
		H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, statChanges[2])
		H.adjust_attribute_buff(PRUDENCE_ATTRIBUTE, statChanges[3])
		H.adjust_attribute_buff(TEMPERANCE_ATTRIBUTE, statChanges[4])
	if((armorMods[1] || armorMods[2] || armorMods[3] || armorMods[4]) != 0)
		H.physiology.armor = H.physiology.armor.modifyRating(red = armorMods[1], white = armorMods[2], black = armorMods[3], pale = armorMods[4])
	if((damageMods[1] || damageMods[2] || damageMods[3] || damageMods[4]) != 1)
		H.physiology.red_mod *= damageMods[1]
		H.physiology.white_mod *= damageMods[2]
		H.physiology.black_mod *= damageMods[3]
		H.physiology.pale_mod *= damageMods[4]

/datum/reagent/abnormality/on_mob_end_metabolize(mob/living/L)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if((statChanges[1] || statChanges[2] || statChanges[3] || statChanges[4]) != 0)
		H.adjust_attribute_buff(FORTITUDE_ATTRIBUTE, -statChanges[1])
		H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, -statChanges[2])
		H.adjust_attribute_buff(PRUDENCE_ATTRIBUTE, -statChanges[3])
		H.adjust_attribute_buff(TEMPERANCE_ATTRIBUTE, -statChanges[4])
	if((armorMods[1] || armorMods[2] || armorMods[3] || armorMods[4]) != 0)
		H.physiology.armor = H.physiology.armor.modifyRating(red = -armorMods[1], white = -armorMods[2], black = -armorMods[3], pale = -armorMods[4])
	if((damageMods[1] || damageMods[2] || damageMods[3] || damageMods[4]) != 1)
		H.physiology.red_mod /= damageMods[1]
		H.physiology.white_mod /= damageMods[2]
		H.physiology.black_mod /= damageMods[3]
		H.physiology.pale_mod /= damageMods[4]

/obj/item/enkephalinScanner
	name = "enkephalin-derived substance scanner"
	desc = "Scans and analyzes substances harvested from abnormalities."
	icon = 'ModularTegustation/Teguicons/teguitems.dmi'
	icon_state = "abnochem-scanner"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	var/list/lastScan = list()

/obj/item/enkephalinScanner/afterattack(atom/A as mob|obj, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!isnull(A.reagents))
		lastScan = list()
		if(A.reagents.reagent_list.len > 0)
			var/abnoCount = 0
			for (var/datum/reagent/abnormality/abnoChem in A.reagents.reagent_list) // I need to do TWO for loops through the same list uuuuuugh
				abnoCount += 1
			if(abnoCount)
				to_chat(user, "<span class='notice'>[abnoCount] enkephalin-derived substance[abnoCount > 1 ? "s" : ""] found.</span>")
				for (var/datum/reagent/abnormality/abnoChem in A.reagents.reagent_list)
					to_chat(user, "<span class='notice'>\t [abnoChem]</span>")
					lastScan |= abnoChem
				to_chat(user,"<span class='notice'>Property analysis <a href='?src=[REF(src)];analysis=1'>available</a>.</span>")
			else
				to_chat(user, "<span class='notice'>No enkephalin-derived substances found in [A].</span>")
		else
			to_chat(user, "<span class='notice'>No enkephalin-derived substances found in [A].</span>")
	else
		to_chat(user, "<span class='notice'>No enkephalin-derived substances found in [A].</span>")

/obj/item/enkephalinScanner/Topic(href, href_list)
	. = ..()
	if(href_list["analysis"])
		var/list/readout1 = list()
		var/list/readout2 = list()
		for(var/datum/reagent/abnormality/abnoChem in lastScan)
			var/special = abnoChem.specialProperties
			for(var/property in special)
				readout1 |= "- [property]"
			if(abnoChem.healthRestore > 0) // This code looks awful. This code IS awful. But it's the best I can figure out...
				readout2 |= "- substance may physically heal subject"
			else if(abnoChem.healthRestore < 0)
				readout2 |= "- substance may physically harm subject"
			if(abnoChem.sanityRestore > 0)
				readout2 |= "- substance may improve subject mental stability"
			else if(abnoChem.healthRestore < 0)
				readout2 |= "- substance may reduce subject mental stability"
			if((abnoChem.statChanges[1] || abnoChem.statChanges[2] || abnoChem.statChanges[3] || abnoChem.statChanges[4]) != 0)
				readout2 |= "- substance may alter subject's abilities"
			if((abnoChem.armorMods[1] || abnoChem.armorMods[2] || abnoChem.armorMods[3] || abnoChem.armorMods[4] || abnoChem.damageMods[1] || abnoChem.damageMods[2] || abnoChem.damageMods[3] || abnoChem.damageMods[4]) != 0)
				readout2 |= "- substance may alter subject's durability"
		for(var/reportLine in readout1)
			to_chat(usr, reportLine)
		for(var/reportLine in readout2)
			to_chat(usr, reportLine)
