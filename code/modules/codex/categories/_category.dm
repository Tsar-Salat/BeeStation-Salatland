/datum/codex_category
	var/name = "Generic Category"
	var/desc = "Some description for a category's codex entry."
	var/list/items

/datum/codex_category/New()
	. = ..()
	items = list()

//Children should call ..() at the end after filling the items list
/datum/codex_category/proc/Initialize()
	if(length(items))
		var/datum/codex_entry/entry = new(_display_name = "[name] (category)")
		entry.lore_text = desc
		SScodex.add_entry_by_string(lowertext(entry.display_name), entry)
