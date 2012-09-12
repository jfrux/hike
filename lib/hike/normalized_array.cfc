import "vendor/underscore"

/**
* @name normalized_array
* @hint 
*/
component accessors=true {
	property name="self"
			type="this";
	property name="frozen"
			type="boolean"
			getter="true"
			default="false";
	property name="arr"
			type="array"
			default="#arrayNew()#";

	public any function init() {
		variables._ = new vendor.underscore();

		return this;
	}
}