extends Button

export var week := 1


func update_timer(cov_weeks : int, vic_weeks : int):
	week += 1
	$Label.text = "W%d %d/%d\nNext Week" % [week, cov_weeks, vic_weeks]

func reset_timer(vic_weeks : int):
	week = 0
	update_timer(0, vic_weeks)

func show_simulate():
	$Label.text = "Simulating..."
