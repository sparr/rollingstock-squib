require 'squib'

def ordinal(number)
  abs_number = number.to_i.abs

  if (11..13).include?(abs_number % 100)
    "th"
  else
    case abs_number % 10
      when 1; "st"
      when 2; "nd"
      when 3; "rd"
      else    "th"
    end
  end
end

def ordinalize(number)
  "#{number}#{ordinal(number)}"
end

max_players = 5
min_players = 1
player_numbers = (1..max_players).to_a
corps = ["Bear","Wheel","Orion","Eagle","Horse","Star","Android","Ship","Jupiter","Saturn"]
corp_colors = ['#F00','#000','#96C','#FD2','#999','#0A0','#AC0','#09F','#963','#F0F']
$share_prices = [
   0,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22,
      24, 26, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 81, 90, 100
]

# Player turn order cards
Squib::Deck.new(
  cards: 5,
  width: 1125,
  height: 825,
  layout: 'layout_turnorder.yml'
  ) do
  background color: :white
  text str: ['Position']*player_numbers.length, layout: :upperlabel
  text str: player_numbers, layout: :ordernumber
  text str: ['in player order']*player_numbers.length, layout: :lowerlabel
  save prefix: 'turnorder_', format: :png
end

# Corporation share cards
shares = 10
Squib::Deck.new(
  cards: corps.length*shares,
  width: 1125,
  height: 825,
  layout: 'layout_share.yml'
  ) do
  background color: :white
  # 1st 2nd 3rd 4th .. 9th 10th 1st 2nd ...
  text str: (((1..shares).to_a)*corps.length).map{|n| ordinalize(n) + " share"}, layout: :firstline
  text str: (0..corps.length*shares).to_a.map{|n| corps[n/shares]}, layout: :companyname
  text str: (((0..shares-1).to_a)*corps.length).map{|n| ((n==0) ? 'President' : (n.to_s + " shares issued"))}, layout: :secondline
  rect layout: :safe
  rect layout: :cut
  save prefix: 'share_', format: :png
end

# Corporation placemats
Squib::Deck.new(
  cards: corps.length,
  width: 1725,
  height: 1125,
  layout: 'layout_placemat.yml'
  ) do
  background color: :white
  text str: "all 10 shares issued", layout: :secondline
  text str: (0..corps.length).to_a.map{|n| corps[n]}, layout: :companyname
  text str: '▲ share price ▲', layout: :lefttext
  text str: '▼ subsidiaries ▼', layout: :bottomtext
  text str: '▲ treasury ▲', layout: :righttext
  save prefix: 'placemat_', format: :png
end

# Foreign Investor placemat
Squib::Deck.new(
  cards: 1,
  width: 1725,
  height: 1125,
  layout: 'layout_foreigninvestor.yml'
  ) do
  background color: :white
  text str: "Foreign Investor", layout: :companyname
  text str: "Starts the game with $4 in treasury.
<b>Phase 5</b>: Buys as many private companies as possible, in ascending face value order.
<b>Phase 6</b>: Offers private companies for maximum price. If more than one corporation wants to buy the same private company, the corporation with the higher share price has priority.
<b>Phase 7</b>: Closes private companies with negative income.
<b>Phase 8</b>: Earns $5 plus normal income from private companies.", layout: :maintext
  text str: '▼ private companies ▼', layout: :bottomtext
  text str: '▲ treasury ▲', layout: :righttext
  circle x: 1600, y: 125, radius: 110,
    fill_color: :gray, stroke_color: :black, stroke_width: 2.0
  text x: 1600-110, y: 125-110, font: "Arial Roman,Sans 75", align: "center", valign: "middle",
    color: :black, width: 220, height: 220, str: '+$5'
  save prefix: 'foreign_investor', format: :png
end

