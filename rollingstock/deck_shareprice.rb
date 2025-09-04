require 'fileutils'

module Rollingstock
  # the payout range for a given stock price, price change, and number of shares
  # spi is the index into SHARE_PRICES
  # row 0 is dropping two prices, row 1 drop 1, row 2 raise 1, row 3 raise 2
  # shares is the number of issued shares
  def Rollingstock.payoutrange(spi, row, shares)
    return '' if spi == SHARE_PRICES.length - 1

    if row == 0 || (row == 1 && spi == 1)
      min = 0
    elsif row == 1
      min = SHARE_PRICES[spi - 1] * shares
    elsif row == 2
      min = SHARE_PRICES[spi] * shares
    else
      min = SHARE_PRICES[spi + 1] * shares
    end

    if row == 3 || (row == 2 && spi==SHARE_PRICES.length - 2)
      max = '∞'
    elsif row == 2
      max = SHARE_PRICES[spi + 1] * shares - 1
    elsif row == 1
      max = SHARE_PRICES[spi] * shares - 1
    else
      max = SHARE_PRICES[spi - 1] * shares - 1
    end

    "$#{min}-#{max}"
  end

  def Rollingstock.deck_shareprice_faceback(face)
    Squib::Deck.new(
      cards: SHARE_PRICES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_shareprice.yml'
    ) do
      background color: :white
      text str: 'share price', layout: :title
      text str: (0..SHARE_PRICES.length - 1).to_a.map { |n| n == 0 ? '' : ('$' + SHARE_PRICES[n - 1].to_s + '←') }, layout: :leftprice
      text str: (0..SHARE_PRICES.length - 1).to_a.map { |n| n == SHARE_PRICES.length - 1 ? '' : ('→$' + SHARE_PRICES[n + 1].to_s) }, layout: :rightprice
      text str: SHARE_PRICES.map { |p| '$' + p.to_s }, color: [:red] + [:black] * (SHARE_PRICES.length - 2) + ['#080'], layout: :shareprice
      rect range: (1..SHARE_PRICES.length - 2), layout: :maxpayoutbox
      text range: (1..SHARE_PRICES.length - 2), str: "max payout\nper share", layout: :maxpayoutlabel
      text range: (1..SHARE_PRICES.length - 2), str: SHARE_PRICES.map { |p| '$' + (p / 3).to_i.to_s }, layout: :maxpayoutamount
      rect range: (6..10), fill_color: TIER_COLORS[0], layout: :ipofirstthird
      text range: (6..10), str: '●', layout: :ipofirstthirdsymbol
      rect range: (6..10), fill_color: TIER_COLORS[1], layout: :iposecondthird
      text range: (6..10), str: '▲', layout: :iposecondthirdsymbol
      rect range: (6..10), fill_color: TIER_COLORS[2], layout: :ipothirdthird
      text range: (6..10), str: '■', layout: :ipothirdthirdsymbol
      rect range: (11..14), fill_color: TIER_COLORS[1], layout: :ipofirstthird
      text range: (11..14), str: '▲', layout: :ipofirstthirdsymbol
      rect range: (11..14), fill_color: TIER_COLORS[2], layout: :iposecondthird
      text range: (11..14), str: '■', layout: :iposecondthirdsymbol
      rect range: (11..14), fill_color: TIER_COLORS[3], layout: :ipothirdthird
      text range: (11..14), str: '⬟', layout: :ipothirdthirdsymbol
      rect range: (15..17), fill_color: TIER_COLORS[2], layout: :ipofirstthird
      text range: (15..17), str: '■', layout: :ipofirstthirdsymbol
      rect range: (15..17), fill_color: TIER_COLORS[3], layout: :iposecondthird
      text range: (15..17), str: '⬟', layout: :iposecondthirdsymbol
      rect range: (15..17), fill_color: TIER_COLORS[4], layout: :ipothirdthird
      text range: (15..17), str: '⬢', layout: :ipothirdthirdsymbol
      rect range: (18..20), fill_color: TIER_COLORS[3], layout: :ipofirstthird
      text range: (18..20), str: '⬟', layout: :ipofirstthirdsymbol
      rect range: (18..20), fill_color: TIER_COLORS[4], layout: :iposecondthird
      text range: (18..20), str: '⬢', layout: :iposecondthirdsymbol
      rect range: (18..20), fill_color: TIER_COLORS[5], layout: :ipothirdthird
      text range: (18..20), str: '★', layout: :ipothirdthirdsymbol
      rect range: (21..23), fill_color: TIER_COLORS[4], layout: :ipofirsthalf
      text range: (21..23), str: '⬢', layout: :ipofirsthalfsymbol
      rect range: (21..23), fill_color: TIER_COLORS[5], layout: :iposecondhalf
      text range: (21..23), str: '★', layout: :iposecondhalfsymbol
      text range: (6..23), str: 'IPO', layout: :ipolabel
      bottom_y = 462
      text str: "When a corporation takes this card, it is declared bankrupt immediately. Remove its subsidiary companies from the game. Return its cash, its shares, and this card without compensation.\n(Shares are available for newly founded corporations.)",
        range: 0,
        y: bottom_y,
        layout: :bottomtext
      text str: 'If this card is in use in phase 10 or after a share has been bought in phase 3, the game ends immediately. In phase 9, assume there is an infinite supply of this card. Each corporation reaching $100 share price after the first returns its old share price card without taking a new one. Its shares have a value of $100 at the end of the game.',
        range: SHARE_PRICES.length - 1,
        y: bottom_y,
        layout: :bottomtext
      text str: 'shares ',
        range: (1..SHARE_PRICES.length - 2), # skip $0 and $100
        x: (face ? 75 : 156.25),
        y: bottom_y,
        align: 'right',
        layout: :bottomgridbox
      (face ? 2..6 : 7..10).each do |col|
        text str: col.to_s,
          range: (1..SHARE_PRICES.length - 2), # skip $0 and $100
          x: (face ? 75 : 156.25) + 162.5 * (col - (face ? 1 : 6)),
          y: bottom_y,
          layout: :bottomgridbox
      end
      (0..3).each do |row|
        text str: (0..SHARE_PRICES.length - 1).to_a.map { |i| ['', '', '→', '→→'][row] + '$' + SHARE_PRICES[i + (row < 2 ? (row - 2) : (row - 1))].to_s + ['←←', '←', '', ''][row] },
          range: ((row > 0 ? 1 : 2)..(SHARE_PRICES.length - (row < 3 ? 2 : 3))),
          x: (face ? 75 : 156.25),
          y: SHARE_PRICES.map { |p| p == 5 || p == 100 ? (bottom_y + row * 55) : (bottom_y + 55 + row * 55) },
          layout: :bottomgridbox
        (face ? 2..6 : 7..10).each do |col|
          text str: (0..SHARE_PRICES.length - 1).map { |i| Rollingstock.payoutrange(i, row, col) },
            range: ((row > 0 ? 1 : 2)..(SHARE_PRICES.length - (row < 3 ? 2 : 3))),
            x: (face ? 75 : 156.25) + 162.5 * (col - (face ? 1 : 6)),
            y: SHARE_PRICES.map { |p| p == 5 || p == 100 ? (bottom_y + row * 55) : (bottom_y + 55 + row * 55) },
            layout: :bottomgridbox
        end
      end
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/shareprice', prefix: 'shareprice_',
        count_format: '%02d' + (face ? '[face]' : '[back]'),
        rotate: ROTATE ? (face ? :clockwise : :counterclockwise) : false,
        format: :png
      FileUtils.touch 'cards/shareprice'
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'shareprice_' + (face ? 'face' : 'back'), count_format: ''
    end
  end

  def Rollingstock.deck_shareprice()
    Rollingstock.deck_shareprice_faceback(true)
    Rollingstock.deck_shareprice_faceback(false)
  end
end