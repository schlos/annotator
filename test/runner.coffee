require.paths.unshift __dirname + "/lib"

specutil  = require 'specutil'
{Sandbox} = require 'sandbox'
{jasmine} = require 'jasmine'

ROOT_DIR     = __dirname + '/..'
SPEC_DIR     = ROOT_DIR + '/test/spec'
FIXTURES_DIR = ROOT_DIR + '/test/fixtures'

# Create new browser/document sandbox
s = new Sandbox(ROOT_DIR)

s.require('lib/vendor/jquery.js')
s.require 'lib/vendor/underscore.js'
s.require 'lib/vendor/json2.js'
s.require 'lib/vendor/showdown.js'

# Add fixture helpers
specutil.addFixtureHelpers(s.window, FIXTURES_DIR)

# Require jasmine
s.require 'lib/vendor/jasmine/jasmine.js'

# Patch in a vendor XPath implementation until jsdom has one
s.require 'lib/vendor/xpath.js'

# Sneaky hack to provide Node.ELEMENT_NODE
s.window.Node or= s.window.document.createElement('span')

s.require 'test/spec_helper.coffee'

s.require 'lib/class.js'
s.require 'lib/extensions.js'
s.require 'lib/annotator.js'
s.require 'lib/plugins/store.js'
s.require 'lib/plugins/auth.js'
s.require 'lib/plugins/markdown.js'

# List of spec files to require
specFiles = specutil.getSpecFiles(SPEC_DIR)

# Really simple filtering. Args on commandline are used to filter specs that get
# run.
filters = process.argv[2..-1]
if filters.length > 0
  matched = filters.map (filter) ->
    specFiles.filter (name) ->
      name.indexOf(filter) > 0

  specFiles = matched.reduce( ((all, x) -> all.concat(x)), [] )

# Require specs
for specFile in specFiles
  s.require(specFile)

reporter = new jasmine.node.ConsoleReporter (runner, log) ->
  console.log("As of 2010-12-28, you should be seeing 2 failures that we know about.")
  # process.exit(runner.results().failedCount)

s.window.jasmine.getEnv().addReporter(reporter)
s.window.jasmine.getEnv().execute()

