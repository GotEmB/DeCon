# Fluent Stuff
Object::toDictionary = ->
	ret = []
	for key of this
		if key isnt "__proto__" and key isnt "toDictionary"
			ret.push
				key: key
				value: this[key]
	ret

Array::select = (fun) ->
	ret = []
	@forEach (item) -> ret.push fun(item)
	ret

Array::where = (fun) ->
	ret = []
	@forEach (item) -> ret.push item if fun(item) is true
	ret

Array::first = (fun) ->
	if @length is 0
		null
	else if fun
		@where(fun).first()
	else
		@[0]

Array::last = (fun) ->
	if @length is 0
		null
	else if fun
		@where(fun).last()
	else
		@[@length - 1]

Array::contains = (item) -> @where((x) -> x is item).length > 0

Array::any = (fun) -> @where(fun).length > 0

Array::all = (fun) -> @where(fun).length is @length

Array::sum = (fun) ->
	return @where(fun).sum() if fun
	ret = 0
	@forEach (x) -> ret += x
	ret

Array::except = (arr) ->
	ret = [];
	@forEach (x) -> ret.push x unless arr.contains x
	ret

Array::flatten = ->
	ret = [];
	@forEach (x) -> x.forEach (y) -> ret.push y
	ret

Array::selectMany = (fun) ->
	@select(fun).flatten()

Array::groupBy = (fun) ->
	g1 = @select (x) ->
		key: fun x
		value: x
	while g1.length isnt 0
		g2 = g1.where (x) -> x.key is g1.first().key
		g1 = g1.except g1.where (x) -> x.key is g1.first().key
		key: g2.first().key
		values: g2.select (x) -> x.value

Array::orderBy = (fun) ->
	ret = @select (x) -> x
	ret.sort (a, b) -> fun(a) - fun(b)
	ret

Array::orderByDesc = (fun) ->
	ret = @select (x) -> x
	ret.sort (a, b) -> fun(b) - fun(a)
	ret

# JSON extension
JSON.parseWithDate = (json) ->
	reISO = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/
	reMsAjax = /^\/Date\((d|-|.*)\)\/$/
	JSON.parse json, (key, value) ->
		if typeof value is "string"
			a = reISO.exec(value)
			return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6])) if a
			a = reMsAjax.exec(value)
			if a
				b = a[1].split(/[-,.]/)
				return new Date(+b[0])
		value