#!/usr/bin/env coffee

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
    console.log "Scores updated at #{ moment(Date.now()).format('MMMM Do YYYY, h:mm:ss a') }"

app.get '/', (req, res) ->

  ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log "Request for leaderboard at #{ moment(Date.now()).format('MMMM Do YYYY, h:mm:ss a') } from #{ ip }"

  contestants.then (entries) ->
    lb = leaderboard.leaderboard entries, $scores
    html = """
    <html>
      <head>
        <title>The Masters Social 2015 Leaderboard</title>
        <style>
          body {
            font-family: Arial, Helvetica, Verdana, Sans-serif;
          }
          .winner {
            opacity: 1.0;
          }
          .golfers {
            font-size: 0.8em;
          }
          .unused {
            opacity: 0.4;
            font-size: 0.5em;
          }
          .total {
            font-weight: bold;
            font-size: 1.2em;
            padding-left: 10px;
            padding-right: 10px;
          }
          .name {
            font-size: 1.2em;
            padding-right: 12px;
          }
          table {
            border-collapse: collapse;
          }
          th {
            background: #eeeeff;
          }
          td {
            border-color: #bbbbbb;
            border-width: 0px 0px 1px 0px;
            border-style: solid;
            padding-bottom: 6px;
          }
          tr {
            opacity: 0.9;
          }
          .champScore {
            font-size: 0.65em;
            opacity: 0.6;
          }
          .red {
            color: #991111;
          }
          .cut {
            opacity: 0.5;
          }
          .email {
            opacity: 0.4;
            font-size: 0.4em;
          }
          .header {
            width: 100%;
            color: #116611;
            text-align: center;
            font-size: 2em;
            font-weight: bold;
            font-family: Georgia, Arial, Helvetica, Sans-serif;
            font-style: italic;
            padding-bottom: 15px;
          }
        </style>
      </head>
      <body>
        <div class="header">The Masters Social 2015</div>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Top 3</th>
              <th>Entry</th>
              <th>Top 3 Golfers</th>
              <th>Other Golfers</th>
              <th><small>Champ (∆)</small></th>
            </tr>
          </thead>
          <tbody>
            #{
              ("""
              <tr class="row#{ if i == 0 then ' winner' else if x.totalString is 'CUT' then ' cut' else '' }">
                <td class="rank">#{ i + 1}.</td>
                <td class="total#{ if x.totalString[0] is '-' then ' red' else '' }">#{ x.totalString }</td>
                <td class="name">#{ x.Name }<br /><small class="email">#{ x.Email }</small></td>
                <td class="golfers">#{ x.via }</td>
                <td class="unused">#{ x.unused }</td>
                <td class="champScore">#{ x.champScore } <small>(∆ #{ x.tiebreakerDelta })</small></td>
              </tr>
              """ for x, i in lb).join ""
            }
          </tbody>
        </table>
        <script>
          setTimeout(function () {
            window.location.reload();
          }, 1000 * 60);
        </script>
      </body>
    </html>
    """
    res.send html
    #x = ("#{i + 1}.) #{y.total} -- #{ y?.Name } -- #{ y?.via} // #{ y?.unused }" for y, i in lb)
    #res.send "<pre>#{ x.join '<br />' }</pre>"


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
