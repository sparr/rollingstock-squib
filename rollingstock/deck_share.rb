require 'fileutils'

# ordinal and ordinalize from
# https://github.com / rails / rails / blob / 4 - 2 - stable / activesupport / lib / active_support / inflector / methods.rb#L312 - L347
def ordinal(number)
  abs_number = number.to_i.abs
  if (11..13).cover?(abs_number % 100)
    'th'
  else
    case abs_number % 10
    when 1 then 'st'
    when 2 then 'nd'
    when 3 then 'rd'
    else        'th'
    end
  end
end

def ordinalize(number)
  "#{number}#{ordinal(number)}"
end

module Rollingstock
  # Corporation share cards
  SHARE_ICON_SIZE = 300
  SHARE_STRIPE_WIDTH = 75
  SHARE_STRIPE_INSET = 25
  def Rollingstock.deck_share(placemat_only = false)
    Squib::Deck.new(
      cards: CORP_NAMES.length * CORP_SHARES,
      width: 825,
      height: 600,
      layout: 'layouts/layout_share.yml'
    ) do
      background color: (0..CORP_NAMES.length * CORP_SHARES - 1).to_a.map { |n| n % 10 != 0 ? 'white' : '(0,0)(0,825) gold@0.0 white@1.0' }
      # 1st 2nd 3rd 4th .. 9th 10th 1st 2nd ...
      text str: ((1..CORP_SHARES).to_a * CORP_NAMES.length).map { |n| ordinalize(n) + ' share' }, layout: :firstline
      png file: (0..CORP_NAMES.length * CORP_SHARES - 1).to_a.map { |n| 'images/corplogos/' + CORP_NAMES[n / CORP_SHARES].downcase + '.png' }, x: (825 - SHARE_ICON_SIZE) / 2, y: 75, width: SHARE_ICON_SIZE, height: SHARE_ICON_SIZE
      # text str: (0..CORP_NAMES.length * CORP_SHARES - 1).to_a.map { |n| CORP_NAMES[n / CORP_SHARES] }, layout: :companyname
      text str: ((0..CORP_SHARES - 1).to_a * CORP_NAMES.length).map { |n| n == 0 ? '<i>President</i>' : ('<i>' + n.to_s + ' share' + (n == 1 ? '' : 's') + ' issued</i>') }, layout: :secondline
      rect x: 75 + SHARE_STRIPE_INSET, width: SHARE_STRIPE_WIDTH, height: 600, fill_color: (0..CORP_NAMES.length * CORP_SHARES - 1).to_a.map { |n| CORP_COLORS[n / CORP_SHARES] }
      rect x: 825 - 75 - SHARE_STRIPE_INSET - SHARE_STRIPE_WIDTH, width: SHARE_STRIPE_WIDTH, height: 600, fill_color: (0..CORP_NAMES.length * CORP_SHARES - 1).to_a.map { |n| CORP_COLORS[n / CORP_SHARES] }
      # unrotated version with no cutlines is used later to render placemats
      save dir: '_temp', prefix: 'share_', format: :png
      if placemat_only
        return
      end
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/share', prefix: 'share_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/share', prefix: 'share_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
      FileUtils.touch 'cards/share'
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'share', count_format: ''
    end
  end
end