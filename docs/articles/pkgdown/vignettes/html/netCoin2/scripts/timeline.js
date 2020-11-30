function timeline(json){

  var nodes = json.nodes,
      options = json.options,

      defaultShape = "Circle", // node shape by default
      symbolTypes = ["Circle","Square","Diamond","Triangle","Cross","Star","Wye"], // list of available shapes
      infoLeft = 0, // global variable for panel left position
      selectedGroups, // temporarily selected in checkboxes
      filter = false; // global filter

  var body = d3.select("body");

  if(options.cex)
    body.style("font-size", 10*options.cex + "px")
  else
    options.cex = 1;

  var tooltip = body.append("div")
        .attr("class","tooltip")
        .style("display","none")

  body.on("click.hideTooltip",function(){
    body.selectAll(".tooltip.fixed").remove();
  })

  body.on("keyup.shortcut",function(){
    var key = getKey(d3.event);
    if(key == "Enter"){
      applyCheckBoxes();
      return;
    }
    if(d3.event.ctrlKey && key == "x"){
      body.selectAll(".tooltip.fixed").remove();
      body.select("div.infopanel div.close-button").dispatch("click");
      return;
    }
  })

  // default linear scale for events
  options.colorScaleeventColor = "WhBu";

  // sort nodes by start
  nodes.sort(function(nodea, nodeb){
    var a = nodea[options.start],
        b = nodeb[options.start];
    return a < b ? -1 : a > b ? 1 : a >= b ? 0 : NaN;
  });

  // prepare events
  if(json.events){
    var events = {};
    json.events.forEach(function(d,i){
      if(typeof events[d[options.eventParent]] == "undefined")
        events[d[options.eventParent]] = [];
      events[d[options.eventParent]].push(i);
    })
    nodes.forEach(function(node){
      if(events.hasOwnProperty(node[options.name]))
        node['_events_'] = events[node[options.name]].map(function(i){ return json.events[i]; });
    });
  }

  // split multivariables
  nodes.forEach(function(d){
      for(var p in d) {
        if(p!=options.name){
          if(typeof d[p] == "string" && d[p].indexOf("|")!=-1){
            d[p] = d[p].split("|").map(function(d){ return isNaN(parseInt(d)) ? d : +d; });
          }
        }
      }
  });

  // top bar
  var topBar = body.append("div")
        .attr("class","topbar")

  topBar.call(iconButton()
        .alt("pdf")
        .width(24)
        .height(24)
        .src(b64Icons.pdf)
        .title(texts.pdfexport)
        .job(svg2pdf));

  topBar.call(iconButton()
        .alt("svg")
        .width(24)
        .height(24)
        .src(b64Icons.svg)
        .title(texts.svgexport)
        .job(svgDownload));

  // multigraph
  if(typeof multiGraph != 'undefined'){
      topBar.append("h3").text(texts.graph + ":")
      multiGraph.graphSelect(topBar);
  }

  // groups selection in topBar
  topBarVisual(topBar,"Group","group",getOptions(nodes));

  if(json.events){
    // event colors in topBar
    topBarVisual(topBar,"Color","eventColor",getOptions(json.events),displayPicker);
    // event shapes in topBar
    topBarVisual(topBar,"Shape","eventShape",getOptions(json.events));
  }

  // node filter in topBar
  var topFilterInst = topFilter()
    .data(nodes)
    .attr(options.name)
    .displayGraph(function(f){
      if(filter && f){
        f = f.filter(function(d){
          return filter.indexOf(d)!=-1;
        })
      }
      filter = f;
      displayGraph();
    });
  topBar.call(topFilterInst);

  topBar.append("span").style("padding","0 10px");

  // expand/collpse bars displaying
  topBar.append("h3")
    .text(texts.expand)
  topBar.append("button")
    .attr("class","switch-button")
    .classed("active",!options.collapse)
    .on("click",function(){
      options.collapse = !options.collapse;
      d3.select(this).classed("active",!options.collapse);
      displayGraph();
    })

  topBar.append("span").style("padding","0 10px");

  // reset button
  topBar.append("button")
        .attr("class","primary reset")
        .text(texts.reset)
        .on("click",function(){
          location.reload();
        })
        .append("title")
          .text("F5")

  var header = body.append("div")
        .attr("class","header")

  var headerButtons = header.append("div")
    .attr("class","header-buttons")

  header.append("div")
        .attr("class","main-title")
        .html(options.main ? options.main : "&nbsp;")

  // styles
  d3.select("head")
      .append("style")
      .text("svg { font-family: sans-serif; font-size: "+body.style("font-size")+"; } "+
    ".laneLines {  shape-rendering: crispEdges; }"+
    ".mini text { font-size:  90%; }"+
    ".mini .item { fill-opacity: .7; stroke-width: 6;  }"+
    ".brush .selection { fill: dodgerblue; }"+
    ".axis path, .axis line { fill: none; stroke: #000; shape-rendering: crispEdges; }"+
    ".main text { font-size:  120%; }")

  displayGraph();

  if(options.note)
    body.append("p")
        .attr("class","note")
        .html(options.note)

  function displayGraph(){

    var plot = body.select("div.plot")

    if(plot.empty()){
      plot = body.append("div")
               .attr("class","plot")
    }else{
      plot.selectAll("*").remove();
    }

    plot.on("click",function(){
      if(d3.event.shiftKey){
        filter = false;
        displayGraph();
      }
    });

    var currentYear = new Date().getFullYear(),
        getEnd = function(y){
          return y === null ? currentYear : y;
        };

    var items = (filter ? nodes.filter(function(d){ return filter.indexOf(d[options.name])!=-1; }) : nodes).filter(function(d){ return d[options.group]!==null; });

    var lanes = options.group?d3.set(items.map(function(d){ return String(d[options.group]); })).values().sort():[""],
        laneLength = lanes.length,
        timeBegin = d3.min(items,function(d){ return d[options.start]; }),
        timeEnd = d3.max(items,function(d){ return getEnd(d[options.end]); });

    if(!options.text){
      items.forEach(function(d){
        d["text"] = d[options.name]+" </br>"+d[options.start]+((d[options.end]===null)?"":" - "+d[options.end]);
      })
      options.text = "text";
    }

    if(options.eventColor){
      if(dataType(json.events,options.eventColor)=="number"){
        var colorDomain = d3.extent(json.events,function(d){ return d[options.eventColor]; }),
            colorRange = colorScales[options.colorScaleeventColor];
        if(colorRange.length==3){
          colorDomain = [colorDomain[0],d3.mean(colorDomain),colorDomain[1]];
        }
        var eventColorScale = d3.scaleLinear()
          .range(colorRange)
          .domain(colorDomain)
      }else{
        var eventColorScale = d3.scaleOrdinal()
          .range(categoryColors)
          .domain(d3.map(json.events,function(d){ return d[options.eventColor]; }).keys().sort())
      }
    }

    var getShape = function() { return d3["symbol"+defaultShape]; };
    if(options.eventShape){
      var eventShapeScale = d3.scaleOrdinal()
        .range(symbolTypes)
        .domain(d3.map(json.events,function(d){ return d[options.eventShape]; }).keys())

      getShape = function(d) { return d3["symbol"+eventShapeScale(d[options.eventShape])]; };
    }

    //topSVG
    var topSVG = plot.append("svg"),
        mini = topSVG.append("g").attr("class", "mini");

    //sizes
    var vp = viewport(),
        marginLeft = 160,
        laneText = mini.append("g").append("g").attr("class","laneText").append("text");
    lanes.forEach(function(l){
      laneText.text(l);
      var w = laneText.node().getBBox().width+34;
      if(w>marginLeft)
        marginLeft = w;
    })
    mini.selectAll("*").remove();
    if(marginLeft>160 && marginLeft>vp.width/3)
      marginLeft = vp.width/3;

    var margin = [30*options.cex, 15, 20*options.cex, marginLeft], //top right bottom left
        w = vp.width - 30 - margin[1] - margin[3],
        miniHeight = laneLength * (20*options.cex),
        mainHeight = 10;

    topSVG
      .attr("width", w + margin[1] + margin[3])
      .attr("height", miniHeight + margin[0] + margin[2]);

    mini.attr("transform", "translate(" + margin[3] + "," + margin[0] + ")");

    //events legends
    if(options.eventColor || options.eventShape){
      var legend = mini.append("g")
        .attr("class","events-legend")
        .attr("transform","translate(0,-5)");
      var x = w;
      if(options.eventColor){
        var lcolor = legend.append("g"),
            values = [];
        items.forEach(function(d){
          if(d["_events_"]){
            d["_events_"].forEach(function(dd){
              values.push(dd[options.eventColor]);
            })
          }
        });
        d3.set(values).values().sort().reverse().forEach(function(d){
          var g = lcolor.append("g")
          g.append("rect")
            .attr("x",0)
            .attr("y",-10)
            .attr("height",8)
            .attr("width",8)
            .style("fill",eventColorScale(d))
          g.append("text")
            .attr("x",10)
            .attr("y",-2)
            .text(d)
          x = x-g.node().getBBox().width-4;
          g.attr("transform","translate("+x+",0)")
        })
        if(legend.node().getBBox().width>=w-50){
          lcolor.remove();
          x = w;
        }
      }
      if(options.eventShape){
        x = x-10;
        var lshape = legend.append("g"),
            values = [];
        items.forEach(function(d){
          if(d["_events_"]){
            d["_events_"].forEach(function(dd){
              values.push(dd[options.eventShape]);
            })
          }
        });
        d3.set(values).values().sort().reverse().forEach(function(d){
          var g = lshape.append("g")
          g.append("path")
            .attr("transform","translate(0,-5)")
            .attr("d",d3.symbol().type(d3["symbol"+eventShapeScale(d)]))
          g.append("text")
            .attr("x",10)
            .attr("y",-2)
            .text(d)
          x = x-g.node().getBBox().width-4;
          g.attr("transform","translate("+x+",0)")
        })
        if(legend.node().getBBox().width>=w-50){
          lshape.remove();
        }
      }
    }

    //scales
    var color,
        getMiniY;
    if(options.group){
      color = d3.scaleOrdinal()
        .range(categoryColors)
        .domain(nodes.map(function(n){ return n[options.group]; }).sort());

      getMiniY = function(d){ return y2((lanes.indexOf(String(d[options.group]))) + 0.5) - 5; }
    }else{
      color = function(){ return categoryColors[0]; }

      getMiniY = function(d){ return y2(0.5) - 5; }
    }

    var x = d3.scaleLinear()
      .domain([timeBegin, timeEnd])
      .range([0, w]);
    var x1 = d3.scaleLinear()
      .range([0, w]);
    var y2 = d3.scaleLinear()
      .domain([0, laneLength])
      .range([0, miniHeight]);

    //mini lanes and texts
    mini.append("g").selectAll(".laneLines")
      .data(lanes)
      .enter().append("line")
      .attr("class", "laneLines")
      .attr("x1", 0)
      .attr("y1", function(d,i) {return y2(i);})
      .attr("x2", w)
      .attr("y2", function(d,i) {return y2(i);})
      .attr("stroke", "lightgray");

    var defCheckOffset = 26,
        y = -4;

    selectedGroups = d3.set();

    var gLaneTexts = mini.append("g");

    var showCheckControls = !filter && laneLength>1;

    headerButtons.selectAll("*").remove();

    if(showCheckControls){
      displayHeaderButtons();
      enableFilterButton(false);

      displaySeparator(mini,margin[3],y);
    }else if(filter){
      headerButtons.append("div").html("&nbsp;")
      headerButtons.append("div")
        .attr("class","goback")
        .on("click",function(){
          filter = false;
          displayGraph();
        })
    }

    var laneText = gLaneTexts.selectAll(".laneText")
      .data(lanes)
      .enter().append("g")
        .attr("class", "laneText")
        .style("pointer-events", showCheckControls ? "all" : "none")
        .style("cursor", "pointer")
        .attr("transform", function(d, i) { return "translate("+(-margin[3])+","+y2(i + .5)+")"; })
        .on("click",function(group){
          selectedGroups[selectedGroups.has(group)?"remove":"add"](group);
          laneText.each(function(g){
            checkBox(d3.select(this),selectedGroups.has(g));
          })
          headerButtons.select(".legend-selectall > .legend-check-box").classed("checked",selectedGroups.size())
          enableFilterButton(selectedGroups.size());
        })

    laneText.append("text")
      .text(String)
      .attr("x", defCheckOffset)
      .attr("y", "4px")

    if(showCheckControls){
      displayCheck(laneText,-5,true);

      y = gLaneTexts.node().getBBox().height + 8*options.cex;
      displaySeparator(mini,margin[3],y);
    }

    function displayCheck(sel,y,item){
      var ml = 2,
          boxml = ml+8;

      sel.append("rect")
    .attr("x",ml)
    .attr("y",y-5)
    .attr("width",110)
    .attr("height",20)
    .attr("pointer-events","all")
    .style("fill","none")

      sel.append("rect")
    .attr("class","legend-check-box")
    .attr("x",boxml)
    .attr("y",y)
    .attr("width",10)
    .attr("height",10)
    .attr("rx",2)

      sel.append("path")
        .attr("class","legend-check-path")
        .attr("transform","translate("+boxml+","+y+")")
        .attr("d",item ? "M1,3L4,6L9,1L10,2L4,8L0,4Z" : "M2,4L8,4L8,6L2,6z")
    }

    function displaySeparator(sel,w,y){
      sel.append("line")
        .attr("class","legend-separator")
        .attr("x1",-8)
        .attr("y1",y)
        .attr("x2",-w+8)
        .attr("y2",y)
    }

    function displayHeaderButtons(){
      var div = headerButtons.append("div")
        .attr("class","legend-selectall")
        .on("click",selectAllChecks)

      div.append("div").attr("class","legend-check-box")
      div.append("span").text(texts.selectall)

      headerButtons.append("button")
        .attr("class","primary filter")
        .text(texts["filter"])
        .on("click",applyCheckBoxes)

      headerButtons.append("button")
        .attr("class","primary filter")
        .text(texts["filter"])
        .on("click",applyCheckBoxes)
        .style("position","absolute")
        .style("left",0)
        .style("top",(header.select(".main-title").node().clientHeight + topSVG.node().clientHeight - margin[2] + 12)+"px")
    }

    function enableFilterButton(enable){
      headerButtons.selectAll("button.primary.filter")
        .classed("disabled",!enable)
    }

    function checkBox(sel,check){
      sel.select(".legend-check-box")
        .classed("checked",check)
    }

    function selectAllChecks(){
        if(!selectedGroups.size()){
          gLaneTexts.selectAll(".laneText").each(function(){
            d3.select(this).dispatch("click");
          })
        }else{
          gLaneTexts.selectAll(".laneText").each(function(g){
            if(selectedGroups.has(g)){
              d3.select(this).dispatch("click");
            }
          })
        }
    }

    //mini axis
    var xAxis = d3.axisBottom(x).tickFormat(formatter);

    mini.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + y2(laneLength) + ")")
      .call(xAxis);

    //mini item rects
    mini.append("g").selectAll(".item")
      .data(items)
      .enter().append("rect")
      .attr("class", function(d){ return "item"; })
      .attr("fill", function(d) { return color(d[options.group]); })
      .attr("x", function(d){ return x(d[options.start]); })
      .attr("y", getMiniY)
      .attr("width", function(d){ return x(timeBegin + getEnd(d[options.end]) - d[options.start]); })
      .attr("height", 10);

    // sticky time header
    var timeHeader = plot.append("svg")
      .attr("class","time-header")
      .attr("width", w + margin[1] + margin[3])
      .attr("height", margin[2]+10);

    timeHeader.append("rect")
      .style("fill","#fff")
      .attr("x",margin[3])
      .attr("width", w)
      .attr("height", margin[2]+10);

    timeHeader.append("g")
      .attr("class", "x1 axis")
      .attr("transform", "translate(" + margin[3] + "," + (margin[2]+10-1) + ")")
    
    //main
    var svgLanes = plot.selectAll("svg.lane")
      .data(lanes)
      .enter().append("svg")
      .attr("class","lane")
      .attr("width", w + margin[1] + margin[3])
      .attr("height", mainHeight + margin[0] + margin[2]);
    
    svgLanes.append("defs").append("clipPath")
      .attr("id", function(d,i){ return "clip"+i; })
      .append("rect")
      .attr("width", w)
      .attr("height", mainHeight);

    var main = svgLanes.append("g")
      .attr("transform", "translate(" + margin[3] + "," + margin[0] + ")")
      .attr("width", w)
      .attr("height", mainHeight)
      .attr("class", "main");

    //main lanes and texts
    main.append("line")
      .attr("class", "laneLines")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", w)
      .attr("y2", 0)
      .attr("stroke", "lightgray");

    main.append("text")
      .attr("class", "laneText")
      .text(String)
      .attr("x", 0)
      .attr("y", 4 + 12*options.cex)

    main.append("g")
      .attr("clip-path", function(d,i){ return "url(#clip"+i+")"; });

    //brush
    var brush = d3.brushX()
      .extent([[0,0],[w,miniHeight - 1]])
      .on("brush", display);

    mini.append("g")
      .attr("class", "x brush")
      .call(brush)

    // zoom
    var zoom = d3.zoom()
        .scaleExtent([1, 10])
        .translateExtent([[0, 0], [w, 1]])
        .extent([[0, 0], [w, 1]])
        .filter(function(){
          return !d3.event.button && (d3.event.ctrlKey || d3.event.metaKey);
        })
        .on("zoom", function() {
          body.selectAll(".tooltip.fixed").remove();
          if (d3.event.sourceEvent && d3.event.sourceEvent.type === "brush") return;
          var t = d3.event.transform;
          mini.select(".brush").call(brush.move,x.range().map(t.invertX, t));
        })

    var zoomArea = plot.append("div")
      .attr("class","zoom-area")
      .style("display","none")
      .style("position","fixed")
      .style("top",0)
      .style("left",margin[3]+"px")
      .style("width",w+"px")
      .style("bottom",0)
      .call(zoom)
      .on("wheel",function(){
        d3.event.preventDefault();
      })

    // dotted vertical guide
    var rect = plot.node().getBoundingClientRect(),
        yearGuideTop = rect.top
          + topSVG.node().clientHeight
          + timeHeader.node().clientHeight
          + 3,
        yearGuide = plot.append("div")
      .attr("class","year-guide")
      .style("position","absolute")
      .style("top",yearGuideTop+"px")
      .style("left",((w/2)+margin[3])+"px")
      .style("width",0)
      .style("height",0)
      .style("border-left","dashed 1px #000")
      .style("z-index",-1);

    var pYear = plot.append("p")
      .attr("class","year")
      .style("background-color","#fff")
      .style("position","absolute")
      .style("top",yearGuideTop+"px")
      .style("margin-left","-16px")
      .style("padding","2px 0")
      .style("border-radius","0 0 5px 5px")
      .style("width","32px")
      .style("text-align","center");

    body.on("mousemove",function(){
      var coords = d3.mouse(body.node());
      if(coords[1]>yearGuideTop && coords[0]>margin[3] && coords[0]<(margin[3]+w)){
        yearGuide.style("left",coords[0]+"px");
        pYear.style("left",coords[0]+"px");
        var year = parseInt(x1.invert(coords[0]-margin[3]));
        pYear.text(year);
      }
    })

    window.onscroll = function(){
      if(window.pageYOffset > (yearGuideTop - topBar.node().offsetHeight)){
        timeHeader.style("position","fixed")
          .style("top",(topBar.node().offsetHeight)+"px")
          .style("left",0)
        pYear.style("position","fixed")
          .style("top",(topBar.node().offsetHeight + margin[2]+10)+"px")
      }else{
        timeHeader.style("position",null)
          .style("top",null)
        pYear.style("position","absolute")
          .style("top",yearGuideTop+"px")
      }
    }

    
    body
      .on("keydown.viewzoom", keyflip)
      .on("keyup.viewzoom", keyflip)

    mini.select(".brush").call(brush.move,x.range());

    function keyflip(){
      if(!d3.event.button && (d3.event.ctrlKey || d3.event.metaKey)){
        if(window.pageYOffset>yearGuideTop){
          zoomArea.style("top",margin[2]+"px");
        }else{
          zoomArea.style("top",(yearGuideTop-window.pageYOffset)+"px");
        }
        zoomArea.style("display","block");
      }else{
        zoomArea.style("display","none");
      }
    }

    function display() {
      var s = d3.event.selection || x.range(),
          extent = s.map(x.invert, x),
          minExtent = extent[0],
          maxExtent = extent[1],
          visItems = items.filter(function(d) {return d[options.start] < maxExtent && getEnd(d[options.end]) > minExtent;});

      zoomArea.call(zoom.transform, d3.zoomIdentity
        .scale(w / (s[1] - s[0]))
        .translate(-s[0], 0));

      x1.domain([minExtent, maxExtent]);

      if(minExtent < maxExtent){
        var x1Axis = d3.axisTop(x1).tickFormat(formatter);
        timeHeader.select("g").call(x1Axis);
      }else{
        timeHeader.select("g").selectAll("*").remove();
      }

      //update main item rects
      svgLanes.each(function(d,i){
        var self = d3.select(this);

        var laneData = options.group ? visItems.filter(function(p){ return p[options.group] == d; }) : visItems;

        if(!laneData.length){
          self.style("display","none");
        }else{
          self.style("display",null);

          var rects = self.select("g[clip-path]").selectAll("g")
            .data(laneData, function(d) { return d[options.name]; })
      
          var rectsEnter = rects.enter()
              .append("g")
            .attr("class", "item")
            .attr("fill", color(d))
            .style("cursor","pointer")
            .on("mouseenter",function(){
              d3.select(this).attr("fill", d3.rgb(color(d)).darker(1));
            })
            .on("mouseleave",function(){
              d3.select(this).attr("fill", color(d));
            })
          rectsEnter.append("rect")
            .attr("height", 10)
            .style("stroke",function(){ return d3.rgb(d3.select(this).style("fill")).darker(1); })
          rectsEnter.append("text")
            .attr("y", -4)

          rectsEnter.selectAll("rect, text").on("click.infopanel",function(d){ displayInfoPanel(d[options.info]); });

          tooltipActions(rectsEnter.selectAll("rect, text"),options.text);

          rects.exit().remove();

          var rectsUpdate = rectsEnter.merge(rects);

          rectsUpdate.select("rect")
            .attr("x", function(d) { return x1(d[options.start]);} )
            .attr("width", function(d) { return x1(getEnd(d[options.end])) - x1(d[options.start]);} );
          rectsUpdate.select("text").each(function(d){
            var self = d3.select(this),
                x = x1(d[options.start]),
                name = d[options.name];
            if(x<0){
                x = 0;
                name = "← " + name;
            }
            self.attr("x", x).text(name)
            if((x+this.getBBox().width)>w)
              self.attr("x",w).attr("text-anchor","end");
            else
              self.attr("text-anchor",null);

            if(options.eventColor && options.eventColor==options.eventParent)
              self.style("fill",eventColorScale(d[options.name]));
          });

          rectsUpdate.each(function(d){
            if(!d['_events_'])
              return;

            var points = d3.select(this).selectAll(".event").data(d['_events_'],function(dd){ return dd[options.eventChild]; });

            var pointsEnter = points.enter()
                  .append("path")
                  .attr("class","event");

            pointsEnter.on("click.infopanel",function(d){ displayInfoPanel(d[options.info]); });

            tooltipActions(pointsEnter,function(d){
              var html = "";
              if(options.text && d[options.text]){
                html = d[options.text];
              }else{
                for(var s in d){
                  if(d.hasOwnProperty(s)){
                    if(s==options.eventParent){
                      continue;
                    }else if(s==options.eventChild){
                      html = d[s]+"<br>"+html;
                    }else if(d[s]){
                      html += s+": "+d[s]+"<br>";
                    }
                  }
                }
              }
              return html;
            });

            points.exit().remove();

            var pointsUpdate = pointsEnter.merge(points);

            pointsUpdate
              .attr("d",d3.symbol().type(getShape))
              .style("fill",options.eventColor ? function(d){ return eventColorScale(d[options.eventColor]); } : null)
              .style("stroke",function(){ return d3.rgb(d3.select(this).style("fill")).darker(1); })

            var lines = [-Infinity];
            pointsUpdate.attr("transform",function(d){
              var dim = 14,
                  x = x1(d[options.eventTime]),
                  y = 0,
                  i = 0;
              while(lines[i]>=x){
                i++;
                if(!lines.length>i)
                  lines.push(-Infinity);
              }
              lines[i] = x+dim;
              y = 18+(i*dim);

              return "translate("+x+","+y+")";
            });
          });

          var lines = [-Infinity],
              lineheight = 10;
          rectsUpdate.attr("transform",function(d){
            var BBox = this.getBBox(),
                i = 0,
                nlines = Math.ceil(BBox.height/lineheight)+(d['_events_']?1:0);
                j = 0,
                collision = true;
            while(collision){
                i++;
                collision = false;
                for(j=i; j<i+nlines; j++){
                  if(!lines.length>j){
                    break;
                  }else if(lines[j]>=BBox.x){
                    collision = true;
                    break;
                  }
                }
            }
            lines[i] = options.collapse ? BBox.x+BBox.width+4 : Infinity;
            for(j=i+1; j<i+nlines; j++){
                lines[j] = lines[i];
            }
            return "translate(0,"+((40+i*lineheight)*options.cex)+")";
          });

          var height =  Math.ceil(this.getBBox().height);
          self.attr("height", height + margin[0] + margin[2]);
          self.select("defs #clip"+i+" rect").attr("height", height);
        }
      });

      var guideHeight = (parseInt(plot.style("height")) - parseInt(plot.select(".plot>svg:first-child").style("height"))) + "px";
      yearGuide.style("height",guideHeight);

    }
  }

  function applyCheckBoxes(){
    if(selectedGroups && selectedGroups.size()){
      filter = nodes
        .filter(function(d){ return selectedGroups.has(d[options.group]); })
        .map(function(d){ return d[options.name]; });
      displayGraph();
    }
  }

  function tooltipActions(sel,text){
    sel
      .on("click.tooltip",function(d){
        d3.event.stopPropagation();
        var tooltipfixed = body.append("div")
          .attr("class","tooltip fixed")
          .on("click",function(){
            d3.event.stopPropagation();
          })
          .call(d3.drag()
            .on("start",function(){
              tooltipfixed.style("cursor","grabbing");
              tooltipfixed.datum(d3.mouse(tooltipfixed.node()));
            })
            .on("drag",function(){
              var coor = d3.mouse(body.node().parentNode),
                  coor2 = tooltipfixed.datum();
              coor[0] = coor[0]-coor2[0];
              coor[1] = coor[1]-coor2[1];
              tooltipfixed
               .style("top",(coor[1])+"px")
               .style("left",(coor[0])+"px")
            })
            .on("end",function(){
              tooltipfixed.style("cursor","grab");
              tooltipfixed.datum(null);
            })
          );
        tooltipText(tooltipfixed,d);
        tooltipCoords(tooltipfixed);
        tooltipfixed.append("span")
          .html("&times;")
          .on("click",function(){
            d3.select(this.parentNode).remove();
          })
        tooltip.style("display","none").html("");
      })
      .on("mouseenter", function(d){
        if(!body.selectAll(".tooltip.fixed").empty()) return;

        tooltipText(tooltip,d);
      })
      .on("mousemove", function(){
        if(!body.selectAll(".tooltip.fixed").empty()) return;

        tooltipCoords(tooltip);
      })
      .on("mouseleave", function(){
        if(!body.selectAll(".tooltip.fixed").empty()) return;

        tooltip.style("display","none").html("")
      })

    function tooltipText(tip,d){
        var html = false;
        if(typeof text == 'string'){
          if(d[text])
            html = d[text];
        }else if(typeof text == 'function'){
          html = text(d);
        }
        if(html)
          tip.style("display","block").html(html);
    }

    function tooltipCoords(tip){
        var coor = [0, 0];
        coor = d3.mouse(body.node());
        tip.style("top",(coor[1]+20)+"px")
           .style("left",(coor[0]+20)+"px")
    }
  }

  function topBarVisual(sel, visual, option, opt, picker){
    sel.append("h3").text(texts[visual] + ":")

    var visualSelect = sel.append("div")
      .attr("class","select-wrapper")
    .append("select")
    .on("change",function(){
      options[option] = this.value;
      if(options[option]=="-"+texts.none+"-")
        options[option] = false;
      displayGraph();
      if(picker && dataType(json.events,options[option])=='number'){
        picker(options, option, displayGraph);
      }
    })
    opt.unshift("-"+texts.none+"-");
    visualSelect.selectAll("option")
        .data(opt)
      .enter().append("option")
        .property("value",String)
        .text(String)
        .property("selected",function(d){ return d==options[option]?true:null; })
  }

  function displayInfoPanel(info){
    if(!options.info)
      return;

    var docSize = viewport(),
        div = body.select("div.infopanel"),
        prevPanel = !div.empty();

    if(info){
      div.remove();
      if(!infoLeft){
        infoLeft = docSize.width * 2/3;
      }
      div = body.append("div")
          .attr("class","infopanel");
      var infoHeight = docSize.height
      - parseInt(div.style("top"))
      - parseInt(div.style("border-top-width"))
      - parseInt(div.style("border-bottom-width"))
      - parseInt(div.style("padding-top"))
      - parseInt(div.style("padding-bottom"))
      - 10;
      div.style("position","fixed")
         .style("height",infoHeight+"px")
         .style("left",docSize.width+"px").transition().duration(prevPanel?0:500)
           .style("left",infoLeft+"px")

      div.append("div")
      .attr("class","drag")
      .call(d3.drag()
        .on("drag", function() {
          var left = d3.mouse(body.node())[0]-parseInt(div.style("border-left-width"));
          if(left>(docSize.width*2/4) && left<(docSize.width*3/4)){
            infoLeft = left;
            div.style("left",infoLeft+"px");
          }
        })
      )
      div.append("div")
          .attr("class","close-button")
          .on("click", function(){
            div.transition().duration(500)
              .style("left",docSize.width+"px")
              .on("end",function(){
                div.remove();
              })
          });
      div.append("div").append("div").html(info);
    }else{
      div.select("div.infopanel > div.close-button").dispatch("click");
    }
  }

  function svgDownload(){
    var svgs = d3.selectAll(".plot>svg").filter(function(){ return d3.select(this).style("display")!="none"; }),
        tWidth = d3.select(".plot>svg").attr("width"),
        tHeight = 0,
        styles = d3.select("head>style").text(),
        svgString = "";

    svgs.each(function(){
      svgString = svgString + '<g transform="translate(0,' + tHeight + ')">' + this.innerHTML + '</g>';
      tHeight = tHeight + parseInt(d3.select(this).attr("height"));
    });

    svgString = '<svg xmlns="http://www.w3.org/2000/svg" width="' + tWidth + '" height="' + tHeight + '"><style>' + styles + '</style>' + svgString + '</svg>';

    var blob = new Blob([svgString], {type: 'image/svg+xml;charset=utf-8'});
    fileDownload(blob, d3.select("head>title").text()+'.svg');
  }

