module Rollingstock
  MAX_PLAYERS = 5
  MIN_PLAYERS = 1
  PLAYER_NUMBERS = (1..MAX_PLAYERS).to_a.freeze
  CORP_NAMES = %w(Bear Wheel Orion Eagle Horse Star Android Ship Jupiter Saturn).freeze
  CORP_COLORS = %w(#F00 #000 #96C #FD2 #999 #0A0 #AC0 #09F #963 #F0F).freeze
  SHARE_PRICES = [
     0,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22,
        24, 26, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 81, 90, 100
  ].freeze
  # red orange yellow green blue purple
  # default blue and purple are too dark
  TIER_COLORS = %w(red orange yellow green #55F #90B).freeze
  # red orange yellow+green blue purple
  SYNERGY_COLORS = [TIER_COLORS[0], TIER_COLORS[1], '#BF0', TIER_COLORS[4], TIER_COLORS[5]].freeze
  SYNERGY_VALUES = [1, 2, 4, 8, 16].freeze
  TIER_SYMBOLS = %w(● ▲ ■ ⬟ ⬢ ★).freeze
  TIER_TO_SYNERGY = [0, 1, 2, 2, 3, 4].freeze 
  CORP_SHARES = 10

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
end