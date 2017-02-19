require 'squib'
require 'set'

CUTLINES = false

ROTATE = true

TURNORDER       = true
CORPSHARES      = true
CORPMATS        = true
FOREIGNINVESTOR = true
TURNSUMMARY     = true
TURNSUMMARYDE   = true
SHAREPRICES     = true
COMPANYCARDS    = true
ENDOFGAME       = true
SYNERGYTOKENS   = true

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

MAX_PLAYERS = 5
MIN_PLAYERS = 1
PLAYER_NUMBERS = (1..MAX_PLAYERS).to_a.freeze
CORP_NAMES = %w(Bear Wheel Orion Eagle Horse Star Android Ship Jupiter Saturn).freeze
CORP_COLORS = %w(#F00 #000 #96C #FD2 #999 #0A0 #AC0 #09F #963 #F0F).freeze
$SHARE_PRICES = [
   0,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22,
      24, 26, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 81, 90, 100
].freeze

# Player turn order cards
Squib::Deck.new(
  cards: 5,
  width: 1125,
  height: 825,
  layout: 'layout_turnorder.yml'
) do
  background color: :white
  text str: ['Position'] * PLAYER_NUMBERS.length, layout: :upperlabel
  text str: PLAYER_NUMBERS, layout: :ordernumber
  text str: ['in player order'] * PLAYER_NUMBERS.length, layout: :lowerlabel
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
end if TURNORDER

# Corporation share cards
shares = 10
Squib::Deck.new(
  cards: CORP_NAMES.length * shares,
  width: 825,
  height: 600,
  layout: 'layout_share.yml'
) do
  background color: (0..CORP_NAMES.length * shares - 1).to_a.map { |n| n % 10 != 0 ? 'white' : '(0,0)(0,825) gold@0.0 white@1.0' }
  # 1st 2nd 3rd 4th .. 9th 10th 1st 2nd ...
  text str: ((1..shares).to_a * CORP_NAMES.length).map { |n| ordinalize(n) + ' share' }, layout: :firstline
  ICON_SIZE = 300
  png file: (0..CORP_NAMES.length * shares - 1).to_a.map { |n| CORP_NAMES[n / shares].downcase + '.png' }, x: (825-ICON_SIZE)/2, y: 75, width: ICON_SIZE, height: ICON_SIZE
  # text str: (0..CORP_NAMES.length * shares - 1).to_a.map { |n| CORP_NAMES[n / shares] }, layout: :companyname
  text str: ((0..shares - 1).to_a * CORP_NAMES.length).map { |n| n == 0 ? '<i>President</i>' : ('<i>' + n.to_s + ' share' + (n == 1 ? '' : 's') + ' issued</i>') }, layout: :secondline
  STRIPE_WIDTH = 75
  STRIPE_INSET = 25
  rect x: 75+STRIPE_INSET, width: STRIPE_WIDTH, height: 600, fill_color: (0..CORP_NAMES.length * shares - 1).to_a.map { |n| CORP_COLORS[n / shares] }
  rect x: 825-75-STRIPE_INSET-STRIPE_WIDTH, width: STRIPE_WIDTH, height: 600, fill_color: (0..CORP_NAMES.length * shares - 1).to_a.map { |n| CORP_COLORS[n / shares] }
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  # unrotated version is used for the placemats
  save prefix: 'share_', format: :png
  save prefix: 'share_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'share_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if CORPSHARES

# Corporation placemats
Squib::Deck.new(
  cards: CORP_NAMES.length,
  width: 1125,
  height: 825,
  layout: 'layout_placemat.yml'
) do
  background color: :white
  # text str: (0..CORP_NAMES.length).to_a.map { |n| CORP_NAMES[n] }, layout: :companyname
  png file: (0..CORP_NAMES.length - 1).map { |n| '_output/share_' + n.to_s + '9.png' },
      crop_x: 37.5, crop_y: 37.5, crop_width: 750, crop_height: 525,
      x: (1125-750)/2, y: (825-525)/2-50
  rect x: 350, y: 500-50, width: 1125-350*2, height: 125, fill_color: :white, stroke_color: '#0000'
  rect x: (1125-750)/2, y: (825-525)/2-50, width: 750, height: 525, radius: 37.5, stroke_width: 8
  text str: '<i>all 10 shares issued</i>', y: 565-50, layout: :secondline
  text str: '▲ share price ▲', layout: :lefttext
  text str: '▼ subsidiaries ▼', layout: :bottomtext
  text str: '▲ treasury ▲', layout: :righttext
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'placemat_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'placemat_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if CORPMATS

# Foreign Investor placemat
Squib::Deck.new(
  cards: 1,
  width: 1125,
  height: 825,
  layout: 'layout_foreigninvestor.yml'
) do
  background color: '#CCC'
  text str: 'Foreign Investor', layout: :companyname
  text str: "Starts the game with $4 in treasury.

<b>Phase 5</b>: Buys as many private companies as possible, in ascending face value order.
<b>Phase 6</b>: Offers private companies for maximum price. If more than one corporation wants to buy the same private company, the corporation with the higher share price has priority.
<b>Phase 7</b>: Closes private companies with negative income.
<b>Phase 8</b>: Earns $5 plus normal income from private companies.", layout: :maintext
  text str: '▼ private companies ▼', layout: :bottomtext
  text str: '▲ treasury ▲', layout: :righttext
  circle x: 950, y: 175, radius: 100,
    fill_color: :gray, stroke_color: :black, stroke_width: 2.0
  text x: 950 - 100, y: 175 - 100, font: 'Signika 66', align: 'center', valign: 'middle',
    color: :black, width: 200, height: 200, str: '+$5'
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'foreign_investor', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'foreign_investor', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if FOREIGNINVESTOR

# Turn Summary card
# duplicate this elsewise
Squib::Deck.new(
  cards: 1,
  width: 1125,
  height: 825,
  layout: 'layout_turnsummary.yml'
) do
  background color: :white
  y = 75
  extents = text str: 'Turn Summary', y: y, layout: :title
  y += extents[0][:height]
  lines = [
    ['1', 'In share price order, corporations <b>issue one share</b> (optional) and turn share price card horizontally.', ['CORP']],
    ['2', 'In descending face value order, private companies <b>form corporations</b> (optional).', ['PRIV']],
    ['3', 'In player order, players either <b>buy one share</b>, <b>sell one share</b>, <b>start an auction for an available private company</b>, or <b>pass</b>. Proceed until all players have passed consecutively. Game ends immediately if $100 share price has been reached after a buy action.', ['PRIV']],
    ['4', '<b>Determine new player order</b> by remaining cash. Break ties by old player order.', ['AUTO']],
    ['5', 'In ascending face value order, <b>foreign investor buys available private companies</b> for face value (as many as possible). After that, newly drawn private companies become available.', ['AUTO']],
    ['6', 'In any order, corporations <b>buy companies</b> from other corporations, players, or foreign investor (optional). Price range see company card (foreign investor only sells for max price). Turn sold companies and payed money vertically until end of phase and don\'t use it for further trades. At any time, each corporations must have at least one subsidiary company.', ['PRIV', 'CORP']],
    ['7', 'In any order, corporations and players <b>close companies</b> (optional). Foreign investor closes companies with negative income. Players must close companies with negative income they would not be able to pay in phase 8.', ['PRIV', 'CORP']],
    ['8', 'Corporations, players, and foreign investor earn <b>income</b>. Synergies only apply to corporations. Corporations unable to pay negative income are removed without compensation.', ['AUTO']],
    ['9', 'In share price order, corporations pay <b>dividends</b> for each issued share (from $0 to max as per share price card), <b>adjust share price</b> and turn share price card vertically.', ['CORP']],
    ['10','If there are no unowned private companies left, <b>flip end card</b>. If it is already flipped, or if $100 share price has been reached, <b>game ends</b>.', ['AUTO']]
  ]
  (0..9).each do |n|
    extents = text str: lines[n][1], y: y + 5, layout: :maintext
    text str: lines[n][0],
      y: y,
      width: 60, height: extents[0][:height] + 10,
      align: :center, valign: :middle,
      layout: :linenumber
    # vertically center the set of who boxes
    who_height = lines[n][2].length * 29 - 5
    who_y = y + (extents[0][:height] + 10 - who_height) / 2
    lines[n][2].each do |who|
      rect y: who_y, layout: :whotext, fill_color: who == 'PRIV' ? '#CBF' : who == 'AUTO' ? '#AFA' : '#FAA'
      text str: who, y: who_y, layout: :whotext
      who_y += 29
    end
    rect x: 75, y: y, width: 975, height: extents[0][:height] + 10
    y += extents[0][:height] + 10
  end
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'turn_summary', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'turn_summary', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if TURNSUMMARY

# Turn Summary card in German
# duplicate this elsewise
Squib::Deck.new(
  cards: 1,
  width: 1125,
  height: 825,
  layout: 'layout_turnsummary.yml'
) do
  background color: :white
  y = 75
  extents = text str: 'Rundenübersicht', y: y, layout: :title
  y += extents[0][:height]
  lines = [
    ['1', 'In Kursreihenfolge <b>geben AGs eine Aktie aus</b> (optional) und drehen Kurskarte waagerecht.', ['AG']],
    ['2', 'In absteigender Nennwertreihenfolge <b>gründen Privatfirmen AGs</b> (optional).', ['PRIV']],
    ['3', 'In Spielerreihenfolge entweder eine Aktie kaufen, <b>eine Aktie verkaufen, eine erhältliche Privatfirma versteigern</b> oder <b>passen</b>. Wiederholen bis alle Spieler nacheinander passen. Wird durch eine Kaufaktion Kurs $100 erreicht, endet das Spiel nach dieser Aktion.', ['PRIV']],
    ['4', '<b>Spielerreihenfolge</b> nach Restgeld neu bestimmen. Bei Gleichstand gilt die alte Reihenfolge.', ['AUTO']],
    ['5', '<b>Ausländischer Investor kauft</b> in aufsteigender Reihenfolge <b>erhältliche Privatfirmen</b> zum Nennwert, solange das Geld reicht. Danach werden alle nachgezogenen Privatfirmen erhältlich.', ['AUTO']],
    ['6', 'In beliebiger Reihenfolge <b>kaufen</b> AGs <b>Firmen</b> von anderen AGs, Spielern oder dem ausländischen Investor (optional). Erlaubte Preisspanne gemäß Firmenkarte (ausländischer Investor verkauft nur zum Maximalpreis). Verkaufte Firmen und dafür bezahltes Geld werden bis zum Phasenende senkrecht gedreht und können solange nicht mehr gehandelt werden. Zu jedem Zeitpunkt muß jede AG mindestens eine Tochterfirma besitzen.', ['PRIV', 'AG']],
    ['7', 'In beliebiger Reihenfolge <b>schließen</b> AGs und Spieler <b>Firmen</b> (optional). Der ausländische Investor schließt Firmen mit negativem Einkommen. Spieler müssen Firmen schließen, deren negatives Einkommen sie in Phase 8 nicht bezahlen können.', ['PRIV', 'AG']],
    ['8', 'AGs, Spieler und ausländischer Investor erhalten <b>Einkommen</b>. Synergien gelten nur für AGs. AGs, die negatives Einkommen nicht bezahlen können, werden entschädigungslos geschlossen.', ['AUTO']],
    ['9', 'In Kursreihenfolge zahlen AGs <b>Dividende</b> für jede ausgegebene Aktie (zwischen $0 und Maximum gemäß Kurskarte), <b>passen</b> ihren <b>Kurs an</b> und drehen ihre Kurskarte senkrecht.', ['AG']],
    ['10','Wenn keine Privatfirmen mehr im Angebot sind, wird die <b>Endkarte umgedreht</b>. Ist sie bereits umgedreht oder hat eine AG Kurs $100, ist das <b>Spiel zuende</b>.', ['AUTO']]
  ]
  (0..9).each do |n|
    extents = text str: lines[n][1], y: y + 5, layout: :maintext_de
    text str: lines[n][0],
      y: y,
      width: 60, height: extents[0][:height] + 10,
      align: :center, valign: :middle,
      layout: :linenumber
    # vertically center the set of who boxes
    who_height = lines[n][2].length * 29 - 5
    who_y = y + (extents[0][:height] + 10 - who_height) / 2
    lines[n][2].each do |who|
      rect y: who_y, layout: :whotext, fill_color: who == 'PRIV' ? '#CBF' : who == 'AUTO' ? '#AFA' : '#FAA'
      text str: who, y: who_y, layout: :whotext
      who_y += 29
    end
    rect x: 75, y: y, width: 975, height: extents[0][:height] + 10
    y += extents[0][:height] + 10
  end
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'turn_summary_de', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'turn_summary_de', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if TURNSUMMARYDE

# the payout range for a given stock price, price change, and number of shares
# spi is the index into $SHARE_PRICES
# row 0 is dropping two prices, row 1 drop 1, row 2 raise 1, row 3 raise 2
# shares is the number of issued shares
def payoutrange(spi, row, shares)
  return '' if spi == $SHARE_PRICES.length - 1

  if row == 0 || (row == 1 && spi == 1)
    min = 0
  elsif row == 1
    min = $SHARE_PRICES[spi - 1] * shares
  elsif row == 2
    min = $SHARE_PRICES[spi] * shares
  else
    min = $SHARE_PRICES[spi + 1] * shares
  end

  if row == 3 || (row == 2 && spi==$SHARE_PRICES.length - 2)
    max = '∞'
  elsif row == 2
    max = $SHARE_PRICES[spi + 1] * shares - 1
  elsif row == 1
    max = $SHARE_PRICES[spi] * shares - 1
  else
    max = $SHARE_PRICES[spi - 1] * shares - 1
  end

  '$' + min.to_s + '-$' + max.to_s
end

def sharepricefrontback(front)
  background color: :white
  text str: 'share price', layout: :title
  text str: (0..$SHARE_PRICES.length - 1).to_a.map { |n| n == 0 ? '' : ('$' + $SHARE_PRICES[n - 1].to_s + '←') }, layout: :leftprice
  text str: (0..$SHARE_PRICES.length - 1).to_a.map { |n| n==$SHARE_PRICES.length - 1 ? '' : ('→$' + $SHARE_PRICES[n + 1].to_s) }, layout: :rightprice
  text str: $SHARE_PRICES.map { |p| '$' + p.to_s}, color: [:red] + [:black] * ($SHARE_PRICES.length - 2) + ['#080'], layout: :shareprice
  rect layout: :maxpayout
  text str: "max payout\nper share", layout: :maxpayoutlabel
  text str: $SHARE_PRICES.map { |p| (p == 0 || p == 100) ? 'n / a' : ('$' + (p / 3).to_i.to_s) }, layout: :maxpayoutamount
  rect range: (6..10), stroke_color: '#0000', fill_color: :red, layout: :ipofirstthird
  text range: (6..10), str: '●', y: 290, layout: :ipofirstthird
  rect range: (6..10), stroke_color: '#0000', fill_color: :orange, layout: :iposecondthird
  text range: (6..10), str: '▲', y: 290, layout: :iposecondthird
  rect range: (6..10), stroke_color: '#0000', fill_color: :yellow, layout: :ipothirdthird
  text range: (6..10), str: '■', y: 290, layout: :ipothirdthird
  rect range: (11..14), stroke_color: '#0000', fill_color: :orange, layout: :ipofirstthird
  text range: (11..14), str: '▲', y: 290, layout: :ipofirstthird
  rect range: (11..14), stroke_color: '#0000', fill_color: :yellow, layout: :iposecondthird
  text range: (11..14), str: '■', y: 290, layout: :iposecondthird
  rect range: (11..14), stroke_color: '#0000', fill_color: :green, layout: :ipothirdthird
  text range: (11..14), str: '⬟', y: 290, layout: :ipothirdthird
  rect range: (15..17), stroke_color: '#0000', fill_color: :yellow, layout: :ipofirstthird
  text range: (15..17), str: '■', y: 290, layout: :ipofirstthird
  rect range: (15..17), stroke_color: '#0000', fill_color: :green, layout: :iposecondthird
  text range: (15..17), str: '⬟', y: 290, layout: :iposecondthird
  rect range: (15..17), stroke_color: '#0000', fill_color: :blue, layout: :ipothirdthird
  text range: (15..17), str: '⬢', y: 290, layout: :ipothirdthird
  rect range: (18..20), stroke_color: '#0000', fill_color: :green, layout: :ipofirstthird
  text range: (18..20), str: '⬟', y: 290, layout: :ipofirstthird
  rect range: (18..20), stroke_color: '#0000', fill_color: :blue, layout: :iposecondthird
  text range: (18..20), str: '⬢', y: 290, layout: :iposecondthird
  rect range: (18..20), stroke_color: '#0000', fill_color: :purple, layout: :ipothirdthird
  text range: (18..20), str: '★', y: 290, layout: :ipothirdthird
  rect range: (21..23), stroke_color: '#0000', fill_color: :blue, layout: :ipofirsthalf
  text range: (21..23), str: '⬢', y: 290, layout: :ipofirsthalf
  rect range: (21..23), stroke_color: '#0000', fill_color: :purple, layout: :iposecondhalf
  text range: (21..23), str: '★', y: 290, layout: :iposecondhalf
  text range: (6..23), str: 'IPO', layout: :ipo
  rect range: (6..23), layout: :ipo
  bottom_y = 475
  text str: 'When a corporation takes this card, it is declared bankrupt immediately. Remove its subsidiary companies from the game. Return its cash, its shares, and this card without compensation.\n(Shares are available for newly founded corporations.)',
    range: 0,
    y: bottom_y,
    font_size: 30,
    layout: :bottomtext
  text str: 'If this card is in use in phase 10 or after a share has been bought in phase 3, the game ends immediately. In phase 9, assume there is an infinite supply of this card. Each corporation reaching $100 share price after the first returns its old share price card without taking a new one. Its shares have a value of $100 at the end of the game.',
    range: $SHARE_PRICES.length - 1,
    y: bottom_y,
    font_size: 27,
    layout: :bottomtext
  text str: 'shares ',
    range: (1..$SHARE_PRICES.length - 2), # skip $0 and $100
    x: (front ? 82 : 162),
    y: bottom_y,
    align: 'right',
    layout: :bottomgridbox
  (front ? 2..6 : 7..10).each do |col|
    text str: col.to_s,
      range: (1..$SHARE_PRICES.length - 2), # skip $0 and $100
      x: (front ? 82 : 162) + 160 * (col - (front ? 1 : 6)),
      y: bottom_y,
      layout: :bottomgridbox
  end
  (0..3).each do |row|
    text str: (0..$SHARE_PRICES.length - 1).to_a.map { |i| ['', '', '→', '→→'][row] + '$' + $SHARE_PRICES[i + (row < 2 ? (row - 2) : (row - 1))].to_s + ['←←', '←', '', ''][row] },
      range: ((row > 0 ? 1 : 2)..($SHARE_PRICES.length - (row < 3 ? 2 : 3))),
      x: (front ? 82 : 162),
      y: $SHARE_PRICES.map { |p| p == 5 || p == 100 ? (bottom_y + row * 50) : (bottom_y + 50 + row * 50) },
      layout: :bottomgridbox
    (front ? 2..6 : 7..10).each do |col|
      text str: (0..$SHARE_PRICES.length - 1).map { |i| payoutrange(i, row, col) },
        range: ((row > 0 ? 1 : 2)..($SHARE_PRICES.length - (row < 3 ? 2 : 3))),
        x: (front ? 82 : 162) + 160 * (col - (front ? 1 : 6)),
        y: $SHARE_PRICES.map { |p| p == 5 || p == 100 ? (bottom_y + row * 50) : (bottom_y + 50 + row * 50) },
        layout: :bottomgridbox
    end
  end
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
end

# Share Price card fronts
Squib::Deck.new(
  cards: $SHARE_PRICES.length,
  width: 1125,
  height: 825,
  layout: 'layout_shareprice.yml'
) do
  sharepricefrontback(true)
  save prefix: 'shareprice_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise : false, format: :png
end if SHAREPRICES

# Share Price card backs
Squib::Deck.new(
  cards: $SHARE_PRICES.length,
  width: 1125,
  height: 825,
  layout: 'layout_shareprice.yml'
) do
  sharepricefrontback(false)
  save prefix: 'shareprice_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if SHAREPRICES

# some data and helper functions originally from https://github.com / tobymao / rolling_stock / blob / master / models / company.rb
COMPANIES = {
  'BME' => { index: 0, tier: 0, value: 1, income: 1, synergies: %w(KME BD HE PR), name: "Bergisch - Märkische\nEisenbahn - Gesellschaft" },
  'BSE' => { index: 1, tier: 0, value: 2, income: 1, synergies: %w(BPM SX MS PR), name: "Berlin - Stettiner\nEisenbahn - Gesellschaft" },
  'KME' => { index: 2, tier: 0, value: 5, income: 2, synergies: %w(BME MHE OL HE PR), name: "Köln - Mindener\nEisenbahn - Gesellschaft" },
  'AKE' => { index: 3, tier: 0, value: 6, income: 2, synergies: %w(BPM MHE OL MS PR), name: "Altona - Kieler\nEisenbahn - Gesellschaft" },
  'BPM' => { index: 4, tier: 0, value: 7, income: 2, synergies: %w(BSE AKE MHE SX MS PR), name: 'Berlin - Potsdam - Magdeburger Eisenbahn' },
  'MHE' => { index: 5, tier: 0, value: 8, income: 2, synergies: %w(KME AKE BPM OL SX MS PR), name: 'Magdeburg - Halberstädter Eisenbahngesellschaft' },
  'WT'  => { index: 6, tier: 1, value: 11, income: 3, synergies: %w(BD BY SBB DR), name: "Königlich Württembergische\nStaats - Eisenbahnen" },
  'BD'  => { index: 7, tier: 1, value: 12, income: 3, synergies: %w(BME WT HE SNCF SBB DR), name: 'Großherzoglich Badische Staatseisenbahnen' },
  'BY'  => { index: 8, tier: 1, value: 13, income: 3, synergies: %w(WT HE SX KK DR), name: 'Königlich Bayerische Staatseisenbahnen' },
  'OL'  => { index: 9, tier: 1, value: 14, income: 3, synergies: %w(KME AKE MHE MS PR DSB NS DR), name: 'Großherzoglich Oldenburgische Staatseisenbahnen' },
  'HE'  => { index: 10, tier: 1, value: 15, income: 3, synergies: %w(BME KME BD BY PR DR), name: 'Großherzoglich Hessische Staatseisenbahnen' },
  'SX'  => { index: 11, tier: 1, value: 16, income: 3, synergies: %w(BSE BPM MHE BY MS PR PKP KK DR), name: 'Königlich Sächsische Staatseisenbahnen' },
  'MS'  => { index: 12, tier: 1, value: 17, income: 3, synergies: %w(BSE AKE BPM MHE OL SX PR DSB PKP DR), name: 'Großherzoglich Mecklenburgische Friedrich - Franz - Eisenbahn' },
  'PR'  => { index: 13, tier: 1, value: 19, income: 3, synergies: %w(BME BSE KME AKE BPM MHE OL HE SX MS DSB NS B PKP DR), name: 'Preußische Staatseisenbahnen' },
  'DSB' => { index: 14, tier: 2, value: 20, income: 6, synergies: %w(OL MS PR DR BSR HH), name: 'Danske Statsbaner' },
  'NS'  => { index: 15, tier: 2, value: 21, income: 6, synergies: %w(OL PR B DR E HA HR), name: 'Nederlandse Spoorwegen' },
  'B'   => { index: 16, tier: 2, value: 22, income: 6, synergies: %w(PR NS SNCF DR E HA HR), name: 'Nationale Maatschappij der Belgische Spoorwegen – Société Nationale des Chemins de fer Belges' },
  'PKP' => { index: 17, tier: 2, value: 23, income: 6, synergies: %w(SX MS PR KK DR SZD BSR HH FRA), name: 'Polskie Koleje Państwowe' },
  'SNCF'=> { index: 18, tier: 2, value: 24, income: 6, synergies: %w(BD B SBB DR RENFE FS E HA CDG), name: 'Société nationale des chemins de fer français' },
  'KK'  => { index: 19, tier: 2, value: 25, income: 6, synergies: %w(BY SX PKP SBB DR FS FRA), name: 'k.k. Österreichische Staatsbahnen' },
  'SBB' => { index: 20, tier: 2, value: 26, income: 6, synergies: %w(WT BD SNCF KK DR FS CDG FRA), name: 'Schweizerische Bundesbahnen – Chemins de fer fédéraux suisses – Ferrovie federali svizzere' },
  'DR'  => { index: 21, tier: 2, value: 29, income: 6, synergies: %w(WT BD BY OL HE SX MS PR DSB NS B PKP SNCF KK SBB BSR HH HR FRA), name: 'Deutsche Reichsbahn' },
  'SJ'  => { index: 22, tier: 3, value: 30, income: 12, synergies: %w(BSR), name: 'Statens Järnvägar' },
  'SZD' => { index: 23, tier: 3, value: 31, income: 12, synergies: %w(PKP), name: "Советские железные дороги\n(Sovetskie železnye dorogi)" },
  'RENFE'=>{ index: 24, tier: 3, value: 32, income: 12, synergies: %w(SNCF MAD), name: "Red Nacional de los\nFerrocarriles Españoles" },
  'BR'  => { index: 25, tier: 3, value: 33, income: 12, synergies: %w(E LHR), name: 'British Rail' },
  'FS'  => { index: 26, tier: 3, value: 37, income: 10, synergies: %w(SNCF KK SBB), name: 'Ferrovie dello Stato' },
  'BSR' => { index: 27, tier: 3, value: 40, income: 10, synergies: %w(DSB PKP DR SJ HH), name: 'Baltic Sea Rail' },
  'E'   => { index: 28, tier: 3, value: 43, income: 10, synergies: %w(NS B SNCF BR HA HR LHR CDG), name: 'Eurotunnel' },
  'MAD' => { index: 29, tier: 4, value: 45, income: 15, synergies: %w(RENFE FR VP LE), name: 'Madrid - Barajas Airport' },
  'HA'  => { index: 30, tier: 4, value: 47, income: 15, synergies: %w(NS B SNCF E RU AL), name: 'Haven van Antwerpen' },
  'HH'  => { index: 31, tier: 4, value: 48, income: 15, synergies: %w(DSB PKP DR BSR RU AL), name: 'Hamburger Hafen' },
  'HR'  => { index: 32, tier: 4, value: 49, income: 15, synergies: %w(NS B DR E RU AL), name: 'Haven van Rotterdam' },
  'LHR' => { index: 33, tier: 4, value: 54, income: 15, synergies: %w(BR E FR MM VP LE), name: 'London Heathrow Airport' },
  'CDG' => { index: 34, tier: 4, value: 56, income: 15, synergies: %w(SNCF SBB E FR VP LE), name: 'Aéroport Paris - Charles - de - Gaulle' },
  'FRA' => { index: 35, tier: 4, value: 58, income: 15, synergies: %w(PKP KK SBB DR FR MM LE), name: 'Flughafen Frankfurt' },
  'FR'  => { index: 36, tier: 4, value: 60, income: 15, synergies: %w(MAD LHR CDG FRA), name: 'Ryanair' },
  'OPC' => { index: 37, tier: 5, value: 70, income: 25, synergies: %w(RU AL TSI), name: 'Outer Planet Consortium' },
  'RCC' => { index: 38, tier: 5, value: 71, income: 25, synergies: %w(RU AL TSI), name: 'Ring Construction Corporation' },
  'MM'  => { index: 39, tier: 5, value: 75, income: 25, synergies: %w(LHR FRA LE TSI), name: 'Mars Mining Associates' },
  'VP'  => { index: 40, tier: 5, value: 80, income: 25, synergies: %w(MAD LHR CDG LE TSI), name: 'Venus Prospectors' },
  'RU'  => { index: 41, tier: 5, value: 85, income: 25, synergies: %w(HA HH HR OPC RCC TSI), name: 'Resources Unlimited' },
  'AL'  => { index: 42, tier: 5, value: 86, income: 25, synergies: %w(HA HH HR OPC RCC TSI), name: 'Asteroid League' },
  'LE'  => { index: 43, tier: 5, value: 90, income: 25, synergies: %w(MAD LHR CDG FRA MM VP TSI), name: 'Lunar Enterprises' },
  'TSI' => { index: 44, tier: 5, value:100, income: 25, synergies: %w(OPC RCC MM VP RU AL LE), name: 'Trans - Space Inc.' }
}.freeze

TIER_COLORS = %w(red orange yellow green #33F purple).freeze
SYNERGY_COLORS = %w(red orange #BF0 #33F purple).freeze
TIER_SYMBOLS = %w(● ▲ ■ ⬟ ⬢ ★).freeze
TIER_TO_SYNERGY = [0, 1, 2, 2, 3, 4].freeze

def min_price(value)
  (value / 2.0).ceil
end

def max_price(tier, value, income)
  case tier
  when 0
    income + value
  when 1
    value * 1.22 + 1
  when 2
    value * 1.20 + 2
  when 3
    value * 1.19 + 7
  when 4
    value * 1.14 + 16
  when 5
    value * 1.10 + 30
  end.floor
end

def synergytier(t1, t2)
  TIER_TO_SYNERGY[[t1, t2].min]
end

COMPANY_GRID_HEIGHT = 115
# for every company, figure out if and where and how to render each synergy and row of synergies
# which companies have each possible tier of synergies?
synergy_rows = Array.new(SYNERGY_COLORS.length) do
  {
    x: Array.new(COMPANIES.length, 75),
    y: Array.new(COMPANIES.length, 0),
    width: Array.new(COMPANIES.length, 162.5),
    height: Array.new(COMPANIES.length, COMPANY_GRID_HEIGHT),
    count: Array.new(COMPANIES.length, 0),
    range: Set.new
  }
end
# which companies have each possible synergy, and where does it render?
synergy_boxes = Array.new(COMPANIES.length) do
  {
    x: Array.new(COMPANIES.length, 0),
    y: Array.new(COMPANIES.length, 0),
    width: Array.new(COMPANIES.length, 162.5),
    range: Set.new
  }
end
synergy_redlines = Array.new(COMPANIES.length)
# first figure out which companies get which synergy tiers and specific synergies
COMPANIES.each do |_k, v|
  # each synergy that company card has
  v[:synergies].each do |s|
    # which synergy tier for the two companies?
    synergytier = synergytier(v[:tier], COMPANIES[s][:tier])
    # mark this company card as needing that synergy tier
    synergy_rows[synergytier][:range].add(v[:index])
    synergy_rows[synergytier][:count][v[:index]] += 1
    # and mark the synergy company as rendering on this company card
    synergy_boxes[COMPANIES[s][:index]][:range].add(v[:index])
  end
end
# now figure out where to draw all of that on each company card
COMPANIES.each do |_k, v|
  y = 825-75-COMPANY_GRID_HEIGHT
  i = v[:index]
  redline = false
  [4, 3, 2, 1, 0].each do |synergy_tier|
    x = 75
    next unless synergy_rows[synergy_tier][:range].include?i
    # this company has at least one synergy at this tier
    count = synergy_rows[synergy_tier][:count][i]
    if count < 6
      firstrow = count
      secondrow = 0
    else
      firstrow = (count / 2.0).floor
      secondrow = (count / 2.0).ceil
    end
    # abandoned effort to make box width dynamic
    # boxwidth = [975/(firstrow + 1),243.75].min
    # synergy_rows[synergy_tier][:width][i] = boxwidth
    # position and size the tier bonus box
    if secondrow > 0
      y -= COMPANY_GRID_HEIGHT
      secondrow == firstrow && synergy_rows[synergy_tier][:height][i] *= 2
    end
    synergy_rows[synergy_tier][:y][i] = y
    x += 162.5
    drawn_count = 0
    # puts k + ' ' + firstrow.to_s + ' ' + secondrow.to_s
    COMPANIES.each do |synk, synv|
      next unless v[:synergies].include?synk
      # this company has this synergy
      next unless synergytier(v[:tier], synv[:tier]) == synergy_tier
      # and it's on this tier
      if drawn_count == firstrow
        # start the second row
        y += COMPANY_GRID_HEIGHT
        x = 75 + (secondrow == firstrow ? 162.5 : 0)
      end
      if !redline && synv[:value] > v[:value]
        synergy_redlines[v[:index]] = { x1: x, y1: y, x2: x, y2: y + COMPANY_GRID_HEIGHT }
        redline = true
        # puts v[:index]
        # puts synergy_redlines[v[:index]]
      end
      synergy_boxes[synv[:index]][:x][i] = x
      synergy_boxes[synv[:index]][:y][i] = y
      x += 162.5
      drawn_count += 1
    end
    if !redline
      synergy_redlines[v[:index]] = { x1: x, y1: y, x2: x, y2: y + COMPANY_GRID_HEIGHT }
    end
    y -= COMPANY_GRID_HEIGHT * (secondrow > 0 ? 2 : 1) + 10
  end
end

# Company card fronts
Squib::Deck.new(
  cards: COMPANIES.length,
  width: 1125,
  height: 825,
  layout: 'layout_company.yml'
) do
  background color: COMPANIES.map { |_k, v| '(0,37.5)(0,787.5) ' + TIER_COLORS[v[:tier]] + '@0.0 white@1.0' }
  extents = text str: COMPANIES.map { |_k, v| '$' + v[:value].to_s }, layout: :value
  y = extents[0][:height] + 40
  extents = text y: y, x: 50, width: extents.map { |e| e[:width] + 50 },
    str: COMPANIES.map { |_k, v| '($' + min_price(v[:value]).to_s + '-$' + max_price(v[:tier], v[:value], v[:income]).to_s + ')' },
    layout: :pricerange
  y += extents[0][:height] * 0.7
  text y: y, x: 75, align: :left,
    str: COMPANIES.map { |_k, v| TIER_SYMBOLS[v[:tier]] }, layout: :tiericon
  circle x: 950, y: 175, radius: 100,
    fill_color: COMPANIES.map { |_k, v| TIER_COLORS[v[:tier]] }, stroke_color: :black, stroke_width: 2.0
  text x: 950 - 100, y: 175 - 100, font: 'Signika 66', align: 'center', valign: 'middle',
    color: :black, width: 200, height: 200, str: COMPANIES.map { |_k, v| '+$' + v[:income].to_s }
  extents = text str: COMPANIES.keys, layout: :acronym
  text y: extents[0][:height] + 5, str: COMPANIES.map { |_k, v| v[:name] }, layout: :name

  SYNERGY_COLORS.each_with_index do |color, index|
    rect fill_color: color, layout: :synergyamount,
      x: synergy_rows[index][:x], y: synergy_rows[index][:y], range: synergy_rows[index][:range],
      width: synergy_rows[index][:width], height: synergy_rows[index][:height]
    text str: '$' + (2 ** index).to_s, layout: :synergyamount,
      x: synergy_rows[index][:x], y: synergy_rows[index][:y], range: synergy_rows[index][:range],
      width: synergy_rows[index][:width], height: synergy_rows[index][:height]
  end
  COMPANIES.each do |k, v|
    i = v[:index]
    rect fill_color: TIER_COLORS[v[:tier]],
      x: synergy_boxes[i][:x], y: synergy_boxes[i][:y], range: synergy_boxes[i][:range],
      width: synergy_boxes[i][:width], height: COMPANY_GRID_HEIGHT, layout: :synergybox
    text str: k,
      x: synergy_boxes[i][:x], y: synergy_boxes[i][:y], range: synergy_boxes[i][:range],
      width: synergy_boxes[i][:width], layout: :synergyacronym
    text str: '(' + v[:value].to_s + ')',
      x: synergy_boxes[i][:x], y: synergy_boxes[i][:y].map { |y| y + 60 }, range: synergy_boxes[i][:range],
      width: synergy_boxes[i][:width], layout: :synergyvalue
  end
  line stroke_color: COMPANIES.map { |_k, v| v[:tier] > 0 ? :red : :yellow }, stroke_width: 10, cap: :round,
    x1: synergy_redlines.map { |r| r[:x1] },
    x2: synergy_redlines.map { |r| r[:x2] },
    y1: synergy_redlines.map { |r| r[:y1] },
    y2: synergy_redlines.map { |r| r[:y2] }
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'company_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise : false, format: :png
  save_sheet
end if COMPANYCARDS

def cost_of_ownership_string(tier)
  if tier < 3
    'no cost of ownership'
  else
    'cost of ownership $' + [1, 3, 6][tier - 3].to_s
  end
end

# Company card backs
Squib::Deck.new(
  cards: COMPANIES.length,
  width: 1125,
  height: 825,
  layout: 'layout_company_back.yml'
) do
  background color: COMPANIES.map { |_k, v| '(0,37.5)(0,787.5) ' + TIER_COLORS[v[:tier]] + '@0.0 white@1.0' }
  text str: COMPANIES.map { |_k, v| TIER_SYMBOLS[v[:tier]] }, layout: :CornerSymbol
  # red box on the back of green cards
  rect layout: :BoxWhole, stroke_width: 0, fill_color: TIER_COLORS[0], range: COMPANIES.select { |_k, v| v[:tier] == 3 }.map { |_k, v| v[:index] }
  text layout: :BoxWholeSymbol, str: TIER_SYMBOLS[0], range: COMPANIES.select { |_k, v| v[:tier] == 3 }.map { |_k, v| v[:index] }
  # red and orange boxes on the back of blue cards
  rect layout: :BoxHalf, stroke_width: 0, fill_color: TIER_COLORS[0], range: COMPANIES.select { |_k, v| v[:tier] == 4 }.map { |_k, v| v[:index] }
  text layout: :BoxHalf, str: TIER_SYMBOLS[0], range: COMPANIES.select { |_k, v| v[:tier] == 4 }.map { |_k, v| v[:index] }
  rect layout: :BoxHalf, x: 562.5, stroke_width: 0, fill_color: TIER_COLORS[1], range: COMPANIES.select { |_k, v| v[:tier] == 4 }.map { |_k, v| v[:index] }
  text layout: :BoxHalf, x: 562.5, str: TIER_SYMBOLS[1], range: COMPANIES.select { |_k, v| v[:tier] == 4 }.map { |_k, v| v[:index] }
  # red orange yellow boxes on the back of purple cards
  rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[0], range: COMPANIES.select { |_k, v| v[:tier] == 5 }.map { |_k, v| v[:index] }
  text layout: :BoxThird, str: TIER_SYMBOLS[0], range: COMPANIES.select { |_k, v| v[:tier] == 5 }.map { |_k, v| v[:index] }
  rect layout: :BoxThird, x: 425, stroke_width: 0, fill_color: TIER_COLORS[1], range: COMPANIES.select { |_k, v| v[:tier] == 5 }.map { |_k, v| v[:index] }
  text layout: :BoxThird, x: 425, str: TIER_SYMBOLS[1], range: COMPANIES.select { |_k, v| v[:tier] == 5 }.map { |_k, v| v[:index] }
  rect layout: :BoxThird, x: 700, stroke_width: 0, fill_color: TIER_COLORS[2], range: COMPANIES.select { |_k, v| v[:tier] == 5 }.map { |_k, v| v[:index] }
  text layout: :BoxThird, x: 700, str: TIER_SYMBOLS[2], range: COMPANIES.select { |_k, v| v[:tier] == 5 }.map { |_k, v| v[:index] }
  text str: COMPANIES.map { |_k, v| cost_of_ownership_string(v[:tier]) }, layout: :CenterishText
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'company_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
end if COMPANYCARDS

# End of Game cards
Squib::Deck.new(
  cards: 6,
  width: 1125,
  height: 825,
  layout: 'layout_endofgame.yml'
) do
  # first we draw the colored boxes
  # front of training game
  rect layout: :BoxHalf, stroke_width: 0, fill_color: TIER_COLORS[0], range: [0]
  rect layout: :BoxHalf, stroke_width: 0, fill_color: TIER_COLORS[1], range: [0], x: 562.5
  # front of short game, back of training game
  rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[0], range: [1,2], x: 0, width: 400
  rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[1], range: [1,2], x: 400
  rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[2], range: [1,2], x: 725, width: 400
  # back of short game, front and back of full game
  rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[0], range: [3,4,5]
  rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[1], range: [3,4,5], x: 562.5
  rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[2], range: [3,4,5], y: 412.5
  rect layout: :BoxQuarter, stroke_width: 0, fill_color: TIER_COLORS[3], range: [3,4,5], x: 562.5, y: 412.5
  # next we draw the symbols
  # bottom left circle
  text layout: :BottomSymbol, str: TIER_SYMBOLS[0], range: [0,1,2], align: :left
  # bottom right triangle
  text layout: :BottomSymbol, str: TIER_SYMBOLS[1], range: [0], align: :right
  # bottom center triangle
  text layout: :BottomSymbol, str: TIER_SYMBOLS[1], range: [1,2]
  # bottom right square
  text layout: :BottomSymbol, str: TIER_SYMBOLS[2], range: [1,2], align: :right
  # all four corners
  text layout: :TopSymbol, str: TIER_SYMBOLS[0], range: [3,4,5], align: :left
  text layout: :TopSymbol, str: TIER_SYMBOLS[1], range: [3,4,5], align: :right
  text layout: :BottomSymbol, str: TIER_SYMBOLS[2], range: [3,4,5], align: :left
  text layout: :BottomSymbol, str: TIER_SYMBOLS[3], range: [3,4,5], align: :right
  # then we draw the text in the middle
  text str: [3,8,6,15,10,16].map{|c| 'cost of ownership $' + c.to_s }, layout: :CenterishText
  text str: "If there are no unowned private companies left at the end of\na turn, flip this card.",
    layout: :SmallerText, range: [0,2,4]
  text str: "The end of the next turn is\nthe end of the game.",
    layout: :SmallerText, range: [1,3,5]
  rect layout: :safe if CUTLINES
  rect layout: :cut if CUTLINES
  save prefix: 'endofgame_training[face]', range: [0], count_format: '', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'endofgame_training[back]', range: [1], count_format: '', rotate: ROTATE ? :counterclockwise : false, format: :png
  save prefix: 'endofgame_short[face]',    range: [2], count_format: '', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'endofgame_short[back]',    range: [3], count_format: '', rotate: ROTATE ? :counterclockwise : false, format: :png
  save prefix: 'endofgame_full[face]',     range: [4], count_format: '', rotate: ROTATE ? :clockwise        : false, format: :png
  save prefix: 'endofgame_full[back]',     range: [5], count_format: '', rotate: ROTATE ? :counterclockwise : false, format: :png
end if ENDOFGAME

# synergy tokens
# to be mixed fronts/backs at production time
Squib::Deck.new(
  cards: 5,
  width: 225,
  height: 225,
  layout: 'layout_synergytoken.yml'
) do
  background color: SYNERGY_COLORS
  text font: 'Signika 40', align: 'center', valign: 'middle', color: :black,
    width: 225, height: 225,
    str: [1,2,4,8,16].map{ |v| '+$' + v.to_s }
  circle layout: :safe if CUTLINES
  circle layout: :cut if CUTLINES
  save prefix: 'synergy_token_', format: :png  
end if SYNERGYTOKENS