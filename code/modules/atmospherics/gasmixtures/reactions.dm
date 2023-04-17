//All defines used in reactions are located in ..\__DEFINES\reactions.dm

/proc/init_gas_reactions()
	. = list()

	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(initial(reaction.exclude))
			continue
		reaction = new r
		. += reaction
	sortTim(., GLOBAL_PROC_REF(cmp_gas_reactions))

/proc/cmp_gas_reactions(list/datum/gas_reaction/a, list/datum/gas_reaction/b) // compares lists of reactions by the maximum priority contained within the list
	if (!length(a) || !length(b))
		return length(b) - length(a)
	var/maxa
	var/maxb
	for (var/datum/gas_reaction/R in a)
		if (R.priority > maxa)
			maxa = R.priority
	for (var/datum/gas_reaction/R in b)
		if (R.priority > maxb)
			maxb = R.priority
	return maxb - maxa

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_MOLE_COUNT.
	var/list/min_requirements
	var/list/max_requirements
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = 100 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

/**
 * Steam Condensation/Deposition:
 *
 * Makes turfs slippery.
 * Can frost things if the gas is cold enough.
 */
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor Condensation"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list(
		GAS_H2O = MOLES_GAS_VISIBLE,
		"MAX_TEMP" = WATER_VAPOR_CONDENSATION_POINT,
	)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.return_temperature() <= WATER_VAPOR_DEPOSITION_POINT)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.adjust_moles(GAS_H2O, -MOLES_GAS_VISIBLE)
		. = REACTING

/* UNIMPLEMENTED
/**
 * Dry Heat Sterilization:
 *
 * Clears out pathogens in the air.
 */
/datum/gas_reaction/miaster
	priority_group = PRIORITY_POST_FORMATION
	name = "Dry Heat Sterilization"
	id = "sterilization"
	desc = "Pathogens cannot survive in a hot environment. Miasma decomposes on high temperature."

