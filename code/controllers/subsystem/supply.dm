SUBSYSTEM_DEF(supply)
	name = "Supply"
	//Get a new stock update every 2 minutes
	wait = 2 MINUTES
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME

	/// All of the possible supply packs that can be purchased by cargo.
	var/list/supply_packs = list()

	/// Queued supplies to be purchased for the chef.
	var/list/chef_groceries = list()

	/// Queued supply packs to be purchased.
	var/list/shoppinglist = list()

	/// Wishlist items made by crew for cargo to purchase at their leisure.
	var/list/requestlist = list()

	/// A listing of previously delivered supply packs.
	var/list/orderhistory = list()

	/// order number given to next order
	var/ordernum = 1

/datum/controller/subsystem/supply/Initialize(timeofday)
	ordernum = rand(1, 9000)

	for(var/pack in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new pack()
		if(!P.contains)
			continue
		supply_packs[P.type] = P
	return ..()

/datum/controller/subsystem/supply/fire()
	var/total_restock_required = 0
	var/list/restock_list = list()
	//Build a list of everything that needs restocking
	for(var/type in supply_packs)
		var/datum/supply_pack/pack = supply_packs[type]
		if (pack.current_supply < pack.max_supply)
			total_restock_required += pack.max_supply - pack.current_supply
			restock_list[pack] = pack.max_supply - pack.current_supply
	//How much stock refilling should we do
	var/lower = sqrt(total_restock_required)
	var/upper = lower + total_restock_required / 10
	var/refill_amount = min(rand(lower, upper), total_restock_required)
	//Perform restocks
	while (refill_amount > 0 && length(restock_list))
		//Reduce the refill amount
		refill_amount --
		var/datum/supply_pack/selected = pick_weight(restock_list)
		selected.current_supply = min(selected.current_supply + 1, selected.max_supply)
		restock_list -= selected
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RESUPPLY)

/datum/controller/subsystem/supply/Recover()
	ordernum = SSsupply.ordernum
	if (istype(SSsupply.shoppinglist))
		shoppinglist = SSsupply.shoppinglist
	if (istype(SSsupply.requestlist))
		requestlist = SSsupply.requestlist
	if (istype(SSsupply.orderhistory))
		orderhistory = SSsupply.orderhistory