function svg2pdf(){
  var svgs = d3.selectAll(".plot>svg").filter(function(){ return d3.select(this).style("display")!="none"; }),
      tWidth = d3.select(".plot>svg").attr("width"),
      tHeight = 0,
      width = +d3.select("#clip0>rect").attr("width"),
      heights = [tHeight],
      margin = getTranslation(d3.select(".plot>svg>g").attr("transform"));

  svgs.each(function(){
    var h = parseInt(d3.select(this).attr("height"));
    tHeight = tHeight + h;
    heights.push(tHeight);
  });

  if(options.main){
    margin[1] = margin[1] + 30;
    tHeight = tHeight + 30;
  }

  if(!d3.select("div.note").empty()){
    tHeight = tHeight + 40;
  }

  var doc = new jsPDF({
    orientation: tWidth>tHeight?"l":"p",
    unit: 'pt',
    format: [tWidth, tHeight]
  });

  doc.polygon = pdfPolygon;

  doc.setTextColor(0);
  doc.setLineWidth(1);

  if(options.main){
      var txt = options.main,
          fontsize = 18,
          txtWidth = doc.getStringUnitWidth(txt) * fontsize,
          x = tWidth/2 - txtWidth/2,
          y = fontsize + 10;
      doc.setFontType("bold");
      doc.setFontSize(fontsize);
      doc.text(x, y, txt);
  }

  doc.setFontType("normal")

  d3.select("div.note").each(function(){
      var self = d3.select(this),
          txt = self.text(),
          fontsize = parseInt(self.style("font-size")),
          x = margin[0],
          y = tHeight - fontsize + 10;
      doc.setFontSize(fontsize);
      doc.text(x, y, txt);
  })

  svgs.each(function(d,i){
    var svg = d3.select(this),
        svgY = heights[i];

    doc.setDrawColor(211);
    svg.selectAll(".laneLines").each(function(){
      var self = d3.select(this),
          x = +self.attr("x1") + margin[0],
          y = +self.attr("y1") + margin[1] + svgY,
          x2 = +self.attr("x2") + margin[0];
      doc.line(x,y,x2,y);
    })
    svg.selectAll(".laneText").each(function(){
      var self = d3.select(this),
          y = (self.attr("transform") ? getTranslation(self.attr("transform"))[1] : +self.attr("y")) + margin[1] + svgY,
          txt = self.text(),
          fontsize = parseInt(self.style("font-size")),
          x = self.attr("transform") ? 10 : margin[0];
      doc.setFontSize(fontsize);
      doc.setTextColor(0);
      doc.text(x, y+3, txt);
    })
    if(!i){ // draw first svg
      var drawAxis = function(name){
        if(!svg.select("."+name+".axis>.domain").empty()){
          var axisY = getTranslation(svg.select("."+name+".axis").attr("transform"))[1],
              y = axisY + margin[1] + svgY;
          doc.setDrawColor(0);
          doc.setFontSize(9);
          doc.line(margin[0],y,margin[0]+width,y)
          svg.selectAll("."+name+".axis .tick text").each(function(){
            var self = d3.select(this),
                x = getTranslation(d3.select(this.parentNode).attr("transform"))[0] + margin[0],
                txt = self.text(),
                txtWidth = doc.getStringUnitWidth(txt) * 9;
            doc.line(x, y, x, y + ((name=="x") ? 6 : -6));
            x = x - txtWidth/2;
            doc.text(x, y + ((name=="x")? 16 : -10) , txt);
          });
        }
      }
      drawAxis("x");
      drawAxis("x1");
      svg.selectAll(".item").each(function(){
        var self = d3.select(this),
            x = +self.attr("x") + margin[0],
            y = +self.attr("y") + margin[1] + svgY,
            w = +self.attr("width"),
            h = +self.attr("height"),
            color = d3.rgb(self.style("fill"));
        doc.setFillColor(color.r,color.g,color.b);
        doc.rect(x, y, w, h, 'F');
      })
      svg.selectAll(".x.brush rect.extent").each(function(){
        var self = d3.select(this),
            x = +self.attr("x") + margin[0],
            y = +self.attr("y") + margin[1] + svgY,
            w = +self.attr("width"),
            h = +self.attr("height");
        doc.setDrawColor(128);
        if(w!=0)
          doc.rect(x, y, w, h, 'D');
      })
    }else{ // draw lanes
      svg.selectAll(".item").each(function(){
        var self = d3.select(this),
            y = getTranslation(self.attr("transform"))[1] + margin[1] + svgY,
            color = d3.rgb(self.style("fill")),
            selfRect = self.select("rect"),
            x = +selfRect.attr("x") + margin[0],
            w = +selfRect.attr("width"),
            h = +selfRect.attr("height"),
            selfText = self.select("text"),
            txt = selfText.text().replace("← ","<- ");
        doc.setFillColor(color.r,color.g,color.b);
        doc.setTextColor(color.r,color.g,color.b);
        if(x<margin[0])
          x = margin[0];
        doc.rect(x, y, w, h, 'F');

        if(self.select("text").attr("text-anchor")=="end"){
          var fontsize = parseInt(selfText.style("font-size")),
          txtWidth = doc.getStringUnitWidth(txt) * fontsize;
          x = margin[0] + width - txtWidth;
        }
        doc.text(x, y-4, txt);

        self.selectAll(".event").each(function(){
          var self = d3.select(this)
              color = d3.rgb(self.style("fill")),
              x = +getTranslation(self.attr("transform"))[0] + margin[0],
              selfY = +getTranslation(self.attr("transform"))[1] + y;

          doc.setFillColor(color.r,color.g,color.b);
          doc.polygon(self.attr("d"),x,selfY,[1,1],'F');
        })
      })
    }
  })
  doc.setFillColor(255);
  doc.rect(tWidth-15,0,15,tHeight,'F');

  doc.save(d3.select("head>title").text()+".pdf");
}

} // timeline function end

if(typeof multiGraph == 'undefined'){
  window.onload = function(){
    timeline(JSON.parse(d3.select("#data").text()));
  };
}
