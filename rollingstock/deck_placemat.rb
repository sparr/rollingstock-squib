module Rollingstock
  # Corporation placemats
  def Rollingstock.deck_placemat()
    Squib::Deck.new(
      cards: CORP_NAMES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_placemat.yml'
    ) do
      background color: :white
      # text str: (0..CORP_NAMES.length).to_a.map { |n| CORP_NAMES[n] }, layout: :companyname
      png file: (0..CORP_NAMES.length - 1).map { |n| '_temp/share_' + n.to_s + '9.png' },
          crop_x: 37.5, crop_y: 37.5, crop_width: 750, crop_height: 525,
          x: (1125 - 750) / 2, y: (825 - 525) / 2 - 50
      rect x: 350, y: 500 - 50, width: 1125 - 350 * 2, height: 125, fill_color: :white, stroke_color: '#0000'
      rect x: (1125 - 750) / 2, y: (825 - 525) / 2 - 50, width: 750, height: 525, radius: 37.5, stroke_width: 8
      text str: '<i>all 10 shares issued</i>', y: 565 - 50, layout: :secondline
      text str: '▲ share price ▲', layout: :lefttext
      text str: '▼ subsidiaries ▼', layout: :bottomtext
      text str: '▲ treasury ▲', layout: :righttext
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/placemat', prefix: 'placemat_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/placemat', prefix: 'placemat_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'placemat', count_format: ''
    end
  end
end