/datum/gas_reaction/miaster/init_reqs()
	requirements = list(
		/datum/gas/miasma = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = MIASTER_STERILIZATION_TEMP,
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	// As the name says it, it needs to be dry
	if(cached_gases[/datum/gas/water_vapor] && cached_gases[/datum/gas/water_vapor][MOLES] / air.total_moles() > MIASTER_STERILIZATION_MAX_HUMIDITY)
		return NO_REACTION

	//Replace miasma with oxygen
	var/cleaned_air = min(cached_gases[/datum/gas/miasma][MOLES], MIASTER_STERILIZATION_RATE_BASE + (air.temperature - MIASTER_STERILIZATION_TEMP) / MIASTER_STERILIZATION_RATE_SCALE)
	cached_gases[/datum/gas/miasma][MOLES] -= cleaned_air
	ASSERT_GAS(/datum/gas/oxygen, air)
	cached_gases[/datum/gas/oxygen][MOLES] += cleaned_air

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.temperature += cleaned_air * MIASTER_STERILIZATION_ENERGY
	SET_REACTION_RESULTS(cleaned_air)

	return REACTING
*/

// Fire:

/**
 * Plasma combustion:
 *
 * Combustion of oxygen and plasma (mostly treated as hydrocarbons).
 * The reaction rate is dependent on the temperature of the gasmix.
 * May produce either tritium or carbon dioxide and water vapor depending on the fuel ratio of the gasmix.
 */
/datum/gas_reaction/plasmafire
	priority = -2 //fire should ALWAYS be last, but plasma fires happen after tritium fires
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	min_requirements = list(
		GAS_PLASMA = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT,
		"TEMP" = PLASMA_MINIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	// This reaction should proceed faster at higher temperatures.
	var/temperature = air.return_temperature()
	var/temperature_scale = 0
	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale <= 0)
			return NO_REACTION

	var/oxygen_burn_ratio = OXYGEN_BURN_RATE_BASE - temperature_scale
	var/plasma_burn_rate = 0
	var/super_saturation = FALSE // Whether we should make tritium.
	var/list/cached_gases = air.reaction_results //this speeds things up because accessing datum vars is slow
	switch(cached_gases[GAS_O2])
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(air.get_moles(GAS_O2) / air.get_moles(GAS_PLASMA) > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(air.get_moles(GAS_O2) > air.get_moles(GAS_PLASMA)*PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (air.get_moles(GAS_PLASMA)*temperature_scale)/PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale*(air.get_moles(GAS_O2)/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate,air.get_moles(GAS_PLASMA),air.get_moles(GAS_O2)/oxygen_burn_rate) //Ensures matter is conserved properly
			air.set_moles(GAS_PLASMA, QUANTIZE(air.get_moles(GAS_PLASMA) - plasma_burn_rate))
			air.set_moles(GAS_O2, QUANTIZE(air.get_moles(GAS_O2) - (plasma_burn_rate * oxygen_burn_rate)))
			if (super_saturation)
				air.adjust_moles(GAS_TRITIUM, plasma_burn_rate)
			else
				air.adjust_moles(GAS_CO2, plasma_burn_rate)

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	SET_REACTION_RESULTS((plasma_burn_rate) * (1 + oxygen_burn_ratio))
	var/energy_released = FIRE_PLASMA_ENERGY_RELEASED * plasma_burn_rate
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.set_temperature((temperature * old_heat_capacity + energy_released) / new_heat_capacity)

	//let the floor know a fire is happening
	var/turf/open/location = holder
	if(istype(location))
		temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority = -1 //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		GAS_TRITIUM = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT
	)

/proc/fire_expose(turf/open/location, datum/gas_mixture/air, temperature)
	if(istype(location) && temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		location.hotspot_expose(temperature, CELL_VOLUME)
		for(var/I in location)
			var/atom/movable/item = I
			item.temperature_expose(air, temperature, CELL_VOLUME)
		location.temperature_expose(air, temperature, CELL_VOLUME)

/proc/radiation_burn(turf/open/location, energy_released)
	if(istype(location) && prob(10))
		radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	var/initial_trit = air.get_moles(GAS_TRITIUM)// Yogs
	if(air.get_moles(GAS_O2) < initial_trit || MINIMUM_TRIT_OXYBURN_ENERGY > (temperature * old_heat_capacity))// Yogs -- Maybe a tiny performance boost? I'unno
		burned_fuel = air.get_moles(GAS_O2)/TRITIUM_BURN_OXY_FACTOR
		if(burned_fuel > initial_trit) burned_fuel = initial_trit //Yogs -- prevents negative moles of Tritium
		air.adjust_moles(GAS_TRITIUM, -burned_fuel)
	else
		burned_fuel = initial_trit // Yogs -- Conservation of Mass fix
		air.set_moles(GAS_TRITIUM, air.get_moles(GAS_TRITIUM) * (1 - 1/TRITIUM_BURN_TRIT_FACTOR)) // Yogs -- Maybe a tiny performance boost? I'unno
		air.adjust_moles(GAS_O2, -air.get_moles(GAS_TRITIUM))
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel * (TRITIUM_BURN_TRIT_FACTOR - 1)) // Yogs -- Fixes low-energy tritium fires

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

		//oxygen+more-or-less hydrogen=H2O
		air.adjust_moles(GAS_H2O, burned_fuel )// Yogs -- Conservation of Mass

		cached_results["fire"] += burned_fuel

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

/**
 * Freon combustion:
 *
 * Combustion of oxygen and freon.
 * Endothermic.
 *
/datum/gas_reaction/freonfire
	priority_group = PRIORITY_FIRE
	name = "Freon Combustion"
	id = "freonfire"
	expands_hotspot = TRUE
	desc = "Reaction between oxygen and freon that consumes a huge amount of energy and can cool things significantly. Also able to produce hot ice."

/datum/gas_reaction/freonfire/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FREON_TERMINAL_TEMPERATURE,
		"MAX_TEMP" = FREON_MAXIMUM_BURN_TEMPERATURE,
	)


/datum/gas_reaction/freonfire/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.temperature
	var/temperature_scale
	if(temperature < FREON_TERMINAL_TEMPERATURE) //stop the reaction when too cold
		temperature_scale = 0
	else if(temperature < FREON_LOWER_TEMPERATURE)
		temperature_scale = 0.5
	else
		temperature_scale = (FREON_MAXIMUM_BURN_TEMPERATURE - temperature) / (FREON_MAXIMUM_BURN_TEMPERATURE - FREON_TERMINAL_TEMPERATURE) //calculate the scale based on the temperature
	if (temperature_scale <= 0)
		return NO_REACTION

	var/oxygen_burn_ratio = OXYGEN_BURN_RATIO_BASE - temperature_scale
	var/freon_burn_rate
	var/list/cached_gases = air.gases
	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/freon][MOLES] * FREON_OXYGEN_FULLBURN)
		freon_burn_rate = ((cached_gases[/datum/gas/oxygen][MOLES] / FREON_OXYGEN_FULLBURN) / FREON_BURN_RATE_DELTA) * temperature_scale
	else
		freon_burn_rate = (cached_gases[/datum/gas/freon][MOLES] / FREON_BURN_RATE_DELTA) * temperature_scale

	if (freon_burn_rate < MINIMUM_HEAT_CAPACITY)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	freon_burn_rate = min(freon_burn_rate, cached_gases[/datum/gas/freon][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(oxygen_burn_ratio)) //Ensures matter is conserved properly
	cached_gases[/datum/gas/freon][MOLES] = QUANTIZE(cached_gases[/datum/gas/freon][MOLES] - freon_burn_rate)
	cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (freon_burn_rate * oxygen_burn_ratio))
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	cached_gases[/datum/gas/carbon_dioxide][MOLES] += freon_burn_rate

	if(temperature < HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE && temperature > HOT_ICE_FORMATION_MINIMUM_TEMPERATURE && prob(HOT_ICE_FORMATION_PROB) && isturf(holder))
		new /obj/item/stack/sheet/hot_ice(holder)

	SET_REACTION_RESULTS(freon_burn_rate * (1 + oxygen_burn_ratio))
	var/energy_consumed = FIRE_FREON_ENERGY_CONSUMED * freon_burn_rate
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((temperature * old_heat_capacity - energy_consumed) / new_heat_capacity, TCMB)

	var/turf/open/location = holder
	if(istype(location))
		temperature = air.temperature
		if(temperature < FREON_MAXIMUM_BURN_TEMPERATURE)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return REACTING
*/

/datum/gas_reaction/genericfire
	priority = -3 // very last reaction
	name = "Combustion"
	id = "genericfire"

/datum/gas_reaction/genericfire/init_reqs()
	var/lowest_fire_temp = INFINITY
	var/list/fire_temperatures = GLOB.gas_data.fire_temperatures
	for(var/gas in fire_temperatures)
		lowest_fire_temp = min(lowest_fire_temp, fire_temperatures[gas])
	var/lowest_oxi_temp = INFINITY
	var/list/oxidation_temperatures = GLOB.gas_data.oxidation_temperatures
	for(var/gas in oxidation_temperatures)
		lowest_oxi_temp = min(lowest_oxi_temp, oxidation_temperatures[gas])
	min_requirements = list(
		"TEMP" = max(lowest_oxi_temp, lowest_fire_temp),
		"FIRE_REAGENTS" = MINIMUM_MOLE_COUNT
	)

// no requirements, always runs
// bad idea? maybe
// this is overridden by auxmos but, hey, good idea to have it readable

/datum/gas_reaction/genericfire/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/list/oxidation_temps = GLOB.gas_data.oxidation_temperatures
	var/list/oxidation_rates = GLOB.gas_data.oxidation_rates
	var/oxidation_power = 0
	var/list/burn_results = list()
	var/list/fuels = list()
	var/list/oxidizers = list()
	var/list/fuel_rates = GLOB.gas_data.fire_burn_rates
	var/list/fuel_temps = GLOB.gas_data.fire_temperatures
	var/total_fuel = 0
	var/energy_released = 0
	for(var/G in air.get_gases())
		var/oxidation_temp = oxidation_temps[G]
		if(oxidation_temp && oxidation_temp > temperature)
			var/temperature_scale = max(0, 1-(temperature / oxidation_temp))
			var/amt = air.get_moles(G) * temperature_scale
			oxidizers[G] = amt
			oxidation_power += amt * oxidation_rates[G]
		else
			var/fuel_temp = fuel_temps[G]
			if(fuel_temp && fuel_temp > temperature)
				var/amt = (air.get_moles(G) / fuel_rates[G]) * max(0, 1-(temperature / fuel_temp))
				fuels[G] = amt // we have to calculate the actual amount we're using after we get all oxidation together
				total_fuel += amt
	if(oxidation_power <= 0 || total_fuel <= 0)
		return NO_REACTION
	var/oxidation_ratio = oxidation_power / total_fuel
	if(oxidation_ratio > 1)
		for(var/oxidizer in oxidizers)
			oxidizers[oxidizer] /= oxidation_ratio
	else if(oxidation_ratio < 1)
		for(var/fuel in fuels)
			fuels[fuel] *= oxidation_ratio
	fuels += oxidizers
	var/list/fire_products = GLOB.gas_data.fire_products
	var/list/fire_enthalpies = GLOB.gas_data.enthalpies
	for(var/fuel in fuels + oxidizers)
		var/amt = fuels[fuel]
		if(!burn_results[fuel])
			burn_results[fuel] = 0
		burn_results[fuel] -= amt
		energy_released += amt * fire_enthalpies[fuel]
		for(var/product in fire_products[fuel])
			if(!burn_results[product])
				burn_results[product] = 0
			burn_results[product] += amt
	var/final_energy = air.thermal_energy() + energy_released
	for(var/result in burn_results)
		air.adjust_moles(result, burn_results[result])
	air.set_temperature(final_energy / air.heat_capacity())
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = min(total_fuel, oxidation_power) * 2
	return cached_results["fire"] ? REACTING : NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD,
		GAS_TRITIUM = FUSION_TRITIUM_MOLES_USED,
		GAS_PLASMA = FUSION_MOLE_THRESHOLD,
		GAS_CO2 = FUSION_MOLE_THRESHOLD)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location
	if (istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)
	if(!air.analyzer_results)
		air.analyzer_results = new
	var/list/cached_scan_results = air.analyzer_results
	var/thermal_energy = air.thermal_energy()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = air.get_moles(GAS_PLASMA)
	var/initial_carbon = air.get_moles(GAS_CO2)
	var/scale_factor = max(air.return_volume() / FUSION_SCALE_DIVISOR, FUSION_MINIMAL_SCALE)
	var/temperature_scale = log(10, air.return_temperature())
	//The size of the phase space hypertorus
	var/toroidal_size = 	TOROID_CALCULATED_THRESHOLD \
							+ (temperature_scale <= FUSION_BASE_TEMPSCALE ? \
							(temperature_scale-FUSION_BASE_TEMPSCALE) / FUSION_BUFFER_DIVISOR \
							: 4 ** (temperature_scale-FUSION_BASE_TEMPSCALE) / FUSION_SLOPE_DIVISOR)
	var/gas_power = 0
	for (var/gas_id in air.get_gases())
		gas_power += (GLOB.gas_data.fusion_powers[gas_id]*air.get_moles(gas_id))
	var/instability = MODULUS((gas_power*INSTABILITY_GAS_POWER_FACTOR),toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results[id] = instability//used for analyzer feedback

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)

	air.set_moles(GAS_PLASMA, plasma*scale_factor + FUSION_MOLE_THRESHOLD )//Scales the gases back up
	air.set_moles(GAS_CO2, carbon*scale_factor + FUSION_MOLE_THRESHOLD)
	var/delta_plasma = min(initial_plasma - air.get_moles(GAS_PLASMA), toroidal_size * scale_factor * 1.5)

	//Energy is gained or lost corresponding to the creation or destruction of mass.
	//Low instability prevents endothermality while higher instability acutally encourages it.
	reaction_energy = 	instability <= FUSION_INSTABILITY_ENDOTHERMALITY || delta_plasma > 0 ? \
						max(delta_plasma*PLASMA_BINDING_ENERGY, 0) \
						: delta_plasma*PLASMA_BINDING_ENERGY * (instability-FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	//To achieve faster equilibrium. Too bad it is not that good at cooling down.
	if (reaction_energy)
		var/middle_energy = (((TOROID_CALCULATED_THRESHOLD / 2) * scale_factor) + FUSION_MOLE_THRESHOLD) * (200 * FUSION_MIDDLE_ENERGY_REFERENCE)
		thermal_energy = middle_energy * FUSION_ENERGY_TRANSLATION_EXPONENT ** log(10, thermal_energy / middle_energy)

		//This bowdlerization is a double-edged sword. Tread with care!
		var/bowdlerized_reaction_energy = 	clamp(reaction_energy, \
											thermal_energy * ((1 / FUSION_ENERGY_TRANSLATION_EXPONENT ** 2) - 1), \
											thermal_energy * (FUSION_ENERGY_TRANSLATION_EXPONENT ** 2 - 1))
		thermal_energy = middle_energy * 10 ** log(FUSION_ENERGY_TRANSLATION_EXPONENT, (thermal_energy + bowdlerized_reaction_energy) / middle_energy)

	//The reason why you should set up a tritium production line.
	air.adjust_moles(GAS_TRITIUM, -FUSION_TRITIUM_MOLES_USED)

	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	var/standard_waste_gas_output = scale_factor * (FUSION_TRITIUM_CONVERSION_COEFFICIENT*FUSION_TRITIUM_MOLES_USED)
	delta_plasma > 0 ? air.adjust_moles(GAS_H2O, standard_waste_gas_output) : air.adjust_moles(GAS_BZ, standard_waste_gas_output)
	air.adjust_moles(GAS_O2, standard_waste_gas_output) //Oxygen is a bit touchy subject

	if(reaction_energy)
		if(location)
			var/standard_energy = 400 * air.get_moles(GAS_PLASMA) * air.return_temperature() //Prevents putting meaningless waste gases to achieve high rads.
			if(prob(PERCENT(((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1))) //Asymptopically approaches 100% as the energy of the reaction goes up.
				location.fire_nuclear_particle(customize = TRUE, custompower = standard_energy)
			radiation_pulse(location, max(2000 * 3 ** (log(10,standard_energy) - FUSION_RAD_MIDPOINT), 0))
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp(thermal_energy/new_heat_capacity, TCMB, INFINITY))
		return REACTING
	else if(reaction_energy == 0 && instability <= FUSION_INSTABILITY_ENDOTHERMALITY)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp(thermal_energy/new_heat_capacity, TCMB, INFINITY)) //THIS SHOULD STAY OR FUSION WILL EAT YOUR FACE
		return REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/nitrous_decomp
	priority = 0
	name = "Nitrous Oxide Decomposition"
	id = "nitrous_decomp"

/datum/gas_reaction/nitrous_decomp/init_reqs()
	min_requirements = list(
		GAS_NITROUS = MINIMUM_MOLE_COUNT,
		"TEMP" = N2O_DECOMPOSITION_MIN_TEMPERATURE,
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity() //this speeds things up because accessing datum vars is slow
	var/temperature = air.return_temperature()
	var/burned_fuel = 0

	burned_fuel = max(0,0.00002*(temperature-(0.00001*(temperature**2))))*air.get_moles(GAS_NITROUS)
	air.set_moles(GAS_NITROUS, air.get_moles(GAS_NITROUS) - burned_fuel)

	if(burned_fuel)
		energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)

		air.set_moles(GAS_O2, air.get_moles(GAS_O2) + burned_fuel/2)
		air.set_moles(GAS_N2, air.get_moles(GAS_N2) + burned_fuel)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)
		return REACTING
	return NO_REACTION

// Nitryl

/**
 * Nitryl Formation:
 *
 * The formation of nitrium.
 * Endothermic.
 * Requires N2O as a catalyst.
 */
/datum/gas_reaction/nitrylformation
	priority = 3
	name = "Nitryl Formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	min_requirements = list(
		GAS_O2 = 20,
		GAS_N2 = 20,
		GAS_PLUOXIUM = 5, //Gates Nitryl behind pluoxium to offset N2O burning up during formation
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*60
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*60),air.get_moles(GAS_O2),air.get_moles(GAS_N2))
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	if ((air.get_moles(GAS_O2) - heat_efficency < 0 )|| (air.get_moles(GAS_N2) - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_O2, -heat_efficency)
	air.adjust_moles(GAS_N2, -heat_efficency)
	air.adjust_moles(GAS_NITRYL, heat_efficency*2)

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity - energy_used)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = 4
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		GAS_NITROUS = 10,
		GAS_PLASMA = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.reaction_results
	var/pressure = air.return_pressure()
	// This slows down in relation to pressure, very quickly. Please don't expect it to be anything more then a snail
	var/reaction_efficency = min(1/((pressure/(0.1 * ONE_ATMOSPHERE)) * (max(air.get_moles(GAS_PLASMA)/air.get_moles(GAS_NITROUS), 1))), air.get_moles(GAS_NITROUS), air.get_moles(GAS_PLASMA) / 2)
	if ((air.get_moles(GAS_NITROUS) - reaction_efficency < 0 )|| (air.get_moles(GAS_PLASMA) - (2 * reaction_efficency) < 0) || reaction_efficency <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/bz, air)

	if(reaction_efficency == air.get_moles(GAS_NITROUS))
		air.adjust_moles(GAS_BZ, -min(pressure,1))
		air.adjust_moles(GAS_O2, min(pressure,1))
	air.adjust_moles(GAS_NITROUS, -reaction_efficency)
	air.adjust_moles(GAS_PLASMA, -2*reaction_efficency)
	SET_REACTION_RESULTS(reaction_efficency)

	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min((reaction_efficency**2)*BZ_RESEARCH_SCALE,BZ_RESEARCH_MAX_AMOUNT))
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, min((reaction_efficency**2)*BZ_RESEARCH_SCALE,BZ_RESEARCH_MAX_AMOUNT)*0.5)

	var/energy_released = 2 * reaction_efficency * FIRE_CARBON_ENERGY_RELEASED
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.return_temperature() = max(((air.return_temperature() * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority = 5
	name = "Stimulum formation"
	id = "stimformation"

/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		GAS_TRITIUM = 30,
		GAS_PLASMA = 10,
		GAS_BZ = 20,
		GAS_NITRYL = 30,
		"TEMP" = STIMULUM_HEAT_SCALE/2)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)

	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = min(air.return_temperature()/STIMULUM_HEAT_SCALE,air.get_moles(GAS_PLASMA),air.get_moles(GAS_NITRYL))
	var/stim_energy_change = heat_scale + STIMULUM_FIRST_RISE*(heat_scale**2) - STIMULUM_FIRST_DROP*(heat_scale**3) + STIMULUM_SECOND_RISE*(heat_scale**4) - STIMULUM_ABSOLUTE_DROP*(heat_scale**5)

	if ((air.get_moles(GAS_PLASMA) - heat_scale < 0) || (air.get_moles(GAS_NITRYL) - heat_scale < 0) || (air.get_moles(GAS_TRITIUM) - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_STIMULUM, heat_scale/10)
	air.adjust_moles(GAS_PLASMA, -heat_scale)
	air.adjust_moles(GAS_NITRYL, -heat_scale)
	air.adjust_moles(GAS_TRITIUM, -heat_scale)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, STIMULUM_RESEARCH_AMOUNT*max(stim_energy_change,0))
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, STIMULUM_RESEARCH_AMOUNT*max(stim_energy_change,0)*0.5)
	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB))
		return REACTING

