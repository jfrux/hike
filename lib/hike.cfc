/**
* @name Hike.cfc
* @hint A port of Hike (ruby) for Coldfusion
* @introduction
*/
component {
	public any function init(obj = {}) {
		this.obj = arguments.obj;

		// _ is referenced throughout this cfc
		variables._ = this;

		// used as the default iterator
		_.identity = function(x) { return x; };

		// for uniqueId
		variables.counter = 1;

		return this;
	}
}