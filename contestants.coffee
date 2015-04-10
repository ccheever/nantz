fastCsv = require 'fast-csv'

module.exports = new Promise (fulfill, reject) ->

  data = []

  fastCsv.fromPath('./contestants.tsv', {
    headers: true
    delimiter: "\t"
  })
  .on 'data', (row) ->
    delete row['']
    golfers = []
    for k, v of row
      if k.match /^Golfer/
        golfers.push v
    row.golfers = golfers
    data.push row
  .on 'end', ->
    fulfill data
  .on 'error', (err) ->
    reject err