/**
 * Hyper-Noblium Formation:
 *
 * Extremely exothermic.
 * Requires very low temperatures.
 * Due to its high mass, hyper-noblium uses large amounts of nitrogen and tritium.
 * BZ can be used as a catalyst to make it less exothermic.
 */
/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority = 6
	name = "Hyper-Noblium Condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	min_requirements = list(
		GAS_N2 = 10,
		GAS_TRITIUM = 5,
		"TEMP" = NOBLIUM_FORMATION_MIN_TEMP,
	)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.reaction_results

	var/old_heat_capacity = air.heat_capacity()
	var/nob_formed = min((air.get_moles(GAS_N2)+air.get_moles(GAS_TRITIUM))/100,air.get_moles(GAS_TRITIUM)/10,air.get_moles(GAS_N2)/20)
	var/energy_taken = nob_formed*(NOBLIUM_FORMATION_ENERGY/(max(air.get_moles(GAS_BZ),1)))
	if ((air.get_moles(GAS_TRITIUM) - 10*nob_formed < 0) || (air.get_moles(GAS_N2) - 20*nob_formed < 0))
		return NO_REACTION
	air.adjust_moles(GAS_TRITIUM, -10*nob_formed)
	air.adjust_moles(GAS_N2, -20*nob_formed)
	air.adjust_moles(GAS_HYPERNOB, nob_formed)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, nob_formed*NOBLIUM_RESEARCH_AMOUNT)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, nob_formed*NOBLIUM_RESEARCH_AMOUNT*0.5)

	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity - energy_taken)/new_heat_capacity),TCMB))

