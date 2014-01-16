path = require 'path'
require 'sugar'

module.exports = (grunt) ->
  require('time-grunt')(grunt)

  config =
    nodeunit:
      all:
        files: [['test/*_test.coffee']]
    watch:
      all:
        files: [
          'lib/*.coffee'
          'test/*.coffee'
          'fixtures/input/*.*'
          'fixtures/expected/*.*'
        ]
        tasks: ['nodeunit:all']

  # Load and initialise
  grunt.loadNpmTasks task for task in [
    'grunt-contrib-nodeunit'
    'grunt-contrib-watch'
  ]
  grunt.registerTask 'default', ['nodeunit:all', 'watch:all']
  grunt.initConfig config
