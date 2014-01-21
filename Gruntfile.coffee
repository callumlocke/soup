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
          'src/*.coffee'
          'test/*.coffee'
          'fixtures/input/*.*'
          'fixtures/expected/*.*'
        ]
        tasks: ['nodeunit:all']
    clean:
      lib: ['lib']
    coffee:
      src:
        options:
          bare: true
        files: [{
          expand: true
          cwd: 'src'
          src: ['*.coffee']
          dest: 'lib'
          ext: '.js'
        }]

  # Load and initialise
  grunt.loadNpmTasks task for task in [
    'grunt-contrib-nodeunit'
    'grunt-contrib-watch'
    'grunt-contrib-coffee'
    'grunt-contrib-clean'
  ]
  grunt.registerTask 'default', ['nodeunit:all', 'watch:all']
  grunt.registerTask 'build', ['nodeunit:all', 'clean:lib', 'coffee:src']
  grunt.initConfig config
