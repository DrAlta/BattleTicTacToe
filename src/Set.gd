extends Object
class_name Set

var set : = []

func append( appendum: Array):
	for x in set:
		appendum.erase(x)

	for i in appendum:
		set.append(i)

func add(x):
	if not set.has(x):
		set.append(x)

func remove(x):
	set.erase(x)

func strip(s: Array):
	for x in s:
		set.erase(x)

func has(x):
	return(set.has(x))
