extends Object
class_name Line

export var StartPoint := Vector2(0,0);
export var EndPoint := Vector2(0,0);

func _init(startPoint := Vector2(0,0), endPoint := Vector2(0,0)):
	StartPoint = startPoint;
	EndPoint = endPoint;
	

func is_on_line(point : Vector2, epsilon := 0.1) -> bool:
	var paramVec := EndPoint - StartPoint;
	if paramVec == Vector2(0,0):
		return false # We don't have a line
	var r := calcR(paramVec.x, point.x, StartPoint.x)
	var r2 := calcR(paramVec.y, point.y, StartPoint.y)
	return abs(r -r2) < epsilon && r < 1 && r > 0;

func calcR(param : float, point : float, startpoint : float) -> float:
	if param == 0:
		return 0.0
	return (point - startpoint) / param
