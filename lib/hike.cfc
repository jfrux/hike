import "modules.foundry.lib.*";
import "modules.underscorecf.*";
import "trail";
/**
* @name Hike.cfc
* @hint A port of Hike (ruby) for Coldfusion
* @introduction test
*/
component {
	
	property name="Trail" type="any";

	public any function init() {
		var _ = new underscore();
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