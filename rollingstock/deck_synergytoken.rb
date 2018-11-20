module Rollingstock
  # synergy tokens
  # to be mixed faces/backs at production time
  def Rollingstock.deck_synergytoken()
    Squib::Deck.new(
      cards: 5,
      width: 225,
      height: 225,
      layout: 'layouts/layout_synergytoken.yml'
    ) do
      background color: SYNERGY_COLORS
      text layout: :tokentext, str: SYNERGY_VALUES.map { |v| '+$' + v.to_s }
      circle layout: :safe if CUTLINES
      circle layout: :cut if CUTLINES
      save dir: 'cards/synergy_token', prefix: 'synergy_token_', format: :png
      circle layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'synergytoken', count_format: ''
    end
  end
end