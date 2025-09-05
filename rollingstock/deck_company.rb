require 'fileutils'

module Rollingstock
  def self.company_min_price(value)
    (value / 2.0).ceil
  end

  def self.company_max_price(tier, value, income)
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

  def self.synergytier(tier1, tier2)
    TIER_TO_SYNERGY[[tier1, tier2].min]
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
  COMPANIES.each_value do |v|
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
  COMPANIES.each_value do |v| # rubocop:disable Style/CombinableLoops
    y = 825 - 75 - COMPANY_GRID_HEIGHT
    i = v[:index]
    redline = false
    [4, 3, 2, 1, 0].each do |synergy_tier|
      x = 75
      next unless SYNERGY_ROWS[synergy_tier][:range].include? i

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
      if secondrow.positive?
        y -= COMPANY_GRID_HEIGHT
        (secondrow == firstrow || secondrow < 6) && SYNERGY_ROWS[synergy_tier][:height][i] *= 2
      end
      SYNERGY_ROWS[synergy_tier][:y][i] = y
      x += 162.5
      drawn_count = 0
      # puts k + ' ' + firstrow.to_s + ' ' + secondrow.to_s
      COMPANIES.each do |synk, synv|
        next unless v[:synergies].include? synk
        # this company has this synergy
        next unless synergytier(v[:tier], synv[:tier]) == synergy_tier

        # and it's on this tier
        if drawn_count == firstrow
          # start the second row
          y += COMPANY_GRID_HEIGHT
          x = 75 + (secondrow == firstrow || secondrow < 6 ? 162.5 : 0)
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
      SYNERGY_REDLINES[v[:index]] = { x1: x, y1: y, x2: x, y2: y + COMPANY_GRID_HEIGHT } unless redline
      y -= COMPANY_GRID_HEIGHT * (secondrow.positive? ? 2 : 1) + 10
    end
  end

  # Company card faces
  def self.deck_company_face
    Squib::Deck.new(
      cards: COMPANIES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_company.yml'
    ) do
      background color: COMPANIES.map { |_k, v| "(0,37.5)(0,787.5) #{TIER_COLORS[v[:tier]]}@0.0 white@1.0" }
      text layout: :value, str: COMPANIES.map { |_k, v| "$#{v[:value]}" }
      text layout: :pricerange,
           str: COMPANIES.map { |_k, v|
             "($#{Rollingstock.company_min_price(v[:value])}-"\
             "$#{Rollingstock.company_max_price(v[:tier], v[:value], v[:income])})"
           }
      text layout: :tiericon, str: COMPANIES.map { |_k, v| TIER_SYMBOLS[v[:tier]] }
      circle layout: :incomecircle, fill_color: COMPANIES.map { |_k, v| TIER_COLORS[v[:tier]] }
      text layout: :incometext, str: COMPANIES.map { |_k, v| "+$#{v[:income]}" }
      extents = text layout: :acronym, str: COMPANIES.keys
      text layout: :name, y: extents[0][:height] + 20, str: COMPANIES.map { |_k, v| v[:name] }

      SYNERGY_COLORS.each_with_index do |color, index|
        rect fill_color: color, layout: :synergyamount,
             x: SYNERGY_ROWS[index][:x], y: SYNERGY_ROWS[index][:y], range: SYNERGY_ROWS[index][:range],
             width: SYNERGY_ROWS[index][:width], height: SYNERGY_ROWS[index][:height]
        text str: "$#{SYNERGY_VALUES[index]}", layout: :synergyamount,
             x: SYNERGY_ROWS[index][:x], y: SYNERGY_ROWS[index][:y], range: SYNERGY_ROWS[index][:range],
             width: SYNERGY_ROWS[index][:width], height: SYNERGY_ROWS[index][:height]
      end
      COMPANIES.each do |k, v|
        i = v[:index]
        rect fill_color: TIER_COLORS[v[:tier]],
             x: SYNERGY_BOXES[i][:x], y: SYNERGY_BOXES[i][:y], range: SYNERGY_BOXES[i][:range],
             width: SYNERGY_BOXES[i][:width], height: COMPANY_GRID_HEIGHT, layout: :synergybox
        text str: k,
             x: SYNERGY_BOXES[i][:x].map { |x| x - 10 }, y: SYNERGY_BOXES[i][:y], range: SYNERGY_BOXES[i][:range],
             width: SYNERGY_BOXES[i][:width].map { |width| width + 20 }, layout: :synergyacronym
        text str: "(#{v[:value]})",
             x: SYNERGY_BOXES[i][:x], y: SYNERGY_BOXES[i][:y].map { |y| y + 70 }, range: SYNERGY_BOXES[i][:range],
             width: SYNERGY_BOXES[i][:width], layout: :synergyvalue
      end
      line stroke_color: COMPANIES.map { |_k, v| v[:tier].positive? ? :red : :yellow }, stroke_width: 10, cap: :round,
           x1: SYNERGY_REDLINES.map { |r| r[:x1] }, y1: SYNERGY_REDLINES.map { |r| r[:y1] },
           x2: SYNERGY_REDLINES.map { |r| r[:x2] }, y2: SYNERGY_REDLINES.map { |r| r[:y2] }
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/company', prefix: 'company_', count_format: '%02d[face]', rotate: ROTATE ? :clockwise : false,
           format: :png
      FileUtils.touch 'cards/company'
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS && !CUTLINES
      save_sheet dir: 'sheets', prefix: 'company_face', count_format: ''
    end
  end

  def self.cost_of_ownership_string(tier)
    if tier < 3
      'no cost of ownership'
    else
      "cost of ownership $#{[1, 3, 6][tier - 3]}"
    end
  end

  def self.tier_companies(tier)
    COMPANIES.select { |_k, v| v[:tier] == tier }.map { |_k, v| v[:index] }
  end

  # Company card backs
  def self.deck_company_back
    Squib::Deck.new(
      cards: COMPANIES.length,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_company_back.yml'
    ) do
      background color: COMPANIES.map { |_k, v| "(0,37.5)(0,787.5) #{TIER_COLORS[v[:tier]]}@0.0 white@1.0" }
      text layout: :CornerSymbol, str: COMPANIES.map { |_k, v| TIER_SYMBOLS[v[:tier]] }
      # red box on the back of green cards
      rect layout: :BoxWhole, stroke_width: 0, fill_color: TIER_COLORS[0], range: Rollingstock.tier_companies(3)
      text layout: :BoxWholeSymbol, str: TIER_SYMBOLS[0], range: Rollingstock.tier_companies(3)
      # red and orange boxes on the back of blue cards
      rect layout: :BoxHalf, stroke_width: 0, fill_color: TIER_COLORS[0], range: Rollingstock.tier_companies(4)
      text layout: :BoxHalfSymbol, str: TIER_SYMBOLS[0], range: Rollingstock.tier_companies(4)
      rect layout: :BoxHalf, x: 562.5, stroke_width: 0, fill_color: TIER_COLORS[1],
           range: Rollingstock.tier_companies(4)
      text layout: :BoxHalfSymbol, x: 562.5, str: TIER_SYMBOLS[1], range: Rollingstock.tier_companies(4)
      # red orange yellow boxes on the back of purple cards
      rect layout: :BoxThird, stroke_width: 0, fill_color: TIER_COLORS[0], range: Rollingstock.tier_companies(5)
      text layout: :BoxThirdSymbol, str: TIER_SYMBOLS[0], range: Rollingstock.tier_companies(5)
      rect layout: :BoxThird, x: 425, stroke_width: 0, fill_color: TIER_COLORS[1], range: Rollingstock.tier_companies(5)
      text layout: :BoxThirdSymbol, x: 425, str: TIER_SYMBOLS[1], range: Rollingstock.tier_companies(5)
      rect layout: :BoxThird, x: 700, stroke_width: 0, fill_color: TIER_COLORS[2], range: Rollingstock.tier_companies(5)
      text layout: :BoxThirdSymbol, x: 700, str: TIER_SYMBOLS[2], range: Rollingstock.tier_companies(5)
      text str: COMPANIES.map { |_k, v| Rollingstock.cost_of_ownership_string(v[:tier]) }, layout: :CenterishText
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/company', prefix: 'company_', count_format: '%02d[back]',
           rotate: ROTATE ? :counterclockwise : false, format: :png
      FileUtils.touch 'cards/company'
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS && !CUTLINES
      save_sheet dir: 'sheets', prefix: 'company_back', count_format: '', rtl: true
    end
  end

  def self.deck_company
    deck_company_face
    deck_company_back
  end
end
