#!/usr/bin/env ruby
require 'squib'
require 'set'
require_relative 'rollingstock/config'
require_relative 'rollingstock/data'
require_relative 'rollingstock/deck_turnorder'
require_relative 'rollingstock/deck_share'
require_relative 'rollingstock/deck_placemat'
require_relative 'rollingstock/deck_foreigninvestor'
require_relative 'rollingstock/deck_turnsummary'
require_relative 'rollingstock/deck_shareprice'
require_relative 'rollingstock/deck_company'
require_relative 'rollingstock/deck_endofgame'
require_relative 'rollingstock/deck_synergytoken'

DECK_TURNORDER       = true
DECK_SHARE           = true
DECK_PLACEMAT        = true
DECK_FOREIGNINVESTOR = true
DECK_TURNSUMMARY     = true
DECK_TURNSUMMARYDE   = true
DECK_SHAREPRICE      = true
DECK_COMPANY         = true
DECK_ENDOFGAME       = true
DECK_SYNERGYTOKEN    = true

if __FILE__ == $0
  Rollingstock.deck_turnorder()       if DECK_TURNORDER
  Rollingstock.deck_share()           if DECK_SHARE
  Rollingstock.deck_placemat()        if DECK_PLACEMAT
  Rollingstock.deck_foreigninvestor() if DECK_FOREIGNINVESTOR
  Rollingstock.deck_turnsummary()     if DECK_TURNSUMMARY
  Rollingstock.deck_turnsummaryde()   if DECK_TURNSUMMARYDE
  Rollingstock.deck_shareprice()      if DECK_SHAREPRICE
  Rollingstock.deck_company()         if DECK_COMPANY
  Rollingstock.deck_endofgame()       if DECK_ENDOFGAME
  Rollingstock.deck_synergytoken()    if DECK_SYNERGYTOKEN
end