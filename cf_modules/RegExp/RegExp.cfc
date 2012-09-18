component {
	property type="string" name="regexp";

	public any function init(required regexp, global = false, insensitive = false) {
		this.regexp = arguments.regexp;
		this.insensitive = arguments.insensitive;
		this.global = arguments.global;
	}

	public any function test(str) {
		var matches = [];

		if(this.insensitive) {
			matches = reMatchNoCase(this.regexp,arguments.str);
		} else {
			matches = reMatch(this.regexp,arguments.str);
		}

		if(arrayLen(matches) GT 0) {
			return true;
		} else {
			return false;
		}
	}
}