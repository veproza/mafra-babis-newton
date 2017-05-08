new Tooltip!watchElements!
kauzy = ig.getData!
container = d3.select ig.containers.base
dimensions =
  fullWidth: 240
  fullHeight: 200
padding = top: 35 left: 10 right: 10 bottom: 25
dimensions.width = dimensions.fullWidth - padding.left - padding.right
dimensions.height = dimensions.fullHeight - padding.top - padding.bottom
fullNames =
  "dluhopisy": "Dluhopisy"
  "emaily": "Sobotkův hacknutý e-mail"
  "capihnizdo": "Čapí hnízdo"
  "policie": "Policejní reforma"
  "regsmluv": "Registr smluv"
  "rop": "R.O.P. Severozápad"
toHumanDate = -> "#{it.getDate!}.#{it.getMonth! + 1}.#{it.getFullYear!}"
kauzy.forEach (kauza) ->
  kauzaContainer = d3.select ig.containers[kauza.name]
    ..classed \kauza-container yes
    ..append \h2
      ..html fullNames[kauza.name]
    ..append \p
      ..html "Časové rozmezí od #{toHumanDate kauza.minDate} do #{toHumanDate kauza.maxDate}"
  xScale = d3.time.scale!
    ..domain [kauza.minDate, kauza.maxDate]
    ..range [0 dimensions.width]
  yScaleCount = d3.scale.linear!
    ..domain [0 kauza.maxCount]
    ..range [dimensions.height / 2, 0]
  yScaleLength = d3.scale.linear!
    ..domain [0 kauza.maxLength]
    ..range [dimensions.height / 2, dimensions.height]
  lengthLine = d3.svg.line!
    ..x -> xScale it.date
    ..y -> yScaleLength it.value
    ..interpolate \step-after
  countLine = d3.svg.line!
    ..x -> xScale it.date
    ..y -> yScaleCount it.value
    ..interpolate \step-after
  lengthArea = d3.svg.area!
    ..x -> xScale it.date
    ..y0 -> yScaleLength it.value
    ..y1 -> yScaleLength 0
    ..interpolate \step-after
  countArea = d3.svg.area!
    ..x -> xScale it.date
    ..y0 -> yScaleCount it.value
    ..y1 -> yScaleCount 0
    ..interpolate \step-after
  voronoi = d3.geom.voronoi!
    ..clipExtent [[0, 0], [dimensions.width, dimensions.height]]
    ..x -> xScale it.date
    ..y -> 0

  averageCount = 0
  averageLength = 0
  for medium in kauza.mediums
    averageCount += medium.totalCount / kauza.mediums.length
    averageLength += medium.totalLength / kauza.mediums.length
  graphsContainer = kauzaContainer.append \div
    ..attr \class \graphs-container
    ..selectAll \svg .data kauza.mediums .enter!append \svg
      ..attr \width dimensions.fullWidth
      ..attr \height dimensions.fullHeight
      ..append \text
        ..attr \class \medium-name
        ..attr \x 5
        ..attr \y 15
        ..text (.name)
      ..append \text
        ..attr \class \length
        ..attr \x 5
        ..attr \y 32
        ..text -> "Celkem zpráv: #{it.totalCount} (#{ig.utils.formatNumber it.totalCount / averageCount * 100} %)"
      ..append \text
        ..attr \class \length
        ..attr \x 5
        ..attr \y dimensions.fullHeight - 10
        ..text -> "Celkem znaků: #{ig.utils.formatNumber it.totalLength} (#{ig.utils.formatNumber it.totalLength / averageLength * 100} %)"
      ..append \g
        ..attr \class \drawing
        ..attr \transform "translate(#{padding.left}, #{padding.top})"
        ..append \g
          ..attr \length
          ..append \path
            ..attr \class \area
            ..attr \d -> lengthArea it.lengthTimeline
          ..append \path
            ..attr \class \line
            ..attr \d -> lengthLine it.lengthTimeline
        ..append \g
          ..attr \count
          ..append \path
            ..attr \class \area
            ..attr \d -> countArea it.countTimeline
          ..append \path
            ..attr \class \line
            ..attr \d -> countLine it.countTimeline
        ..append \line
          ..attr \x1 0
          ..attr \x2 dimensions.width
          ..attr \y1 -> (Math.round dimensions.height / 2) + 0.5
          ..attr \y2 -> (Math.round dimensions.height / 2) + 0.5
        ..append \g
          ..attr \class \guidelines
          ..selectAll \line .data [0, dimensions.height / 4, dimensions.height / 4 * 3, dimensions.height] .enter!append \line
            ..attr \x1 0
            ..attr \x2 dimensions.width
            ..attr \y1 -> 0.5 + Math.round it
            ..attr \y2 -> 0.5 + Math.round it
        ..append \g
          ..attr \class \voronoi
          ..selectAll \path .data (-> (voronoi it.lengthTimeline.filter (.clanek)).filter -> it) .enter!append \path
            ..attr \data-tooltip ->
              {clanek} = it.point
              return void unless clanek
              "<b>#{clanek.titulek}</b><br>
              Autor: #{clanek.autor}<br>
              Vydáno: #{clanek.datum}<br>
              Délka: #{clanek.delka} znaků<br>
              Rubrika: #{clanek.rubrika}<br>
              Strana: #{clanek.strana}"
            ..attr \d -> "M#{it.join "L"}Z"