/datum/gas_reaction/nobliumsupression
	priority = INFINITY
	name = "Hyper-Noblium Reaction Suppression"
	id = "nobstop"

/datum/gas_reaction/nobliumsupression/init_reqs()
	min_requirements = list(GAS_HYPERNOB = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

/datum/gas_reaction/stim_ball
	priority = 7
	name ="Stimulum Energy Ball"
	id = "stimball"

/datum/gas_reaction/stim_ball/init_reqs()
	min_requirements = list(
		GAS_PLUOXIUM = STIM_BALL_GAS_AMOUNT,
		GAS_STIMULUM = STIM_BALL_GAS_AMOUNT,
		GAS_NITRYL = MINIMUM_MOLE_COUNT,
		GAS_PLASMA = MINIMUM_MOLE_COUNT,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/stim_ball/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location
	var/old_heat_capacity = air.heat_capacity()
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var/ball_shot_angle = 180*cos(air.get_moles(GAS_H2O)/air.get_moles(GAS_NITRYL))+180
	var/stim_used = min(STIM_BALL_GAS_AMOUNT/air.get_moles(GAS_PLASMA),air.get_moles(GAS_STIMULUM))
	var/pluox_used = min(STIM_BALL_GAS_AMOUNT/air.get_moles(GAS_PLASMA),air.get_moles(GAS_PLUOXIUM))
	var/energy_released = stim_used*STIMULUM_HEAT_SCALE//Stimulum has a lot of stored energy, and breaking it up releases some of it
	location.fire_nuclear_particle(ball_shot_angle)
	air.adjust_moles(GAS_CO2, 4*pluox_used)
	air.adjust_moles(GAS_N2, 8*stim_used)
	air.adjust_moles(GAS_PLUOXIUM, -pluox_used)
	air.adjust_moles(GAS_STIMULUM, -stim_used)
	air.adjust_moles(GAS_PLASMA, max(-air.get_moles(GAS_PLASMA)/2,-30))
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(CLAMP((air.return_temperature()*old_heat_capacity + energy_released)/new_heat_capacity,TCMB,INFINITY))
		return REACTING

// Halon UNIMPLEMENTED

/**
 * Halon Combustion:
 *
 * Consumes a large amount of oxygen relative to the amount of halon consumed.
 * Produces carbon dioxide.
 * Endothermic.
 *
/datum/gas_reaction/halon_o2removal
	priority_group = PRIORITY_PRE_FORMATION
	name = "Halon Oxygen Absorption"
	id = "halon_o2removal"
	desc = "Halon interaction with oxygen that can be used to snuff fires out."

/datum/gas_reaction/halon_o2removal/init_reqs()
	requirements = list(
		/datum/gas/halon = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
	)

/datum/gas_reaction/halon_o2removal/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/heat_efficency = min(temperature / ( FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), cached_gases[/datum/gas/halon][MOLES], cached_gases[/datum/gas/oxygen][MOLES] * INVERSE(20))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/halon][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency * 20 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/carbon_dioxide, air)
	cached_gases[/datum/gas/halon][MOLES] -= heat_efficency
	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency * 20
	cached_gases[/datum/gas/carbon_dioxide][MOLES] += heat_efficency * 5

	SET_REACTION_RESULTS(heat_efficency * 5)
	var/energy_used = heat_efficency * HALON_COMBUSTION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB)
	return REACTING
*/

// Healium UNIMPLEMENTED

/**
 * Healium Formation:
 *
 * Exothermic
 *
/datum/gas_reaction/healium_formation
	priority_group = PRIORITY_FORMATION
	name = "Healium Formation"
	id = "healium_formation"
	desc = "Production of healium using BZ and freon."

/datum/gas_reaction/healium_formation/init_reqs()
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = HEALIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = HEALIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/healium_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/heat_efficency = min(temperature * 0.3, cached_gases[/datum/gas/freon][MOLES] * INVERSE(2.75), cached_gases[/datum/gas/bz][MOLES] * INVERSE(0.25))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/freon][MOLES] - heat_efficency * 2.75 < 0 ) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/healium, air)
	cached_gases[/datum/gas/freon][MOLES] -= heat_efficency * 2.75
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.25
	cached_gases[/datum/gas/healium][MOLES] += heat_efficency * 3

	SET_REACTION_RESULTS(heat_efficency * 3)
	var/energy_released = heat_efficency * HEALIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING

/**
 * Zauker Formation:
 *
 * Exothermic.
 * Requires Hypernoblium.
 */
/datum/gas_reaction/zauker_formation
	priority_group = PRIORITY_FORMATION
	name = "Zauker Formation"
	id = "zauker_formation"
	desc = "Production of zauker using hyper-noblium and nitrium under very high temperatures."

/datum/gas_reaction/zauker_formation/init_reqs()
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = ZAUKER_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = ZAUKER_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/zauker_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/heat_efficency = min(temperature * ZAUKER_FORMATION_TEMPERATURE_SCALE, cached_gases[/datum/gas/hypernoblium][MOLES] * INVERSE(0.01), cached_gases[/datum/gas/nitrium][MOLES] * INVERSE(0.5))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/hypernoblium][MOLES] - heat_efficency * 0.01 < 0 ) || (cached_gases[/datum/gas/nitrium][MOLES] - heat_efficency * 0.5 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/zauker, air)
	cached_gases[/datum/gas/hypernoblium][MOLES] -= heat_efficency * 0.01
	cached_gases[/datum/gas/nitrium][MOLES] -= heat_efficency * 0.5
	cached_gases[/datum/gas/zauker][MOLES] += heat_efficency * 0.5

	SET_REACTION_RESULTS(heat_efficency * 0.5)
	var/energy_used = heat_efficency * ZAUKER_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB)
	return REACTING


