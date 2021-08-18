function barplot(json){

  var options = json.options,
      nodes = json.nodes,
      links = json.links,
      filter = false,
      sigFilter = 0;

  var body = d3.select("body");

  if(options.cex)
    body.style("font-size", 10*options.cex + "px")
  else
    options.cex = 1;

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

  if(!options.defaultColor)
    options.defaultColor = categoryColors[0];

  var wordSVG = d3.select("body").append("svg"),
      words = nodes.map(function(node){ return node[options.label?options.label:options.name]; }),
      maxWord = d3.max(words.map(function(word){
        var text = wordSVG.append("text")
          .style("font-family","sans-serif")
          .style("font-size", body.style("font-size"))
          .text(word);
        return text.node().getBoundingClientRect().width;
      }));
  wordSVG.remove();

  maxWord = maxWord + 20;

  if(maxWord<160)
    maxWord = 160;

  var vp = viewport(),
      margin = {top: 80, right: 40, bottom: 40, left: maxWord};

  var width = vp.width - 40 - margin.left - margin.right,
      height = vp.height - 40 - margin.top - margin.bottom;

  var x = d3.scaleLinear()
      .range([0, width]);

  var y = d3.scaleBand()

  var xAxis = d3.axisBottom(x);

  var yAxis = d3.axisLeft(y);

  if(options.label)
    yAxis.tickFormat(function(d){ return nodes.filter(function(p){ return d==p[options.name]; })[0][options.label]; })
  else
    options.label = options.name;

  var main = "coincidences",
      textLegend = ["coincidences","incidences"];
  if(options.expected){
    main = "concoincidences";
    textLegend = ["coincidences","expected"];
    if(options.confidence)
      textLegend.push(Array.isArray(options.confidence)?"confidenceinterval":"expectedconfidence");
  }

  var maxIncidence = d3.max(nodes, function(d){ return d[options.incidences]; }),
      maxExpected = options.expected ? d3.max(links,function(d){
        var conf = [];
        if(options.confidence){
          if(Array.isArray(options.confidence))
            conf = options.confidence.map(function(e){ return d[e]; });
          else
            conf = [d[options.confidence]];
        }
        return d3.max(d3.merge([[d[options.coincidences],d[options.expected]],conf]));
      }) : 0,
      subject = options.select? options.select : null; //nodes.filter(function(d){ return d[options.incidences]==maxIncidence; });

  //subject = subject[0][options.name];

  // top bar
  var topBar = displayTopBar();
  body.call(topBar);

  topBar.addIcon(iconButton()
        .alt("pdf")
        .width(24)
        .height(24)
        .src(b64Icons.pdf)
        .title(texts.pdfexport)
        .job(svg2pdf));

  topBar.addIcon(iconButton()
        .alt("svg")
        .width(24)
        .height(24)
        .src(b64Icons.svg)
        .title(texts.svgexport)
        .job(svgDownload));

  // events
  var eventSelect,
      nodeslist;
  topBar.addBox(function(box){
    box.append("h3").text(texts.subjectselect + ":")
    eventSelect = box.append("div")
      .attr("class","select-wrapper")
    .append("select")
    .on("change",function(){
      subject = this.value;
      if(subject=="-default-"){
        subject = null;
      }
      sigButtonAndSlider();
      displayGraph();
    })
    nodeslist = nodes.map(function(d){
          return [d[options.name],d[options.label]];
        }).sort(function(a,b){
          return sortAsc(a[1],b[1]);
        });
    nodeslist.unshift(["-default-","-"+texts.total+"-"]);
    eventSelect.selectAll("option")
        .data(nodeslist)
      .enter().append("option")
        .property("value",function(d){ return d[0]; })
        .text(function(d){ return d[1]; })
        .property("selected",function(d){ return d[0]==subject?true:null; })
  });

  // node order
  topBar.addBox(function(box){
    topOrder(box,nodes,displayGraph);
  });

  // colors
  topBar.addBox(function(box){
    box.append("h3").text(texts.Color + ":")
    var colorSelect = box.append("div")
      .attr("class","select-wrapper")
    .append("select")
    .on("change",function(){
      options.color = this.value;
      if(options.color=="-"+texts.none+"-")
        options.color = false;
      displayGraph();
    })
    var opt = getOptions(nodes);
    opt.unshift("-"+texts.none+"-");
    colorSelect.selectAll("option")
        .data(opt)
      .enter().append("option")
        .property("value",String)
        .text(String)
        .property("selected",function(d){ return d==options.color?true:null; })

    box.append("button")
      .text(texts.Color)
      .on("click",function(){
        var panel = displayWindow();
        panel.append("ul")
          .attr("class","picker")
          .style("width","100px")
          .selectAll("li")
            .data(categoryColors)
          .enter().append("li")
            .style("color",String)
            .style("background-color",String)
            .text(String)
            .on("click",function(){
              options.defaultColor = this.textContent;
              displayGraph();
              d3.select("div.window-background").remove();
            })
      })
  });

  // node filter
  var topFilterInst = topFilter()
    .data(nodes)
    .datanames(getOptions(nodes))
    .attr(options.name)
    .displayGraph(displayGraph);

  topBar.addBox(topFilterInst);

  sigButtonAndSlider();

  height = height - topBar.height();

  body.append("svg")
    .attr("class","plot")

  if(options.note){
    var pnote = body.append("p")
        .attr("class","note")
        .html(options.note)
  }

  // graph
  displayGraph();

  function sigButtonAndSlider(){
    if(subject===null){
      topBar.removeBox("significance");
      topBar.removeBox("slider");
      return;
    }

    // button
    if(options.expected && !options.significance){
      topBar.addBox(function(box){
        box.append("button")
         .text(options.confidence ? "Sig." : ">Exp.")
         .on("click",function(){
            if(subject){
              sigFilter = !sigFilter;
              d3.select(this).style("background-color",sigFilter?basicColors.mediumGrey:null)
              displayGraph();
            }
         })
        .style("background-color",sigFilter?basicColors.mediumGrey:null);
      },"significance");
    }

    //slider
    if(options.significance){
      topBar.addBox(function(box){
        sigFilter = 1;
        var sliderWidth = 200;
        var values = [0,0.0001,0.001,0.01,0.05,0.10,0.20,0.50,1];

        box.append("span")
        .style("margin-right","5px")
        .text("p<");

        var slider = box.append("span")
        .style("position","relative");

        var bubble = slider.append("span")
        .attr("class","slider-text")
        .style("position","absolute")
        .style("top","8px")
        .style("left",bubblePos(8))
        .text("1")

        slider.append("input")
        .attr("type","range")
        .attr("min","0")
        .attr("max","8")
        .attr("value","8")
        .style("width",sliderWidth+"px")
        .on("input",function(){
          sigFilter = values[+this.value];
          bubble.style("left",bubblePos(+this.value)).text(String(sigFilter));
          displayGraph();
        })

        function bubblePos(value){
          return (10+((value)*((sliderWidth-12)/8)))+"px";
        }
      },"slider")
    }
  }

  function displayGraph(newfilter){

    var data = [],
        whiskers = subject && options.confidence && !options.significance;

    if(typeof newfilter != "undefined")
      filter = newfilter;

    if(subject){
      links.forEach(function(d){
        if(d.Source == subject || d.Target == subject){
          var row = {};
          row.object = (d.Source == subject ? d.Target : d.Source);
          if(options.significance){
            if(d[options.significance]>sigFilter)
              return;
          }else if(sigFilter && options.expected){
            if(options.confidence){
              if(Array.isArray(options.confidence) && (d[options.expected] >= d[options.confidence[0]] && d[options.expected] <= d[options.confidence[1]]))
                return;
            }else{
              if(d[options.coincidences] <= d[options.expected])
                return;
            }
          }
          if(!filter || filter.indexOf(row.object)!=-1){
            row.a = d[options.coincidences];
            if(options.expected){
              row.b = d[options.expected];
              if(options.confidence)
                if(whiskers)
                  row.c = [d[options.confidence[0]],d[options.confidence[1]]];
                else
                  row.c = d[options.confidence];
            }else{
              row.b = nodes.filter(function(p){ return row.object==p[options.name]; })[0][options.incidences];
            }
            if(options.text)
              row.t = nodes.filter(function(p){ return row.object==p[options.name]; })[0][options.text];
              if(options.significance)
                row.sig = d[options.significance];
            data.push(row);
          }
        }
      })
    }else{
      nodes.forEach(function(d){
        if(!filter || filter.indexOf(d[options.name])!=-1){
          var row = {};
          row.object = d[options.name];
          row.b = d[options.incidences];
          if(options.text)
            row.t = d[options.text];
          data.push(row);
        }
      })
    }

    if(!options.order){
      data.sort(function(a,b){
        var ba = b.a,
            aa = a.a,
            ab = a.b?a.b:a.c?a.c:a.a,
            bb = b.b?b.b:b.c?b.c:b.a;

        var s1 = compareFunction(ba,aa,options.rev);
        if(s1){
          return s1;
        }else{
          return compareFunction(bb,ab,options.rev);
        }
      });
    }else{
      data.sort(function(a,b){
        var aa = nodes.filter(function(node){ return a.object==node[options.name]; })[0][options.order],
            bb = nodes.filter(function(node){ return b.object==node[options.name]; })[0][options.order];

        var rev = false;
        if((typeof aa == "number" && typeof bb == "number") ^ options.rev){
          rev = true;
        }

        return compareFunction(aa,bb,rev);
      });
    }

    if(!options.scalebar){
      height = data.length*20;
    }else if(options.note){
      height = height - pnote.node().getBoundingClientRect().height + 10;
    }

    if(height/data.length < 13)
      height = data.length*13;

    if(subject && options.expected)
      x.domain([0,maxExpected]).nice()
    else
      x.domain([0,maxIncidence]).nice()

    y.range([0, height])
     .paddingInner(.3)
     .paddingOuter(.6)
     .domain(data.map(function(d){ return d.object; }));

    var bandwidth = y.bandwidth();

    var getColors = function(col){
      var color1 = d3.hsl(col),
          l2 = 0.90,
          l1 = (color1.l+l2)/2;
      var color2 = d3.hsl(color1.h,color1.s,l1),
          color3 = d3.hsl(color1.h,color1.s,l2);
      return [color1.toString(),color2.toString(),color3.toString()];
    }

    var colors = getColors(options.defaultColor);

    if(options.color){
      var type = dataType(nodes,options.color);
      if(type=="number"){
          var colorScaleLinear = d3.scaleLinear()
            .range([0.2,1])
            .domain(d3.extent(nodes,function(node){
              return node[options.color];
            }))
      }
      if(type=="string"){
          var colorScaleOrdinal = d3.scaleOrdinal()
            .range(categoryColors)
            .domain(d3.map(nodes,function(node){
              return node[options.color];
            }).keys())
      }
    }

    var svg = body.select("svg.plot");
    svg.selectAll("*").remove();

    svg
      .attr("xmlns","http://www.w3.org/2000/svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .on("dblclick",function(){
        sigFilter = 0;
        sigButtonAndSlider();
        topFilterInst.removeFilter();
      })

    svg.append("style").text("svg { font-family: sans-serif; font-size: "+body.style("font-size")+"; } "+
      ".main { font-size: 200%; } "+
      (whiskers ? "" : ".bar, .legend path { stroke: "+basicColors.black+"; stroke-width: .4px; } ") +
      ".a { fill: "+colors[0]+"; } "+
      ".b { fill: "+colors[1]+"; } "+
      ".c { fill: "+colors[2]+"; } " +
      (whiskers ? ".c, " : "") + ".axis path, .axis line { fill: none; stroke: "+basicColors.black+"; shape-rendering: crispEdges; } "+
      ".dotted { stroke: "+basicColors.mediumGrey+"; stroke-width: 2; stroke-dasharray: 1, 10; stroke-linecap: round; } " +
      ".y.axis path, .y.axis line { display: none; } "+
      ".line { stroke-dasharray: 2, 2; stroke: "+basicColors.black+"; }");

    svg.append("text")
        .attr("class","main")
        .attr("x",margin.left)
        .attr("y",margin.top/2)
        .text(subject?texts[main] + " " + texts.ofsomeone + " " + nodes.filter(function(p){ return subject==p[options.name]; })[0][options.label] + " " + texts.withsomeone + "...":texts.total)

    var legend = svg.append("g")
        .attr("class","legend")
        .attr("transform","translate("+(margin.left)+","+margin.top/1.1+")")

    legend.selectAll("text")
          .data(subject?textLegend:["incidences"])
        .enter().append("text")
          .text(function(d){ return texts[d]+((d=="expectedconfidence" || d=="confidenceinterval") && options.level?" "+(options.level*100)+"%":""); })
          .attr("x",function(d,i){ return i*110*options.cex + 20; })

    legend.selectAll("path")
          .data(subject?textLegend:["incidences"])
        .enter().append("path")
          .attr("class",function(d){
            switch(d){
             case "coincidences":
               return "a";
             case "incidences":
             case "expected":
               return "b";
             case "expectedconfidence":
             case "confidenceinterval":
               return "c";
            }
          })
          .attr("d",function(d,i){
            var x = i*110*options.cex,
                y = -7,
                width = 16,
                height = 8;

            if(whiskers){
              if(d=="coincidences"){
                var r = height/2;
                return "M "+(x+width/2)+", "+(y+r)+" m -"+r+", 0 a "+r+","+r+" 0 1,0 "+(r*2)+",0 a "+r+","+r+" 0 1,0 -"+(r*2)+",0";
              }
              if(d=="expected")
                return "M"+(x+((width-height)/2))+","+y+"h"+height+"v"+height+"h"+(-height)+"Z";
              if(d=="confidenceinterval")
                return "M"+x+","+y+"v"+height+"v"+(-height/2)+"h"+width+"v"+(height/2)+"v"+(-height);
            }else
              return "M"+x+","+y+"h"+width+"v"+height+"h"+(-width)+"Z";
          })

    var g = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    data.forEach(function(d){
      var gBar = g.append("g").datum(d);
      gBar.attr("transform","translate(0,"+y(d.object)+")");

      if(whiskers){
        display_dotline(gBar);
        display_square(gBar);
        display_whiskers(gBar);
        display_circle(gBar);
      }else{
        if(d.c < d.b){
          display_bar(gBar,"b");
          display_bar(gBar,"c");
        }else{
          display_bar(gBar,"c");
          display_bar(gBar,"b");
        }
        display_bar(gBar,"a");
      }

     if(options.color){
        var val = nodes.filter(function(node){ return d.object==node[options.name]; })[0][options.color];
        if(colorScaleLinear){
          gBar.style("opacity",function(d){
            return colorScaleLinear(val);
          })
        }
        if(colorScaleOrdinal){
          var colors = getColors(colorScaleOrdinal(val));
          gBar.select(".a").style("fill",colors[0]);
          gBar.select("rect.b").style("fill",colors[1]);
          gBar.select("rect.c").style("fill",colors[2]);
        }
      }

      if(options.text){
        tooltip(gBar,"t");
      }
    })

    g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    g.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .selectAll(".tick > text").on("dblclick",function(d){
        subject = d;
        sigButtonAndSlider();
        displayGraph();
        eventSelect.node().selectedIndex = nodeslist.map(function(d){ return d[0]; }).indexOf(subject);
      })

    function display_bar(g,type){
      var d = g.datum(),
          value = d[type];
      if(typeof value == "undefined")
        return;
      var bar = g.append("rect")
        .attr("class","bar "+type)
        .attr("x", 0)
        .attr("width", 0)
        .attr("y", (type=="a")?bandwidth*0.2:0)
        .attr("height", bandwidth-((type=="a")?bandwidth*0.4:0));

      if(!options.text)
        bar.append("title")
          .text("(" + d.object + ", " + formatter(value) + ")");

      if(options.significance && drawSig(d.sig) && type=="a")
        g.append("text")
          .attr("class","significance")
          .style("text-anchor","end")
          .style("fill",basicColors.white)
          .style("font-size",(bandwidth)+"px")
          .attr("x",x(value)-4)
          .attr("y",bandwidth*1.08)
          .text(drawSig(d.sig))

      bar.transition().duration(1000)
        .attr("width", x(value));
    }

    function display_circle(g){
      var d = g.datum();
      var circle = g.append("circle")
        .attr("class","a")
        .attr("cx", 0)
        .attr("cy", bandwidth/2)
        .attr("r", bandwidth/2);

      if(!options.text)
        circle.append("title")
          .text("(" + d.object + ", " + formatter(d.a) + ")");

      circle.transition().duration(1000)
        .attr("cx", x(d.a));
    }

    function display_square(g){
      var d = g.datum();
      var square = g.append("rect")
        .attr("class","b")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", bandwidth)
        .attr("height", bandwidth);

      if(!options.text)
        square.append("title")
          .text("(" + d.object + ", " + formatter(d.b) + ")");

      square.transition().duration(1000)
        .attr("x", x(d.b)-(bandwidth/2));
    }

    function display_whiskers(g){
      var d = g.datum();
      var whiskers = g.append("path")
        .attr("class","c")
        .attr("d",function(){
          var x1 = x(d.c[0]),
              x2 = x(d.c[1]);
          return "M"+x1+",0v"+bandwidth+"v"+(-bandwidth/2)+"h"+(x2-x1)+"v"+(-bandwidth/2)+"v"+bandwidth;
        })
    }

    function display_dotline(g){
      var d = g.datum();
      var dotline = g.append("line")
        .attr("class","dotted")
        .attr("x1", 0)
        .attr("y1", bandwidth/2)
        .attr("x2", 0)
        .attr("y2", bandwidth/2)

      dotline.transition().duration(1000)
        .attr("x2", x(Math.min(d.a,d.b)));
    }
  }

  function drawSig(d){
    if(d<=0.001)
      return "***";
    if(d<=0.01)
      return "**";
    if(d<=0.05)
      return "*";
    return "";
  }

  function svgDownload(){
    var svg = d3.select("svg.plot");
    var svgString = new XMLSerializer().serializeToString(svg.node());
    var blob = new Blob([svgString], {type: 'image/svg+xml;charset=utf-8'});
    fileDownload(blob, d3.select("head>title").text()+'.svg');
  }

