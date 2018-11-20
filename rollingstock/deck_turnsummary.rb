module Rollingstock
  # Turn Summary card
  # duplicate this elsewise
  def Rollingstock.deck_turnsummary()
    Squib::Deck.new(
      cards: 1,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_turnsummary.yml'
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
      save dir: 'cards/singles', prefix: 'turnsummary', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/singles', prefix: 'turnsummary', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'turnsummary', count_format: '', columns: 1
    end
  end

  # Turn Summary card in German
  # duplicate this elsewise
  def Rollingstock.deck_turnsummaryde()
    Squib::Deck.new(
      cards: 1,
      width: 1125,
      height: 825,
      layout: 'layouts/layout_turnsummary.yml'
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
        rect x: 75, y: y, width: 975, height: extents[0][:height] + 8
        y += extents[0][:height] + 8
      end
      rect layout: :safe if CUTLINES
      rect layout: :cut if CUTLINES
      save dir: 'cards/singles', prefix: 'turnsummaryde', count_format: '%02d[face]', rotate: ROTATE ? :clockwise        : false, format: :png
      save dir: 'cards/singles', prefix: 'turnsummaryde', count_format: '%02d[back]', rotate: ROTATE ? :counterclockwise : false, format: :png
      rect layout: :cut, dash: '', stroke_color: :black if CUTLINES_SHEETS and not CUTLINES
      save_sheet dir: 'sheets', prefix: 'turnsummaryde', count_format: '', columns: 1
    end
  end
end