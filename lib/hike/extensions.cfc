/**
* @name Extensions
* @extends normalized_array
* @hint 
*/
component {
	public any function init() {
		NormalizedArray.init(this);
		return this;
	}

	public any function clone() {
		var obj = new Extensions();

		obj.prepend(this.toArray());

		return obj;
	}
}