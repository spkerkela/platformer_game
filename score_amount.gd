extends Label

var score = 0

func _ready():
	for coin in get_node("/root/stage/coins").get_children():
		coin.connect("coin_taken", self, "_score_changed")
	self.text = str(score)


func _score_changed():
	score += 1
	self.text = str(score)

func _at_score_changed():
    self.connect("coin_taken", self, "_score_changed")