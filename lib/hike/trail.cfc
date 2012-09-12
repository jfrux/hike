import "vendor/Underscore"
import "index"
import "paths"
import "extensions"
import "common"
import "aliases"

function index_proxy(proto, func) {
  proto[func] = function () {
    var index = this.index;
    return index[func].apply(index, arguments);
  };
}

/**
* @name Trail.cfc
* @hint Public container class for holding paths and extensions.
*/
component {
	public any function init() {
		// _ is referenced throughout this cfc
		variables._ = new vendor.Underscore;
		variables.Paths = new paths();
		variables.Extensions = new extensions();
		variables.Aliases = new aliases();
		variables.prop = new common().prop;

		return this;
	}
}