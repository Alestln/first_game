extends Label

@export var coin_wallet: CoinWallet

func _ready() -> void:
	assert(coin_wallet != null, "%s: 'coin_wallet' обязателен для работы!" % name)
	
	coin_wallet.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(coin_wallet.coins)

func _on_coins_changed(new_coins: int) -> void:
	text = str(new_coins)
