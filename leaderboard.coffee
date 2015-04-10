{
  clone
  sortBy
} = require 'lodash-node'

contestants = require './contestants'
espn = require './espn'

leaderboardAsync = ->
  contestants.then (entries) ->
    espn.scoresAsync().then (scores) ->
      leaderboard entries, scores

leaderboard = (entries, scores) ->

      byName = {}
      for player in scores
        player.score = parseInt player.to_par
        byName[player.name] = player

      for entry in entries
        go = (byName[g] for g in entry.golfers)
        scores = (g?.score for g in go)
        entry.scores = scores
        #ss = clone scores
        #ss.sort()
        #total = ss[0] + ss[1] + ss[2]
        #entry.total = total

        gos = sortBy go, (g) ->
          g?.score

        f = (n) ->
          g = gos[n]
          if g?
            "#{ g.name } (#{ g.to_par })"
          else
            ""
        entry.via = [f(0), f(1), f(2)].join ', '
        entry.unused = [f(3), f(4), f(5), f(6)].join ', '

        entry.total = gos[0].score + gos[1].score + gos[2].score



        # 3)  The winner will be determined by the lowest team score determined by your best 3 players (i.e., if you have 4 players make the cut who finish Sunday at -5, -5, -5, and +1, your score is -15).

      sortBy entries, 'total'


module.exports = {
  leaderboard
  leaderboardAsync
}
