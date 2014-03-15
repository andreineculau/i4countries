# i4countries

Interface to a slim country dataset

An experiment serving these purposes:

- provide a CLI
- provide an "API" (HTTP server)
  - enacting proper HTTP usage
  - creating/using some vendor media-types (targeting a future media-type registration)


## Install

`npm install i4countries`


## Usage

### CLI

```bash
i4countries name,lang:RO
```

### NodeJS

```js
i4countries = require 'i4countries'

i4countries.search {keys: ['name', 'lang'], which: 'RO'}, (err, res) ->
  throw err  if err?
  if res.headers['Content-Type'] is 'application/vnd.hyperrest.countries-v1+json'
    console.log res.body.items
    consoel.log res.body.links
```

### HTTP API

"TODO"


## License

[UNLICENSE](LICENSE)