function topOrder(div,data,displayGraph){

  div.append("h3").text(texts.Order + ":")

  var selOrder = div.append("div")
      .attr("class","select-wrapper")
    .append("select")
    .on("change",function(){
      options.order = this.value;
      if(options.order=="-default-")
        options.order = false;
      displayGraph();
    })

  var opt = getOptions(data).sort(function(a,b){
    if(a=="incidences")
      return -1;
    if(b=="incidences")
      return 1;
    return sortAsc(a,b);
  }).map(function(d){ return [d,d]; });
  if(opt[0][0]=="incidences")
    opt[0][1] = texts.incidences;
  opt.unshift(["-default-","-"+texts.coincidences+"-"]);
  selOrder.selectAll("option")
        .data(opt)
      .enter().append("option")
        .property("selected",function(d){
          return d[0]==options.order;
        })
        .property("value",function(d){ return d[0]; })
        .text(function(d){ return d[1]; })

  div.append("h3")
    .text(texts.Reverse)
  div.append("button")
    .attr("class","switch-button")
    .classed("active",options.rev)
    .on("click",function(){
      options.rev = !options.rev;
      d3.select(this).classed("active",options.rev);
      displayGraph();
    })
}

function tooltip(sel,text){
    var body = d3.select("body"),
        tip = body.select("div.tooltip");

    if(tip.empty())
      tip = body.append("div")
          .attr("class","tooltip")

    sel
      .on("mouseenter", function(d){
        if(d[text]){
          tip.style("display","block").html(d[text]);
        }
      })
      .on("mousemove", function(){
        var coor = [0, 0];
        coor = d3.mouse(body.node());
        tip.style("top",(coor[1]+20)+"px")
           .style("left",(coor[0]+20)+"px")
      })
      .on("mouseleave", function(){
        tip.style("display","none").html("")
      })
}