# Turn Summary card
# duplicate this elsewise
Squib::Deck.new(
  cards: 1,
  width: 1725,
  height: 1125,
  layout: 'layout_turnsummary.yml'
  ) do
  background color: :white
  y = 50
  extents = text str: "Turn Summary", y: y, layout: :title
  y = y + extents[0][:height]
  lines = [
    ["1", "In share price order, corporations <b>issue one share</b> (optional) and turn share price card horizontally.", ["CORP"]],
    ["2", "In descending face value order, private companies <b>form corporations</b> (optional).", ["PRIV"]],
    ["3", "In player order, players either <b>buy one share</b>, <b>sell one share</b>, <b>start an auction for an available private company</b>, or <b>pass</b>. Proceed until all players have passed consecutively. Game ends immediately if $100 share price has been reached after a buy action.", ["PRIV"]],
    ["4", "<b>Determine new player order</b> by remaining cash. Break ties by old player order.", ["AUTO"]],
    ["5", "In ascending face value order, <b>foreign investor buys available private companies</b> for face value (as many as possible). After that, newly drawn private companies become available.", ["AUTO"]],
    ["6", "In any order, corporations <b>buy companies</b> from other corporations, players, or foreign investor (optional). Price range see company card (foreign investor only sells for max price). Turn sold companies and payed money vertically until end of phase and don't use it for further trades. At any time, each corporations must have at least one subsidiary company.", ["PRIV","CORP"]],
    ["7", "In any order, corporations and players <b>close companies</b> (optional). Foreign investor closes companies with negative income. Players must close companies with negative income they would not be able to pay in phase 8.", ["PRIV","CORP"]],
    ["8", "Corporations, players, and foreign investor earn <b>income</b>. Synergies only apply to corporations. Corporations unable to pay negative income are removed without compensation.", ["AUTO"]],
    ["9", "In share price order, corporations pay <b>dividends</b> for each issued share (from $0 to max as per share price card), <b>adjust share price</b> and turn share price card vertically.", ["CORP"]],
    ["10","If there are no unowned private companies left, <b>flip end card</b>. If it is already flipped, or if $100 share price has been reached, <b>game ends</b>.", ["AUTO"]]
  ]
  for n in 0..9
    text str: lines[n][0], y: y, layout: :linenumber
    extents = text str: lines[n][1], y: y, layout: :maintext
    # vertically center the set of who boxes
    who_y = y+(extents[0][:height]-lines[n][2].length*26)/2
    for who in lines[n][2]
      text str: who, y: who_y, layout: :whotext
      who_y += 26
    end
    rect x: 100, y: y, width: 1525, height: extents[0][:height]
    y += extents[0][:height]
  end
  save prefix: 'turn_summary', format: :png
end

# the payout range for a given stock price, price change, and number of shares
# spi is the index into $share_prices
# row 0 is dropping two prices, row 1 drop 1, row 2 raise 1, row 3 raise 2
# shares is the number of issued shares
def payoutrange(spi,row,shares)
  if spi == $share_prices.length-1
    return ''
  end

  if row==0 || (row==1 && spi==1)
    min = 0
  elsif row==1
    min = $share_prices[spi-1]*shares
  elsif row==2
    min = $share_prices[spi]*shares
  else
    min = $share_prices[spi+1]*shares
  end

  if row==3 || (row==2 && spi==$share_prices.length-2)
    max = '∞'
  elsif row==2
    max = $share_prices[spi+1]*shares-1
  elsif row==1
    max = $share_prices[spi]*shares-1
  else
    max = $share_prices[spi-1]*shares-1
  end

  '$' + min.to_s + '-$' + max.to_s
end

