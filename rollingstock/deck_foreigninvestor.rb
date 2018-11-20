module Rollingstock
  # Foreign Investor placemat
  def Rollingstock.deck_foreigninvestor()
    Squib::Deck.new(
      cards: 1,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_foreigninvestor.yml'
    ) do
      background color: '#CCC'
      text layout: :companyname, str: 'Foreign Investor'
      text layout: :maintext, str: "Starts the game with $4 in treasury.

<b>Phase 5</b>: Buys as many private companies as possible, in ascending face value order.
<b>Phase 6</b>: Offers private companies for maximum price. If more than one corporation wants to buy the same private company, the corporation with the higher share price has priority.
<b>Phase 7</b>: Closes private companies with negative income.
<b>Phase 8</b>: Earns $5 plus normal income from private companies."
      text layout: :bottomtext, str: '▼ private companies ▼'
      text layout: :righttext, str: '▲ treasury ▲'
      circle layout: :incomecircle
      text layout: :incometext, str: '+$5'
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/singles', prefix: 'foreigninvestor_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/singles', prefix: 'foreigninvestor_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'foreigninvestor', count_format: '', columns: 1
    end
  end
end