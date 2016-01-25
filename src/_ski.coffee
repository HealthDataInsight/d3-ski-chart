"use strict"

d3 = require 'd3'

# Use a sample of the data where there is more than one data point per pixel.
# Visually our target is approximately one data point every 4px.
sampleData = (data, height) ->
  # Calculate the step size so that there is approximately
  # one data point every 4px
  sample_step = parseInt(4 * data.length / height, 10)
  sample_step = 1 if sample_step < 1
  last = data.length - 1
  # filter the data to the the sample step, including the first and last values.
  # NOTE: (0 % sample_step) will always return the first value.
  (d for d, i in data when i % sample_step == 0 || i == last)

skiChart = (geography_type, digestor) ->
  skiChart._id = 0 unless skiChart._id

  _id = skiChart._id++
  _svg = null
  _margins = {top: 15, right: 1, bottom: 15, left: 1}
  width = 263
  _height = 85
  _suffix = ''
  _lines = []

  x_extent = null
  y_extent = null
  x_scale = null
  y_scale = null

  x_axis = null

  area = d3.svg.area()
    .x((d) -> y_scale(d.index))
    .y0(0)
    .y1((d) -> x_scale(_valueAccessor(d)) )
    .interpolate('basis')

  headingLayer = null

  _colour = () -> 'primary'
  _valueAccessor = (d) -> d.value
  _xMinAccessor = (data) -> d3.min(data, (d) -> _valueAccessor(d))
  _xMaxAccessor = (data) -> d3.max(data, (d) -> _valueAccessor(d))

  chart_height = () -> _height - _margins.top - _margins.bottom
  chart_width = () -> width - _margins.left - _margins.right

  renderHeading = (heading) ->
    heading
      .append("text")
        .text("#{x_extent[0]}#{_suffix}")
        .attr(
          "class": "heading",
          "text-anchor": "start",
          "x": 0
        )
    # heading.append("text")
    #     .text('Referrals meeting target')
    #     .attr({
    #       "class": "heading",
    #       "text-anchor": "middle",
    #       "x": chart_width() / 2
    #     })
    heading.append("text")
        .text("#{x_extent[1]}#{_suffix}")
        .attr({
          "class": "heading",
          "text-anchor": "end",
          "x": chart_width()
        })

  _chart = (selection) ->
    # generate the chart here
    selection.each (data, i) ->
      # Calculate the extents and redefine the domains
      x_extent = d3.extent([_xMinAccessor(data), _xMaxAccessor(data)])
      y_extent = d3.extent([0, data.length - 1])

      # Calculate the scales
      x_scale = d3.scale.linear()
        .range([0, chart_width()])
      # rangeRound
        .domain(x_extent)
      y_scale = d3.scale.linear()
        .range([0, chart_height()])
        .domain(y_extent)

      x_axis = d3.svg.axis()
        .scale(x_scale)
        .tickSize(_margins.top + _margins.bottom - _height)
        .tickFormat(() -> '')

      unless _svg? || data.length == 0
        datum.index = i for datum, i in data

        d3.select(this).selectAll(".empty")
          .remove()

        # Add SVG element
        _svg = d3.select(this)
          .append("svg")
            .attr("width", "100%")
            .attr("height", _height)
            .attr("viewBox", "0 0 #{width} #{_height}")
            # .attr("preserveAspectRatio", "none")
          .append("g")
            .attr("transform", "translate(#{_margins.left},#{_margins.top})")

        # Add the rectangles
        _svg.append("rect")
          .attr("class", "chartbg")
          .attr("width", chart_width() )
          .attr("height", chart_height() )
          .attr("x", 0)
          .attr("y", 0)

        # Path
        sample = sampleData(data, chart_height())
        _svg.append("defs")
          .append("clipPath")
            .attr("id", "ski_mask_#{_id}")
          .append("path")
            .datum(sample)
            .attr("class", "area")
            .attr("d", area)
            .attr('transform', 'scale(1 -1) rotate(-90)')

        _svg.append("text")
          .text("Best #{geography_type}")
          .attr("class": "heading position area")
          .attr("x": 3)
          .attr("y": 11)

        _svg.append("text")
          .text("Worst #{geography_type}")
          .attr("class": "heading position area")
          .attr("x": 3)
          .attr("y": () -> chart_height() - 3)

        _svg.append("rect")
          .attr("class", "area")
          .attr("width", chart_width() )
          .attr("height", chart_height() )
          .attr("x", 0)
          .attr("y", 0)
          .attr("clip-path", "url(#ski_mask_#{_id})")

        # Add the axis
        _svg.append("g")
          .attr("class", "x axis")
          .attr("transform", () -> "translate(0,#{chart_height()})" )
          .call(x_axis)

        _svg.append("text")
          .text("Best #{geography_type}")
          .attr("class": "heading position")
          .attr("x": 3)
          .attr("y": 11)
          .attr("clip-path", "url(#ski_mask_#{_id})")

        _svg.append("text")
          .text("Worst #{geography_type}")
          .attr("class": "heading position")
          .attr("x": 3)
          .attr("y": () -> chart_height() - 3)
          .attr("clip-path", "url(#ski_mask_#{_id})")

        # Render the target/average lines
        enter_lines = _svg.selectAll("g.line").data(_lines)
          .enter()
            .append("g")
              .attr("class", "line")
              # .attr("transform", (d, i) -> "translate(0,#{y_scale(i)})")

        enter_lines.append("rect")
          .attr("width", 2 )
          .attr("height", chart_height)
          .attr("x", (d) -> x_scale(d.value) - 1)
          .attr("y", 0)
          .attr("fill", (d) -> d.colour)
        enter_lines.append("circle")
          .attr("cx", (d) -> x_scale(d.value))
          .attr("cy", (d) -> chart_height() - 0.5)
          .attr("r", 2)
          .attr("fill", (d) -> d.colour)
        enter_lines.append("text")
          .text((d) -> d.label)
          .attr("text-anchor", (d) -> d.anchor)
          .attr("x", (d) -> x_scale(d.value) - 1)
          .attr("y", (d) -> chart_height() + 11)
          .attr("fill", (d) -> d.colour)

        # Add a group for each CCG
        css_prefix = geography_type.toLowerCase()
        enter = _svg.selectAll("g.geography").data(data)
          .enter()
            .append("g")
              .attr("id", (d) ->
                # a hashed version of the original identifier
                digestor.consume(d.ccg_code)[0]
              )
              .attr("class", (d) -> "geography #{_colour(d)}")
              .attr("transform", (d, i) -> "translate(0,#{y_scale(i)})")

        enter.append("rect")
          .attr("width", (d) -> x_scale(_valueAccessor(d)) )
          .attr("height", 2)
          .attr("x", 0)
          .attr("y", -1)
        enter.append("circle")
          .attr("cx", (d) ->
            x_scale(_valueAccessor(d))
          )
          .attr("cy", 0)
          .attr("r", 4)
        enter.append("text")
          .text((d) -> "#{_valueAccessor(d)}#{_suffix}")
          .attr(
            "class": "label heading bg",
            "text-anchor": "start",
            "x": (d) -> x_scale(_valueAccessor(d)) + 8
            "y": 3.5
          )
        enter.append("text")
          .text((d) -> "#{_valueAccessor(d)}#{_suffix}")
          .attr(
            "class": "label heading",
            "text-anchor": "start",
            "x": (d) -> x_scale(_valueAccessor(d)) + 8
            "y": 3.5
          )

        _svg.selectAll("text.label")
          .attr("x", (d) ->
            bbox = d3.select(this).node().getBBox()
            if bbox.x > width - _margins.left - bbox.width - 3
              width - _margins.left -  bbox.width - 3
            else
              bbox.x
          )
          .attr("y", (d, i) ->
            bbox = d3.select(this).node().getBBox()
            # + 2 here allows for rounding issues
            if bbox.x + 2 < x_scale(_valueAccessor(d)) + 8
              # x has moved
              if y_scale(i) > d3.mean(y_scale.range())
                3.5 - 12
              else
                3.5 + 12
            else
              3.5
          )

        headingLayer = _svg.append("g")
          .attr("class", "heading")
          .attr("transform", () -> "translate(0,-4)" )
        # headingLayer.selectAll("g.heading").data(data).call(renderHeading)
        renderHeading(headingLayer)

  _chart.svg = (value) ->
    return _svg if (!arguments.length)
    _svg = value
    _chart

  _chart.margins = (value) ->
    return _margins if (!arguments.length)
    _margins = value
    _chart

  _chart.colour = (value) ->
    return _colour if (!arguments.length)
    _colour = value
    _chart

  _chart.valueAccessor = (value) ->
    return _valueAccessor if (!arguments.length)
    _valueAccessor = value
    _chart

  _chart.percent = () ->
    _suffix = '%'
    # _xMinAccessor = () -> 0
    # _xMaxAccessor = () -> 100
    _chart

  _chart.line = (value, label, colour, anchor) ->
    _lines = _lines.concat(
      value: value,
      label: label,
      colour: colour,
      anchor: anchor || "middle"
    )
    _chart

  # _chart.height = (value) ->
  #   return _height if (!arguments.length)
  #   _height = value
  #   _chart
  #
  # _chart.round = (value) ->
  #   return round if (!arguments.length)
  #   round = value
  #   _chart
  #
  # # TODO: xAxis accessor

  _chart

module.exports = skiChart
