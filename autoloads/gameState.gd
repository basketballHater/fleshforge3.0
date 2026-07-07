extends Node
# GameState.gd

var active_player = 1

var customization_mode

var singleplayer_data: PlayerData = PlayerData.new()
var player1_data: VersusPlayerData = VersusPlayerData.new()
var player2_data: VersusPlayerData = VersusPlayerData.new()

func get_active_data() -> PlayerDataBase:
	if customization_mode == "versus":
		if active_player == 1:
			return player1_data
		else:
			return player2_data
	else:
		return singleplayer_data
