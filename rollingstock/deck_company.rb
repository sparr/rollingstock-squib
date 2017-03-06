module Rollingstock
  def Rollingstock.company_min_price(value)
    (value / 2.0).ceil
  end

  def Rollingstock.company_max_price(tier, value, income)
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

  def Rollingstock.synergytier(t1, t2)
    TIER_TO_SYNERGY[[t1, t2].min]
  end

  COMPANY_GRID_HEIGHT = 115
  # for every company, figure out if and where and how to render each synergy and row of synergies
  # which companies have each possible tier of synergies?
  SYNERGY_ROWS = Array.new(SYNERGY_COLORS.length) do
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
  SYNERGY_BOXES = Array.new(COMPANIES.length) do
    {
      x: Array.new(COMPANIES.length, 0),
      y: Array.new(COMPANIES.length, 0),
      width: Array.new(COMPANIES.length, 162.5),
      range: Set.new
    }
  end
  SYNERGY_REDLINES = Array.new(COMPANIES.length)
  # first figure out which companies get which synergy tiers and specific synergies
  COMPANIES.each do |_k, v|
    # each synergy that company card has
    v[:synergies].each do |s|
      # which synergy tier for the two companies?
      synergytier = synergytier(v[:tier], COMPANIES[s][:tier])
      # mark this company card as needing that synergy tier
      SYNERGY_ROWS[synergytier][:range].add(v[:index])
      SYNERGY_ROWS[synergytier][:count][v[:index]] += 1
      # and mark the synergy company as rendering on this company card
      SYNERGY_BOXES[COMPANIES[s][:index]][:range].add(v[:index])
    end
  end
  # now figure out where to draw all of that on each company card
  COMPANIES.each do |_k, v|
    y = 825 - 75 - COMPANY_GRID_HEIGHT
    i = v[:index]
    redline = false
    [4, 3, 2, 1, 0].each do |synergy_tier|
      x = 75
      next unless SYNERGY_ROWS[synergy_tier][:range].include?i
      # this company has at least one synergy at this tier
      count = SYNERGY_ROWS[synergy_tier][:count][i]
      if count < 6
        firstrow = count
        secondrow = 0
      else
        firstrow = (count / 2.0).floor
        secondrow = (count / 2.0).ceil
      end
      # abandoned effort to make box width dynamic
      # boxwidth = [975/(firstrow + 1),243.75].min
      # SYNERGY_ROWS[synergy_tier][:width][i] = boxwidth
      # position and size the tier bonus box
      if secondrow > 0
        y -= COMPANY_GRID_HEIGHT
        secondrow == firstrow && SYNERGY_ROWS[synergy_tier][:height][i] *= 2
      end
      SYNERGY_ROWS[synergy_tier][:y][i] = y
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
          SYNERGY_REDLINES[v[:index]] = { x1: x, y1: y, x2: x, y2: y + COMPANY_GRID_HEIGHT }
          redline = true
          # puts v[:index]
          # puts SYNERGY_REDLINES[v[:index]]
        end
        SYNERGY_BOXES[synv[:index]][:x][i] = x
        SYNERGY_BOXES[synv[:index]][:y][i] = y
        x += 162.5
        drawn_count += 1
      end
      if !redline
        SYNERGY_REDLINES[v[:index]] = { x1: x, y1: y, x2: x, y2: y + COMPANY_GRID_HEIGHT }
      end
      y -= COMPANY_GRID_HEIGHT * (secondrow > 0 ? 2 : 1) + 10
    end
  end

  # Company card faces
  def Rollingstock.deck_company_face()
    Squib::Deck.new(
      cards: COMPANIES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_company.yml'
    ) do
      background color: COMPANIES.map { |_k, v| '(0,37.5)(0,787.5) ' + TIER_COLORS[v[:tier]] + '@0.0 white@1.0' }
      extents = text str: COMPANIES.map { |_k, v| '$' + v[:value].to_s }, layout: :value
      y = extents[0][:height] + 40
      extents = text y: y, x: 50, width: extents.map { |e| e[:width] + 50 },
        str: COMPANIES.map { |_k, v| '($' + Rollingstock.company_min_price(v[:value]).to_s + '-$' + Rollingstock.company_max_price(v[:tier], v[:value], v[:income]).to_s + ')' },
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
          x: SYNERGY_ROWS[index][:x], y: SYNERGY_ROWS[index][:y], range: SYNERGY_ROWS[index][:range],
          width: SYNERGY_ROWS[index][:width], height: SYNERGY_ROWS[index][:height]
        text str: '$' + SYNERGY_VALUES[index].to_s, layout: :synergyamount,
          x: SYNERGY_ROWS[index][:x], y: SYNERGY_ROWS[index][:y], range: SYNERGY_ROWS[index][:range],
          width: SYNERGY_ROWS[index][:width], height: SYNERGY_ROWS[index][:height]
      end
      COMPANIES.each do |k, v|
        i = v[:index]
        rect fill_color: TIER_COLORS[v[:tier]],
          x: SYNERGY_BOXES[i][:x], y: SYNERGY_BOXES[i][:y], range: SYNERGY_BOXES[i][:range],
          width: SYNERGY_BOXES[i][:width], height: COMPANY_GRID_HEIGHT, layout: :synergybox
        text str: k,
          x: SYNERGY_BOXES[i][:x], y: SYNERGY_BOXES[i][:y], range: SYNERGY_BOXES[i][:range],
          width: SYNERGY_BOXES[i][:width], layout: :synergyacronym
        text str: '(' + v[:value].to_s + ')',
          x: SYNERGY_BOXES[i][:x], y: SYNERGY_BOXES[i][:y].map { |y| y + 60 }, range: SYNERGY_BOXES[i][:range],
          width: SYNERGY_BOXES[i][:width], layout: :synergyvalue
      end
      line stroke_color: COMPANIES.map { |_k, v| v[:tier] > 0 ? :red : :yellow }, stroke_width: 10, cap: :round,
        x1: SYNERGY_REDLINES.map { |r| r[:x1] },
        x2: SYNERGY_REDLINES.map { |r| r[:x2] },
        y1: SYNERGY_REDLINES.map { |r| r[:y1] },
        y2: SYNERGY_REDLINES.map { |r| r[:y2] }
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/company', prefix: 'company_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'company_face', count_format: ''
    end
  end

  def Rollingstock.cost_of_ownership_string(tier)
    if tier < 3
      'no cost of ownership'
    else
      'cost of ownership $' + [1, 3, 6][tier - 3].to_s
    end
  end

  # Company card backs
  def Rollingstock.deck_company_back()
    Squib::Deck.new(
      cards: COMPANIES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_company_back.yml'
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
      text str: COMPANIES.map { |_k, v| Rollingstock.cost_of_ownership_string(v[:tier]) }, layout: :CenterishText
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/company', prefix: 'company_', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'company_back', count_format: '', rtl: true
    end
  end

  def Rollingstock.deck_company()
    Rollingstock.deck_company_face()
    Rollingstock.deck_company_back()
  end
end