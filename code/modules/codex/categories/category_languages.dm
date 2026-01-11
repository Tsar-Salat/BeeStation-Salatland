/datum/codex_category/languages
	name = "Languages"
	desc = "Languages spoken in known space."

/datum/codex_category/languages/Initialize()
	var/example_line = "This is just some random words. What did you expect here? Hah hah!"
	for(var/datum/language/L as anything in GLOB.all_languages)
		if(!L.key) // Skip languages without a key (not learnable/real)
			continue
		if(L.hidden_from_codex)
			continue

		var/list/lang_info = list()
		lang_info += "Key to use it: '[L.key]'"

		if(L.flags & TONGUELESS_SPEECH)
			lang_info += "It can be spoken even without a tongue (though you'll murmur)."

		var/list/lang_lore = list(L.desc)

		// Show an example of the language if it has syllables for scrambling
		if(L.syllables && length(L.syllables))
			var/scrambled = L.scramble(example_line)
			var/verb /*= L.get_spoken_verb(".")*/
			// Build the example manually
			var/lang_example = "[verb], \"[capitalize(scrambled)]\""
			lang_lore += "It sounds like this:"
			lang_lore += ""
			lang_lore += "<b>CodexBot</b> [lang_example]"

		var/datum/codex_entry/entry = new(
			_display_name = "[L.name] (language)",
			_lore_text = jointext(lang_lore, "<br>"),
			_mechanics_text = jointext(lang_info, "<br>")
		)
		entry.associated_strings += L.name
		SScodex.add_entry_by_string(entry.display_name, entry)
		items += entry.display_name
	..()
