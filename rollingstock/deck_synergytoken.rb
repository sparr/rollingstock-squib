require 'fileutils'

module Rollingstock
  # synergy tokens
  # to be mixed faces/backs at production time
  def self.deck_synergytoken
    Squib::Deck.new(
      cards: 5,
      width: 225,
      height: 225,
      layout: 'layouts/layout_synergytoken.yml'
    ) do
      background color: SYNERGIES.map { |s| s[:color] }
      text layout: :tokentext, str: SYNERGIES.map { |s| "+$#{s[:value]}" }
      circle layout: :safe if CUTLINES
      circle layout: :cut if CUTLINES
      save dir: 'cards/synergytoken', prefix: 'synergytoken_', format: :png
      FileUtils.touch 'cards/synergytoken'
      circle layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS && !CUTLINES
      save_sheet dir: 'sheets', prefix: 'synergytoken', count_format: ''
    end
  end
end
