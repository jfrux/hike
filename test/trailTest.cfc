component name="pathTests" extends="mxunit.framework.TestCase" {
	import "cf_modules.underscorecf.underscore";
	import "lib.trail";

	FIXTURE_ROOT = expandPath("/test/fixtures");

	public void function new_trail() {
		trail = new trail(FIXTURE_ROOT);
		trail.paths.append( "app/views", "vendor/plugins/signal_id/app/views", ".");
		trail.extensions.append( "builder", "coffee", "str", ".erb");
		trail.aliases.append( "html","htm");
		trail.aliases.append( "html","xhtml");
		trail.aliases.append( "html","php");
		trail.aliases.append( "js", "coffee");

		assertTrue(isObject(trail));
		// yield trail if block_given?
		
	}

	public void function setUp() {
		variables.Trail = new Trail();
		variables.isWindows = server.os.name === 'Windows';
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