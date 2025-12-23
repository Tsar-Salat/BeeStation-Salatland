/datum/cultural_info/culture/hidden
	description = "This is a hidden cultural detail. If you can see this, please report it on the tracker."
	hidden = TRUE
	hidden_from_codex = TRUE

//Heretics
/datum/cultural_info/culture/hidden/mansus
	name = CULTURE_ALIUM
	//Unsure what I want to assign to heretics, since mansus isn't really a language between people.
	//language = LANGUAGE_ALIUM
	secondary_langs = null

//Cult of Rat'var, the Time God
/datum/cultural_info/culture/hidden/clockwork
	name = CULTURE_STARLIGHT
	language = /datum/language/ratvar

//Cult of Rat'var, the Goddess of Domination
/datum/cultural_info/culture/hidden/domination
	name =   CULTURE_CULTIST
	language = /datum/language/narsie

/datum/cultural_info/culture/hidden/cultist/get_random_name()
	return "[pick("Anguished", "Blasphemous", "Corrupt", "Cruel", "Depraved", "Despicable", "Disturbed", "Exacerbated", "Foul", "Hateful", "Inexorable", "Implacable", "Impure", "Malevolent", "Malignant", "Malicious", "Pained", "Profane", "Profligate", "Relentless", "Resentful", "Restless", "Spiteful", "Tormented", "Unclean", "Unforgiving", "Vengeful", "Vindictive", "Wicked", "Wronged")] [pick("Apparition", "Aptrgangr", "Dis", "Draugr", "Dybbuk", "Eidolon", "Fetch", "Fylgja", "Ghast", "Ghost", "Gjenganger", "Haint", "Phantom", "Phantasm", "Poltergeist", "Revenant", "Shade", "Shadow", "Soul", "Spectre", "Spirit", "Spook", "Visitant", "Wraith")]"

/datum/cultural_info/culture/hidden/monkey
	name = CULTURE_MONKEY
	language = /datum/language/monkey

/datum/cultural_info/culture/hidden/monkey/get_random_name()
	return "[lowertext(name)] ([rand(100,999)])"

/datum/cultural_info/culture/hidden/monkey/farwa
	name =   CULTURE_FARWA

/datum/cultural_info/culture/hidden/monkey/neara
	name =   CULTURE_NEARA

/datum/cultural_info/culture/hidden/monkey/stok
	name =   CULTURE_STOK