/**
 * Zauker Decomposition:
 *
 * Occurs in the presence of nitrogen to prevent zauker floods.
 * Exothermic.
 */
/datum/gas_reaction/zauker_decomp
	priority_group = PRIORITY_POST_FORMATION
	name = "Zauker Decomposition"
	id = "zauker_decomp"
	desc = "Decomposition of zauker when exposed to nitrogen."

/datum/gas_reaction/zauker_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/zauker = MINIMUM_MOLE_COUNT,
	)

/datum/gas_reaction/zauker_decomp/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/burned_fuel = min(ZAUKER_DECOMPOSITION_MAX_RATE, cached_gases[/datum/gas/nitrogen][MOLES], cached_gases[/datum/gas/zauker][MOLES])
	if (burned_fuel <= 0 || cached_gases[/datum/gas/zauker][MOLES] - burned_fuel < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/zauker][MOLES] -= burned_fuel
	ASSERT_GAS(/datum/gas/oxygen, air)
	cached_gases[/datum/gas/oxygen][MOLES] += burned_fuel * 0.3
	ASSERT_GAS(/datum/gas/nitrogen, air)
	cached_gases[/datum/gas/nitrogen][MOLES] += burned_fuel * 0.7

	SET_REACTION_RESULTS(burned_fuel)
	var/energy_released = ZAUKER_DECOMPOSITION_ENERGY * burned_fuel
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING
*/

