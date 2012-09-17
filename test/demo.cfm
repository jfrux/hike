<cfscript>
trail = new lib.Trail(expandPath("/"));
trail.extensions.append(".cfc");
trail.paths.append("lib", "test");
writeDump(var=trail,abort=true);
writeDump(trail.find("lib/trail"));
// => "/home/ixti/Projects/hike-js/lib/hike/trail.cfc"

writeDump(trail.find("test_trail"));
// => "/home/ixti/Projects/hike-js/test/test_trail.rb"
</cfscript>