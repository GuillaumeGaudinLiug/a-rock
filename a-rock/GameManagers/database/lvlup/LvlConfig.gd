# LvlConfig.gd (Autoload)

const INVESTABLE_STATS := ["determination", "courage", "passion", "spirit", "adaptability"]
@export var max_lvl_for_stats: int = 30
@export var ep_bonus_per_stat: Dictionary = {
	"determination": 1, "courage": 2, "passion": 0, "spirit": 1, "adaptability": 1
}
@export var sp_bonus_per_stat: Dictionary = {
	"determination": 0, "courage": 0, "passion": 2, "spirit": 2, "adaptability": 1,
}

@export var stat_level_costs: Array[ProgressionLevelEntry] = []  # index 0 = coût du 1er stat_level, etc.


func get_stat_level_cost(total_stat_levels_done: int) -> int:
	if total_stat_levels_done < 0 or total_stat_levels_done >= stat_level_costs.size():
		push_warning("BalanceConfig: pas de coût défini pour le stat_level n°%d." % total_stat_levels_done)
		return -1  # coût invalide : signale qu'on a dépassé la table (voir plus bas)
	return stat_level_costs[total_stat_levels_done].xp_required
