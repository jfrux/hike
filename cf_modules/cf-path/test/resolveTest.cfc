component name="resolveTests" extends="mxunit.framework.TestCase" {
	import "cf_modules.underscore.underscore";

	public void function testDirname() {
		assertEquals('/a',path.dirname('/a/b/'));
		assertEquals('/a',path.dirname('/a/b'));
		assertEquals('/',path.dirname('/a'));
		assertEquals('/',path.dirname('/'));
	}

	public void function testExtname() {
		var failures = [];
		var arrTests = [['',''],
			['','/path/to/file'],
			['.ext','/path/to/file.ext'],
			['.ext','/path.to/file.ext'],
			['','/path.to/file'],
			['','/path.to/.file'],
			['.ext','/path.to/.file.ext'],
			['.ext','/path/to/f.ext'],
			['.ext','/path/to/..ext'],
			['','file'],
			['.ext','file.ext']];

		_.forEach(arrTests,function(test) {
			var actual = path.extname(test[2]);

		  var expected = isWindows ? replace(test[1],"/", "\","all") : test[1];
		  var message = '<br /><br />path.extname(' & arrayToList(_.map(test[2],function(str) { return serialize(str); }),",") & ')' &
		                '<br />expect=' & serialize(expected) &
		                '<br />actual=' & serialize(actual);

		  if (ToString(actual) NEQ ToString(expected)) failures.add('<br />' & message);
		 
		});
		//writeDump(var="",abort=true);
		assertEquals(0,arrayLen(failures),ArrayToList(failures,''));
	}

	public void function testJoin() {
	    // path.join tests
		var failures = [];
		var arrTests =
		    // arguments result
		    [[['.', 'x/b', '..', '/b/c.js'], 'x/b/c.js'],
		     [['/.', 'x/b', '..', '/b/c.js'], '/x/b/c.js'],
		     [['/foo', '../../../bar'], '/bar'],
		     [['foo', '../../../bar'], '../../bar'],
		     [['foo/', '../../../bar'], '../../bar'],
		     [['foo/x', '../../../bar'], '../bar'],
		     [['foo/x', './bar'], 'foo/x/bar'],
		     [['foo/x/', './bar'], 'foo/x/bar'],
		     [['foo/x/', '.', 'bar'], 'foo/x/bar'],
		     [['./'], './'],
		     [['.', './'], './'],
		     [['.', '.', '.'], '.'],
		     [['.', './', '.'], '.'],
		     [['.', '/./', '.'], '.'],
		     [['.', '/////./', '.'], '.'],
		     [['.'], '.'],
		     [['', '.'], '.'],
		     [['', 'foo'], 'foo'],
		     [['foo', '/bar'], 'foo/bar'],
		     [['', '/foo'], '/foo'],
		     [['', '', '/foo'], '/foo'],
		     [['', '', 'foo'], 'foo'],
		     [['foo', ''], 'foo'],
		     [['foo/', ''], 'foo/'],
		     [['foo', '', '/bar'], 'foo/bar'],
		     [['./', '..', '/foo'], '../foo'],
		     [['./', '..', '..', '/foo'], '../../foo'],
		     [['.', '..', '..', '/foo'], '../../foo'],
		     [['', '..', '..', '/foo'], '../../foo'],
		     [['/'], '/'],
		     [['/', '.'], '/'],
		     [['/', '..'], '/'],
		     [['/', '..', '..'], '/'],
		     [[''], '.'],
		     [['', ''], '.'],
		     [[' /foo'], ' /foo'],
		     [[' ', 'foo'], ' /foo'],
		     [[' ', '.'], ' '],
		     [[' ', '/'], ' /'],
		     [[' ', ''], ' '],
		     // filtration of non-strings.
		     [['x', true, 7, 'y', {}], 'x/y']
		    ];

		_.forEach(arrTests,function(test) {
			var pathArr = test[1];
			var paths = {};

			for (i=1;i <= arrayLen(test[1]);i++) {
				paths[i] = test[1][i];
			}
			var serializedPaths = serialize(paths);
			var actual = path.join(argumentCollection=paths);

		  var expected = isWindows ? replace(test[2],"/", "\","all") : test[2];
		  var message = '<br /><br />path.join(' & arrayToList(_.map(test[1],function(str) { return serialize(str); }),",") & ')' &
		                '<br />expect=' & serialize(expected) &
		                '<br />actual=' & serialize(actual);

		  if (actual NEQ expected) failures.add('<br />' & message);
		 
		});
		assertEquals(0,arrayLen(failures),ArrayToList(failures,''));
	}

	public void function setUp() {
		import "path";
		variables.isWindows = server.os.name === 'Windows';
		variables.Path = new Path();
		variables._ = new Underscore();
		variables.expectedBasePath = "/Users/rountrjf/Sites/cf-path/test/testpaths";
		variables.relPath = "testpaths/"
		variables.absPath = "/test/testpaths/"
		variables.physPath = expandPath("/test/testpaths/");
	}

	public void function tearDown() {
		structDelete(variables, "Path");
	}
	
}