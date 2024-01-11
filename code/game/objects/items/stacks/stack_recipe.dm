/*
 * Recipe datum
 */
/datum/stack_recipe
	///The name of the recipe
	var/title = "ERROR"
	///The thing we get from doing the recipe
	var/result_type
	///The amount of type of material we need
	var/req_amount = 1
	///The amount of thing we make
	var/res_amount = 1
	///The maximum amount of thing we can get from crafting
	var/max_res_amount = 1
	///The time it takes to make
	var/time = 0
	///Can we have only one instance of recipe result per turf?
	var/one_per_turf = FALSE
	///Can we make the result on non-solid turfs (space)
	var/on_floor = FALSE
	///Do we do placement checks while placing the recipe?
	var/placement_checks = FALSE
	var/applies_mats = FALSE

/datum/stack_recipe/New(
	title,
	result_type,
	req_amount = 1,
	res_amount = 1,
	max_res_amount = 1,
	time = 0,
	one_per_turf = FALSE,
	on_floor = FALSE,
	window_checks = FALSE,
	placement_checks = FALSE,
	applies_mats = FALSE
)

	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.placement_checks = placement_checks
	src.applies_mats = applies_mats

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes
