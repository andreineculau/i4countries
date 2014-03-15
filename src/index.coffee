define = require('amdefine')(module)  if typeof define isnt 'function'

define [
  'lodash'
  'fs-extra'
  'async'
], (
  _
  fs
  async
) ->
  "use strict"

  exports = {}

  exports.rebuild = (next) ->
    parseCountries = () ->
      mappings =
        name: null
        tld: 'top_level_domains'
        cca2: 'iso2'
        cca3: 'iso3'
        ccn3: 'ison'
        currency: 'currencies'
        callingCode: 'calling_codes'
        languageCodes: 'languages'
        capital: null

      result = {}
      result.length = 0
      countries = JSON.parse fs.readFileSync 'sources/countries/countries.json'
      for country, index in countries
        country = do (result) ->
          result = {}
          for from, to of mappings
            to ?= from
            result[to] = country[from]
          result.id = result.iso3
          result.ison = parseInt result.ison, 10
          result.geolocation =
            region: country.region
            subregion: country.subregion
            bordering_countries: country.borders
            latitude: country.latlng[0]
            longitude: country.latlng[1]
          result.name_translations = {}
          for lang, translation of country.translations
            continue  if translation is result.name
            result.name_translations[lang] = translation
          if country.languageCodes.length is 1
            result.name_translations[country.languageCodes[0]] = country.nativeName
          result
        result[index] = result[country.id] = country
        result.length += 1
      result


    sources =
      countries: parseCountries()
      lifelink: []

    countries = sources.countries

    for country in countries
      fs.writeFileSync "dataset/#{country.id}.json", JSON.stringify country, null, 2
    next null, countries


  exports.dataset = (next) ->
    results = {}
    countries = fs.readdirSync 'dataset'
    for country, index in countries
      country = JSON.parse fs.readFileSync "dataset/#{country}"
      countries[index] = countries[country.id] = country
    next null, countries


  exports.makeCountry = (data, next) ->
    body = _.cloneDeep data
    body.links = []

    next null, {
      headers:
        'Content-Type': 'application/vnd.hyperrest.country-v1+json'
      body
    }

  exports.makeCountries = (countryData, next) ->
    items = []
    links = []

    fun = (countries) ->
      for country, index in countries
        countryLink = _.find country.links, (link) -> _.contains link.rel.split(' '), 'self'
        countryLink = {
          rel: ['item', 'http://rel.hyperrest.com/country'].join ' '
          href: countryLink.href
          index
        }  if countryLink?
        delete country.links

        items.push country.body
        links.push countryLink

      next null, {
        headers:
          'Content-Type': 'application/vnd.hyperrest.countries-v1+json'
        body: {
          items
          links
        }
      }

    async.mapSeries countryData, exports.makeCountry, (err, countries) ->
      return next err  if err?
      fun countries


  exports.search = ({keys, value}, next) ->
    keys ?= ['name', 'iso', 'lang', 'phone', 'currency', 'tld']
    keys = _.uniq keys
    value = value.toUpperCase()

    searchCountries = (countries, next) ->
      results = []

      makeMatching = (country) ->
        result = []
        for key in keys
          switch key
            when 'name'
              translations = _.map country.name_translations, _.identity
              result = result.concat [country.name], translations
            when 'iso'
              result = result.concat [country.iso3, country.iso2, country.ison.toString()]
            when 'lang'
              result = result.concat country.languages
            when 'phone'
              result = result.concat country.calling_codes
            when 'tld'
              result = result.concat country.top_level_domains
        result = _.map result, (item) -> item.toUpperCase()
        result

      for country in countries
        matching = makeMatching country
        continue  unless value in matching
        results.push country
      exports.makeCountries results, next

    exports.dataset (err, countries) ->
      return next err  if err?
      searchCountries countries, next

  exports
