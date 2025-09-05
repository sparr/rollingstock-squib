require 'rake/clean'
require 'squib'
require_relative 'rollingstock/config'
require_relative 'rollingstock/data'

rule (/cards\//) =>
                    proc { |task_name|
                      [
                        'rollingstock/data.rb',
                        task_name.sub(/^cards\//, 'rollingstock/deck_').sub(/$/, '.rb'),
                        task_name.sub(/^cards\//, 'layouts/layout_').sub(/$/, '.yml'),
                      ]
                    } do |t|
  require_relative t.name.sub(/^cards\//, 'rollingstock/deck_')
  Rollingstock.send(t.name.sub(/^cards\//, 'deck_'))
end

file 'cards/placemat' => [
  'rollingstock/data.rb',
  'rollingstock/deck_placemat.rb', 'rollingstock/deck_share.rb',
  'layouts/layout_placemat.yml', 'layouts/layout_share.yml'
] do
  require_relative 'rollingstock/deck_share'
  Rollingstock.deck_share(true)
  require_relative 'rollingstock/deck_placemat'
  Rollingstock.deck_placemat()
end

file 'cards/singles' => [
  'rollingstock/deck_endofgame.rb', 'rollingstock/deck_foreigninvestor.rb', 'rollingstock/deck_turnsummary.rb',
  'layouts/layout_endofgame.yml', 'layouts/layout_foreigninvestor.yml', 'layouts/layout_turnsummary.yml',
] do
  require_relative 'rollingstock/deck_endofgame'
  Rollingstock.deck_endofgame()
  require_relative 'rollingstock/deck_foreigninvestor'
  Rollingstock.deck_foreigninvestor()
  require_relative 'rollingstock/deck_turnsummary'
  Rollingstock.deck_turnsummary()
end

task :cards => [
  'cards/company',
  'cards/placemat',
  'cards/share',
  'cards/shareprice',
  'cards/synergytoken',
  'cards/singles',
  'cards/turnorder'
]

task :default => [:cards, :clean]

CLEAN << "_temp"

CLOBBER << "_temp"
CLOBBER << "cards"
CLOBBER << "sheets"