// Proto-Nitrate UNIMPLEMENTED

/**
 * Proto-Nitrate formation:
 *
 * Exothermic.
 *
/datum/gas_reaction/proto_nitrate_formation
	priority_group = PRIORITY_FORMATION
	name = "Proto Nitrate Formation"
	id = "proto_nitrate_formation"
	desc = "Production of proto-nitrate from pluoxium and hydrogen under high temperatures."

/datum/gas_reaction/proto_nitrate_formation/init_reqs()
	requirements = list(
		/datum/gas/pluoxium = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = PN_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/proto_nitrate_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/heat_efficency = min(temperature * 0.005, cached_gases[/datum/gas/pluoxium][MOLES] * INVERSE(0.2), cached_gases[/datum/gas/hydrogen][MOLES] * INVERSE(2))
	if (heat_efficency <= 0 || (cached_gases[/datum/gas/pluoxium][MOLES] - heat_efficency * 0.2 < 0 ) || (cached_gases[/datum/gas/hydrogen][MOLES] - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	ASSERT_GAS(/datum/gas/proto_nitrate, air)
	cached_gases[/datum/gas/hydrogen][MOLES] -= heat_efficency * 2
	cached_gases[/datum/gas/pluoxium][MOLES] -= heat_efficency * 0.2
	cached_gases[/datum/gas/proto_nitrate][MOLES] += heat_efficency * 2.2

	SET_REACTION_RESULTS(heat_efficency * 2.2)
	var/energy_released = heat_efficency * PN_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING

/**
 * Proto-Nitrate Hydrogen Conversion
 *
 * Converts hydrogen into proto-nitrate.
 * Endothermic.
 */
