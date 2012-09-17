/**
* @name Common.cfc
* @hint 
*/
component extends="hike" {
	import "cf_modules.UnderscoreCF.underscore";
	public any function init() {
		return this;
	}


	// helper that stubs `obj` with methods throwing error when they are called
	public any function stub(obj, methods, msg) {
	  _ = new Underscore();
	  var theMsg = (!_.isEmpty(arguments.msg)) ? (": " & arguments.msg) : "";
	  obj[methods[1]] = function() {
	      throw "Can't call `" & method & "()`" & theMsg;
	    };
	};
}