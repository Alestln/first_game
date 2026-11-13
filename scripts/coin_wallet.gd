class_name CoinWallet
extends Node

signal coins_changed(new_coins: int)

const MIN_COINS: int = 0

var _coins: int = MIN_COINS

var coins: int:
	get:
		return _coins

func add_coins(amount: int) -> void:
	assert(amount > 0, "%s: количество монет должно быть больше 0 (передано: %d)!" % [name, amount])
	_set_coins(_coins + amount)

func _set_coins(value: int) -> void:
	_coins = max(MIN_COINS, value)
	coins_changed.emit(_coins)
