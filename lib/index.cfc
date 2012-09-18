/**
* 
* @name Index
* @hint 
*/
component extends="hike" {
	import "cf_modules.UnderscoreCF.*";
	import "cf_modules.Path.*";
	import "cf_modules.RegExp.RegExp";
	/**
	* new Index(root, paths, extensions, aliases)
	**/
	public any function init(root, paths, extensions, aliases) {
		variables._ = new Underscore();
		variables.Path = new Path();

		/** internal, read-only
		* Index#root -> String
		*
		* Root path. This attribute is immutable.
		**/
		this['root'] = arguments.root;

		// Freeze is used here so an error is throw if a mutator method
		// is called on the array. Mutating `paths`, `extensions`, or
		// `aliases` would have unpredictable results.

		/** read-only
		* Index#paths -> Paths
		*
		* Immutable (frozen) [[Paths]] collection.
		**/
		this['paths'] = arguments.paths.clone();

		/** read-only
		* Index#extensions -> Extensions
		*
		* Immutable (frozen) [[Extensions]] collection.
		**/
		this['extensions'] = arguments.extensions.clone();

		/** read-only
		* Index#aliases -> Aliases
		*
		* Immutable map of aliases.
		**/
		this['aliases'] = arguments.aliases.clone();

		// internal cache
		this['__entries__'] = {};
		this['__patterns__'] = {};
		this['__stats__'] = {};

		return this;
	}


	//PRIVATE
	private function sort_matches(self, matches, basename) {
	  var aliases = self.aliases.get(path.extname(basename)).toArray();

	  return _.sortBy(matches, function (match) {
	    var extnames = ListToArray(replace(basename, '','all'),".");
	    return extnames.reduce(function (sum, ext) {
	      ext = '.' + ext;

	      if (0 <= self.extensions.indexOf(ext)) {
	        return sum + self.extensions.indexOf(ext) + 1;
	      } else if (0 <= aliases.indexOf(ext)) {
	        return sum + aliases.indexOf(ext) + 11;
	      } else {
	        return sum;
	      }
	    }, 0);
	  });
	}


	//HELPERS
	// escape special chars.
	// so the string could be safely used as literal in the RegExp.
	public any function regexp_escape(str) {
	  return rereplaceNoCase(str,"([.?*+{}()\[\]])",'\\$1','all');
	}

	// tells whenever pathname seems like a relative path or not
	public any function is_relative(pathname) {
	  return (arrayLen(reMatchNoCase("^\.{1,2}\/",pathname)) GT 0);
	}

	// Returns a `Regexp` that matches the allowed extensions.
	//
	// pattern_for(self, "index.html");
	// // -> /^index(.html|.htm)(.builder|.erb)*$/
	public any function pattern_for(self, basename) {
	  var aliases = [];
	  var extname = "";
	  var pattern = "";

	  if (NOT structKeyExists(self.__patterns__,basename)) {
	    extname = path.extname(basename);
	    aliases = self.aliases.get(extname).toArray();

	    if (0 EQ arrayLen(aliases)) {
	      pattern = regexp_escape(basename);
	    } else {
	      basename = path.basename(basename, extname);
	      aliases.addAll(extname);
	      pattern = regexp_escape(basename) & '(?:' & _.map(aliases, regexp_escape).join('|') & ')';
	    }

	    pattern &= '(?:' & arrayToList(_.map(self.extensions.toArray(), regexp_escape),'|') & ')*';
	    self.__patterns__[basename] = new RegExp('^' & pattern & '$');
	  }

	  return self.__patterns__[basename];
	}


	// Checks if the path is actually on the file system and performs
	// any syscalls if necessary.
	public any function match(self, dirname, basename, fn) {
	  var ret = "";
	  var pathname = "";
	  var stats = "";
	  var pattern = "";
	  var matches = self.entries(dirname);

	  pattern = pattern_for(self, basename);
	  matches = arrayFilter(matches,function (m) { return pattern.test(m); });
	  matches = sort_matches(self, matches, basename);

	  while (arrayLen(matches) AND "" EQ ret) {
	  	arrayDeleteAt(matches,1);
	    pathname = path.join(dirname,matches);
	    stats = getFileInfo(pathname);
	    WriteLog (text="match[#pathname#]", type="info", file="finds");
	    
	    if (stats && stats.isFile()) {
	      ret = fn(pathname);
	    }
	  }

	  return ret;
	}


	// Returns true if `dirname` is a subdirectory of any of the `paths`
	public any function contains_path(self, dirname) {
	  return _.any(self.paths.toArray(), function (path) {
	    return (path EQ mid(dirname,0, path.length));
	  });
	}

	// Finds relative logical path, `../test/test_trail`. Requires a
	// `base_path` for reference.
	public any function find_in_base_path (self, logical_path, base_path, fn) {
		WriteLog (text="find_in_base_path[#logical_path#]", type="info", file="finds");
	    
	  var candidate = path.resolve(base_path, logical_path);
	  var dirname = path.dirname(candidate);
	  var basename = path.basename(candidate);

	  if (contains_path(self, dirname)) {
	    return match(self, dirname, basename, fn);
	  }
	}

	// Finds logical path across all `paths`
	public any function find_in_paths(self, logical_path, fn) {
		WriteLog (text="find_in_path[#logical_path#]", type="info", file="finds");
	    
	  var dirname = path.dirname(logical_path);
	  var basename = path.basename(logical_path);
	  var paths = self.paths.toArray();
	  var pathname = "";
	  while (arrayLen(paths) AND "" EQ pathname) {
	  	paths = paths.subList(0,1);
	  	WriteLog (text="find_in_path while loop[#dirname#, #basename#, #fn#]", type="info", file="finds");
	    
	    pathname = match(self, path.resolve(paths, dirname), basename, fn);
	  }

	  return pathname;
	}

	// PUBLIC //////////////////////////////////////////////////////////////////////
	/**
	* Index#index -> Index
	*
	* Self-reference to be compatable with the [[Trail]] interface.
	**/
	public any function get() {
		return this;
	};


	/**
	* Index#find(logical_paths[, options][, fn]) -> String
	*
	* The real implementation of `find`.
	* [[Trail#find]] generates a one time index and delegates here.
	*
	* See [[Trail#find]] for usage.
	**/
	public any function find(logical_paths, options, fn) {
		var pathname = "";
		var base_path = "";
		var logical_path = "";
		var func = (structKeyExists(arguments,"fn"))? arguments.fn : "";
		var opts = (structKeyExists(arguments,"options") AND isStruct(arguments.options))? arguments.options : {};
		WriteLog (text="[#func#]", type="info", file="finds");
	    
		if (!_.isFunction(func) AND _.isFunction(opts)) {
		    func = opts;
		    opts = {};
	  } else if (!_.isFunction(func)) {
	    return this.find(logical_paths, opts, function (p) {
	      return p;
	    });
	  }

	  base_path = (structKeyExists(opts,'basePath'))? opts.basePath : this.root;
	  logical_paths = _.isArray(logical_paths) ? logical_paths : [logical_paths];

	  while (arrayLen(logical_paths) GT 0 AND ("" EQ pathname)) {
	  	arrayDeleteAt(logical_paths,arrayLen(logical_paths));
	    logical_path = rereplace(arrayToList(logical_paths,"/"),"^\/", '',"ALL");
	    WriteLog (text="[#logical_path#]", type="info", file="finds");
	    if (is_relative(logical_path)) {
	      pathname = find_in_base_path(this, logical_path, base_path, func);
	    } else {
	      pathname = find_in_paths(this, logical_path, func);
	    }
	  }

	  return pathname;
	};


	/**
	* Index#entries(pathname) -> Array
	* - pathname(String): Pathname to get files list for.
	*
	* A cached version of `fs.readdirSync` that filters out `.` files and
	* `~` swap files. Returns an empty `Array` if the directory does
	* not exist.
	**/
	public any function entries(pathname = "") {
		var thePath = arguments.pathname;

	  if (NOT structKeyExists(this.__entries__,thePath)) {
	    this.__entries__[thePath] = [];
		 if(directoryExists(this.root & "/" & thePath)) {
		 	thePaths = directoryList(this.root & "/" & thePath,true,"name");
		 	thePaths = ArrayFilter(thePaths,function(a) {
				var regex = new RegExp("^\.|~$|^\##.*\##$");
				return !regex.test(a);
			});

			this.__entries__[thePath] = thePaths;
		  };
	    // try {


	    // } catch (any err) {
	    //   if ('ENOENT' NEQ err.code) {
	    //     throw err;
	    //   }
	    // }
	  }

	  return this.__entries__[pathname];
	};


	/**
	* Index#stat(pathname) -> Stats|Null
	* - pathname(String): Pathname to get stats for.
	*
	* Cached version of `path.statsSync()`.
	* Retuns `null` if file does not exists.
	**/
	public any function stat(pathname) {
		if (structKeyExists(this.__stats__,pathname)) {
		    try {
				this.__stats__[pathname] = "";
				this.__stats__[pathname] = GetFileInfo(pathname);
		    } catch (any err) {
		      if ('ENOENT' NEQ err.code) {
		        throw err;
		      }
		    }

	  		return this.__stats__[pathname];
		}

		return {};
	};

	public array function filterArray(Array a, function filter) 
    { 
        resultarray = arraynew(1); 
            for(i=1;i<=ArrayLen(a);i++) 
            { 
                if(filter(a[i])) 
                ArrayAppend(resultarray,a[i]); 
            } 
        return resultarray; 
    } 
}

// Sorts candidate matches by their extension priority.
// Extensions in the front of the `extensions` carry more weight.