function svg2pdf(){

  var tWidth = width + margin.left + margin.right,
      tHeight = height + margin.top + margin.bottom;

  var doc = new jsPDF(tWidth>tHeight?"l":"p","pt",[tWidth, tHeight]);

  doc.setTextColor(0);
  doc.setDrawColor(0);
  doc.setLineWidth(1);

  d3.selectAll("svg>text").each(function(){
    var self = d3.select(this),
        x = margin.left,
        y = +self.attr("y"),
        txt = self.text(),
        fontsize = parseInt(self.style("font-size"));
    doc.setFontSize(fontsize);
    doc.text(x,y,txt);
  })

  doc.setFontSize(10);

  d3.selectAll(".legend").each(function(){
    var self = d3.select(this),
        coors = getTranslation(self.attr("transform"));
    self.selectAll("text").each(function(){
      var self = d3.select(this),
          x = +self.attr("x") + coors[0],
          txt = self.text();
      doc.text(x,coors[1],txt);
    })
    self.selectAll("path").each(function(){
      var self = d3.select(this),
          y = coors[1],
          d = self.attr("d"),
          x = coors[0],
          color = d3.rgb(self.style("fill")),
          stroke = self.style("stroke")!="none",
          circle = d.indexOf("a")!=-1,
          closed = d.indexOf("Z")!=-1;

      d = d.replace(/M|Z/g,"").split(/[hvam]/);

      var M = d[0].split(",").map(function(e){ return +e; });
      x = x+M[0];
      y = y+M[1];

      if(!isNaN(color.opacity))
        doc.setFillColor(color.r,color.g,color.b);
      if(circle){
        doc.circle(x, y, +d[2].split(",")[0], 'F');
      }else if(closed){
        doc.rect(x, y, +d[1], +d[2], stroke?'FD':'F');
      }else{
        var h = +d[1],
            w = +d[3];
        doc.line(x, y + (h/2), x + w, y + (h/2), 'S');
        doc.line(x, y, x, y + h, 'S');
        doc.line(x + w, y, x + w, y + h, 'S');
      }
    })
  })

  d3.selectAll(".bar").each(function(){
    var self = d3.select(this),
        x = +self.attr("x") + margin.left,
        y = getTranslation(d3.select(this.parentNode).attr("transform"))[1] + (+self.attr("y")) + margin.top,
        w = +self.attr("width"),
        h = +self.attr("height"),
        color = d3.rgb(self.style("fill"));
    doc.setFillColor(color.r,color.g,color.b);
    doc.rect(x, y, w, h, 'FD');
  });

  d3.selectAll("svg.plot>g:last-child rect.b:not(.bar)").each(function(){
    var self = d3.select(this),
        x = +self.attr("x") + margin.left,
        y = getTranslation(d3.select(this.parentNode).attr("transform"))[1] + (+self.attr("y")) + margin.top,
        w = +self.attr("width"),
        h = +self.attr("height"),
        color = d3.rgb(self.style("fill"));
    doc.setFillColor(color.r,color.g,color.b);
    doc.rect(x, y, w, h, 'F');
  });

  d3.selectAll("svg.plot>g:last-child path.c").each(function(){
    var self = d3.select(this),
        y = getTranslation(d3.select(this.parentNode).attr("transform"))[1] + margin.top,
        d = self.attr("d").substr(1).split(/[hv]/),
        x = margin.left + (+d[0].split(",")[0]);
    
    doc.line(x, y+(+d[1]/2), x + (+d[3]), y+(+d[1]/2), 'S');
    doc.line(x, y, x, y+(+d[1]), 'S');
    doc.line(x + (+d[3]), y, x + (+d[3]), y+(+d[1]), 'S');
  });

  d3.selectAll("svg.plot>g:last-child circle.a").each(function(){
    var self = d3.select(this),
        x = +self.attr("cx") + margin.left,
        y = getTranslation(d3.select(this.parentNode).attr("transform"))[1] + (+self.attr("cy")) + margin.top,
        r = +self.attr("r"),
        color = d3.rgb(self.style("fill"));
    doc.setFillColor(color.r,color.g,color.b);
    doc.circle(x, y, r, 'F');
  });

  d3.selectAll(".y.axis .tick text").each(function(){
    var self = d3.select(this),
        y = getTranslation(d3.select(this.parentNode).attr("transform"))[1] + margin.top,
        txt = self.text(),
        txtWidth = doc.getStringUnitWidth(txt) * 10,
        x = margin.left - txtWidth;
    doc.text(x-6, y+3, txt);
  });

  doc.line(margin.left,margin.top+height,margin.left+width,margin.top+height)

  d3.selectAll(".x.axis .tick text").each(function(){
    var self = d3.select(this),
        x = getTranslation(d3.select(this.parentNode).attr("transform"))[0] + margin.left,
        y = height + margin.top,
        txt = self.text();
    doc.line(x,y,x,y+6);
    doc.text(x-3, y+16, txt);
  });

  d3.selectAll("p.note").each(function(){
    var self = d3.select(this),
        x = margin.left,
        y = height + margin.top + margin.bottom/2,
        txt = self.text();
    doc.text(x, y, txt);
  })

  doc.setTextColor(255);
  d3.selectAll("text.significance").each(function(){
    var self = d3.select(this),
        y = getTranslation(d3.select(this.parentNode).attr("transform"))[1] + (+self.attr("y")) + margin.top,
        txt = self.text(),
        fontsize = parseInt(self.style("font-size")),
        txtWidth = doc.getStringUnitWidth(txt) * fontsize,
        x = margin.left + (+self.attr("x")) - txtWidth - 2;
    doc.setFontSize(fontsize);
    doc.text(x, y, txt);
  });

  doc.save(d3.select("head>title").text()+".pdf");
}

} // barplot function end

if(typeof multiGraph == 'undefined'){
  window.onload = function(){
    barplot(JSON.parse(d3.select("#data").text()));
  };
}