/datum/gas_reaction/proto_nitrate_hydrogen_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate Hydrogen Response"
	id = "proto_nitrate_hydrogen_response"
	desc = "Conversion of hydrogen into proto nitrate."

/datum/gas_reaction/proto_nitrate_hydrogen_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = PN_HYDROGEN_CONVERSION_THRESHOLD,
	)

/datum/gas_reaction/proto_nitrate_hydrogen_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/produced_amount = min(PN_HYDROGEN_CONVERSION_MAX_RATE, cached_gases[/datum/gas/hydrogen][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES])
	if (produced_amount <= 0 || cached_gases[/datum/gas/hydrogen][MOLES] - produced_amount < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/hydrogen][MOLES] -= produced_amount
	cached_gases[/datum/gas/proto_nitrate][MOLES] += produced_amount * 0.5

	SET_REACTION_RESULTS(produced_amount * 0.5)
	var/energy_used = produced_amount * PN_HYDROGEN_CONVERSION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity - energy_used) / new_heat_capacity, TCMB)
	return REACTING

/**
 * Proto-Nitrate Tritium De-irradiation
 *
 * Converts tritium to hydrogen.
 * Releases radiation.
 * Exothermic.
 */
/datum/gas_reaction/proto_nitrate_tritium_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate Tritium Response"
	id = "proto_nitrate_tritium_response"
	desc = "Conversion of tritium into hydrogen that consumes a small amount of proto-nitrate."

