import "cf_modules.*";
/**
* @name Path.cfc
* @hint A port of Node.js Path for Coldfusion
* @author Joshua F. Rountree (http://www.joshuairl.com/)
*/
component accessors=true {
	property name="sep"
	type="string";

	public function init() {
		variables._ = new underscore.Underscore();
		variables.console = new Console.Console();
		console.config("testing this out");
		variables.isWindows = server.os === "Windows";
		variables.jpath = createObject("java","org.apache.commons.io.FilenameUtils");
		variables.jregex = createObject("java","java.util.regex.Pattern");
		this.setSep(sep());
		return this;
	}

	/**
	* 	@header path.normalize(p)
	*	@hint Normalize a string path, taking care of '..' and '.' parts.<br /><br />When multiple slashes are found, they're replaced by a single one; when the path contains a trailing slash, it is preserved. On windows backslashes are used. 
	* 	@example path.normalize('/foo/bar//baz/asdf/quux/..')<br />// returns<br />'/foo/bar/baz/asdf'
	*   @author S. Isaac Dealey (info@turnkey.to) 
	*/
	public string function normalize(p) {
		var thePath = jpath.separatorsToSystem(arguments.p);
			
		//windows
		if(isWindows) {
			// var result = splitDeviceRe.exec(path),
			//        device = result[1] || '',
			//        isUnc = device && device.charAt(1) !== ':',
			//        isAbsolute = !!result[2] || isUnc, // UNC paths are always absolute
			//        tail = result[3],
			//        trailingSlash = /[\\\/]$/.test(tail);

			//    // Normalize the tail path
			//    tail = normalizeArray(tail.split(/[\\\/]+/).filter(function(p) {
			//      return !!p;
			//    }), !isAbsolute).join('\\');

			//    if (!tail && !isAbsolute) {
			//      tail = '.';
			//    }
			//    if (tail && trailingSlash) {
			//      tail += '\\';
			//    }

			//    // Convert slashes to backslashes when `device` points to an UNC root.
			//    device = device.replace(/\//g, '\\');

			//    return device + (isAbsolute ? '\\' : '') + tail;
		//posix
		} else {
			// var isAbsolute = path.charAt(0) === '/',
			//        trailingSlash = path.substr(-1) === '/';

			//    // Normalize the path
			//    path = normalizeArray(path.split('/').filter(function(p) {
			//      return !!p;
			//    }), !isAbsolute).join('/');

			//    if (!path && !isAbsolute) {
			//      path = '.';
			//    }
			//    if (path && trailingSlash) {
			//      path += '/';
			//    }

			//    return (isAbsolute ? '/' : '') + path;

		    var isAbsolute = charAt(thePath,1) === "/";
	        var trailingSlash = right(thePath,1) === "/";
			var splitPaths = listToArray(thePath,"/");
			
			splitPaths = arrayFilter(splitPaths,function(p) {
				return !_.isEmpty(arguments.p);
			});

			splitPaths = normalizeArray(splitPaths,(!isAbsolute));
			//Back to a string path
			thePath = ArrayToList(splitPaths,"/");

	        if(_.isEmpty(thePath) && !isAbsolute) {
	        	thePath = ".";
	        }
	        if(!_.isEmpty(thePath) && trailingSlash) {
	        	thePath &= getSep();
	        }
	        return (isAbsolute ? getSep() : '') & thePath;
		}
		
	}

	/**
	* 	@header path.extname(p)
	*	@hint Return the extension of the path, from the last '.' to end of string in the last portion of the path. If there is no '.' in the last portion of the path or the first character of it is '.', then it returns an empty string. Examples: 
	* 	@example path.extname('index.html')<br />// returns<br />'.html'<br /><br />path.extname('index.')<br />// returns<br />'.'<br /><br />path.extname('index')<br />// returns<br />''
	* 	@author Alexander Sicular &amp; Raymond Camden
	*/
	public string function extname(p) {
		return splitPath(arguments.p)[4];
	}

	/**
	* 	@header path.resolve([from ...], to)
	*	@hint Resolves to <pre>to</pre> an absolute path.<br><br>If to isn't already absolute from arguments are prepended in right to left order, until an absolute path is found. If after using all from paths still no absolute path is found, the current working directory is used as well. The resulting path is normalized, and trailing slashes are removed unless the path gets resolved to the root directory. Non-string arguments are ignored.<br><br>Another way to think of it is as a sequence of cd commands in a shell. 
	* 	@example path.resolve('/foo/bar', './baz')<br />// returns<br />'/foo/bar/baz'<br /><br />path.resolve('/foo/bar', '/tmp/file/')<br />// returns<br />'/tmp/file'<br /><br />path.resolve('wwwroot', 'static_files/png/', '../gif/image.gif')<br />// if currently in /home/myself/node, it returns'/home/myself/node/wwwroot/static_files/gif/image.gif'
	*/
	public string function resolve() {
		var resolvedPath = '';
        var resolvedAbsolute = false;
	    for (var i = arrayLen(structKeyArray(arguments)); i >= 1 && !resolvedAbsolute; i--) {
	      var path = (i >= 1) ? arguments[i] : expandPath("/");
	      
	      // Skip empty and invalid entries
	      if (NOT _.isString(path) || NOT _.isEmpty(path)) {
	        continue;
	      }

	      resolvedPath = expandPath(path & '/' & resolvedPath);
	      resolvedAbsolute = isAbsolute(path);
	    }

	    return resolvedPath;
	}

	function join() {
		var joinArgs = arguments;
		var paths = [];
		if(isStruct(joinArgs)) {
		    for(i=1; i <= listLen(structKeyList(joinArgs));i++) {
		    	argValue = joinArgs[i];
		    	if (_.isString(argValue) AND len(trim(argValue)) GT 0) {
		    		paths.add(argValue);
				}
		    }
		} else {
			writeDump(label="join args",var=joinArgs,abort=true);
		}


	   	var joined = ArrayToList(paths,getSep());
	   	return normalize(joined);
	}

	//HELPERS
	function splitPath(filename) {
		//windows regex
		var splitDeviceRe = "^([\s\S]+[\\\/](?!$)|[\\\/])?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/\\]*)?)$";
		var splitTailRe = "^([\s\S]+[\\\/](?!$)|[\\\/])?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/\\]*)?)$";
		
		//posix regex
		var splitPathRe = "^(\/?)([\s\S]+\/(?!$)|\/)?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/]*)?)$";

		var result = [];
		var result2 = [];
		var device = "";
		var dir = "";
		var ext = "";
		var basename = "";
		var tail = "";

		//windows only
		if (isWindows) {
			result = ReMatchGroups(arguments.filename,splitDeviceRe);
				device = ((structKeyExists(result,'1') && !_.isEmpty(result['1']))? result['1'] : '') & ((structKeyExists(result,'2') && !_.isEmpty(result['2']))? result['2'] : '');
				tail = ((structKeyExists(result,'3') && !_.isEmpty(result['4']))? result['3'] : '');
			
			result2 = ReMatchGroups(tail);
				dir = ((structKeyExists(result2,'1') && !_.isEmpty(result2['1']))? result2['1'] : '');
				basename = ((structKeyExists(result2,'2') && !_.isEmpty(result2['2']))? result2['2'] : '');
				ext = ((structKeyExists(result2,'3') && !_.isEmpty(result2['3']))? result2['3'] : '');

		//posix only
		} else {
			result = ReMatchGroups(arguments.filename,splitPathRe);
			device = ((structKeyExists(result,'1') && !_.isEmpty(result['1']))? result['1'] : '');
			dir = ((structKeyExists(result,'2') && !_.isEmpty(result['2']))? result['2'] : '');
			basename = ((structKeyExists(result,'3') && !_.isEmpty(result['3']))? result['3'] : '');
			ext = ((structKeyExists(result,'4') && !_.isEmpty(result['4']))? result['4'] : '');
			
		};

		return [device,dir,basename,ext];
	}

	function normalizeArray(parts, allowAboveRoot) {
	  // if the path tries to go above the root, `up` ends up > 0
	  var up = 0;
	  for (var i = arrayLen(parts) - 1; i >= 1; i--) {
	    var last = parts[i];
	    if (last === '.') {
	      _.splice(parts,i, 1);
	    } else if (last === '..') {
	      _.splice(parts,i, 1);
	      up++;
	    } else if (up) {
	      _.splice(parts,i, 1);
	      up--;
	    }

	  }

	  // if the path is allowed to go above the root, restore leading ..s
	  if (allowAboveRoot) {
	    for (; up--; up) {
	    	unshift(parts,'..');
	    }
	  }

	  return parts;
	}

	public any function dirname(path) {
	  var result = splitPath(path);
	  var root = result[1];
	  var dir = result[2];
	 if (_.isEmpty(root) && _.isEmpty(dir)) {
	    // No dirname whatsoever
	    return '.';
	  }

	  if (!_.isEmpty(dir)) {
	    // It has a dirname, strip trailing slash
	    dir = left(dir,len(dir)-1);
	  }
	  return root & dir;
	};


	public any function basename(path, ext) {
	  var f = splitPath(path)[2];
	  // TODO: make this comparison case-insensitive on windows?
	  if (ext && f.substr(-1 * ext.length) === ext) {
	    f = f.substr(0, f.length - ext.length);
	  }
	  return f;
	};

	public any function existsSync(path, callback) {
	  if(directoryExists(path)) {
	  	callback();
	  };
	};

	public any function unshift(obj = this.obj) {
		var elements = _.slice(arguments, 2);
		for (var i = arrayLen(elements); i > 0; i--) {
			arrayPrepend(obj, elements[i]);
		}
		return obj;
	}

	function isAbsolute(str) {
		return (reFindNoCase("[a-zA-Z]:\\",str) GT 0 || left(str,1) === "/");
	}

	function CharAt(str,pos) {
	    return Mid(str,pos,1);
	}

	public any function sep() {
		return toString(jpath.separatorsToSystem("/"));
	}

	/**
	* reSplit UDF
	* @Author Ben Nadel <http://bennadel.com/>
	*/
	private array function reSplit(regex,value) {
		var local = {};
		local.result = []
		local.parts = javaCast( "string", arguments.value ).split(
			javaCast( "string", arguments.regex ),
			javaCast( "int", -1 )
		)

		writeDump(var=local.parts,abort=true);

		for (local.part in local.parts) {
			arrayAppend(local.result,local.part )
		}

		return local.result;
	}
	/**
	* REMatchGroups UDF
	* @Author Ben Nadel <http://bennadel.com/>
	*/
	private array function REMatchGroups(text,pattern,scope) {
		var local = structnew();
		local.results = {};
		local.pattern =createobject( "java", "java.util.regex.Pattern" ).compile( javacast( "string", arguments.pattern ) );
		
		local.matcher =local.pattern.matcher( javacast( "string", arguments.text ) );
		
		while (local.Matcher.Find()) {
			local.groups =structnew();
			
			for(local.GroupIndex=0; local.GroupIndex <= local.Matcher.GroupCount();LOCAL.GroupIndex++) {
				local.results[local.groupindex] = (local.matcher.group( javacast( "int", local.groupindex ) ));
			}
			
			//arrayappend( local.results, local.groups )
			
			if(arguments.scope EQ "one") {
				break;
			}
			
		}

		return local.results;
	}
	
}