extends RefCounted

const BalanceConfig = preload("res://scripts/config/BalanceConfig.gd")

func run() -> bool:
	var required_positive := [
		BalanceConfig.STARTING_CREDITS,
		BalanceConfig.PASSIVE_INCOME_PER_SECOND,
		BalanceConfig.COST_ANALYST_BATCH,
		BalanceConfig.ANALYSTS_PER_BATCH,
		BalanceConfig.COST_AUDITOR_HERO,
		BalanceConfig.COST_TOWER_UPGRADE_L1_TO_L2,
		BalanceConfig.COST_TOWER_UPGRADE_L2_TO_L3,
		BalanceConfig.KILL_REWARD_UNIT,
		BalanceConfig.KILL_REWARD_TOWER,
		BalanceConfig.KILL_REWARD_HQ,
		BalanceConfig.KILL_REWARD_ACCENTURE_MOB,
	]
	for value in required_positive:
		if float(value) <= 0.0:
			print("Balance value should be positive but was ", value)
			return false
	return true