/datum/gas_reaction/proto_nitrate_tritium_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_TRITIUM_CONVERSION_MIN_TEMP,
		"MAX_TEMP" = PN_TRITIUM_CONVERSION_MAX_TEMP,
	)

/datum/gas_reaction/proto_nitrate_tritium_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/produced_amount = min(air.temperature / 34 * (cached_gases[/datum/gas/tritium][MOLES] * cached_gases[/datum/gas/proto_nitrate][MOLES]) / (cached_gases[/datum/gas/tritium][MOLES] + 10 * cached_gases[/datum/gas/proto_nitrate][MOLES]), cached_gases[/datum/gas/tritium][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES] * INVERSE(0.01))
	if(cached_gases[/datum/gas/tritium][MOLES] - produced_amount < 0 || cached_gases[/datum/gas/proto_nitrate][MOLES] - produced_amount * 0.01 < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/proto_nitrate][MOLES] -= produced_amount * 0.01
	cached_gases[/datum/gas/tritium][MOLES] -= produced_amount
	ASSERT_GAS(/datum/gas/hydrogen, air)
	cached_gases[/datum/gas/hydrogen][MOLES] += produced_amount

	SET_REACTION_RESULTS(produced_amount)
	var/turf/open/location
	var/energy_released = produced_amount * PN_TRITIUM_CONVERSION_ENERGY
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder
	if (location && energy_released > PN_TRITIUM_CONVERSION_RAD_RELEASE_THRESHOLD * (air.volume / CELL_VOLUME) ** ATMOS_RADIATION_VOLUME_EXP)
		radiation_pulse(location, max_range = min(sqrt(produced_amount) / PN_TRITIUM_RAD_RANGE_DIVISOR, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE), threshold = PN_TRITIUM_RAD_THRESHOLD)

	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

/**
 * Proto-Nitrate BZase Action
 *
 * Breaks BZ down into nitrogen, helium, and plasma in the presence of proto-nitrate.
 */
/datum/gas_reaction/proto_nitrate_bz_response
	priority_group = PRIORITY_PRE_FORMATION
	name = "Proto Nitrate BZ Response"
	id = "proto_nitrate_bz_response"
	desc = "Breakdown of BZ into nitrogen, helium, and plasma by proto-nitrate under low temperatures."

/datum/gas_reaction/proto_nitrate_bz_response/init_reqs()
	requirements = list(
		/datum/gas/proto_nitrate = MINIMUM_MOLE_COUNT,
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PN_BZASE_MIN_TEMP,
		"MAX_TEMP" = PN_BZASE_MAX_TEMP,
	)

/datum/gas_reaction/proto_nitrate_bz_response/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/consumed_amount = min(air.temperature / 2240 * cached_gases[/datum/gas/bz][MOLES] * cached_gases[/datum/gas/proto_nitrate][MOLES] / (cached_gases[/datum/gas/bz][MOLES] + cached_gases[/datum/gas/proto_nitrate][MOLES]), cached_gases[/datum/gas/bz][MOLES], cached_gases[/datum/gas/proto_nitrate][MOLES])
	if (consumed_amount <= 0 || cached_gases[/datum/gas/bz][MOLES] - consumed_amount < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_gases[/datum/gas/bz][MOLES] -= consumed_amount
	ASSERT_GAS(/datum/gas/nitrogen, air)
	cached_gases[/datum/gas/nitrogen][MOLES] += consumed_amount * 0.4
	ASSERT_GAS(/datum/gas/helium, air)
	cached_gases[/datum/gas/helium][MOLES] += consumed_amount * 1.6
	ASSERT_GAS(/datum/gas/plasma, air)
	cached_gases[/datum/gas/plasma][MOLES] += consumed_amount * 0.8

	SET_REACTION_RESULTS(consumed_amount)
	var/turf/open/location
	var/energy_released = consumed_amount * PN_BZASE_ENERGY
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder
	if (location && energy_released > PN_BZASE_RAD_RELEASE_THRESHOLD * (air.volume / CELL_VOLUME) ** ATMOS_RADIATION_VOLUME_EXP)
		///How many nuclear particles will fire in this reaction.
		var/nuclear_particle_amount = min(round(consumed_amount / PN_BZASE_NUCLEAR_PARTICLE_DIVISOR), PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM)
		for(var/i in 1 to nuclear_particle_amount)
			location.fire_nuclear_particle()
		radiation_pulse(location, max_range = min(sqrt(consumed_amount - nuclear_particle_amount * PN_BZASE_NUCLEAR_PARTICLE_RADIATION_ENERGY_CONVERSION) / PN_BZASE_RAD_RANGE_DIVISOR, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE), threshold = PN_BZASE_RAD_THRESHOLD)
		visible_hallucination_pulse(location, 1, consumed_amount * 2 SECONDS)

	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING

#undef SET_REACTION_RESULTS
*/