# Share Price card fronts
Squib::Deck.new(
  cards: $share_prices.length,
  width: 1125,
  height: 825,
  layout: 'layout_shareprice.yml'
  ) do
  background color: :white
  text str: 'share price', layout: :title
  text str: (0..$share_prices.length-1).to_a.map{|n| n==0 ? '' : ('← $'+$share_prices[n-1].to_s)}, layout: :leftprice
  text str: (0..$share_prices.length-1).to_a.map{|n| n==$share_prices.length-1 ? '' : ('$'+$share_prices[n+1].to_s+' →')}, layout: :rightprice
  extents = text str: $share_prices.map{|p| '$'+p.to_s}, color: [:red] + [:black]*($share_prices.length-2) + [:green], layout: :shareprice
  rect layout: :maxpayout
  text str: "max payout\nper share", layout: :maxpayoutlabel
  text str: $share_prices.map{|p| (p==0||p==100) ? 'n/a' : ('$'+(p/3).to_i.to_s)}, layout: :maxpayoutamount
  rect range: (6..10), stroke_color: '#0000', fill_color: :red, layout: :ipofirstthird
  text range: (6..10), str: '●', y: 250, layout: :ipofirstthird
  rect range: (6..10), stroke_color: '#0000', fill_color: :orange, layout: :iposecondthird
  text range: (6..10), str: '▲', y: 250,  layout: :iposecondthird
  rect range: (6..10), stroke_color: '#0000', fill_color: :yellow, layout: :ipothirdthird
  text range: (6..10), str: '■', y: 250,  layout: :ipothirdthird
  rect range: (11..14), stroke_color: '#0000', fill_color: :orange, layout: :ipofirstthird
  text range: (11..14), str: '▲', y: 250,  layout: :ipofirstthird
  rect range: (11..14), stroke_color: '#0000', fill_color: :yellow, layout: :iposecondthird
  text range: (11..14), str: '■', y: 250,  layout: :iposecondthird
  rect range: (11..14), stroke_color: '#0000', fill_color: :green, layout: :ipothirdthird
  text range: (11..14), str: '⬟', y: 250,  layout: :ipothirdthird
  rect range: (15..17), stroke_color: '#0000', fill_color: :yellow, layout: :ipofirstthird
  text range: (15..17), str: '■', y: 250,  layout: :ipofirstthird
  rect range: (15..17), stroke_color: '#0000', fill_color: :green, layout: :iposecondthird
  text range: (15..17), str: '⬟', y: 250,  layout: :iposecondthird
  rect range: (15..17), stroke_color: '#0000', fill_color: :blue, layout: :ipothirdthird
  text range: (15..17), str: '⬢', y: 250,  layout: :ipothirdthird
  rect range: (18..20), stroke_color: '#0000', fill_color: :green, layout: :ipofirstthird
  text range: (18..20), str: '⬟', y: 250,  layout: :ipofirstthird
  rect range: (18..20), stroke_color: '#0000', fill_color: :blue, layout: :iposecondthird
  text range: (18..20), str: '⬢', y: 250,  layout: :iposecondthird
  rect range: (18..20), stroke_color: '#0000', fill_color: :purple, layout: :ipothirdthird
  text range: (18..20), str: '★', y: 250,  layout: :ipothirdthird
  rect range: (21..23), stroke_color: '#0000', fill_color: :blue, layout: :ipofirsthalf
  text range: (21..23), str: '⬢', y: 250,  layout: :ipofirsthalf
  rect range: (21..23), stroke_color: '#0000', fill_color: :purple, layout: :iposecondhalf
  text range: (21..23), str: '★', y: 250,  layout: :iposecondhalf
  text range: (6..23), str: 'IPO', layout: :ipo
  rect range: (6..23), layout: :ipo
  bottom_y = 410
  text str: "When a corporation takes this card, it is declared bankrupt immediately. Remove its subsidiary companies from the game. Return its cash, its shares, and this card without compensation.\n(Shares are available for newly founded corporations.)",
    range: 0, 
    y: bottom_y, 
    font_size: 33,
    layout: :bottomtext
  text str: 'If this card is in use in phase 10 or after a share has been bought in phase 3, the game ends immediately. In phase 9, assume there is an infinite supply of this card. Each corporation reaching $100 share price after the first returns its old share price card without taking a new one. Its shares have a value of $100 at the end of the game.',
    range: $share_prices.length-1, 
    y: bottom_y, 
    font_size: 30, 
    layout: :bottomtext
  text str: 'shares ',
    range: (1..$share_prices.length-2), # skip $0 and $100
    x: 82,
    y: bottom_y,
    align: "right",
    layout: :bottomgridbox
  for col in 2..6
    text str: col.to_s,
      range: (1..$share_prices.length-2), # skip $0 and $100
      x: 82+160*(col-1),
      y: bottom_y,
      layout: :bottomgridbox
  end

  for row in [0,1,2,3]
    text str: (0..$share_prices.length-1).to_a.map{|i| (['←← ','← ','',''][row]) + '$' + $share_prices[i+(row<2 ? (row-2) : (row-1))].to_s + (['','',' →',' →→'][row])},
      range: ((row>0 ? 1 : 2)..($share_prices.length-(row<3 ? 2 : 3))),
      x: 82,
      y: $share_prices.map{|p| (p==5||p==100) ? (bottom_y+row*50) : (bottom_y+50+row*50)},
      layout: :bottomgridbox
    for col in 2..6
      text str: (0..$share_prices.length-1).map{|i| payoutrange(i,row,col)},
        range: ((row>0 ? 1 : 2)..($share_prices.length-(row<3 ? 2 : 3))),
        x: 82+160*(col-1),
        y: $share_prices.map{|p| (p==5||p==100) ? (bottom_y+row*50) : (bottom_y+50+row*50)},
        layout: :bottomgridbox
    end
  end
    
  rect layout: :safe
  rect layout: :cut
  save prefix: 'shareprice_', count_format: '%02d[face]', rotate: :clockwise, format: :png
