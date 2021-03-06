module Rollingstock
  # End of Game cards
  def Rollingstock.deck_endofgame()
    Squib::Deck.new(
      cards: 6,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_endofgame.yml'
    ) do
      # first we draw the colored boxes
      # face of training game
      rect layout: :BoxHalf, stroke_width: 0, fill_color: TIER_COLORS[0], range: [0]
      rect layout: :BoxHalf, stroke_width: 0, fill_color: TIER_COLORS[1], range: [0], x: 562.5
      # face of short game, back of training game
      rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[0], range: [1, 2], x: 0, width: 400
      rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[1], range: [1, 2], x: 400
      rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[2], range: [1, 2], x: 725, width: 400
      # back of short game, face and back of full game
      rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[0], range: [3, 4, 5]
      rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[1], range: [3, 4, 5], x: 562.5
      rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[2], range: [3, 4, 5], y: 412.5
      rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[3], range: [3, 4, 5], x: 562.5, y: 412.5
      # next we draw the symbols
      # bottom left circle
      text layout: :BottomSymbol, str: TIER_SYMBOLS[0], range: [0, 1, 2], align: :left
      # bottom right triangle
      text layout: :BottomSymbol, str: TIER_SYMBOLS[1], range: [0], align: :right
      # bottom center triangle
      text layout: :BottomSymbol, str: TIER_SYMBOLS[1], range: [1, 2]
      # bottom right square
      text layout: :BottomSymbol, str: TIER_SYMBOLS[2], range: [1, 2], align: :right
      # all four corners
      text layout: :TopSymbol, str: TIER_SYMBOLS[0], range: [3, 4, 5], align: :left
      text layout: :TopSymbol, str: TIER_SYMBOLS[1], range: [3, 4, 5], align: :right
      text layout: :BottomSymbol, str: TIER_SYMBOLS[2], range: [3, 4, 5], align: :left
      text layout: :BottomSymbol, str: TIER_SYMBOLS[3], range: [3, 4, 5], align: :right
      # then we draw the text in the middle
      text str: [3, 8, 6, 15, 10, 16].map { |c| 'cost of ownership $' + c.to_s }, layout: :CenterishText
      text str: "If there are no unowned private companies left at the end of\na turn, flip this card.",
        layout: :SmallerText, range: [0, 2, 4]
      text str: "The end of the next turn is\nthe end of the game.",
        layout: :SmallerText, range: [1, 3, 5]
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/singles', prefix: 'endofgame_training[face]', range: [0], count_format: '', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/singles', prefix: 'endofgame_training[back]', range: [1], count_format: '', rotate: ROTATE ? :counterclockwise : false, format: :png
      save dir: 'cards/singles', prefix: 'endofgame_short[face]',    range: [2], count_format: '', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/singles', prefix: 'endofgame_short[back]',    range: [3], count_format: '', rotate: ROTATE ? :counterclockwise : false, format: :png
      save dir: 'cards/singles', prefix: 'endofgame_full[face]',     range: [4], count_format: '', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/singles', prefix: 'endofgame_full[back]',     range: [5], count_format: '', rotate: ROTATE ? :counterclockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'endofgame_face', count_format: '', range: [0, 2, 4], columns: 3
      save_sheet dir: 'sheets', prefix: 'endofgame_back', count_format: '', range: [5, 3, 1], columns: 3
    end
  end
end