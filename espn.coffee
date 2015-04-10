cheerio = require 'cheerio'
co = require 'co'
instapromise = require 'instapromise'
request = require 'request'


scoresAsync = co.wrap ->
  """Gets the scores from the ESPN website"""

  { body } = yield request.promise "http://espn.go.com/golf/leaderboard?tournamentId=2241"
  body

  #columns = ['POS', 'START', 'CTRY', 'PLAYER', 'TO PAR', 'TODAY', 'THRU', 'R1', 'R2', 'R3', 'R4', 'TOT']

  $ = cheerio.load body
  table = $("table.leaderboard").html()
  thead = table.replace(/^.*<thead/, '<thead').replace(/<\/thead>.*$/, '</thead>')
  ths = thead.split('<th ')[1...]
  columns = (x.match(/>([^<]*)</)?[1]?.toLowerCase().replace(/ /g, '_') for x in ths)

  data = []
  trs = table.split('<tr id="player-')[1...]


  for tr in trs
    tds = tr.split('<td ')[1...]
    vals = (x.match(/>(.*)<\/td/)?[1] for x in tds)
    row = {}
    for c, i in columns
      row[c] = vals[i]
    #row.vals = vals
    row.playerId = row.player.match(/name="([^"]*)"/)?[1]

    unwrap = (s) ->
      """Unwraps something like <a href="...">Ernie Els</a> to just Ernie Els"""

      s.match(/>([^<]*)</)?[1]

    row.player = unwrap row.player
    row.today = unwrap row.today
    data.push row
  data


module.exports = {
  scoresAsync
}
