# name [![Build Status][2]][1]

description


## Install/update

Install via  
`bash <(curl -s https://raw.github.com/andreineculau/coffee.mk/master/install.sh)`

* fix `package.json`
* fix `AUTHORS`
* fix `NOTICE`
* fix `NOTICE2`

Check for upstream diff via  
`bash <(curl -s https://raw.github.com/andreineculau/coffee.mk/master/changelog.sh)`.

Update via  
`bash <(curl -s https://raw.github.com/andreineculau/coffee.mk/master/update.sh)`  
and then commit the change in your repository.


## Usage

SHOULD be self-explanatory


## Customization

* update `.gitignore`
* add your custom make targets to `custom.mk`
* create `test/_utils.custom.coffee` with your custom test utils


## License

[Apache 2.0](LICENSE)


  [1]: https://travis-ci.org/YOUR_GITHUB_USERNAME/YOUR_PROJECT_NAME
  [2]: https://travis-ci.org/YOUR_GITHUB_USERNAME/YOUR_PROJECT_NAME.png
