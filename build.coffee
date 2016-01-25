"use strict"

path = require 'path'
fs = require 'fs'
browserify = require 'browserify'
coffeeify = require 'coffeeify'
uglifyify = require 'uglifyify'

# Warning: Doing this with client-side code has security implications, it exposes package.json
# dependencies, etc to the client. We are only using it here, in our off-line build script.
package_json = require './package.json'

license_comment = "/*\n
  d3-ski-chart v#{package_json.version}\n
  Copyright (c) 2015-2016 Health Data Insight\n
  Released under the MIT License\n
  */\n"

console.log('Building d3-ski-chart.js…')

bundle = browserify()
  .external(['d3'])
  .add('./src/_ski.coffee')

bundle.transform coffeeify,
  bare: false
  header: false

bundle.bundle (error, result) ->
  throw error if error?
  filepath = path.join(__dirname, 'd3-ski-chart.js')
  writer = fs.createWriteStream(filepath, 'utf8')
  writer.write(license_comment)
  writer.write(result)

console.log('Building d3-ski-chart.min.js…')

bundle = browserify()
  .external(['d3'])
  .add('./src/_ski.coffee')

bundle.transform coffeeify,
  bare: false
  header: false

bundle.transform uglifyify,
  global: true
  sourcemap: false

bundle.bundle (error, result) ->
  throw error if error?
  filepath = path.join(__dirname, 'd3-ski-chart.min.js')
  writer = fs.createWriteStream(filepath, 'utf8')
  writer.write(license_comment)
  writer.write(result)
