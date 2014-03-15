#!/usr/bin/env coffee

pkg = require '../package'
argparse = require 'argparse'
ArgumentParser = argparse.ArgumentParser
i4countries = require '../index'
_ = require 'lodash'

parser = new ArgumentParser
  description: pkg.description
  version: pkg.version
  addHelp: true

parser.addArgument ['which'],
  help: 'Which country are you looking for?'
  nargs: '+'

parser.addArgument ['--json'],
  dest: 'asJSON'
  help: 'Return data as JSON'
  defaultValue: false
  action: 'storeTrue'

exports.main = (args = process.args) ->
  args = parser.parseArgs args
  {which, asJSON} = args
  which = which.join ' '
  [keys, value] = which.split ':'
  unless value?
    value = keys
    keys = undefined
  else
    keys = keys.split ','

  i4countries.search {keys, value}, (err, res) ->
    throw err  if err?
    unless res.headers['Content-Type'] is 'application/vnd.hyperrest.countries-v1+json'
      throw JSON.stringify res, null, 2
    if asJSON
      console.log JSON.stringify res, null, 2
      return
    for country in res.body.items
      country.name_translations = _.map country.name_translations, (translation, lang) ->
        "#{translation} (#{lang})"
      console.log _.template exports.countryTpl, country


exports.countryTpl = """
--------------------------------------------------------------------------------
${ name.toUpperCase() } ${ iso3 } ${ iso2 } ${ ison }

Also known as: ${ name_translations.join(', ') }
Languages:     ${ languages.join(', ') }
Calling codes: ${ calling_codes.join(', ') }
Currencies:    ${ currencies.join(', ') }
TLDs:          ${ top_level_domains.join(', ') }

Capital:       ${ capital }
Region:        ${ geolocation.region }
Subregion:     ${ geolocation.subregion }
Borders with:  ${ geolocation.bordering_countries.join(', ') }
Latitude:      ${ geolocation.latitude }
Longitude:     ${ geolocation.longitude }

"""

exports.main()  if require.main is module
