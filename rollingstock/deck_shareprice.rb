require 'fileutils'

module Rollingstock
  # the payout range for a given stock price, price change, and number of shares
  # spi is the index into SHARE_PRICES
  # row 0 is dropping two prices, row 1 drop 1, row 2 raise 1, row 3 raise 2
  # shares is the number of issued shares
  def self.payoutrange(spi, row, shares)
    return '' if spi == SHARE_PRICES.length - 1

    min = if row.zero? || (row == 1 && spi == 1)
            0
          elsif row == 1
            SHARE_PRICES[spi - 1] * shares
          elsif row == 2
            SHARE_PRICES[spi] * shares
          else
            SHARE_PRICES[spi + 1] * shares
          end

    max = if row == 3 || (row == 2 && spi == SHARE_PRICES.length - 2)
            '∞'
          elsif row == 2
            SHARE_PRICES[spi + 1] * shares - 1
          elsif row == 1
            SHARE_PRICES[spi] * shares - 1
          else
            SHARE_PRICES[spi - 1] * shares - 1
          end

    "$#{min}-#{max}"
  end

  def self.deck_shareprice_faceback(face)
    Squib::Deck.new(
      cards: SHARE_PRICES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_shareprice.yml'
    ) do
      background color: :white
      text str: 'share price', layout: :title
      text str: (0..SHARE_PRICES.length - 1).map { |n| n.zero? ? '' : "$#{SHARE_PRICES[n - 1]}←" },
           layout: :leftprice
      text str: (0..SHARE_PRICES.length - 1).map { |n| n == SHARE_PRICES.length - 1 ? '' : "→$#{SHARE_PRICES[n + 1]}" },
           layout: :rightprice
      text str: SHARE_PRICES.map { |p|
        "$#{p}"
      }, color: [:red] + [:black] * (SHARE_PRICES.length - 2) + ['#080'], layout: :shareprice
      rect range: (1..SHARE_PRICES.length - 2), layout: :maxpayoutbox
      text range: (1..SHARE_PRICES.length - 2), str: "max payout\nper share", layout: :maxpayoutlabel
      text range: (1..SHARE_PRICES.length - 2), str: SHARE_PRICES.map { |p| "$#{(p / 3).to_i}" },
           layout: :maxpayoutamount
      rect range: (6..10), fill_color: TIERS[0][:color], layout: :ipofirstthird
      text range: (6..10), str: '●', layout: :ipofirstthirdsymbol
      rect range: (6..10), fill_color: TIERS[1][:color], layout: :iposecondthird
      text range: (6..10), str: '▲', layout: :iposecondthirdsymbol
      rect range: (6..10), fill_color: TIERS[2][:color], layout: :ipothirdthird
      text range: (6..10), str: '■', layout: :ipothirdthirdsymbol
      rect range: (11..14), fill_color: TIERS[1][:color], layout: :ipofirstthird
      text range: (11..14), str: '▲', layout: :ipofirstthirdsymbol
      rect range: (11..14), fill_color: TIERS[2][:color], layout: :iposecondthird
      text range: (11..14), str: '■', layout: :iposecondthirdsymbol
      rect range: (11..14), fill_color: TIERS[3][:color], layout: :ipothirdthird
      text range: (11..14), str: '⬟', layout: :ipothirdthirdsymbol
      rect range: (15..17), fill_color: TIERS[2][:color], layout: :ipofirstthird
      text range: (15..17), str: '■', layout: :ipofirstthirdsymbol
      rect range: (15..17), fill_color: TIERS[3][:color], layout: :iposecondthird
      text range: (15..17), str: '⬟', layout: :iposecondthirdsymbol
      rect range: (15..17), fill_color: TIERS[4][:color], layout: :ipothirdthird
      text range: (15..17), str: '⬢', layout: :ipothirdthirdsymbol
      rect range: (18..20), fill_color: TIERS[3][:color], layout: :ipofirstthird
      text range: (18..20), str: '⬟', layout: :ipofirstthirdsymbol
      rect range: (18..20), fill_color: TIERS[4][:color], layout: :iposecondthird
      text range: (18..20), str: '⬢', layout: :iposecondthirdsymbol
      rect range: (18..20), fill_color: TIERS[5][:color], layout: :ipothirdthird
      text range: (18..20), str: '★', layout: :ipothirdthirdsymbol
      rect range: (21..23), fill_color: TIERS[4][:color], layout: :ipofirsthalf
      text range: (21..23), str: '⬢', layout: :ipofirsthalfsymbol
      rect range: (21..23), fill_color: TIERS[5][:color], layout: :iposecondhalf
      text range: (21..23), str: '★', layout: :iposecondhalfsymbol
      text range: (6..23), str: 'IPO', layout: :ipolabel
      bottom_y = 462
      text str: 'When a corporation takes this card, it is declared bankrupt immediately. '\
                'Remove its subsidiary companies from the game. Return its cash, its shares, '\
                'and this card without compensation.\n(Shares are available for newly founded corporations.)',
           range: 0, y: bottom_y, layout: :bottomtext
      text str: 'If this card is in use in phase 10 or after a share has been bought in phase 3, '\
                'the game ends immediately. In phase 9, assume there is an infinite supply of this '\
                'card. Each corporation reaching $100 share price after the first returns its old '\
                'share price card without taking a new one. Its shares have a value of $100 at the '\
                'end of the game.',
           range: SHARE_PRICES.length - 1, y: bottom_y, layout: :bottomtext
      text str: 'shares ', range: (1..SHARE_PRICES.length - 2), # skip $0 and $100
           x: (face ? 75 : 156.25), y: bottom_y, align: 'right', layout: :bottomgridbox
      (face ? 2..6 : 7..10).each do |col|
        text str: col.to_s,
             range: (1..SHARE_PRICES.length - 2), # skip $0 and $100
             x: (face ? 75 : 156.25) + 162.5 * (col - (face ? 1 : 6)),
             y: bottom_y, layout: :bottomgridbox
      end
      (0..3).each do |row|
        text str: (0..SHARE_PRICES.length - 1).to_a.map { |i|
          "#{['', '', '→', '→→'][row]}"\
          "$#{SHARE_PRICES[i + (row < 2 ? (row - 2) : (row - 1))]}"\
          "#{['←←', '←', '', ''][row]}"
        },
             range: ((row.positive? ? 1 : 2)..(SHARE_PRICES.length - (row < 3 ? 2 : 3))),
             x: (face ? 75 : 156.25),
             y: SHARE_PRICES.map { |p| [5, 100].include?(p) ? (bottom_y + row * 55) : (bottom_y + 55 + row * 55) },
             layout: :bottomgridbox
        (face ? 2..6 : 7..10).each do |col|
          text str: (0..SHARE_PRICES.length - 1).map { |i| Rollingstock.payoutrange(i, row, col) },
               range: ((row.positive? ? 1 : 2)..(SHARE_PRICES.length - (row < 3 ? 2 : 3))),
               x: (face ? 75 : 156.25) + 162.5 * (col - (face ? 1 : 6)),
               y: SHARE_PRICES.map { |p| [5, 100].include?(p) ? (bottom_y + row * 55) : (bottom_y + 55 + row * 55) },
               layout: :bottomgridbox
        end
      end
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/shareprice', prefix: 'shareprice_',
           count_format: "%02d#{face ? '[face]' : '[back]'}",
           rotate: if ROTATE
                     face ? :clockwise : :counterclockwise
                   else
                     false
                   end,
           format: :png
      FileUtils.touch 'cards/shareprice'
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS && !CUTLINES
      save_sheet dir: 'sheets', prefix: "shareprice_#{face ? 'face' : 'back'}", count_format: ''
    end
  end

  def self.deck_shareprice
    deck_shareprice_faceback(true)
    deck_shareprice_faceback(false)
  end
end
