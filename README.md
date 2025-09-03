# Rolling Stock Squib script

These scripts use the [Squib](https://github.com/andymeneely/squib) [Ruby](https://www.ruby-lang.org/) [gem](https://rubygems.org/gems/squib/) to render a set of cards and other components for the game [Rolling Stock](http://rabenste.in/rollingstock/) designed by [Björn Rabenstein](http://rabenste.in). Commercial copies of the game are available from [All Aboard Games](http://www.all-aboardgames.com/home/bjoern-rabenstein-s-rolling-stock). This version of the game is shared for non-commercial print and play with Björn's permission. Also included are versions of the original rules and guidebooks, split into individual page images suitable for various print-on-demand services.

Example rendered results: https://imgur.com/a/c4oIM

## Getting Started

If you just want to print a copy of the game, grab one of the pre-rendered [Releases](http://github.com/rollingstock-squib/releases) from this repo once they exist. Until then, or if you want to make changes or render it yourself...

### Prerequisites

- A recent version of [Ruby](https://www.ruby-lang.org/).
- [DejaVu Sans](https://dejavu-fonts.github.io/) and [Signika](https://fonts.google.com/specimen/Signika) Fonts

The instructions below have a few other requirements such as Bundler, but those can be skipped if you're comfortable installing gems manually.

### Installing

1. clone this repository `git clone https://github.com/sparr/rollingstock-squib.git`
2. install the prerequisites `bundle`

### Rendering the components

`rake`

This will run `ruby rollingstock.rb` and then remove the transient `_temp` folder. You will find all of the individual cards in the `cards` folder, and the assembled card sheets in `sheets`.

Cutlines and other options can be toggled in [rollingstock/config.rb](rollingstock/config.rb).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* [Toby Mao](https://github.com/tobymao/) for http://rollingstock.net and some well formatted company data