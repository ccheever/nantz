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
    html = """
    <html>
      <head>
        <title>The Masters Social 2015 Leaderboard</title>
        <style>
          body {
            font-family: 'Georgia', 'Helvetica', 'Sans-serif';
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
          }
          .name {
            font-size: 1.2em;
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
        </style>
      </head>
      <body>
        <div style="width: 100%; height: 100px; color: #116611; text-align: center; font-size: 3em; font-weight: bold; font-family: Georgia, Times New Roman, Serif; margin-top: 20px;">The Masters Social 2015</div>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Top 3</th>
              <th>Entry</th>
              <th>Top 3 Golfers</th>
              <th>Other Golfers</th>
            </tr>
          </thead>
          <tbody>
            #{
              ("""
              <tr class="row">
                <td class="rank">#{ i + 1}.</td>
                <td class="total">#{ x.totalString }</td>
                <td class="name">#{ x.Name }</td>
                <td class="golfers">#{ x.via }</td>
                <td class="unused">#{ x.unused }</td>
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
