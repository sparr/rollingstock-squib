require 'rake/clean'
require 'squib'
require_relative 'rollingstock/config'
require_relative 'rollingstock/data'

file 'cards/company' => ['rollingstock/data.rb', 'rollingstock/deck_company.rb'] do
  require_relative 'rollingstock/deck_company'
  Rollingstock.deck_company()
end

file 'cards/placemat' => ['rollingstock/data.rb', 'rollingstock/deck_placemat.rb'] do
  require_relative 'rollingstock/deck_share'
  Rollingstock.deck_share(true)
  require_relative 'rollingstock/deck_placemat'
  Rollingstock.deck_placemat()
end

file 'cards/share' => ['rollingstock/data.rb', 'rollingstock/deck_share.rb'] do
  require_relative 'rollingstock/deck_share'
  Rollingstock.deck_share()
end

file 'cards/shareprice' => ['rollingstock/data.rb', 'rollingstock/deck_shareprice.rb'] do
  require_relative 'rollingstock/deck_shareprice'
  Rollingstock.deck_shareprice()
end

file 'cards/synergytoken' => ['rollingstock/data.rb', 'rollingstock/deck_synergytoken.rb'] do
  require_relative 'rollingstock/deck_synergytoken'
  Rollingstock.deck_synergytoken()
end

file 'cards/singles' => ['rollingstock/deck_endofgame.rb','rollingstock/deck_foreigninvestor.rb','rollingstock/deck_turnsummary.rb']  do
  require_relative 'rollingstock/deck_endofgame'
  Rollingstock.deck_endofgame()
  require_relative 'rollingstock/deck_foreigninvestor'
  Rollingstock.deck_foreigninvestor()
  require_relative 'rollingstock/deck_turnsummary'
  Rollingstock.deck_turnsummary()
end

file 'cards/turnorder' => ['rollingstock/data.rb', 'rollingstock/deck_turnorder.rb'] do
  require_relative 'rollingstock/deck_turnorder'
  Rollingstock.deck_turnorder()
end

task :cards => ['cards/company', 'cards/placemat', 'cards/share', 'cards/shareprice', 'cards/synergytoken', 'cards/singles', 'cards/turnorder' ]

task :default => [:cards, :clean]

CLEAN << "_temp"

CLOBBER << "_temp"
CLOBBER << "cards"
CLOBBER << "sheets"
