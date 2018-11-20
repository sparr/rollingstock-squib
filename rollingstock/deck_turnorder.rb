module Rollingstock
  # Player turn order cards
  def Rollingstock.deck_turnorder()
    Squib::Deck.new(
      cards: 5,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_turnorder.yml'
    ) do
      background color: :white
      text layout: :upperlabel, str: ['Position'] * PLAYER_NUMBERS.length
      text layout: :ordernumber, str: PLAYER_NUMBERS
      text layout: :lowerlabel, str: ['in player order'] * PLAYER_NUMBERS.length
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/turnorder', prefix: 'turnorder_', count_format: '%02d', rotate: ROTATE ? :clockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'turnorder', count_format: ''
    end
  end
end