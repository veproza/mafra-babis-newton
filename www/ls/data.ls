mediaIndices =
  "Hospodářské noviny": 0
  "iHNed.cz": 1
  "aktualne.cz": 2
  "Lidové noviny": 7
  "lidovky.cz": 8
  "Mladá fronta DNES": 5
  "zpravy.iDNES.cz": 6
  "Právo": 3
  "novinky.cz": 4
  "zpravy.rozhlas.cz": 9

class Kauza
  (@name) ->
    @mediums = []
    @mediumsAssoc = {}
    @maxDate = new Date!
      ..setTime 0
    @minDate = new Date!
      ..setFullYear 2018

  addClanek: (clanek) ->
    if !@mediumsAssoc[clanek.medium]
      @addMedium clanek.medium
    @mediumsAssoc[clanek.medium].addClanek clanek
    if @maxDate < clanek.date
      @maxDate.setTime clanek.date.getTime!
    if @minDate > clanek.date
      @minDate.setTime clanek.date.getTime!

  getTotals: ->
    @mediums.forEach (.getTotals!)
    @mediums.sort (a, b) -> mediaIndices[a.name] - mediaIndices[b.name]
    @maxLength = d3.max @mediums.map (.totalLength)
    @maxCount = d3.max @mediums.map (.totalCount)
    @mediums.forEach (medium) ~>
      medium.lengthTimeline.push {date: @maxDate, value: medium.totalLength, end: yes}
      medium.countTimeline.push {date: @maxDate, value: medium.totalCount, end: yes}


  addMedium: (medium) ->
    @mediumsAssoc[medium] = new Medium medium
    @mediums.push @mediumsAssoc[medium]


class Medium
  (@name) ->
    @clanky = []
    @totalLength = 0
    @totalCount = 0
    @lengthTimeline = []
    @countTimeline = []

  addClanek: (clanek) ->
    @clanky.push clanek

  getTotals: ->
    @clanky.sort (a, b) -> a.date.getTime! - b.date.getTime!
    @lengthTimeline.push {date: @clanky[0].date, value: 0, start: yes}
    @countTimeline.push {date: @clanky[0].date, value: 0, start: yes}
    for clanek in @clanky
      @totalCount++
      @totalLength += clanek.length
      {date} = clanek
      @lengthTimeline.push {date, value: @totalLength, clanek}
      @countTimeline.push {date, value: @totalCount, clanek}

ig.getData = ->
  clanky = d3.tsv.parse ig.data.clanky, (row) ->
    [d, m, y] = row.datum.split "." .map parseInt _, 10
    row.date = new Date!
      ..setTime 12 * 3600 * 1e3
      ..setDate d
      ..setMonth m - 1
      ..setFullYear y
    row.length = parseInt row.delka, 10
    row.page = parseInt row.strana, 10
    row
  # console.log clanky[28]
  kauzyAssoc = {}
  kauzy = []
  for clanek in clanky
    continue if clanek.medium == "info.cz"
    continue if clanek.medium == "zpravy.rozhlas.cz"
    if kauzyAssoc[clanek.kauza] is void
      kauzyAssoc[clanek.kauza] = new Kauza clanek.kauza
      kauzy.push kauzyAssoc[clanek.kauza]
    kauzyAssoc[clanek.kauza].addClanek clanek
  kauzy.forEach (.getTotals!)
  kauzy
