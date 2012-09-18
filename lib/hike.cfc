/**
* @name Hike.cfc
* @hint A port of Hike (ruby) for Coldfusion
* @introduction
*/
component {
	
	property name="Trail" type="any";


	import "cf_modules.UnderscoreCF.underscore";
	import "hike.trail";
	public any function init() {
		var _ = new vendor.underscore();
		this.Trail = createObject("component","hike.trail");
		return this;
	}

	public any function include() {
		var object = (arrayLen(structKeyArray(arguments)) >= 1) ? arguments[1] : this;

		for (i=2;i <= arrayLen(structKeyArray(arguments));i++) {
			__extend(object,arguments[i]);
		}
	}

	function __extend(object, mixin) {
		var mixable = duplicate(mixin);

		for(property in SKIP_PROPERTIES) {
			mixable = structDelete(mixable,property);
		}

		structAppend(object,mixable,true);

		return object;
	}
	  
}