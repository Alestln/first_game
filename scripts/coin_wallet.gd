class_name CoinWallet
extends Node

signal coins_changed(new_coins: int)

const MIN_COINS: int = 0

var _coins: int = MIN_COINS

func get_coins() -> int:
	return _coins

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	_set_coins(_coins + amount)

func _set_coins(value: int) -> void:
	_coins = max(MIN_COINS, value)
	coins_changed.emit(_coins)
