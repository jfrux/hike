/**
* @name Paths.cfc
* @hint 
*/
component extends="normalized_array" {
	property name="__root__" type="string";
	import "cf_modules.cf-path.path";
	public any function init(root = "") {
		super.init(this);
		variables.path = new Path();
		variables._ = new cf_modules.UnderscoreCF.Underscore();
		this.__root__ = arguments.root;
		return this;
	}

	// require('util').inherits(Paths, NormalizedArray);


	/**
	 *  Paths#clone() -> Paths
	 *
	 *  Return copy of the instance.
	 **/
	public any function clone() {
	  var obj = this.init(this.__root__);
	  obj.prepend(this.toArray());
	  return obj;
	};


	/**
	 *  Paths#normalize(path) -> String
	 *
	 *  Relative paths added to this array are expanded relative to `root`.
	 *
	 *      paths = new Paths("/usr/local");
	 *
	 *      paths.append("tmp");
	 *      paths.append("/tmp");
	 *
	 *      paths.toArray();
	 *      // -> ["/usr/local/tmp", "/tmp"]
	 **/
	public any function normalize(p) {
	  if ('/' NEQ left(p,1)) {
	    p = path.resolve(this.__root__, p);
	  }

	  return path.normalize(p);
	};

}