end

# Share Price card backs
Squib::Deck.new(
  cards: $share_prices.length,
  width: 1125,
  height: 825,
  layout: 'layout_shareprice.yml'
  ) do
  background color: :white
  text str: 'share price', layout: :title
  text str: (0..$share_prices.length-1).to_a.map{|n| n==0 ? '' : ('← $'+$share_prices[n-1].to_s)}, layout: :leftprice
  text str: (0..$share_prices.length-1).to_a.map{|n| n==$share_prices.length-1 ? '' : ('$'+$share_prices[n+1].to_s+' →')}, layout: :rightprice
  extents = text str: $share_prices.map{|p| '$'+p.to_s}, color: [:red] + [:black]*($share_prices.length-2) + [:green], layout: :shareprice
  rect layout: :maxpayout
  text str: "max payout\nper share", layout: :maxpayoutlabel
  text str: $share_prices.map{|p| (p==0||p==100) ? 'n/a' : ('$'+(p/3).to_i.to_s)}, layout: :maxpayoutamount
  bottom_y = 410
  text str: "When a corporation takes this card, it is declared bankrupt immediately. Remove its subsidiary companies from the game. Return its cash, its shares, and this card without compensation.\n(Shares are available for newly founded corporations.)",
    range: 0, 
    y: bottom_y, 
    font_size: 33, 
    layout: :bottomtext
  text str: 'If this card is in use in phase 10 or after a share has been bought in phase 3, the game ends immediately. In phase 9, assume there is an infinite supply of this card. Each corporation reaching $100 share price after the first returns its old share price card without taking a new one. Its shares have a value of $100 at the end of the game.',
    range: $share_prices.length-1, 
    y: bottom_y, 
    font_size: 30, 
    layout: :bottomtext
  text str: 'shares ',
    range: (1..$share_prices.length-2), # skip $0 and $100
    x: 162,
    y: bottom_y,
    align: "right",
    layout: :bottomgridbox
  for col in 7..10
    text str: col.to_s,
      range: (1..$share_prices.length-2), # skip $0 and $100
      x: 162+160*(col-6),
      y: bottom_y,
      layout: :bottomgridbox
  end

  for row in [0,1,2,3]
    text str: (0..$share_prices.length-1).to_a.map{|i| (['←← ','← ','',''][row]) + '$' + $share_prices[i+(row<2 ? (row-2) : (row-1))].to_s + (['','',' →',' →→'][row])},
      range: ((row>0 ? 1 : 2)..($share_prices.length-(row<3 ? 2 : 3))),
      x: 162,
      y: $share_prices.map{|p| (p==5||p==100) ? (bottom_y+row*50) : (bottom_y+50+row*50)},
      layout: :bottomgridbox
    for col in 7..10
      text str: (0..$share_prices.length-1).map{|i| payoutrange(i,row,col)},
        range: ((row>0 ? 1 : 2)..($share_prices.length-(row<3 ? 2 : 3))),
        x: 162+160*(col-6),
        y: $share_prices.map{|p| (p==5||p==100) ? (bottom_y+row*50) : (bottom_y+50+row*50)},
        layout: :bottomgridbox
    end
  end
    
  rect layout: :safe
  rect layout: :cut
  save prefix: 'shareprice_', count_format: '%02d[back]', rotate: :counterclockwise, format: :png
end
