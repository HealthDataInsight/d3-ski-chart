/*
 d3-ski-chart v0.0.1
 Copyright (c) 2015-2016 Health Data Insight
 Released under the MIT License
 */
(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
"use strict";
var d3, sampleData, skiChart;

d3 = require('d3');

sampleData = function(data, height) {
  var d, i, j, last, len, results, sample_step;
  sample_step = parseInt(4 * data.length / height, 10);
  if (sample_step < 1) {
    sample_step = 1;
  }
  last = data.length - 1;
  results = [];
  for (i = j = 0, len = data.length; j < len; i = ++j) {
    d = data[i];
    if (i % sample_step === 0 || i === last) {
      results.push(d);
    }
  }
  return results;
};

skiChart = function(geography_type, digestor) {
  var _chart, _colour, _height, _id, _lines, _margins, _suffix, _svg, _valueAccessor, _xMaxAccessor, _xMinAccessor, area, chart_height, chart_width, headingLayer, renderHeading, width, x_axis, x_extent, x_scale, y_extent, y_scale;
  if (!skiChart._id) {
    skiChart._id = 0;
  }
  _id = skiChart._id++;
  _svg = null;
  _margins = {
    top: 15,
    right: 1,
    bottom: 15,
    left: 1
  };
  width = 263;
  _height = 85;
  _suffix = '';
  _lines = [];
  x_extent = null;
  y_extent = null;
  x_scale = null;
  y_scale = null;
  x_axis = null;
  area = d3.svg.area().x(function(d) {
    return y_scale(d.index);
  }).y0(0).y1(function(d) {
    return x_scale(_valueAccessor(d));
  }).interpolate('basis');
  headingLayer = null;
  _colour = function() {
    return 'primary';
  };
  _valueAccessor = function(d) {
    return d.value;
  };
  _xMinAccessor = function(data) {
    return d3.min(data, function(d) {
      return _valueAccessor(d);
    });
  };
  _xMaxAccessor = function(data) {
    return d3.max(data, function(d) {
      return _valueAccessor(d);
    });
  };
  chart_height = function() {
    return _height - _margins.top - _margins.bottom;
  };
  chart_width = function() {
    return width - _margins.left - _margins.right;
  };
  renderHeading = function(heading) {
    heading.append("text").text("" + x_extent[0] + _suffix).attr({
      "class": "heading",
      "text-anchor": "start",
      "x": 0
    });
    return heading.append("text").text("" + x_extent[1] + _suffix).attr({
      "class": "heading",
      "text-anchor": "end",
      "x": chart_width()
    });
  };
  _chart = function(selection) {
    return selection.each(function(data, i) {
      var css_prefix, datum, enter, enter_lines, j, len, sample;
      x_extent = d3.extent([_xMinAccessor(data), _xMaxAccessor(data)]);
      y_extent = d3.extent([0, data.length - 1]);
      x_scale = d3.scale.linear().range([0, chart_width()]).domain(x_extent);
      y_scale = d3.scale.linear().range([0, chart_height()]).domain(y_extent);
      x_axis = d3.svg.axis().scale(x_scale).tickSize(_margins.top + _margins.bottom - _height).tickFormat(function() {
        return '';
      });
      if (!((_svg != null) || data.length === 0)) {
        for (i = j = 0, len = data.length; j < len; i = ++j) {
          datum = data[i];
          datum.index = i;
        }
        d3.select(this).selectAll(".empty").remove();
        _svg = d3.select(this).append("svg").attr("width", "100%").attr("height", _height).attr("viewBox", "0 0 " + width + " " + _height).append("g").attr("transform", "translate(" + _margins.left + "," + _margins.top + ")");
        _svg.append("rect").attr("class", "chartbg").attr("width", chart_width()).attr("height", chart_height()).attr("x", 0).attr("y", 0);
        sample = sampleData(data, chart_height());
        _svg.append("defs").append("clipPath").attr("id", "ski_mask_" + _id).append("path").datum(sample).attr("class", "area").attr("d", area).attr('transform', 'scale(1 -1) rotate(-90)');
        _svg.append("text").text("Best " + geography_type).attr({
          "class": "heading position area"
        }).attr({
          "x": 3
        }).attr({
          "y": 11
        });
        _svg.append("text").text("Worst " + geography_type).attr({
          "class": "heading position area"
        }).attr({
          "x": 3
        }).attr({
          "y": function() {
            return chart_height() - 3;
          }
        });
        _svg.append("rect").attr("class", "area").attr("width", chart_width()).attr("height", chart_height()).attr("x", 0).attr("y", 0).attr("clip-path", "url(#ski_mask_" + _id + ")");
        _svg.append("g").attr("class", "x axis").attr("transform", function() {
          return "translate(0," + (chart_height()) + ")";
        }).call(x_axis);
        _svg.append("text").text("Best " + geography_type).attr({
          "class": "heading position"
        }).attr({
          "x": 3
        }).attr({
          "y": 11
        }).attr("clip-path", "url(#ski_mask_" + _id + ")");
        _svg.append("text").text("Worst " + geography_type).attr({
          "class": "heading position"
        }).attr({
          "x": 3
        }).attr({
          "y": function() {
            return chart_height() - 3;
          }
        }).attr("clip-path", "url(#ski_mask_" + _id + ")");
        enter_lines = _svg.selectAll("g.line").data(_lines).enter().append("g").attr("class", "line");
        enter_lines.append("rect").attr("width", 2).attr("height", chart_height).attr("x", function(d) {
          return x_scale(d.value) - 1;
        }).attr("y", 0).attr("fill", function(d) {
          return d.colour;
        });
        enter_lines.append("circle").attr("cx", function(d) {
          return x_scale(d.value);
        }).attr("cy", function(d) {
          return chart_height() - 0.5;
        }).attr("r", 2).attr("fill", function(d) {
          return d.colour;
        });
        enter_lines.append("text").text(function(d) {
          return d.label;
        }).attr("text-anchor", function(d) {
          return d.anchor;
        }).attr("x", function(d) {
          return x_scale(d.value) - 1;
        }).attr("y", function(d) {
          return chart_height() + 11;
        }).attr("fill", function(d) {
          return d.colour;
        });
        css_prefix = geography_type.toLowerCase();
        enter = _svg.selectAll("g.geography").data(data).enter().append("g").attr("id", function(d) {
          return digestor.consume(d.ccg_code)[0];
        }).attr("class", function(d) {
          return "geography " + (_colour(d));
        }).attr("transform", function(d, i) {
          return "translate(0," + (y_scale(i)) + ")";
        });
        enter.append("rect").attr("width", function(d) {
          return x_scale(_valueAccessor(d));
        }).attr("height", 2).attr("x", 0).attr("y", -1);
        enter.append("circle").attr("cx", function(d) {
          return x_scale(_valueAccessor(d));
        }).attr("cy", 0).attr("r", 4);
        enter.append("text").text(function(d) {
          return "" + (_valueAccessor(d)) + _suffix;
        }).attr({
          "class": "label heading bg",
          "text-anchor": "start",
          "x": function(d) {
            return x_scale(_valueAccessor(d)) + 8;
          },
          "y": 3.5
        });
        enter.append("text").text(function(d) {
          return "" + (_valueAccessor(d)) + _suffix;
        }).attr({
          "class": "label heading",
          "text-anchor": "start",
          "x": function(d) {
            return x_scale(_valueAccessor(d)) + 8;
          },
          "y": 3.5
        });
        _svg.selectAll("text.label").attr("x", function(d) {
          var bbox;
          bbox = d3.select(this).node().getBBox();
          if (bbox.x > width - _margins.left - bbox.width - 3) {
            return width - _margins.left - bbox.width - 3;
          } else {
            return bbox.x;
          }
        }).attr("y", function(d, i) {
          var bbox;
          bbox = d3.select(this).node().getBBox();
          if (bbox.x + 2 < x_scale(_valueAccessor(d)) + 8) {
            if (y_scale(i) > d3.mean(y_scale.range())) {
              return 3.5 - 12;
            } else {
              return 3.5 + 12;
            }
          } else {
            return 3.5;
          }
        });
        headingLayer = _svg.append("g").attr("class", "heading").attr("transform", function() {
          return "translate(0,-4)";
        });
        return renderHeading(headingLayer);
      }
    });
  };
  _chart.svg = function(value) {
    if (!arguments.length) {
      return _svg;
    }
    _svg = value;
    return _chart;
  };
  _chart.margins = function(value) {
    if (!arguments.length) {
      return _margins;
    }
    _margins = value;
    return _chart;
  };
  _chart.colour = function(value) {
    if (!arguments.length) {
      return _colour;
    }
    _colour = value;
    return _chart;
  };
  _chart.valueAccessor = function(value) {
    if (!arguments.length) {
      return _valueAccessor;
    }
    _valueAccessor = value;
    return _chart;
  };
  _chart.percent = function() {
    _suffix = '%';
    return _chart;
  };
  _chart.line = function(value, label, colour, anchor) {
    _lines = _lines.concat({
      value: value,
      label: label,
      colour: colour,
      anchor: anchor || "middle"
    });
    return _chart;
  };
  return _chart;
};

module.exports = skiChart;


},{"d3":"d3"}]},{},[1]);
