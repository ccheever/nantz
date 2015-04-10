co = require 'co'
express = require 'express'
moment = require 'moment-timezone'
timeconstants = require 'timeconstants'

contestants = require './contestants'
espn = require './espn'
leaderboard = require './leaderboard'

app = express()

$scores = []
setScoresAsync = ->
  espn.scoresAsync().then (scores) ->
    $scores = scores
    console.log "Scores updated at #{ moment(Date.now()).format('MMMM Do YYYY, h:mm:ss a'); }"

app.get '/', (req, res) ->
  contestants.then (entries) ->
    lb = leaderboard.leaderboard entries, $scores
    x = ("#{i + 1}.) #{y.total} -- #{ y?.Name } -- #{ y?.via} // #{ y?.unused }" for y, i in lb)
    res.send "<pre>#{ x.join '<br />' }</pre>"


if module is require.main
  setScoresAsync().then ->
    server = app.listen 3000, ->

      host = server.address().address;
      port = server.address().port;

      console.log "TMS Leaderboard app listening at http://%s:%s", host, port

  setInterval setScoresAsync, 1 * timeconstants.minute

module.exports = {
  setScoresAsync
  app
}
