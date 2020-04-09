class_name Simulation
extends Node

var cities : Array
var citiesNode : Node2D
var cables : Array
var r_paths := []

func _init(_cities : Node2D):
	citiesNode = _cities

#
# Think about multithreading
#
func simulate(_cables : Array, mfac : float, ensure_full_maintenance : bool):
	randomize()
	cables = _cables
	cities = citiesNode.get_children()
	var router := []
	var connected_inhabitants := 0
	var inhabitants := 0
	var costs := 0
	for city in cities:
		if city.is_router:
			router.push_back(city)
		city.connected_inhabitants = 0
	var break_chance := _route_death_chance(mfac)
	for cnt in cables.duplicate():
		cnt.workload = 0
		costs += cnt.get_maintenance_costs()
		# Verbindungen warten und kaputtgehen lassen (Kaputte aus cables entfernt)
		if !ensure_full_maintenance && rand_range(0,1) < break_chance || cnt.broken:
			cables.erase(cnt)
			cnt.set_broken()
	
	# Städte nach Größe sortieren
	cities.sort_custom(City, "sort_inhabitants")
	
	# Verbindungen von Städten zu Router finden
	for city in cities:
		var c := city as City
		inhabitants += c.inhabitants
		if c.is_router:
			c.coverage = 1
			connected_inhabitants += c.inhabitants
			continue
		var paths = _find_paths_to_nodes(c, router)
		for path in paths:
			# Verbindungen auslasten
			# Städteanbindung berechnen
			var cpy := _get_path_capacity(path)
			if cpy == 0:
				continue
			if cpy < c.get_unconnected_inhabitants():
				c.connected_inhabitants += cpy
				connected_inhabitants += cpy
				_use_path(path, cpy)
			else:
				cpy = c.get_unconnected_inhabitants()
				c.connected_inhabitants += cpy
				connected_inhabitants += cpy
				_use_path(path, cpy)
				break
	# Geld berechnen
	return {
		coverage = connected_inhabitants / float(inhabitants),
		income = connected_inhabitants,
		maintenance = costs * mfac,
		router_size = router.size(),
	}


func _route_death_chance(mfac : float) -> float:
	return pow(0.6,0.4*mfac) - 0.7


func _get_path_capacity(path : Array) -> int:
	var capacity = 3000
	for cnt in path:
		if cnt.get_free_capacity() < capacity:
			capacity = cnt.get_free_capacity()
	return capacity


func _use_path(path : Array, capacity):
	for cnt in path:
		cnt.workload += capacity


func _find_paths_to_nodes(start : City, nodes : Array) -> Array:
	var paths := []
	for n in nodes:
		paths += _find_paths_to_node(start, n)
	paths.sort_custom(Cable, "sort_path_length")
	return paths


func _find_paths_to_node(start : City, dest : City) -> Array:
	r_paths.clear()
	_fptn(start, dest)
	return r_paths


func _fptn(start : City, dest : City, visited := [], cnts := [], cable = null):
	visited.push_back(start)
	if cable != null:
		cnts.push_back(cable)
	for p_cc in _find_connected_cities(start):
		var city := p_cc[0] as City
		var cnt := p_cc[1] as Cable
		if city in visited:
			continue
		if city == dest:
			r_paths.push_back(cnts + [cnt])
			continue
		_fptn(city, dest, visited.duplicate(), cnts.duplicate(), cnt)


func _find_connected_cities(city : City) -> Array:
	var result := []
	for cnt in cables:
		if cnt.from_city == city:
			result.push_back([cnt.to_city, cnt])
		elif cnt.to_city == city:
			result.push_back([cnt.from_city, cnt])
	return result


func _find_connections_with_city(city : City) -> Array:
	var result := []
	for cnt in cables:
		if cnt.from_city == city || cnt.to_city == city:
			result.push_back(cnt)
	return result
