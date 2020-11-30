function network(Graph){

  var docSize = viewport(),
      width = docSize.width,
      height = docSize.height,
      images = false,
      images64 = false,
      egoNet = false,
      transform = d3.zoomIdentity,
      backupNodes = false,
      frameControls = false,
      Sliders = {},
      Legends = {},
      VisualHandlers = {},
      Controllers = {},
      GraphNodesLength = 0,
      GraphLinksLength = 0,
      options = Graph.options;

  delete Graph.options;

  var defaultColor = categoryColors[0], // nodes and areas default color
      defaultLinkColor = "#999999", // links default color
      defaultShape = "Circle", // node shape by default
      symbolTypes = ["Circle","Square","Diamond","Triangle","Cross","Star","Wye"], // list of available shapes
      darkGrey = "#777777", // dark grey
      lightGrey = "#f5f5f5", // light grey
      nodeSizeRange = [0.5,4], // node size range
      nodeLabelSizeRange = [8,20], // node label size range
      linkWeightRange = [200,40], // link weight range (link distance)
      linkWidthRange = [1,5], // link width range
      zoomRange = [0.1, 10], // zoom range
      chargeRange = [0,-1000], // charge range
      linkDistanceRange = [0,500], // link distance range
      timeRange = [5000,500], // speed range for dynamic net
      axisExtension = 50, // pixels to increase the axes size
      sidebarWidth = 240, // sidebar width (will increase with cex)
      infoLeft = 0, // global variable for panel left position
      nodeRadius = 4.514, // base node radius
      findNodeRadius = 20, // radius in which to find a node in the canvas
      hiddenFields = ["Source","Target","x","y","source","target","fx","fy","hidden","childNodes","parentNode","_frame_"]; // not to show in sidebar controllers or tables

  var simulation = d3.forceSimulation()
      .force("link", d3.forceLink())
      .force("charge", d3.forceManyBody())
      .on("end", forceEnd)
      .stop();

  var scaleCoorX,
      scaleCoorY;

  var body = d3.select("body");

  var fontFamily = body.style("font-family");

  var zoom = d3.zoom()
    .scaleExtent(zoomRange)
    .on("end",function(){
      d3.select(this).style("cursor","grab");
    }) 
    .on("zoom", function() {
      transform = d3.event.transform;
      options.zoomScale = transform.k;
      Sliders.zoom.update(options.zoomScale).brushedValue(true);
    })

  checkGraphData();

  width = computeWidth();

  // main bar
  var main = body.append("div")
        .attr("class", "main")
  displayMain();

  // panel
  var panel = body.append("div")
      .attr("class", "panel");

  var plot = panel.append("div")
      .attr("class", "plot")
      .style("position","relative")

  var sidebar = panel.append("div")
      .attr("class", "sidebar")
      .style("width", (sidebarWidth) + "px")

  var legendPanel = panel.append("div")
      .attr("class", "legend-panel")
      .style("width", (sidebarWidth) + "px")

  if(typeof options.showTables != "undefined"){
    panel.append("div")
      .attr("class","showHideTable")
      .classed("showing",options.showTables)
      .on("click",function(){
        if(d3.select(this).classed("showing")){
          options.showTables = false;
        }else{
          options.showTables = true;
        }
        displayBottomPanel();
      })
  }

  body.on("keydown.shortcut",function(){
    if(!body.select("body > div.window-background").empty()){
      return;
    }
    if(d3.event.ctrlKey){
      d3.event.preventDefault();
      var key = getKey(d3.event);
      switch(key){
        case "+":
          if(d3.event.shiftKey){
            Sliders.repulsion.update(options['charge']+(chargeRange[1]/100));
          }else{
            plot.select(".zoombutton.zoomin").dispatch("click");
          }
          return;
        case "-":
          if(d3.event.shiftKey){
            Sliders.repulsion.update(options['charge']-(chargeRange[1]/100));
          }else{
            plot.select(".zoombutton.zoomout").dispatch("click");
          }
          return;
        case "ArrowUp":
        case "ArrowLeft":
        case "ArrowDown":
        case "ArrowRight":
          if(d3.event.shiftKey){
            moveShift(key);
          }else{
            movePan(key);
          }
          return;
      }
    }
  });

  body.on("keyup.shortcut",function(){
    if(!body.select("body > div.window-background").empty()){
      return;
    }
    var key = getKey(d3.event);
    if(d3.event.ctrlKey){
      switch(key){
        case "Enter":
          if(frameControls.play){
            frameControls.play = false;
            clearInterval(frameControls.frameInterval);
          }else{
            frameControls.play = true;
            handleFrames(frameControls.frame+1);
          }
          clickFrameCtrlBtn();
          return;
        case "0":
          plot.select(".zoombutton.zoomreset").dispatch("click");
          return;
        case "1":
          if(typeof options.showSidebar != "undefined"){
            options.showSidebar = !options.showSidebar;
            displaySidebar();
          }
          return;
        case "2":
          if(typeof options.showButtons2 != "undefined"){
            options.showButtons2 = !options.showButtons2;
            displayPanelButtons();
          }
          return;
        case "3":
          if(typeof options.showTables != "undefined"){
            options.showTables = !options.showTables;
            displayBottomPanel();
          }
          return;
        case "4":
          if(typeof options.showExport != "undefined"){
            options.showExport = !options.showExport;
            displayMain();
          }
          return;
        case "a":
          if(Graph.links.filter(checkSelectableLink).length){
            options.showArrows = !options.showArrows;
            if(options.heatmap){
              drawNet();
            }else{
              simulation.restart();
            }
            displaySidebar();
          }
          return;
        case "b":
          if(selectedNodesLength()) addNeighbors();
          return;
        case "c":
          resetPan();
          return;
        case "d":
          options.dynamicNodes = !options.dynamicNodes;
          stopResumeNet();
          return;
        case "e":
          if(selectedNodesLength()) switchEgoNet();
          return;
        case "f":
          if(selectedNodesLength()) filterSelection();
          return;
        case "g":
          if(options.heatmap){
            options.heatmapTriangle = !options.heatmapTriangle;
            drawNet();
            displaySidebar();
          }
          return;
        case "h":
          if(options.help){
            displayInfoPanel(options.help);
          }
          return;
        case "i":
          applyInitialFilter();
          return;
        case "l":
          if(!panel.select(".legend-panel > .legends").empty()){
            options.showLegend = !options.showLegend;
            showLegendFunction();
          }
          return;
        case "m":
          if(GraphLinksLength){
            options.heatmap = !options.heatmap;
            drawSVG();
            displaySidebar();
          }
          return;
        case "n": // warning: new window
          return;
        case "o":
          if(selectedNodesLength()) selectNodesFromTable();
          return;
        case "p":
          treeAction();
          return;
        case "r":
          showHidden();
          return;
        case "s":
          selectAllNodes();
          return;
        case "t": // warning: new tab
          return;
        case "x":
          if(d3.event.shiftKey){
            if(options.showExport){
              options.showExport = false;
            }
            if(options.showButtons2){
              options.showButtons2 = false;
            }
            if(options.showTables){
              options.showTables = false;
            }
            if(options.showSidebar){
              options.showSidebar = false;
            }
            displayMain();
            displayPanelButtons();
            displayBottomPanel();
            displaySidebar();
          }else{
            body.select("div.infopanel div.close-button").dispatch("click");
          }
          return;
        case "y":
          options.showAxes = !options.showAxes;
          showAxesFunction();
          displaySidebar();
          return;
      }
    }else{
      if(key == "Enter"){
        if(selectedNodesLength()) switchEgoNet();
        return;
      }
    }
  })

  if(options.note){
    var divNote = plot.append("div")
      .attr("class", "note")
      .append("div")
        .html(typeof options.note == "string" ? options.note : "")
        .on("click",function(){
          displayWindow().html(d3.select(this).html());
        });
  }

  var poweredby = plot.append("div")
      .attr("class", "poweredby")
  poweredby.append("img")
    .attr("width",20)
    .attr("height",15)
    .attr("src",b64Icons.netcoin)
  poweredby.append("span")
        .text(texts.poweredby+" ")
  poweredby.append("a")
    .attr("target","_blank")
    .attr("href","https://sociocav.usal.es/blog/nca/")
    .text("netCoin")

  selectLayout();
  adaptLayout();

  displayPanelButtons();
  displayBottomPanel();
  drawSVG();
  displaySidebar();
  applyInitialFilter();

  if(options.helpOn){
    displayInfoPanel(options.help);
  }

  function selectedNodesLength(){
    return Graph.nodes.filter(function(d){ return d.selected; }).length;
  }

  function checkGraphData(){

    simulation.force("link").id(function(d) { return d[options.nodeName]; });

    if(options.background){
      var s = new Option().style;
      s.background = options.background;
      if(s.background != ""){
        body.style("background",s.background);
        s.color = options.background;
        if(s.color!="")
          options.background = s.color;
        else
          delete options.background;
      }else
        delete options.background;
    }

    if(options.frames){
      if(options.frames.length>1 && Graph.linknames && Graph.linknames.indexOf("_frame_")!=-1){

        var speed = 50;
        if(options.hasOwnProperty("speed"))
          speed = options.speed;
        speed = speed/100 * (timeRange[1]-timeRange[0]) + timeRange[0];

        var frame = 0;
        if(options.frame && options.frame<options.frames.length)
          frame = options.frame;

        frameControls = {
          "play": true,
          "frame": frame,
          "frames": options.frames,
          "frameInterval": null,
          "time": speed,
          "loop": false
        };
      }
      ["zoom","repulsion","distance"].forEach(function(d){
        if(options.hasOwnProperty(d) && Array.isArray(options[d])){
          if(frameControls){
            frameControls[d] = options[d];
          }
          options[d] = options[d][0];
        }
      });
      delete options.frames;
    }

    var nodes = [],
        len = 0;

    len = Graph.nodes[0].length;
    for(var i = 0; i<len; i++){
      var node = {};
      Graph.nodenames.forEach(function(d,j){
        node[d] = Graph.nodes[j][i];
      })
      node.degree = 0;
      splitMultiVariable(node);
      node[options.nodeName] = String(node[options.nodeName]);
      nodes.push(node);
    }

    Graph.nodes = nodes;

    if(frameControls){
      Graph.nodes.forEach(function(node){
        if(node.hasOwnProperty("fx") && !Array.isArray(node.fx))
          node.fx = frameControls.frames.map(function(){ return node.fx; });
        if(node.hasOwnProperty("fy") && !Array.isArray(node.fy))
          node.fy = frameControls.frames.map(function(){ return node.fy; });
      })
      backupNodes = JSON.parse(JSON.stringify(Graph.nodes));
    }

    if(Graph.links){
      var links = [];

      len = Graph.links[0].length;
      for(var i = 0; i<len; i++){
        var link = {};
        Graph.linknames.forEach(function(d,j){
          link[d] = Graph.links[j][i];
        })
        splitMultiVariable(link);
        link.source = Graph.nodes[link.Source];
        link.Source = link.source[options.nodeName];
        link.target = Graph.nodes[link.Target];
        link.Target = link.target[options.nodeName];
        links.push(link);
      }

      Graph.links = links;
    }else{
      Graph.links = [];
      Graph.linknames = [];
    }

    GraphNodesLength = Graph.nodes.length;
    GraphLinksLength = Graph.links.length;

    if(GraphLinksLength){
      Graph.nodenames.push("degree");
    }

    loadTree();

    ["nodeText","nodeInfo"].forEach(function(d){
      if(options[d] && options[d]!=options.nodeName)
        hiddenFields.push(options[d]);
    });

    if(options.defaultColor)
      defaultColor = options.defaultColor;

    options.colorScalenodeColor = "RdWhGn"; // default linear scale for nodes
    options.colorScalelinkColor = "RdBkGn"; // default linear scale for links
    options.colorScalenodeGroup = "RdBkGn"; // default linear scale for groups

    if(options.nodeBipolar){
      switch(defaultColor) {
        case "black":
        case "#000":
        case "#000000":
          options.colorScalenodeColor = "RdWhBk";
          break;
        case "#2ca02c":
          options.colorScalenodeColor = "RdWhGn";
          break;
        default:
          colorScales['custom1'] = ["#d62728","#ffffff",defaultColor];
          colorScales['custom2'] = [defaultColor,"#ffffff","#d62728"];
          options.colorScalenodeColor = "custom1";
      }
    }else{
      switch(defaultColor) {
        case "black":
        case "#000":
        case "#000000":
          options.colorScalenodeColor = "WhBk";
          break;
        case "#1f77b4":
          options.colorScalenodeColor = "WhBu";
          break;
        case "#2ca02c":
          options.colorScalenodeColor = "WhGn";
          break;
        case "#d62728":
          options.colorScalenodeColor = "WhRd";
          break;
        default:
          colorScales['custom1'] = [defaultColor,,"#ffffff"];
          colorScales['custom2'] = ["#ffffff",defaultColor];
          options.colorScalenodeColor = "custom2";
      }
    }

    if(options.cex){
      body.style("font-size", 10*options.cex + "px")
      sidebarWidth = sidebarWidth * Math.sqrt(options.cex);
    }else{
      options.cex = 1;
    }

    if(!options.hasOwnProperty("zoom"))
      options.zoom = 1;

    if(!options.hasOwnProperty("repulsion"))
      options.repulsion = 25;

    if(!options.hasOwnProperty("distance"))
      options.distance = 10;

    if(options.imageNames){
      if(!Array.isArray(options.imageNames))
        options.imageNames = [options.imageNames];
    }else
      options.imageNames = [];
    if(options.imageItems){
      if(!Array.isArray(options.imageItems))
        options.imageItems = [options.imageItems];
      options.nodeImage = options.imageNames[0];
      images = {};
      Graph.nodes.forEach(function(node){
        options.imageItems.forEach(function(col){
          var img = new Image();
          img.src = node[col];
          images[node[col]] = img;
        })
      })
    }else
      options.imageItems = [];

    options.imageItems.forEach(function(d){
      hiddenFields.push(d);
    })

    options.showSidebar = showControls(1);
    options.showButtons2 = showControls(2);
    options.showTables = showControls(3);
    options.showExport = showControls(4);

    if(Array.isArray(options.axesLabels)){
      if(options.axesLabels.length>4)
        options.axesLabels.length = 4;
    }else{
      if(options.axesLabels)
        options.axesLabels = [options.axesLabels];
      else
        options.axesLabels = [];
    }

    options.heatmap = false;
    options.heatmapTriangle = false;
    if(GraphLinksLength){
      if(options.mode && (options.mode=="h" || options.mode[0]=="h")){
        options.heatmap = true;
      }
    }else{
      delete options.mode;
    }

    function splitMultiVariable(d){
      for(var p in d) {
        if(p!=options.nodeName){
          if(typeof d[p] == "string" && d[p].indexOf("|")!=-1){
            var aux = d[p].split("|");
            if(!frameControls || aux.length==frameControls.frames.length){
              d[p] = aux.map(function(d){ return d=="" ? null : (isNaN(parseInt(d)) ? d : +d); });
            }
          }
        }
      }
    }

    function showControls(n){
      if(options.hasOwnProperty("controls")){
        if(options.controls===0)
          return undefined;
        if(options.controls==-n)
          return undefined;
        if(options.controls==n)
          return true;
        if(Array.isArray(options.controls)){
          if(options.controls.indexOf(-n)!=-1)
            return undefined;
          if(options.controls.indexOf(n)!=-1)
            return true;
        }
      }
      return false;
    }
  } // end of checkGraphData

  function loadFrameData(frame){
    for(var i=0; i<Graph.nodes.length; i++){
      Graph.nodenames.forEach(function(col){
        if(Array.isArray(backupNodes[i][col]))
          Graph.nodes[i][col] = backupNodes[i][col][frame];
      })
    }
    loadTree(frameControls.frame);
  }

  function loadTree(frame){
      if(!Graph.tree)
        return;
      if(frameControls && frame===undefined)
        return;

      Graph.nodes.forEach(function(node){
        node.childNodes = [];
        node.parentNode = false;
      })
      var len = Graph.tree[0].length;
      for(var i = 0; i<len; i++){
        if(frame===undefined || frame==Graph.tree[2][i]){
          var source = Graph.tree[0][i],
              target = Graph.tree[1][i];
          Graph.nodes[source].childNodes.push(Graph.nodes[target]);
          Graph.nodes[target].parentNode = Graph.nodes[source];
        }
      }
  }

function displayMain(){
  main.selectAll("*").remove();
  if(options.main || typeof multiGraph != 'undefined' || options.showExport){
    main.style("display",null);
    if(options.main){
      main.append("span").attr("class", "title").html(typeof options.main == "string" ? options.main : options.main[0]);
    }else{
      main.append("span").attr("class", "title").html("&nbsp;")
    }
    if(options.main && typeof multiGraph != 'undefined'){
      main.append("span").attr("class","separator").text("/");
    }
    if(typeof multiGraph != 'undefined'){
      multiGraph.graphSelect(main.append("span"));
    }
    if(options.help){
        main.call(iconButton()
        .alt("help")
        .width(24)
        .height(24)
        .src(b64Icons.help)
        .title(texts.showHelp+" (ctrl+h)")
        .job(function(){ displayInfoPanel(options.help); }));
    }
    if(options.showExport){
      main.call(iconButton()
        .alt("pdf")
        .width(24)
        .height(24)
        .src(b64Icons.pdf)
        .title(texts.pdfexport)
        .job(function(){ embedImages(svg2pdf); }));

      main.call(iconButton()
        .alt("png")
        .width(24)
        .height(24)
        .src(b64Icons.png)
        .title(texts.pngexport)
        .job(function(){
          if(options.heatmap){
            svg2png(getFile);
          }else{
            plot.select("canvas").node().toBlob(getFile)
          }

          function getFile(blob){
            fileDownload(blob, d3.select("head>title").text()+'.png');
          }
        }));
    }
    if(options.frequencies){
      main.call(iconButton()
        .alt("freq")
        .width(24)
        .height(24)
        .src(b64Icons.chart)
        .title("frequencies")
        .job(displayFreqBars));
    }
  }else{
    main.style("display","none")
  }

  height = computeHeight();
}


function displayPanelButtons(){
  panel.select("div.panel-buttons").remove();
  if(options.showButtons2){
    var buttonsSelect = panel.append("div")
        .attr("class","panel-buttons");
    displayButton(buttonsSelect,"selectall",selectAllNodes,"ctrl + s",true,"primary");
    displayButton(buttonsSelect,"selectneighbors",addNeighbors,"ctrl + b",false,"primary");
    displayButton(buttonsSelect,"filter",switchEgoNet,texts.filterInfo+" (ctrl + e)",false,"primary");
    displayButton(buttonsSelect,"isolate",filterSelection,texts.isolateInfo+" (ctrl + f)",false,"primary");
    if(Graph.tree){
      displayButton(buttonsSelect,"expand",treeActionExpand,"ctrl + p",false,"primary");
      displayButton(buttonsSelect,"collapse",treeActionCollapse,"ctrl + p",false,"primary");
    }
    displayButton(buttonsSelect,"resetfilter",showHidden,"ctrl + r",false,"primary-outline clear");

    buttonsSelect.style("left",width-buttonsSelect.node().offsetWidth-poweredby.node().offsetWidth+"px")
    showTables();
  }
}

function displayBottomPanel(){

  body.select("div.panel-dragbar").remove();
  body.select("div.tables").remove();
  panel.select("div.switchNodeLink").remove();

  if(!plot.selectAll("svg, canvas").empty()){
    height = computeHeight();
    drawSVG();
  }

  if(options.showTables){

    // panel dragbar
    var dragbar = body.append("div")
      .attr("class","panel-dragbar")

    var dragOffset;

    dragbar.call(d3.drag()
      .on("start", function() {
        body.style("cursor","row-resize");
        plot.select("canvas").remove();
        plot.select("svg").remove();
        dragOffset = d3.mouse(body.node())[1]-height;
      })
      .on("drag", function() {
        var value = d3.mouse(body.node())[1];
        if(value > 200){
          height = value-dragOffset;
          plot.style("height",height+"px");
        }
      })
      .on("end", function() {
        body.style("cursor",null);
        drawSVG();
      })
    );

    // tables
    var tables = body.append("div")
      .attr("class", "tables")

    tables.style("min-height","150px");
    panel.append("div")
      .attr("class","switchNodeLink")
      .selectAll("div")
        .data(GraphLinksLength ? ["nodes","links"] : ["nodes"])
        .enter().append("div")
          .on("click",function(d){
              panel.selectAll("div.switchNodeLink > div")
                .classed("active",false)
              d3.select(this)
                .classed("active",true)
              tables.selectAll("div.nodes, div.links").style("display","none");
              tables.select(".tables > div."+d).style("display",null);
              tables.select("div.table-title."+d).style("display",null);
          })
          .append("h3")
            .text(function(d){ return texts[d]; })
    panel.select("div.switchNodeLink > div")
      .classed("active",true)

    if(options.scenarios){
      tables.append("h3").text(texts.scenarios + ": " + options.scenarios);
    }

    var tableHeader = tables.append("div")
      .attr("class","table-header")

    tableHeader.append("div")
      .attr("class","table-title nodes")
    tableHeader.append("div")
      .attr("class","table-title links").style("display","none");
    tableHeader.call(iconButton()
        .alt("xlsx")
        .width(14)
        .height(14)
        .src(b64Icons.xlsx)
        .title(texts.downloadtable)
        .job(tables2xlsx))
      .select("img")
        .style("float","none")
        .style("margin-right","24px")
        .style("margin-bottom","-2px")

    tableHeader.append("input")
      .attr("type", "text")
      .attr("placeholder",texts.searchanode)
      .on("keyup",function(){
        var txt = d3.select(this).property("value");
        if(txt.length>1){
          txt = new RegExp(txt,'i');
          Graph.nodes.forEach(function(node){
            node.selected = false;
            if(checkSelectable(node)){
              var i = 0;
              while(!node.selected && i<Graph.nodenames.length){
                if(String(node[Graph.nodenames[i++]]).match(txt))
                  node.selected = true;
              }
            }
          });
          showTables();
        }
      })

    displayButton(tableHeader,"tableselection",selectNodesFromTable,"ctrl + o",false,"primary");

    tables.append("div").attr("class","nodes");
    tables.append("div").attr("class","links").style("display","none");
    showTables();
  }

  if(options.showSidebar){
    sidebar.select(".nav li.active").dispatch("click");
  }

  if(!panel.select(".showHideTable").empty()){
    panel.select(".showHideTable").classed("showing",options.showTables);
  }

  height = computeHeight();
}

function displayButton(sel,txt,clk,tooltip,enable,classes){
          sel.append("button")
            .attr("class",classes+" "+txt+(enable?"":" disabled"))
            .text(texts[txt])
            .on("click",clk)
            .attr("title",tooltip)
}

function displaySidebar(){

  if(sidebar.select(".subSearch").empty()){

    sidebar.append("div")
      .attr("class","subSearch")
      .call(displayMultiSearch()
        .data(Graph.nodes)
        .column(options.nodeLabel ? options.nodeLabel : options.nodeName)
        .update(showTables)
        .update2(switchEgoNet)
        .filterData(checkSelectable));

  }else{
    sidebar.selectAll("div.sidebar>div:not(.subSearch)").remove();
  }

  if(options.showSidebar){
    showSidebar();
  }else if(typeof options.showSidebar!="undefined"){
    displayShowPanelButton(sidebar,function(){
          options.showSidebar = true;
          displaySidebar();
    });
  }

  function showSidebar(){
    var divControl, visData;

    var subSidebar = sidebar.append("div")
      .attr("class","subSidebar")

    subSidebar.append("div")
      .attr("class","highlight-header")
      .text(texts.tools)
      .append("div")
        .attr("class","close-button")
        .on("click",function(){
          options.showSidebar = false;
          displaySidebar();
        })

    var nav = subSidebar.append("div")
      .attr("class","nav")

    var navs = nav.append("ul");

    navs.append("li").text(texts.graph).on("click",function(){
      navClick(this,"graph");
    }).classed("active",true);
    navs.append("li").text(texts.nodes).on("click",function(){
      navClick(this,"nodes");
    })
    if(GraphLinksLength){
      navs.append("li").text(texts.links).on("click",function(){
        navClick(this,"links");
      })
    }

    function navClick(thiz,tab){
      subSidebar.selectAll(".tab").style("display",null);
      subSidebar.select(".tab."+tab).style("display","block");
      nav.selectAll("li").classed("active",false);
      d3.select(thiz).classed("active",true);
      updateSidebarFilters(true);
      subSidebarHeight(subSidebar.select(".tab."+tab));
    }

    // sidebar graph
    var sideGraph = subSidebar.append("div")
      .attr("class","tab graph")
      .style("display","block")

    SVGcontrols(sideGraph);
    displayFrameControls(sideGraph);
    
    // sidebar nodes
    var sideNodes = subSidebar.append("div")
      .attr("class","tab nodes")

    if(options.heatmap){
      visData = ["Label","Color","Shape","Legend","OrderA","OrderD"];
    }else{
      visData = ["Label","Size","LabelSize","Color","Shape","Image","Legend","Group"];
    }
    divControl = sideNodes.append("div")
      .attr("class", "nodeAuto")

    Controllers.nodeVisual = addVisualController()
      .item("nodes")
      .visual(visData);
    divControl.call(Controllers.nodeVisual); // nodes visualization

    divControl = sideNodes.append("div")
      .attr("class","nodeFilter");

    Controllers.nodeFilter = addFilterController()
      .item("nodes")
    divControl.call(Controllers.nodeFilter); // nodes filter

    // sidebar links
    var sideLinks = subSidebar.append("div")
      .attr("class", "tab links")

    if(options.heatmap){
      visData = ["Intensity","Color","Text"];
    }else{
      visData = ["Width","Weight","Color","Text"];
    }
    divControl = sideLinks.append("div")
      .attr("class", "linkAuto");

    Controllers.linkVisual = addVisualController()
      .item("links")
      .visual(visData);
    divControl.call(Controllers.linkVisual); // links visualization

    divControl = sideLinks.append("div")
      .attr("class","linkFilter");

    Controllers.linkFilter = addFilterController()
      .item("links")
    divControl.call(Controllers.linkFilter); // links filter

    subSidebarHeight(sideGraph);

showTables();

    function subSidebarHeight(tab){
      subSidebar.selectAll(".tab").style("height",null);
      var maxHeight = height
      - sidebar.select(".sidebar > .subSearch").node().offsetHeight
      - nav.node().offsetHeight
      - 60;
      if(options.note){
        maxHeight = maxHeight - 24;
      }
      if(!panel.select(".switchNodeLink").empty()){
        maxHeight = maxHeight - panel.select(".switchNodeLink > div").node().offsetHeight;
      }else{
        maxHeight = maxHeight - 24;
      }
      if(parseInt(tab.node().offsetHeight)>maxHeight){
        tab.style("height",maxHeight+"px");
      }
    }

    function SVGcontrols(sel){
      var dynamicNodes = {txt: texts.stopresume, key: "dynamicNodes", tooltip: "ctrl + d", callback: stopResumeNet},
          showArrows = {txt: texts.directional, key: "showArrows", tooltip: "ctrl + a", callback: function(){
          if(options.heatmap){
            drawNet();
          }else{
            simulation.restart();
          }
        }},
          showAxes = {txt: texts.showhideaxes, key: "showAxes", tooltip: "ctrl + x", callback: showAxesFunction},
          heatmap = {txt: texts.heatmap, key: "heatmap", tooltip: "ctrl + m", callback: function(){
          drawSVG();
          displaySidebar();
        }},
          heatmapTriangle = {txt : texts.trianglesquare, key: "heatmapTriangle", tooltip: "ctrl + g", callback: drawNet};

      var sliders = sel.append("div")
        .attr("class","sliders")

      if(!options.heatmap && options.dynamicNodes){
        if(Graph.links.filter(checkSelectableLink).length){
          sliders.call(Sliders.distance);
          Sliders.distance.update(options['linkDistance']);
        }

        sliders.call(Sliders.repulsion);
        Sliders.repulsion.update(options['charge']);
      }

      sliders.call(Sliders.zoom);
      Sliders.zoom.update(options.zoomScale);

      if(frameControls){
        sliders.call(Sliders.frame);
        Sliders.frame.update(frameControls.frame);

        sliders.call(Sliders.time);
        Sliders.time.update(frameControls.time);
      }

      displayLayoutSelection(sideGraph);

      var secondColW = sidebarWidth/2 - 20,
          divButtons = sel.append("div")
            .attr("class","buttons")

      var checkContainer = divButtons.append("div")
        .style("display","inline-block")
        .style("padding-left","5px")
        .style("width",secondColW+"px")

      if(!options.heatmap && !options.fixed && !options.constructural){
        checkContainer.datum(dynamicNodes)
        var checkbox = checkContainer.append("div")
          .attr("class","legend-check-box dynamicNodes")
          .classed("checked",function(d){ return options[d.key]; });
        checkContainer
          .style("cursor","pointer")
          .on("click",function(d){
            options[d.key] = !options[d.key];
            checkbox.classed("checked",options[d.key]);
            d.callback();
          })
          .append("span")
            .style("margin-left","5px")
            .text(function(d){ return d.txt; })
      }

      divButtons.append("button")
        .attr("class","primary reset")
        .text(texts.reset)
        .on("click",function(){
          location.reload();
        })
        .append("title")
          .text("F5")

      var countY = 16,
          svg = divButtons.append("svg")
        .attr("width",sidebarWidth-24)
        .attr("height",countY)

      var buttons = svg.append("g")
        .attr("class","buttons")
        .attr("transform","translate(5,0)")

      if(Array.isArray(options.mode)){
        buttons.append("g")
      .attr("class",function(d){ return "button heatmap"; })
      .attr("transform","translate("+secondColW+","+countY*options.cex+")")
      .datum(heatmap)
      }

      if(GraphLinksLength){
        buttons.append("g")
        .attr("class",function(d){ return "button showArrows"; })
        .classed("disabled",!Graph.links.filter(checkSelectableLink).length)
        .attr("transform","translate(0,"+countY*options.cex+")")
        .datum(showArrows)

        countY = countY+30;
      }

      if(options.heatmap){
        buttons.append("g")
      .attr("class",function(d){ return "button heatmapTriangle"; })
      .attr("transform","translate(0,"+countY*options.cex+")")
      .datum(heatmapTriangle)
      }else{
        buttons.append("g")
      .attr("class",function(d){ return "button showAxes"; })
      .attr("transform","translate(0,"+countY*options.cex+")")
      .datum(showAxes)
      }

      buttons.selectAll(".button").each(function(d){

        var self = d3.select(this);

        self.append("rect")
      .attr("x",0)
      .attr("y",5*(options.cex-1))
      .attr("rx",5)
      .attr("ry",5)
      .attr("width",20)
      .attr("height",10)
      .on("click",function(){
        options[d.key] = !options[d.key];
        activeButton(250);
        d.callback();
      }).append("title")
        .text(function(d){
          return d.tooltip;
        })

        self.append("circle")
      .attr("cx",5)
      .attr("cy",5*(options.cex-1)+5)
      .attr("r",5)

        self.append("text")
        .attr("x",30)
        .attr("y",9*options.cex)
        .text(d.txt);

        activeButton(0);

        function activeButton(time){
          var circle = self.select("circle");
          if(time){
            circle = circle.transition()
            .duration(time)
            .on("end",function(){
              self.classed("off",!options[d.key])
            });
          }else{
            self.classed("off",!options[d.key])
          }
          circle.attr("cx",options[d.key] ? 15 : 5);
        }

      })

      svg.attr("height",countY*options.cex+parseInt(svg.attr("height")))
    }

    function displayLayoutSelection(sel){
      if(options.dynamicNodes || !Graph.layouts || Graph.layouts.length<=1 || options.heatmap){
        return;
      }

      var div = sel.append("div")
        .attr("class", "layouts")

      div.append("div")
        .style("display","inline-block")
        .style("width","40%")
        .append("span")
          .text(texts.Layout+" ")
          .append("img")
            .attr("width","12")
            .attr("height","12")
            .attr("src",b64Icons.help)
            .attr("title",texts.LayoutInfo);

      div.append("div")
        .style("display","inline-block")
        .style("width","60%")
        .attr("class","select-wrapper")
        .append("select")
        .on("change",function(){
          selectLayout(this.value);
          delete options.dynamicNodes;
          adaptLayout();
          simulation.restart();
        })
        .selectAll("option")
          .data(d3.keys(Graph.layouts))
        .enter().append("option")
          .property("value",String)
          .text(String)
    }

    function displayFrameControls(sel){
      if(!frameControls){
        return;
      }

      var divFrameCtrl = sel.append("div")
        .attr("class", "divFrameCtrl")

      divFrameCtrl.append("div")
        .attr("class","select-wrapper")
      .append("select")
      .attr("class","selectFrame")
      .on("change",function(){
        frameControls.play = false;
        handleFrames(+(this.value));
        clickFrameCtrlBtn();
      })
      .selectAll("option")
        .data(frameControls.frames)
      .enter().append("option")
        .property("value",function(d,i){ return i; })
        .text(function(d,i){
          if(Array.isArray(options.main))
            return options.main[i];
          else
            return d;
        })

      var frameButons = divFrameCtrl.append("div")
        .attr("class","frame-buttons")

      frameButons.append("button") // prev
      .call(getSVG().d(d4paths.prev))
      .on("click",function(){
        var val = frameControls.frame-1;
        if(val < 0)
          val = frameControls.frames.length+val;
        frameControls.play = false;
        handleFrames(val);
        clickFrameCtrlBtn();
      })
      frameButons.append("button") // loop
      .call(getSVG().d(d4paths.loop))
      .on("click",function(){
        frameControls.loop = !frameControls.loop;
        d3.select(this).style("background-color",frameControls.loop?darkGrey:null)
          .selectAll("path").style("fill",frameControls.loop?lightGrey:null);
      })
      var stopRecord = function(){
          frameControls.recorder.stop();
          frameControls.recorder.save(Math.round((new Date()).getTime() / 1000)+'record.webm');
          delete frameControls.recorder;
          divFrameCtrl.select("button.rec").style("background-color",null)
            .select("path").style("fill",null);
      }
      frameButons.append("button") // rec
      .attr("class","rec")
      .call(getSVG().d(d4paths.rec))
      .on("click",function(){
        if(options.heatmap){
          displayWindow()
            .append("p")
              .attr("class","window-message")
              .text(texts.alertrecordheatmap);
        }else{
          if(frameControls.recorder){
            stopRecord();
          }else{
            frameControls.recorder = new CanvasRecorder(d3.select("div.plot > canvas").node());
            simulation.restart();
            if(frameControls.recorder.start && frameControls.recorder.start()){
              d3.select(this).style("background-color",darkGrey)
                .select("path").style("fill","Red");
            }else{
              delete frameControls.recorder;
            }
          }
        }
      }).style("background-color", frameControls.recorder ? darkGrey : null)
      .select("path").style("fill", frameControls.recorder ? "#d62728" : null);
      frameButons.append("button") // stop
      .call(getSVG().d(d4paths.stop))
      .on("click",function(){
        frameControls.play = false;
        handleFrames(0);
        if(frameControls.recorder){
          stopRecord();
        }
        clickFrameCtrlBtn();
      })
      frameButons.append("button") // pause
      .attr("class","pause")
      .call(getSVG().d(d4paths.pause))
      .on("click",function(){
        frameControls.play = false;
        clearInterval(frameControls.frameInterval);
        clickFrameCtrlBtn();
      })
      frameButons.append("button") // play
      .attr("class","play")
      .call(getSVG().d(d4paths.play))
      .on("click",function(){
        frameControls.play = true;
        handleFrames(frameControls.frame+1);
        clickFrameCtrlBtn();
      })
      frameButons.append("button") // next
      .call(getSVG().d(d4paths.next))
      .on("click",function(){
        frameControls.play = false;
        handleFrames(frameControls.frame+1);
        clickFrameCtrlBtn();
      })

      clickFrameCtrlBtn();
    }
  }
} // end display sidebar function

// sidebar controller for visual aspects
function addVisualController(){
  var items,
      item,
      data,
      visData,
      attrData,
      onlyNumeric = ["Size","LabelSize","Width","Weight","Intensity"];

  function exports(sel){
    var sels = sel.selectAll("visSel")
        .data(visData)
      .enter().append("div")
        .attr("class","visSel")
        .property("value",String)

    sels.append("div")
      .append("span")
          .text(function(d){ return texts[d]+" "; })
          .append("img")
            .attr("width","12")
            .attr("height","12")
            .attr("src",b64Icons.help)
            .attr("title",function(d){ return texts[d+"Info"]; });

    sels.each(function(visual){
      var tmpData = attrData.filter(function(d){
          var t = dataType(data,d,true);
          if((onlyNumeric.indexOf(visual)!=-1 && t!="number") || (visual=="Image" && options.imageNames.indexOf(d)==-1)){
            return false;
          }
          return true;
        });
      tmpData.unshift("-"+texts.none+"-");

      d3.select(this).append("div")
        .attr("class","select-wrapper")
        .append("select")
      .on("change", function(){
        var attr = this.value;
        applyAuto(item+visual,attr);
        if((visual=="Color"|| visual=="Group") && dataType(data,attr) == "number"){
          displayPicker(options,item+visual,function(){
            delete VisualHandlers[item+visual];
            drawNet();
          });
        }
      })
      .selectAll("option")
        .data(tmpData)
      .enter().append("option")
        .property("selected",function(d){
          if(options[item+visual]==d)
            return true;
          else
            return null;
        })
        .property("value",String)
        .text(String)
    })

    sel.append("div").attr("class","clear")
  }

  exports.item = function(x) {
      if (!arguments.length) return items;
      items = x;
      data = Graph[items];
      item = items.slice(0, 4);
      attrData = Graph[item+"names"].filter(function(d){ return hiddenFields.indexOf(d)==-1; });
      return exports;
  };

  exports.visual = function(x) {
      if (!arguments.length) return visData;
      visData = x;
      return exports;
  };

  return exports;
} // end of Visual Controller

function applyAuto(key, attr){
    if(attr=="-"+texts.none+"-"){
      delete options[key];
    }else{
      options[key] = attr;
    }
    if(key == "nodeOrderA"){
        delete options.nodeOrderD;
    }
    if(key == "nodeOrderD"){
        delete options.nodeOrderA;
    }
    if(VisualHandlers.hasOwnProperty(key)){
      delete VisualHandlers[key];
    }
    drawNet();
}

// sidebar controller for filters and selections
function addFilterController(){
  var items,
      item,
      attrData = [],
      itemFilter,
      attrSelect,
      valSelector,
      slider;

  function exports(sel){

    itemFilter = sel.append("div")
        .attr("class","filter-controls")

    itemFilter.append("h4")
      .text(texts.filter)

    attrSelect = itemFilter.append("div")
        .attr("class","select-wrapper")
      .append("select")
      .attr("class","attrSel");

    attrSelect.selectAll("option")
      .data(attrData)
      .enter().append("option")
        .property("value",String)
        .text(String)

    attrSelect.on("change", function() { 
      changeAttrSel(this.value);
    })

    valSelector = itemFilter.append("div")
      .attr("class","valSel")
      .style("margin-bottom",0);

    if(items=="nodes"){
        itemFilter.append("button")
        .attr("class","primary")
        .text(texts.filter)
        .attr("title",texts.filterInfo+" (ctrl + e)")
        .on("click",function(){
          applyValueSelection();
          switchEgoNet();
        });

      itemFilter.append("button")
        .attr("class","primary")
        .text(texts.isolate)
        .attr("title",texts.isolateInfo+" (ctrl + f)")
        .on("click",function(){
          applyValueSelection();
          filterSelection();
        })
    }else{
      itemFilter.append("button")
        .attr("class","primary")
        .text(texts.filter)
        .on("click",function(){
          applyValueSelection();
          filterSelection();
        })
    }

    itemFilter.append("button")
      .attr("class","primary-outline clear")
      .text(texts.clear)
      .on("click", function(){
        Graph.nodes.forEach(function(d){
          delete d.selected;
        });
        updateSidebarFilters(true);
        applyInitialFilter();
      })
  }

  function applyValueSelection(){
    if(!slider){
      valSelector.select("select").dispatch("change");
    }else{
      slider.dispatch();
    }
  }

  function changeAttrSel(val){
      valSelector.selectAll("*").remove();
      slider = false;
      var tmpData = items=="nodes" ? Graph.nodes.filter(checkSelectable) : Graph.links.filter(checkSelectableLink);
      var type = dataType(tmpData,val);
      if(type == 'number'){
        var extent = d3.extent(tmpData, function(d){ return d[val]; }),
            mid = (extent[0]+extent[1])/2;
            baseWidth = parseInt(valSelector.style("width"));
        slider = brushSlider()
          .domain(extent)
          .current([mid,mid])
          .callback(function(s){
            Graph.nodes.forEach(function(d){
              delete d.selected;
              if(items=="nodes" && checkSelectable(d) && (d[val]>=s[0] && d[val]<=s[1])){
                d.selected = true;
              }
            });
            if(items=="links"){
              tmpData.forEach(function(d){
                if(d[val]>=s[0] && d[val]<=s[1]){
                  d.source.selected = d.target.selected = true;
                }
              });
            }
            showTables();
          })
          .baseWidth(baseWidth);
        valSelector.call(slider);
      }else{
        var dat = tmpData.map(function(d){ return d[val]; });
        if(type != 'string')
          dat = dat.reduce(function(a,b) { return b ? a.concat(b) : a; }, []);
        valSelector.style("height",null);
        valSelector.append("select")
          .attr("multiple","multiple")
          .attr("size",8)
          .on("change",function(){
            var values = [];
            d3.select(this).selectAll("option")
              .filter(function(){ return this.selected; })
              .each(function(){
                values.push(this.value);
              })
            Graph.nodes.forEach(function(d){
              delete d.selected;
              if(items=="nodes" && checkSelectable(d)){
                if(typeof d[val] == "object"){
                  if(intersection(values,d[val]).length){
                    d.selected = true;
                  }
                }else{
                  if(values.indexOf(String(d[val]))!=-1){
                    d.selected = true;
                  }
                }
              }
            });
            if(items=="links"){
              tmpData.forEach(function(d){
                if(values.indexOf(String(d[val]))!=-1){
                  d.source.selected = d.target.selected = true;
                }
              });
            }
            showTables();
          })
          .selectAll("option")
        .data(d3.set(dat).values().sort())
          .enter().append("option")
          .property("value",function(d){ return d.replace(/\'/g, "\\'"); })
          .text(stripTags)
          .each(function(d){
            this.selected = true;
            for(var i=0; i<tmpData.length; i++){
              if(items=="nodes"){
                if(!tmpData[i].selected){
                  if(typeof tmpData[i][val] == "object"){
                    if(tmpData[i][val].indexOf(d)!=-1){
                      this.selected = false;
                    }
                  }else{
                    if(String(tmpData[i][val])==d){
                      this.selected = false;
                    }
                  }
                }
              }else{
                if(!(tmpData[i].source.selected && tmpData[i].target.selected) && String(tmpData[i][val])==d){
                  this.selected = false;
                }
              }
              if(!this.selected){
                break;
              }
            }
          })
      }
  }

  exports.update = function(onlyslider){
    if(onlyslider ^ !slider){
      attrSelect.dispatch("change");
    }
  }

  exports.item = function(x) {
      if (!arguments.length) return items;
      items = x;
      item = items.slice(0, 4);
      attrData = Graph[item+"names"].filter(function(d){ return hiddenFields.indexOf(d)==-1; });
      return exports;
  };

  return exports;
} // end of Filter Controller

function updateSidebarFilters(onlyslider){
  if(Controllers.nodeFilter){
    Controllers.nodeFilter.update(onlyslider);
  }
  if(Controllers.linkFilter){
    Controllers.linkFilter.update(onlyslider);
  }
}

function displayShowPanelButton(sel,callback){
    var showPanelButton = sel.append("div")
      .attr("class","show-panel-button")
      .on("click",callback)
    showPanelButton.append("span");
    showPanelButton.append("span");
    showPanelButton.append("span");
}

function applyInitialFilter(){
    showHidden();
    Graph.nodes.forEach(function(d){
      if(d.hidden){
        d._hidden = true;
        delete d.selected;
      }
    });
    Graph.links.forEach(function(d){
      if(d.hidden){
        d._hidden = true;
      }
    });
    drawNet();
}

function checkInitialFilters(){
  for(var i = 0; i<Graph.nodes.length; i++){
    if((Graph.nodes[i].hidden ? 1 : 0) != (Graph.nodes[i]._hidden ? 1 : 0)){
      return false;
    }
  }
  return true;
}

// draw canvas and svg environment for plot
function drawSVG(){

  legendPanel.style("left",(width - sidebarWidth + 10) + "px")

  adaptLayout();

  plot.select("canvas").remove();
  plot.select("svg").remove();

  var size = Math.min(width,height);

  simulation
      .force("x", d3.forceX().strength(0.1))
      .force("y", d3.forceY().strength(0.1))

  body
    .on("keydown.viewbrush", keyflip)
    .on("keyup.viewbrush", keyflip)
  
  var svg = plot.insert("svg",":first-child")
      .attr("xmlns","http://www.w3.org/2000/svg")
      .attr("width", width)
      .attr("height", height)
    .style("position","absolute")
    .style("top",0)
    .style("left",0)

  var canvas = plot.insert("canvas",":first-child")
    .attr("width", width)
    .attr("height", height)

  var defs = svg.append("defs");
  d3.keys(colorScales).forEach(function(d){ addGradient(defs,d,colorScales[d]); });

  defs.append("clipPath")
    .attr("id","heatmapClip")
    .append("rect")
      .attr("x",-height)
      .attr("y",-height/2 - 10)
      .attr("width",height*2)
      .attr("height",height)

  var rect = svg.append("rect")
    .attr("x", 0)
    .attr("y", 0)
    .attr("width", width)
    .attr("height", height)
    .attr("pointer-events","all")
    .style("fill","none")
    .on("click",clickNet)
    .on("mousemove",hoverNet)

  if(!options.fixed){
    rect.on("mousedown.grabbing",function(){
          d3.select(this).style("cursor","grabbing");
        })
        .on("mouseup.grabbing",function(){
          d3.select(this).style("cursor","grab");
        })
    rect.call(d3.drag()
          .subject(dragsubject)
          .on("start", dragstarted)
          .on("drag", options.constructural ? dragged_constructural : dragged)
          .on("end", dragended))
  }

  rect.call(zoom)
    .on("dblclick.zoom",dblClickNet)

  if(typeof options.zoomScale != "undefined"){
    rect.call(zoom.transform,transform);
  }

  if(!options.heatmap && options.showCoordinates){
      var range = getLayoutRange();

      var xAxisScale = d3.scaleLinear()
        .range(range.x)
        .domain([scaleCoorX.invert(range.x[0]),scaleCoorX.invert(range.x[1])]);

      var yAxisScale = d3.scaleLinear()
        .range(range.y)
        .domain([scaleCoorY.invert(range.y[0]),scaleCoorY.invert(range.y[1])]);

      var gxaxis = svg.append("g")
        .attr("class", "x axis")
        .style("opacity",options.showAxes?1:0)
        .attr("transform", "translate(0," + (range.y[1]) + ")")

      if(options.axesLabels.length>0){
        svg.append("text")
          .attr("class","axisLabel")
          .style("opacity",options.showAxes?1:0)
          .attr("x", range.x[1])
          .attr("y", range.y[1]-4)
          .style("text-anchor", "end")
          .text(options.axesLabels[0]);
      }

      var xAxis = d3.axisBottom();

      var gyaxis = svg.append("g")
        .attr("class", "y axis")
        .style("opacity",options.showAxes?1:0)
        .attr("transform", "translate(" + (range.x[0]) + ",0)")

      if(options.axesLabels.length>1){
        svg.append("text")
          .attr("class","axisLabel")
          .style("opacity",options.showAxes?1:0)
          .attr("transform", "rotate(-90)")
          .attr("x", -range.y[0])
          .attr("y", range.x[0]+(10*options.cex))
          .style("text-anchor", "end")
          .text(options.axesLabels[1]);
      }

      var yAxis = d3.axisLeft();
  }

  var net = svg.append("g")
    .attr("class","net")

  var brush = d3.brush()
      .keyModifiers(false)
      .filter(function(){
        return !d3.event.button && d3.event.shiftKey;
      })
      .extent( [ [0,0], [width,height] ] )
        .on("start", function() {
          brushg.selectAll('.selection').style("display",null);
        })
        .on("end", function() {
          d3.selectAll(".legend > g > text").style("stroke",function(){
            delete this.parentNode.selected;
            return null;
          });
          var extent = d3.event.selection;
          if(extent){
            extent[0][0] = transform.invertX(extent[0][0]);
            extent[0][1] = transform.invertY(extent[0][1]);
            extent[1][0] = transform.invertX(extent[1][0]);
            extent[1][1] = transform.invertY(extent[1][1]);
            Graph.nodes.forEach(function(node) {
              node.selected = checkSelectable(node) && (node.selected ^ (extent[0][0] <= node.x && node.x < extent[1][0] && extent[0][1] <= node.y && node.y < extent[1][1]));
            });
          }
          showTables();
          brushg.selectAll('.selection').style("display","none");
        });

  var brushg = svg.append("g")
    .attr("class","brush")
    .call(brush)

  brushg.selectAll('.handle').remove();

  brushg.style("display","none")
     .on("click",applyInitialFilter);

  chargeRange = [0,-(size*2)];
  linkDistanceRange = [0,size*3/4];

  if(!options.hasOwnProperty("charge"))
      options.charge = chargeRange[1] * (options.repulsion/100);
  if(!options.hasOwnProperty("linkDistance"))
      options.linkDistance = linkDistanceRange[1] * (options.distance/100);

  Sliders.zoom = displaySlider()
      .domain(zoomRange)
      .text("Zoom")
      .prop('zoomScale')
      .callback(function(value){
          options.zoomScale = value;
          transform.k = options.zoomScale;
          net.attr("transform", transform);
          if(!options.heatmap){
            if(gxaxis){
              gxaxis.call(xAxis.scale(transform.rescaleX(xAxisScale)));
            }
            if(gyaxis){
              gyaxis.call(yAxis.scale(transform.rescaleY(yAxisScale)));
            }
            simulation.restart();
          }
      });

  resetZoom();

  if(frameControls){
      Sliders.frame = displaySlider()
      .domain([0,frameControls.frames.length-1])
      .domain2([1,frameControls.frames.length])
      .rounded(true)
      .text("Frame")
      .prop('frames')
      .callback(frameStep);

      Sliders.time = displaySlider()
      .domain(timeRange)
      .domain2([0,100])
      .text(texts.speed)
      .prop('time')
      .callback(function(value){
        frameControls.time = value;
        if(frameControls.play)
          handleFrames(frameControls.frame);
      });
  }

  Sliders.distance = displaySlider()
      .domain(linkDistanceRange)
      .domain2([0,100])
      .text(texts.distance)
      .prop('linkDistance')
      .callback(function(value){
        options['linkDistance'] = value;
        update_forces();
      })

  Sliders.repulsion = displaySlider()
      .domain(chargeRange)
      .domain2([0,100])
      .text(texts.repulsion)
      .prop('charge')
      .callback(function(value){
        options['charge'] = value;
        update_forces();
      })

  var makeZoomButton = function(y,n){
    var zoombutton = svg.append("g")
      .attr("class","zoombutton "+n)
      .attr("transform","translate("+(width-35)+","+(height-y)+")")

    zoombutton.append("rect")
      .attr("x",0)
      .attr("y",0)
      .attr("rx",3)
      .attr("ry",3)
      .attr("width",30)
      .attr("height",30)

    return zoombutton;
  }

  // zoom in
  var zoomin = makeZoomButton(130,"zoomin");
  zoomin.on("click",function(){
        transform.k = transform.k + 0.1;
        if(transform.k>zoomRange[1]){
          transform.k = zoomRange[1];
          return;
        }
        options.zoomScale = transform.k
        Sliders.zoom.update(options.zoomScale).brushedValue(true);
      })
  zoomin.append("rect")
      .attr("x",7)
      .attr("y",12)
      .attr("width",16)
      .attr("height",6)
  zoomin.append("rect")
      .attr("x",12)
      .attr("y",7)
      .attr("width",6)
      .attr("height",16)
  zoomin.append("title").text(texts.zoomin + " (ctrl + '+')")

  // reset zoom
  var zoomreset = makeZoomButton(95,"zoomreset");
  zoomreset.on("click",function(){
        resetZoom();
      })
  zoomreset.append("title").text(texts.resetzoom + " (ctrl + 0)")
  zoomreset.append("path")
      .attr("transform","translate(7,6)")
      .style("fill","#fff")
      .attr("d",d4paths.resetzoom)

  // zoom out
  var zoomout = makeZoomButton(60,"zoomout");
  zoomout.on("click",function(){
        transform.k = transform.k - 0.1;
        if(transform.k<zoomRange[0]){
          transform.k = zoomRange[0];
          return;
        }
        options.zoomScale = transform.k
        Sliders.zoom.update(options.zoomScale).brushedValue(true);
      })
  zoomout.append("rect")
      .attr("x",7)
      .attr("y",12)
      .attr("width",16)
      .attr("height",6)
  zoomout.append("title").text(texts.zoomout + " (ctrl + '-')")

  if(frameControls){
    handleFrames(frameControls.frame);
  }else{
    drawNet();
  }

  function keyflip() {
    if(d3.event.shiftKey){
      if(!options.heatmap){
        brushg.style("display",null);
      }
    }else{
      if(brushg){
        brushg.style("display","none");
      }
    }
  }

  function displaySlider(){
    var scale,
        brush,
        slider,
        bubble,
        domain = [1,0],
        domain2 = false,
        scale2 = false,
        text = "",
        prop = "",
        callback = null,
        rounded = false,
        brushedValue = false,
        handleRadius = 5,
        sliderWidth = sidebarWidth-70;

    function exports(sel){
      scale = d3.scaleLinear()
        .clamp(true)
        .domain(domain)
        .range([0, sliderWidth])

      scale2 = d3.scaleLinear()
        .clamp(true)
        .domain(domain2 ? domain2 : domain)
        .range([0, sliderWidth])

      brush = d3.brushX().extent([[-handleRadius,0], [sliderWidth + handleRadius, handleRadius*2]]);

      var svg = sel.append("svg")
        .attr("class","slider "+prop)
        .attr("width",sidebarWidth)

      var sliders = svg.append("g")

      var x = 5, y = 10 + 10*options.cex;

      sliders.append("text")
        .attr("x", x)
        .attr("y", y - 10)
        .text(text);

      slider = sliders.append("g")
        .attr("transform", "translate("+ x +","+ y +")")
        .attr("class", "x axis brushSlider")
        .call(d3.axisBottom(scale)
          .tickSize(0)
          .ticks(0))
        .append("g")
          .attr("class", "slider")
          .attr("transform", "translate(0,-5)")
          .call(brush)
          .call(function(g){
            g.select(".overlay")
             .datum({type:"selection"})
             .on("mousedown touchstart", beforebrushstarted);
          });

      slider.selectAll('.handle').remove();
      slider.selectAll('rect.selection')
      .attr("fill",null)
      .attr("fill-opacity",null)
      .attr("stroke",null)
      .attr("shape-rendering",null)
      .attr("rx",handleRadius)
      .attr("ry",handleRadius)
      .on("mouseover",function(){ bubble.style("visibility","visible"); })
      .on("mouseleave",function(){ bubble.style("visibility","hidden"); })

      bubble = slider.append("g")
        .style("visibility","hidden");
      bubble.append("rect")
        .attr("y",-12)
        .attr("x",-4)
        .attr("width",20)
        .attr("height",16)
        .attr("rx",2)
        .style("stroke",darkGrey)
        .style("fill","#fff")
      bubble.append("text")
        .attr("text-anchor","start")
        .attr("fill","#000000")

      brush.on("brush", brushed)
           .on("start",function(){
             slider.selectAll('rect.selection').on("mouseleave",null);
             bubble.style("visibility","visible");
           })
           .on("end",function(){
             bubble.style("visibility","hidden");
             slider.selectAll('rect.selection').on("mouseleave",function(){ bubble.style("visibility","hidden"); });
           })

      svg.attr("height",sliders.node().getBBox().height+(y/2))
    }

    function innerBrushed(brValue,value) {
      var renderedValue = scale2.invert(brValue);
      renderedValue = rounded ? Math.round(renderedValue) : formatter(renderedValue);
      bubble.select("text").text(renderedValue);
      var bubbleWidth = bubble.select("text").node().getBoundingClientRect().width+6;
      bubble.select("rect").attr("width",bubbleWidth);
      var tomove = brValue;
      if(rounded){
        value = Math.round(value);
        tomove = scale2(renderedValue);
        slider.call(brush.move,[tomove-handleRadius,tomove+handleRadius]);
      }
      bubble.attr("transform","translate("+(tomove+5)+",-2)");
      return value;
    }

    function beforebrushstarted() {
      exports.update(scale.invert(d3.mouse(this)[0]));
      brushedValue = true;
    }

    function brushed() {
      if (!d3.event.sourceEvent || ["mousemove","click"].indexOf(d3.event.sourceEvent.type)==-1) return;
      brushedValue = d3.mean(d3.event.selection);
      callback(innerBrushed(brushedValue,scale.invert(brushedValue)));
    }

    exports.update = function(value) {
      if(value >= d3.min(domain) && value <= d3.max(domain)){
        if(slider){
          brush.on("brush", null);
          slider.call(brush.move,[scale(value)-handleRadius,scale(value)+handleRadius]);
          callback(innerBrushed(scale(value),value));
          brush.on("brush", brushed);
        }else{
          callback(value);
        }
      }
      return exports;
    }

    exports.domain = function(x) {
      if (!arguments.length) return domain;
      domain = x;
      return exports;
    };

    exports.domain2 = function(x) {
      if (!arguments.length) return domain2;
      domain2 = x;
      return exports;
    };

    exports.text = function(x) {
      if (!arguments.length) return text;
      text = x;
      return exports;
    };

    exports.prop = function(x) {
      if (!arguments.length) return prop;
      prop = x;
      return exports;
    };

    exports.callback = function(x) {
      if (!arguments.length) return callback;
      callback = x;
      return exports;
    };

    exports.rounded = function(x) {
      if (!arguments.length) return rounded;
      rounded = x;
      return exports;
    };

    exports.brushedValue = function(x) {
      if (!arguments.length) return brushedValue;
      brushedValue = x;
      return exports;
    };

    return exports;
  }
}

function update_forces(){
      if(options.dynamicNodes){
        simulation.force("charge")
          .strength(options.charge)
        if(!options.linkWeight)
          simulation.force("link")
            .distance(options.linkDistance)

        simulation.alpha(frameControls?0.1:1).restart();
      }else
        simulation.restart();
}

function handleFrames(value){
      clearInterval(frameControls.frameInterval);
      Sliders.frame.update(checkLoop(value));

      if(frameControls.play){
        frameControls.frameInterval = setInterval(function(){
          Sliders.frame.update(checkLoop(frameControls.frame+1));
        }, frameControls.time);
      }

      function checkLoop(value){
        if(value>=frameControls.frames.length)
          return 0; 
        return value;
      }
}

function clickFrameCtrlBtn(){
        var divFrameCtrl = sidebar.select(".divFrameCtrl");
        if(!divFrameCtrl.empty()){
          divFrameCtrl.selectAll("button.pause, button.play")
            .style("background-color",null)
            .selectAll("path").style("fill",null);
          if(frameControls.play){
            divFrameCtrl.select("button.play")
              .style("background-color",darkGrey)
              .selectAll("path").style("fill","LawnGreen");
          }else{
            divFrameCtrl.select("button.pause")
              .style("background-color",darkGrey)
              .selectAll("path").style("fill",lightGrey);
          }
        }
}

function frameStep(value){
        frameControls.frame = value;

        var selectFrame = d3.select(".divFrameCtrl .selectFrame");
        if(!selectFrame.empty())
          selectFrame.node().selectedIndex = frameControls.frame;
        loadFrameData(frameControls.frame);

        if(Array.isArray(options.main))
          main.select("span.title").html(options.main[frameControls.frame]);
        if(Array.isArray(options.note))
          body.select("div.note > div").html(options.note[frameControls.frame]);

        Graph.nodes.forEach(function(node){
          node._hideFrame = true;
        });

        Graph.links.forEach(function(link){
          link._hideFrame = link['_frame_']!=frameControls.frame;
          if(!link._hideFrame){
            delete link.source._hideFrame;
            delete link.target._hideFrame;
            delete link._hideFrame;
          }
        });

        GraphNodesLength = Graph.nodes.filter(function(node){ return !node._hideFrame; }).length;
        GraphLinksLength = Graph.links.filter(function(link){ return !link._hideFrame; }).length;

        drawNet();

        if(frameControls.hasOwnProperty("zoom")){
          options.zoom = frameControls.zoom[frameControls.frame];
          if(Sliders.zoom.brushedValue()===false){
            resetZoom();
          }
        }
        if(frameControls.hasOwnProperty("repulsion")){
          options.repulsion = frameControls.repulsion[frameControls.frame];
          if(Sliders.repulsion.brushedValue()===false){
            options.charge = chargeRange[1] * (options.repulsion/100);
            Sliders.repulsion.update(options.charge).brushedValue(false);
          }
        }
        if(frameControls.hasOwnProperty("distance")){
          options.distance = frameControls.distance[frameControls.frame];
          if(Sliders.distance.brushedValue()===false){
            options.linkDistance = linkDistanceRange[1] * (options.distance/100);
            Sliders.distance.update(options.linkDistance).brushedValue(false);
          }
        }

        if(frameControls.frame==frameControls.frames.length-1 && !frameControls.loop)
          d3.select(".divFrameCtrl .pause").dispatch("click");
}

function drawNet(){  
  var svg = d3.select(".plot svg g.net");

  var ctx = d3.select(".plot canvas").node().getContext("2d");

  legendPanel.selectAll("*").remove();

  if(Graph.tree){
    var hideChildren = function(d){
      d.childNodes.forEach(function(d){
        d._hidden = true;
        d.selected = false;
        hideChildren(d);
      });
    }
    Graph.nodes.forEach(function(d){
      if(checkSelectable(d) && d.childNodes.length)
        hideChildren(d);
    });
  }

  var nodes = Graph.nodes.filter(function(node){
    node.degree = 0;
    return checkSelectable(node);
  });

  var links = Graph.links.filter(checkSelectableLink);

  d3.select("button.primary-outline.resetfilter").classed("disabled",(nodes.length==GraphNodesLength) && (links.length==GraphLinksLength));

  for(var i=1; i<links.length; i++){
    for(var j = i-1; j>=0; j--){
      if((links[i].Source == links[j].Source && links[i].Target == links[j].Target)||(links[i].Source == links[j].Target && links[i].Target == links[j].Source)){
        if(!links[j].linkNum)
          links[j].linkNum = 1;
        links[i].linkNum = links[j].linkNum + 1;
        break;
      }
    }
  }

  links.forEach(function(link){
    link.source.degree = +link.source.degree+1;
    link.target.degree = +link.target.degree+1;
  })

  var imgidx = options.imageNames.indexOf(options.nodeImage);
  options.imageItem = imgidx!=-1 ? options.imageItems[imgidx] : false;

  // compute colors
  if(!VisualHandlers.hasOwnProperty("nodeColor")){
    VisualHandlers.nodeColor = setColorScale()
        .data(GraphLinksLength && options.nodeColor=="degree" ? nodes : Graph.nodes)
        .item('node')
        .itemAttr("nodeColor")
        .computeScale()
  }

  if(!VisualHandlers.hasOwnProperty("nodeGroup")){
    VisualHandlers.nodeGroup = setColorScale()
        .data(GraphLinksLength && options.nodeGroup=="degree" ? nodes : Graph.nodes)
        .item('node')
        .itemAttr("nodeGroup")
        .computeScale()
  }

  if(!VisualHandlers.hasOwnProperty("linkColor")){
    VisualHandlers.linkColor = setColorScale()
        .data(Graph.links)
        .item('link')
        .itemAttr("linkColor")
        .computeScale()
  }

  // compute link attributes
  if(options.heatmap){
    var getLinkIntensity = getNumAttr(Graph.links,'linkIntensity',[0.1,1],1);
  }else{
    var getLinkDistance = getNumAttr(Graph.links,'linkWeight',linkWeightRange,options.linkDistance),
        getLinkWidth = getNumAttr(links,'linkWidth',linkWidthRange,1);

    // compute node size
    var getNodeSize = getNumAttr(nodes,'nodeSize',nodeSizeRange,options.imageItem?3:1),
        getNodeLabelSize = getNumAttr(nodes,'nodeLabelSize',nodeLabelSizeRange,10*options.cex);
    nodes.forEach(function(node){
      node.nodeSize = getNodeSize(node) * nodeRadius;
      node.nodeLabelSize = getNodeLabelSize(node);
    });
  }

  // compute shapes
  if(!VisualHandlers.hasOwnProperty("nodeShape")){
    VisualHandlers.nodeShape = setShapeScale()
        .data(Graph.nodes)
        .item('node')
        .itemAttr("nodeShape")
        .computeScale()
  }

  sidebar.select(".buttons .button.showArrows").classed("disabled",!links.length)

  svg.attr("clip-path", options.heatmap && options.heatmapTriangle?"url(#heatmapClip)":null);
  if(options.heatmap){ // draw heatmap

    ctx.clearRect(0, 0, width, height);
    svg.selectAll("*").remove();
    svg = svg.append("g")
               .attr("class","heatmap")

    var n = nodes.length,
        x = d3.scaleBand().range([0, n*20]),
        matrix = [];

    var size = Math.min(width, height),
        side = x.range()[1],
        k = 14/30 + n/150,
        scale = size * (k < 0.8 ? k : 0.8) / side,
        scaledSide = side*scale;

    svg.attr("transform", options.heatmapTriangle ?
      "translate(" + -(Math.sqrt(scaledSide*scaledSide*2))/2 + "," + (height/2 - 10) + ")scale(" + scale + ")rotate(-45)" :
      "translate(" + (-scaledSide/2) + "," + (height/2 - scaledSide - 10) + ")scale(" + scale + ")");

    nodes.forEach(function(node, i) {
      node.index = i;
      matrix[i] = d3.range(n).map(function(j) { return {x: j, y: i}; });
    });

    links.forEach(function(link) {
      var val = options.linkIntensity?link[options.linkIntensity]:1,
          valColor = options.linkColor?link[options.linkColor]:1,
          loadMatrix = function(i,j){
            matrix[i][j][options.linkIntensity] = val;
            matrix[i][j].linkColor = valColor;
            if(options.linkText)
              matrix[i][j].txt = link[options.linkText];
          }
      if(options.linkBipolar)
        val = Math.abs(val);
      loadMatrix(link.source.index,link.target.index);
      if(!options.showArrows || options.heatmapTriangle)
        loadMatrix(link.target.index,link.source.index);
    });

  if(options.nodeOrderA || options.nodeOrderD){
    if(options.nodeOrderA)
      options.nodeOrder = options.nodeOrderA;
    else
      options.nodeOrder = options.nodeOrderD;
    x.domain(d3.range(n).sort(function(a, b) {
          a = nodes[a][options.nodeOrder];
          b = nodes[b][options.nodeOrder]
          if(options.nodeOrderD)
            b = [a, a = b][0];
          return a < b ? -1 : a > b ? 1 : a >= b ? 0 : NaN;
        }));
  }else
    x.domain(d3.range(n));

  svg.append("rect")
      .style("fill","#eee")
      .attr("width", side)
      .attr("height", side);

  var row = svg.selectAll(".row")
      .data(matrix)
    .enter().append("g")
      .attr("class", "row")
      .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .each(rowFunc);

  row.append("line")
      .attr("x2", side)
    .style("stroke","#fff");

  appendText(row,true);
      
  var column = svg.selectAll(".column")
      .data(matrix)
    .enter().append("g")
      .attr("class", "column")
      .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });

  column.append("line")
      .attr("x1", -side)
    .style("stroke","#fff");

  appendText(column,false);

  if(options.nodeOrder){
    var clusters = nodes.map(function(d){ return d[options.nodeOrder]; }).sort(function(a, b) { 
          if(options.nodeOrderD)
            b = [a, a = b][0];
          return a < b ? -1 : a > b ? 1 : a >= b ? 0 : NaN;
        }),
        step = NaN,
        lines = {};
    for(var i=0; i<clusters.length; i++){
      if(step!=String(clusters[i])){
        step = String(clusters[i]);
        lines[step] = [i,i];
      }else
        lines[step][1] = i;
    }
    svg.selectAll(".cluster")
        .data(d3.values(lines))
      .enter().append("path")
        .attr("class","cluster")
        .style("stroke", darkGrey)
        .style("fill", "none")
        .attr("d",function(d){
            var x1 = d[0]*x.bandwidth() + x.bandwidth()/2,
                x2 = d[1]*x.bandwidth() + x.bandwidth()/2;
            return "M"+x1+",-6L"+x1+",-12L"+x2+",-12L"+x2+",-6";
        })

    delete options.nodeOrder;
  }

  function appendText(sel,row){
    if(options.nodeLabel){
    sel.append("text")
      .attr("class","label")
      .attr("x", row? (options.heatmapTriangle? side + 6 : -6) : ((options.heatmapTriangle?-1:1) * (options.nodeOrder?18:6)))
      .attr("y", (!row && options.heatmapTriangle? -1 : 1) * (x.bandwidth() / 2))
      .attr("text-anchor", row ^ options.heatmapTriangle? "end" : "start")
      .attr("transform", !row && options.heatmapTriangle? "rotate(180)" : null)
      .attr("dy", ".32em")
      .style("font-size",(x.bandwidth()-2)+"px")
      .style("fill",options.nodeColor? function(d, i) {
        var col = d3.rgb(VisualHandlers.nodeColor(nodes[i]));
        if(col.r==255 && col.g==255 && col.b==255)
          col = col.darker(1);
        return col;
      } : null)
      .style("opacity",0)
      .text(function(d, i) { return (!row ? nodes[i][options.nodeLabel] : nodes[i][options.nodeName]); })
      .on("click",function(d,i){
        var name = nodes[i][options.nodeName];
        nodes.forEach(function(p){
            if(d3.event.ctrlKey || d3.event.metaKey)
              p.selected = p.selected ^ name == p[options.nodeName];
            else
              p.selected = name == p[options.nodeName];
        });
        showTables();
      })
      .on("dblclick", row || !options.linkIntensity ? function(){
        d3.event.stopPropagation();
        switchEgoNet();
      } : function(d,i){
        d3.event.stopPropagation();
        var order = d3.transpose(matrix)[i].sort(function(a,b){
              var aIntensity = a[options.linkIntensity]?a[options.linkIntensity]:0,
                  bIntensity = b[options.linkIntensity]?b[options.linkIntensity]:0;
              if(bIntensity==aIntensity){
                if(a.y==i) return -1;
                if(b.y==i) return 1;
                return a.y-b.y;
              }else
                return bIntensity-aIntensity;
            }).map(function(p){ return p.y; })
        x.domain(order);

        var t = svg.transition().duration(2500);

        svg.selectAll("path.cluster").remove();

        t.selectAll(".column .label").attr("x",((options.heatmapTriangle?-1:1) * 6))

        t.selectAll(".row")
          .delay(function(d, i) { return x(i) * 4; })
          .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
         .selectAll(".cell")
          .delay(function(d) { return x(d.x) * 4; })
          .attr("x", function(d) { return x(d.x); });

        t.selectAll(".row .cellText")
          .delay(function(d) { return x(d.x) * 4; })
          .attr("x", function(d) { return x(d.x) + x.bandwidth()/2; });

        t.selectAll(".column")
          .delay(function(d, i) { return x(i) * 4; })
          .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });
      })
      .on("mouseover", function(){
        d3.select(this).style("font-weight","bold");
      })
      .on("mouseout", mouseout)
      .transition()
      .duration(500)
      .style("opacity",1)
    }
  }

  function rowFunc(row) {
    d3.select(this).selectAll(".cell")
        .data(row.filter(function(d) { return d[options.linkIntensity]; }))
      .enter().append("rect")
        .attr("class", "cell")
        .attr("x", function(d) { return x(d.x); })
        .attr("width", x.bandwidth())
        .attr("height", x.bandwidth())
        .style("fill-opacity", getLinkIntensity)
        .style("fill", function(link) { return VisualHandlers.linkColor(link); })
        .on("mouseover", mouseover)
        .on("mouseout", mouseout)
        .on("click",click)
        .on("dblclick",dblclick)
    if(options.linkText){
      d3.select(this).selectAll(".cellText")
        .data(row.filter(function(d) { return d[options.linkIntensity]; }))
      .enter().append("text")
        .attr("class", "cellText")
        .attr("x", function(d) { return x(d.x) + x.bandwidth()/2; })
        .attr("y", x.bandwidth()/2)
        .attr("dy", ".32em")
        .attr("text-anchor", "middle")
        .style("font-weight", "bold")
        .style("fill", "#ffffff")
        .style("font-size", x.bandwidth()*2/5 + "px")
        .on("mouseover", mouseover)
        .text(function(d){
            if(!isNaN(+d.txt))
              return d.txt.toFixed(1);
            return d.txt;
        })
    }
  }

  function mouseover(p) {
    d3.selectAll(".row .label").style("font-weight", function(d, i) {
      if(i == p.y) return "bold"; else return null;
    });
    d3.selectAll(".column .label").style("font-weight", function(d, i) {
      if(i == p.x) return "bold"; else return null;
    });
  }

  function mouseout() {
    d3.selectAll(".label").style("font-weight",null);
  }
  
  function click(p){
    links.forEach(function(l){ checkNeighbors(l,p); });
    nodes.forEach(function(n){
      n.selected = !n._hidden && n.__neighbor;
      delete n.__neighbor;
    });
    showTables();
  }

  function dblclick(p){
    d3.event.stopPropagation();
    links.forEach(function(l){ checkNeighbors(l,p); });
    nodes.forEach(function(n){
      n.selected = (checkSelectable(n) && (n.index == p.x || n.index == p.y))? true : false;
      delete n.__neighbor;
    });
    switchEgoNet();
  }

    function checkNeighbors(l,p){
      if(!l._hidden && !l._hideFrame && (((!options.showArrows || options.heatmapTriangle) && (l.target.index==p.x || l.target.index==p.y)) || (l.source.index==p.x || l.source.index==p.y))){
        l.source.__neighbor = l.target.__neighbor = true;
      }
    }

  }else{ // draw network

    svg.select("g.heatmap").remove();

    //hide sliders
    sidebar.select(".slider.charge").style("display",nodes.length<2?"none":null)
    sidebar.select(".slider.linkDistance").style("display",!links.length || options.linkWeight?"none":null)

    simulation.nodes(nodes);

    simulation.force("link")
      .links(links)
      .distance(getLinkDistance);

    simulation.on("tick", tick);

    update_forces();

    updateSidebarFilters();

    //axes
    if(!options.showCoordinates){
      var axes = svg.selectAll(".axis")
      .data([[0,1],[1,0]])
      .enter().append("line")
      .attr("class","axis")
      .attr("pointer-events","none")
      .style("opacity",0)

      var axesLabelsAnchors = ["start","middle","end","middle"],
          axesLabels = svg.selectAll(".axisLabel")
        .data(options.axesLabels)
      .enter().append("text")
      .attr("class","axisLabel")
      .attr("pointer-events","none")
      .style("opacity",0)
      .text(String)
      .attr("text-anchor",function(d,i){
        return axesLabelsAnchors[i];
      })

      if(!options.dynamicNodes){
        updateAxes();
      }
    }

    //groups
    var groups = getGroups(nodes);
  }

    // display scale
    if(options.heatmap){
      VisualHandlers.linkColor.displayScale();
    }else{
      VisualHandlers.nodeColor.displayScale();
    }

    // display legends
    var legendLegend = options.nodeLegend ? true : false,
        legendColor = !options.imageItem && (options.nodeColor && dataType(nodes,options.nodeColor)!='number'),
        legendShape = !options.imageItem && options.nodeShape,
        legendImage = (!options.heatmap && options.imageItem) && (options.imageItems && options.imageNames);

    Legends = {};
    var data;

    if(legendLegend){
      data = nodes.map(function(d){ return d[options.nodeLegend]; });
      if(dataType(nodes,options.nodeLegend) == 'object'){
        data = data.reduce(function(a,b) { return a.concat(b); }, []);
      }
      data = d3.set(data).values();
      Legends.legend = displayLegend()
      .type("Legend")
      .key(options.nodeLegend)
      .data(data.sort(sortAsc));
    }

    if(legendColor){
      data = d3.map(nodes.filter(function(d){ return d[options.nodeColor]!==null; }), function(d){ return d[options.nodeColor]; }).keys();
      Legends.color = displayLegend()
        .type("Color")
        .key(options.nodeColor)
        .data(data.sort(sortAsc))
        .color(VisualHandlers.nodeColor.getScale());
    }

    if(legendShape){
      data = d3.map(nodes, function(d){ return d[options.nodeShape]; }).keys();
      Legends.shape = displayLegend()
        .type("Shape")
        .key(options.nodeShape)
        .data(data.sort(sortAsc))
        .shape(VisualHandlers.nodeShape.getScale())
    }

    if(legendImage){
      var title = options.imageNames[options.imageItems.indexOf(options.imageItem)];
      data = nodes.map(function(d){ return [d[title],d[options.imageItem]]; })
      data.sort(function(a,b){
          return sortAsc(a[0],b[0]);
      })
      var data2 = d3.map(data, function(d){ return d[0]; }).keys();
      data = d3.map(data, function(d){ return d[1]; }).keys()
      var textFunc = function(d,i){ return data2[i]; };
      if(data2.length!=data.length){
        title = options.imageItem;
        textFunc = getImageName;
      }
      Legends.image = displayLegend()
        .type("Image")
        .key(options.imageItem)
        .data(data)
        .title(title)
        .text(textFunc)
        .color("image")
    }

    if(d3.keys(Legends).length){
      var legendsHeight = height - 240;
      if(!legendPanel.select(".legend-panel > .scale").empty()){
        legendsHeight = legendsHeight-legendPanel.select(".legend-panel > .scale").node().offsetHeight-10;
      }

      displayShowPanelButton(legendPanel,function(){
          options.showLegend = true;
          showLegendFunction();
      });

      var divLegends = legendPanel.append("div")
        .attr("class","legends")

      showLegendFunction();

      divLegends.append("div")
      .attr("class","highlight-header")
      .text(texts.Legend)
      .append("div")
        .attr("class","close-button")
        .on("click",function(){
          options.showLegend = false;
          showLegendFunction();
        })

      if(egoNet || !checkInitialFilters()){
        divLegends.append("div")
          .attr("class","goback")
          .on("click",applyInitialFilter)
          .append("title")
            .text("ctrl + i")

        legendsHeight = legendsHeight-22;
      }

      var div = divLegends.append("div")
        .attr("class","legends-content");

      ["legend","color","shape","image"].forEach(function(k){
        if(Legends.hasOwnProperty(k)){
          div.call(Legends[k]);
        }
      })

      if(div.node().offsetHeight>legendsHeight){
        div.style("height",legendsHeight+"px")
      }

      var legendBottomControls = divLegends.append("div")
        .attr("class","legend-bottom-controls")

      var gSelectAll = legendBottomControls.append("div")
        .attr("class","legend-selectall")
      displaycheck(gSelectAll,function(self){
        Graph.nodes.forEach(function(d){
            if(self.selected && checkSelectable(d)){
              d.selected = true;
            }else{
              delete d.selected;
            }
        });
      });
      gSelectAll.append("span")
        .text(texts.selectall)

      displayBottomButton(legendBottomControls,"filter",texts.filterInfo+" (ctrl + e)",switchEgoNet);
      displayBottomButton(legendBottomControls,"isolate",texts.isolateInfo+" (ctrl + f)",filterSelection);
    }
    // end legends

  showTables();

  //render network
  function tick() {
    ctx.save();
    ctx.clearRect(0, 0, width, height);

    if(frameControls.recorder){
      ctx.fillStyle = options.background ? options.background : "#ffffff";
      ctx.fillRect(0, 0, width, height);
      var text = frameControls.frames[frameControls.frame];
      if(options.main && Array.isArray(options.main))
        text = options.main[frameControls.frame];
      ctx.font = 10*options.cex+"px "+fontFamily;
      ctx.textAlign = "right";
      ctx.fillStyle = "#000000";
      ctx.fillText(text,width-10,height-10);
    }

    ctx.translate(transform.x, transform.y);
    ctx.scale(transform.k, transform.k);

    // draw areas
    ctx.lineJoin = "round";
    if(options.nodeGroup){
      ctx.globalAlpha = 0.2;
      ctx.lineWidth = 3;
      groups.forEach(function(group){
        ctx.strokeStyle = VisualHandlers.nodeGroup(group);
        ctx.fillStyle = d3.rgb(ctx.strokeStyle).brighter(0.6);
        var points = getArea(group,nodes);
        ctx.beginPath();
        ctx.rect(points[0],points[1],points[2],points[3]);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      })
    }

    // draw links
    links.forEach(function(link) {
      ctx.globalAlpha = link._back? 0.2 : 0.6;
      var points = getLinkCoords(link);
      if(!points)
        return;
      ctx.beginPath();
      ctx.lineWidth = getLinkWidth(link);
      ctx.strokeStyle = link._selected? "#F00" : VisualHandlers.linkColor(link);
      ctx.moveTo(points[0][0], points[0][1]);
      if(link.linkNum)
        ctx.quadraticCurveTo(points[2][0], points[2][1], points[1][0], points[1][1]);
      else
        ctx.lineTo(points[1][0], points[1][1]);
      if(options.showArrows){
        var arrow;
        if(link.linkNum)
          arrow = getArrow(points[2][0], points[2][1], points[1][0], points[1][1], ctx.lineWidth);
        else
          arrow = getArrow(points[0][0], points[0][1], points[1][0], points[1][1], ctx.lineWidth);
        ctx.lineTo(arrow[2][0], arrow[2][1]);
        ctx.lineTo(arrow[0][0], arrow[0][1]);
        ctx.lineTo(points[1][0], points[1][1]);
      }
      ctx.stroke();
    });

    ctx.lineJoin = "miter";
    ctx.globalAlpha = 1;

    if(options.linkText){
      ctx.fillStyle = defaultLinkColor;
      ctx.beginPath();
      ctx.font = 10*options.cex+"px "+fontFamily;
      links.forEach(function(link) {
        var coords = getLinkTextCoords(link);

        ctx.textAlign = "left";
        if(link.linkNum && link.linkNum%2==0)
          ctx.textAlign = "right";

        ctx.fillText(formatter(link[options.linkText]), coords[0], coords[1]);
      });
      ctx.fill();
    }

    // draw nodes
    nodes.forEach(function(node) {
      var nodeSize = checkNodeBigger(node);
      ctx.globalAlpha = node._back? 0.2 : 1;
      ctx.lineWidth = node.selected || node._selected ? 2 : 1;
      var strokeStyle = node._selected ? "#F00" : (node.selected ? "#FF0" : false);
      ctx.strokeStyle = strokeStyle;
      ctx.translate(node.x, node.y);
      if(options.imageItem){
        var img = images[node[options.imageItem]],
            imgHeight = img.height*2/img.width;
        if(options.nodeShape){
          var renderShape = function(){
            d3.symbol().type(VisualHandlers.nodeShape(node)).size(nodeSize * nodeSize * Math.PI / 2.4).context(ctx)();
          }
          ctx.save();
          renderShape();
          ctx.clip();
        }
        try{
          ctx.drawImage(img, -nodeSize, -(imgHeight/2)*nodeSize, nodeSize * 2, nodeSize * imgHeight);
        }catch(e){}
        if(options.nodeShape){
          ctx.restore();
        }
        if(!strokeStyle && (options.nodeColor || options.nodeShape)){
          if(options.nodeColor){
            strokeStyle = VisualHandlers.nodeColor(node);
          }else{
            strokeStyle = "#777777";
          }
          ctx.strokeStyle = strokeStyle;
          ctx.lineWidth = 2;
        }
        if(strokeStyle){
          ctx.beginPath();
          if(options.nodeShape){
            renderShape();
          }else{
            ctx.arc(0, 0, nodeSize, 0, 2 * Math.PI);
          }
          ctx.closePath();
          ctx.stroke();
        }
      }else{
        ctx.fillStyle = VisualHandlers.nodeColor(node);

        if(!strokeStyle)
          ctx.strokeStyle = d3.rgb(ctx.fillStyle).darker(1);
        ctx.beginPath();
        d3.symbol().type(VisualHandlers.nodeShape(node)).size(nodeSize * nodeSize * Math.PI).context(ctx)();
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      }
      ctx.translate(-node.x, -node.y);
    });

    // write labels
    if(options.nodeLabel){
      ctx.textAlign = "left";
      ctx.fillStyle = "#000000";
      ctx.beginPath();
      ctx.font = 10*options.cex+"px "+fontFamily;
      nodes.forEach(function(node) {
        var fontSize = node._bigger ? 10/transform.k : 0;
        ctx.globalAlpha = node._back? 0.2 : 1;
        if(options.nodeLabelSize){
          if(node[options.nodeLabelSize]<0)
            return;
          fontSize = node.nodeLabelSize+fontSize;
        }else{
          fontSize = 10+fontSize;
        }
        ctx.font = fontSize*options.cex+"px "+fontFamily;
        ctx.fillText(node[options.nodeLabel], node.x + checkNodeBigger(node) + 4, node.y - 4);
      });
      ctx.fill();
    }
    ctx.restore();

    function checkNodeBigger(node){
      return node._bigger ? node.nodeSize + 10/transform.k : node.nodeSize;
    }

    if(options.nodeText){
      plot.selectAll("div.tooltip")
        .style("top",function(node){ return (transform.applyY(node.y)+findNodeRadius-10)+"px"; })
        .style("left",function(node){ return (transform.applyX(node.x)+findNodeRadius-10)+"px"; })
    }
  }

  // generate pdf
  svg2pdf = function(){

    var doc = new jsPDF({
      orientation: (width>height)?"l":"p",
      unit: 'pt',
      format: [width,height]
    });

    doc.polygon = pdfPolygon;

    var translate = [transform.x,transform.y],
        scale = transform.k;

    doc.setLineWidth(scale);

    if(options.heatmap){ // heatmap display
      doc.setDrawColor(255);
      doc.setFillColor(238,238,238);
      var size = parseInt(d3.select("g.heatmap>rect").attr("width")) * scale,
          dim = parseInt(d3.select("g.heatmap rect.cell").attr("width")) * scale;
      for(i=0;i<size/dim;i++){
        for(j=0;j<size/dim;j++){
          doc.rect(((i*dim)+translate[0]),((j*dim)+translate[1]), dim, dim, 'FD');
        }
      }

      d3.selectAll("g.heatmap rect.cell").each(function(){
        var self = d3.select(this),
            x = (+self.attr("x")*scale) + translate[0],
            y = (getTranslation(d3.select(this.parentNode).attr("transform"))[1]*scale) + translate[1],
            o = self.style("fill-opacity"),
            color = d3.rgb(self.style("fill"));
        color = applyOpacity(color,o,{r:238,g:238,b:238});
        doc.setFillColor(color.r,color.g,color.b);
        doc.rect(x, y, dim, dim, 'FD');
      });

      doc.setTextColor(64);
      d3.selectAll("g.heatmap .row text").each(function(){
        var self = d3.select(this),
            y = (getTranslation(d3.select(this.parentNode).attr("transform"))[1]*scale) + translate[1],
            txt = self.text(),
            x = translate[0],
            fontSize = parseInt(self.style("font-size"))*scale;
        doc.setFontSize(fontSize);
        doc.text(x-6, y+fontSize, txt, { align: "right" });
      });
      d3.selectAll("g.heatmap .column text").each(function(){
        var self = d3.select(this),
            x = (getTranslation(d3.select(this.parentNode).attr("transform"))[0]*scale) + translate[0],
            txt = self.text(),
            y = translate[1],
            fontSize = parseInt(self.style("font-size"))*scale;
        doc.setFontSize(fontSize);
        doc.text(x+fontSize, y-6, txt, null, 90);
      });

    }else{ // network display
      var areas = [];
      groups.forEach(function(group){
        var d = {},
            color = VisualHandlers.nodeGroup(group),
            points = getArea(group,nodes);
        d.colorf = applyOpacity(d3.rgb(color).brighter(0.6),0.2);
        d.colord = applyOpacity(d3.rgb(color),0.2);
        d.x = (points[0]*scale)+translate[0];
        d.y = (points[1]*scale)+translate[1];
        d.width = points[2]*scale;
        d.height = points[3]*scale;
        areas.push(d);
      });
      areas.sort(function(a,b){
        var areaA = a.width * a.height,
            areaB = b.width * b.height;
        if (areaA < areaB) {
          return 1;
        }
        if (areaA > areaB) {
          return -1;
        }
        return 0;
      });
      areas.forEach(function(d){
        doc.setFillColor(d.colorf.r,d.colorf.g,d.colorf.b);
        doc.setDrawColor(d.colord.r,d.colord.g,d.colord.b);
        doc.roundedRect(d.x,d.y,d.width,d.height,10,10,"FD");
      });

      links.forEach(function(link){
        var color = applyOpacity(d3.rgb(VisualHandlers.linkColor(link)),0.6),
            w = getLinkWidth(link)*scale,
            points = getLinkCoords(link);

        if(!points)
          return;

        var x1 = (points[0][0]*scale)+translate[0],
            y1 = (points[0][1]*scale)+translate[1],
            x2 = (points[1][0]*scale)+translate[0],
            y2 = (points[1][1]*scale)+translate[1];

        doc.setDrawColor(color.r,color.g,color.b);
        doc.setLineWidth(w);
        if(link.linkNum){
          var cpx = (points[2][0]*scale)+translate[0]-x1,
              cpy = (points[2][1]*scale)+translate[1]-y1;
          doc.lines([[cpx,cpy,cpx,cpy,x2-x1,y2-y1]],x1,y1);
        }else
          doc.line(x1, y1, x2, y2);

        if(options.showArrows){
          var arrow;
          if(link.linkNum)
            arrow = getArrow(cpx+x1, cpy+y1, x2, y2, w);
          else
            arrow = getArrow(x1, y1, x2, y2, w);
          doc.line(x2, y2, arrow[2][0], arrow[2][1]);
          doc.line(arrow[2][0], arrow[2][1], arrow[0][0], arrow[0][1]);
          doc.line(arrow[0][0], arrow[0][1], x2, y2);
        }
      });

      if(options.linkText){
        doc.setFontSize(10*options.cex*scale);
        doc.setTextColor(defaultLinkColor);
        links.forEach(function(link){
          var coords = getLinkTextCoords(link),
              x = (coords[0]*scale)+translate[0],
              y = (coords[1]*scale)+translate[1],
              t = String(formatter(link[options.linkText])),
              tAlign = "left";
          if(link.linkNum && link.linkNum%2==0)
            tAlign = "right";
          doc.text(x, y, t, { align: tAlign });
        });
      }

      nodes.forEach(function(node){
        var color = d3.rgb(VisualHandlers.nodeColor(node)),
            sColor = d3.rgb(node.selected ? "#FF0" : d3.rgb(color).darker(1)),
            size = node.nodeSize*scale,
            x = (node.x*scale)+translate[0],
            y = (node.y*scale)+translate[1];
        doc.setLineWidth((node.selected ? 2 : 1)*scale);
        doc.setDrawColor(sColor.r,sColor.g,sColor.b);
        doc.setFillColor(color.r,color.g,color.b);
        if(options.imageItem){
          var imgSrc = node[options.imageItem];
          if(images64[imgSrc]){
            var imgHeight = images[imgSrc].height*2/images[imgSrc].width;
            doc.addImage(images64[imgSrc], 'PNG', x-size, y-(imgHeight/2)*size, 2*size, imgHeight*size);
            if(node.selected){
              doc.circle(x, y, size);
            }
          }
        }else{
          var points = d3.symbol().type(VisualHandlers.nodeShape(node))();
          doc.polygon(points, x, y, [size/nodeRadius,size/nodeRadius], 'FD');
        }
      });

      if(options.nodeLabel){
        doc.setFontSize(10*options.cex*scale);
        doc.setTextColor("#000000");
        nodes.forEach(function(node){
          var x = ((node.x + node.nodeSize + 8)*scale)+translate[0],
              y = ((node.y + 4)*scale)+translate[1],
              txt = String(node[options.nodeLabel]);
          doc.setFontSize(node.nodeLabelSize*scale);
          doc.text(x, y, txt);
        });
      }
    }

    doc.setTextColor("#000000");

    d3.selectAll("div.main span.title").each(function(){
      doc.setFontSize(parseInt(d3.select(this).style("font-size")));
      doc.setFontType("bold");
      doc.text(12, 28, this.textContent);
    })

    doc.setFontType("normal");

    d3.selectAll("div.note").each(function(){
      doc.setFontSize(parseInt(d3.select(this).style("font-size")));
      doc.text(12, height-12, this.textContent);
    })

    if(!legendPanel.empty()){
      // scale
      if(!legendPanel.select(".scale").empty()) {
          var svrRect = legendPanel.select(".scale svg > rect");
          var colors = colorScales[svrRect.attr("fill").replace(/(url\()|(\))/g, "").replace("#","")];
          var canvas = document.createElement("canvas");
          canvas.width = parseInt(svrRect.attr("width"));
          canvas.height = parseInt(svrRect.attr("height"));
          var ctx = canvas.getContext("2d");
          var grd = ctx.createLinearGradient(0,0,canvas.width,0);
          colors.forEach(function(c,i){
            grd.addColorStop(i/(colors.length-1),c);
          })
          ctx.fillStyle = grd;
          ctx.fillRect(0,0,canvas.width,10);
          var uri = canvas.toDataURL();
          doc.addImage(uri, 'PNG', (width-canvas.width-20), 40, canvas.width, 10);
          [
            {"selector":"title", "x":+(width-(canvas.width/2)-20), "y":30, "align":"center", "fontSize":14},
            {"selector":"domain1", "x":+(width-canvas.width-20), "y":70, "align":"left", "fontSize":12},
            {"selector":"domain2", "x":+(width-20), "y":70, "align":"right", "fontSize":12}
          ].forEach(function(d){
            var text = legendPanel.select(".scale ."+d.selector).text();
            doc.setFontSize(d.fontSize);
            doc.text(d.x, d.y, text, { align: d.align });
          });
      }

      // legend
      if(!legendPanel.select(".legends").empty()) {
        var y = legendPanel.select(".scale").empty() ? 20 : 100;
        doc.setDrawColor(198, 198, 198);
        ["legend","color","shape","image"].forEach(function(k){
          if(Legends.hasOwnProperty(k)){
            var data = Legends[k].data(),
                title = Legends[k].title(),
                type = Legends[k].type(),
                key = Legends[k].key(),
                shape = Legends[k].shape(),
                color = Legends[k].color(),
                text = Legends[k].text(),
                titleText = texts[type] + " / " + (typeof title == "undefined" ? key : title);

            doc.setFontSize(12);
            doc.text(width-20, y, titleText, { align: "right" });
            y = y + 10;
            doc.line(width-120,y,width-20,y);
            doc.setFontSize(10);
            data.forEach(function(d,i){
              y = y + 18;
              doc.text(width-40, y, text(d,i), { align: "right" }); 

              if(k!="image"){
                doc.setFillColor(typeof color == "function" ? color(d) : color);
                var points = d3.symbol().type(d3["symbol"+(typeof shape == "function" ? shape(d) : shape)])();
                doc.polygon(points, width-25, y-4, [1,1], 'F');
              }else{
                if(images64[d]){
                  var widthRatio = 1,
                      heightRatio = images[d].height/images[d].width;
                  if(heightRatio>1){
                    widthRatio = 1/heightRatio;
                    heightRatio = 1;
                  }
                  doc.addImage(images64[d], 'PNG', width-36, y-12, 16*widthRatio, heightRatio*16);
                }
              }
            });
            y = y + 40;
          }
        })
      }
    }

    // axes
    doc.setLineWidth(scale);
    doc.setDrawColor(170, 170, 170);
    doc.setTextColor(170, 170, 170);
    d3.selectAll(".net .axis").each(function(){
      var self = d3.select(this);
      if(self.style("opacity")=="1"){
        var x1 = (+self.attr("x1")*scale)+translate[0],
            y1 = (+self.attr("y1")*scale)+translate[1],
            x2 = (+self.attr("x2")*scale)+translate[0],
            y2 = (+self.attr("y2")*scale)+translate[1];

        doc.line(x1, y1, x2, y2);
      }
    })
    d3.selectAll(".net .axisLabel").each(function(){
      var self = d3.select(this);
      if(self.style("opacity")=="1"){
        var x = (+self.attr("x")*scale)+translate[0],
            y = (+self.attr("y")*scale)+translate[1],
            anchors = {"start":"left","middle":"center","end":"right"},
            tAlign = anchors[self.attr("text-anchor")];

        doc.text(x, y, self.text(), { align: tAlign });
      }
    })

    doc.save(d3.select("head>title").text()+".pdf");
  } // end pdf function
}

function showTooltip(node,fixed){
    if(options.nodeText && node[options.nodeText] && plot.select("div.tooltip").filter(function(d){ return node[options.nodeName]==d[options.nodeName]; }).empty()){
        plot.append("div")
             .attr("class","tooltip"+(fixed?" fixed":""))
             .datum(node)
             .html(node[options.nodeText])
    }
}

function findNode(){
  return simulation.find(transform.invertX(d3.mouse(d3.event.target)[0]), transform.invertY(d3.mouse(d3.event.target)[1]), findNodeRadius);
}

function clickNet(){
  var node = findNode();
  if(options.nodeText){
    plot.selectAll("div.tooltip").remove();
  }
  if(node){
    if(d3.event.ctrlKey || d3.event.metaKey){
      node.selected = !node.selected;
    }else{
      Graph.nodes.forEach(function(n){
        n.selected = false;
      });
      node.selected = true;
    }
    if(options.nodeText){
      showTooltip(node,true);
    }
    if(options.nodeInfo){
      displayInfoPanel(node[options.nodeInfo]);
    }
  }else{
    Graph.nodes.forEach(function(n){
      n.selected = false;
    });
  }
  showTables();
}

function dblClickNet(){
  var node = findNode();
  if(node){
    if(Graph.tree && (d3.event.ctrlKey || d3.event.metaKey)){
      node.selected = true;
      treeAction();
    }else{
      switchEgoNet();
    }
  }else{
    d3.select(this).transition()
      .call(zoom.scaleBy,2,d3.mouse(this));
  }
}

var someBigger = false;
function hoverNet(){
  var node = findNode();
  if(someBigger){
    Graph.nodes.forEach(function(node){
      delete node._bigger;
    })
    someBigger = false;
    simulation.restart();
  }
  if(options.nodeText){
    plot.selectAll("div.tooltip:not(.fixed)").remove();
  }
  if(node){
    someBigger = true;
    node._bigger = true;
    simulation.restart();
    d3.select(this).style("cursor","pointer");
    if(options.nodeText && plot.select("div.tooltip.fixed").empty())
      showTooltip(node);
  }else{
    d3.select(this).style("cursor","grab");
  }
}

function dragsubject() {
  var node = simulation.find(transform.invertX(d3.event.x), transform.invertY(d3.event.y), findNodeRadius);
  if(node){
    node.position = [node.x,node.y];
    node.x = transform.applyX(node.x);
    node.y = transform.applyY(node.y);
  }
  return node;
}

function dragstarted(d) {
  if (!d3.event.active) simulation.alphaTarget(0.3).restart();
  var node = d3.event.subject;
  if(typeof node.fx == 'number' || typeof node.fy == 'number')
    node.fixed = true;
  node.fx = transform.invertX(node.x);
  node.fy = transform.invertY(node.y);
}

function dragged(d) {
    d3.event.subject.fx = transform.invertX(d3.event.x);
    d3.event.subject.fy = transform.invertY(d3.event.y);
}

function dragged_constructural(d) {
    var node = d3.event.subject;
    if(node.type=="parent"){
      var dx = node.fx,
          dy = node.fy;
    }
    node.fx = transform.invertX(d3.event.x);
    node.fy = transform.invertY(d3.event.y);
    if(node.type=="parent"){
      dx = node.fx-dx;
      dy = node.fy-dy;
      Graph.nodes.filter(checkSelectable)
        .filter(function(n){ return isDescendant(n,node); })
        .forEach(function(n){
          n.fx = n.fx + dx;
          n.fy = n.fy + dy;
        })
    }
}

function isDescendant(node,parent){
  var links = Graph.links.filter(function(link){ return link.Target==node[options.nodeName] && link.Constructural });
  for(var i = 0; i<links.length; i++){
    if(links[i].Source==parent[options.nodeName]){
      return true;
    }else if(isDescendant(links[i].source,parent)){
      return true;
    }
  }
  return false;
}

function dragended(d) {
  if (!d3.event.active) simulation.alphaTarget(0);
  var node = d3.event.subject;

  if(node.position[0].toFixed(3)==node.fx.toFixed(3) && node.position[1].toFixed(3)==node.fy.toFixed(3)){
    // only click (not dragging)
    node.fx = node.x = node.position[0];
    node.fy = node.y = node.position[1];
  }
  delete node.position;

  if (options.dynamicNodes && !node.fixed) {
    node.fx = null;
    node.fy = null;
  }
  if(node.fixed)
    delete node.fixed;

  d3.select(this).style("cursor","grab");
}

function getGroups(nodes){
    var groups = [];
    if(options.nodeGroup){
      groups = d3.map(nodes.filter(function(node){ return node[options.nodeGroup] !== null; }), function(node){ return node[options.nodeGroup]; }).keys()
      .map(function(g){
        var group = {};
        group[options.nodeGroup] = g;
        group.xExt = [0,0];
        group.yExt = [0,0];
        return group;
      });
    }
    return groups;
}

function getArea(group,nodes){
    var points = nodes.filter(function(node){ return node[options.nodeGroup]==group[options.nodeGroup]; }).map(function(node){ return [node.x,node.y]; }),
        xExt = d3.extent(points,function(point){ return point[0];}),
        yExt = d3.extent(points,function(point){ return point[1];});
    return [xExt[0]-3,yExt[0]-3,xExt[1]-xExt[0]+6,yExt[1]-yExt[0]+6];
}

function getLinkCoords(link){
      var sx = link.source.x,
          sy = link.source.y,
          tx = link.target.x,
          ty = link.target.y,
          offSetX,
          offSetY;

      if(sx==tx && sy==ty)
        return 0;

      if(options.showArrows || link.linkNum){
        var dx = tx - sx,
            dy = ty - sy;

        var dr = Math.sqrt((dx * dx) + (dy * dy));

        if(options.showArrows){
          var radius = (link.target.nodeSize),
              offsetX = (dx * radius) / dr,
              offsetY = (dy * radius) / dr;

          tx = tx - offsetX;
          ty = ty - offsetY;
        }

        if(link.linkNum){
          var offset = (Math.ceil(link.linkNum/2))*10;

          var midpoint_x = (sx + tx) / 2,
              midpoint_y = (sy + ty) / 2;

          var offSetX = offset*(dy/dr),
              offSetY = offset*(dx/dr);

          if(link.linkNum%2 ^ (link.Target<link.Source)){
            offSetX = midpoint_x + offSetX;
            offSetY = midpoint_y - offSetY;
          }else{
            offSetX = midpoint_x - offSetX;
            offSetY = midpoint_y + offSetY;
          }
        }
      }

      return [[sx,sy],[tx,ty],[offSetX,offSetY]];
}

function getArrow(x1,y1,x2,y2,w){
    var w = w ? Math.log(w+1)/Math.log(10) : 1;
    var dx = x2-x1,
        dy = y2-y1,
        dr = Math.sqrt(dx*dx+dy*dy),
        tx = dx/dr*8,
        ty = dy/dr*8,
        x3 = x2-(ty/2*w)-tx,
        y3 = y2+(tx/2*w)-ty,
        x4 = x2+(ty/2*w)-tx,
        y4 = y2-(tx/2*w)-ty;
    return [[x4,y4],[x2,y2],[x3,y3]];
}

function getLinkTextCoords(link){
        var x = ((link.target.x)+(link.source.x))/2,
            y = ((link.target.y)+(link.source.y))/2;

        if(link.linkNum){
          x = x + (link.linkNum%2==0? -1 : 1) * (Math.ceil(link.linkNum/2)*6);
          y = y + (Math.floor(link.linkNum/2)%2==0? -1 : 1) * ((6*Math.ceil(link.linkNum/2))-3);
        }

        return [x,y];
}

function forceEnd(){
  if(options.dynamicNodes && !options.showCoordinates){
    updateAxes();
  }
}

function updateAxes(){
    var nodes = simulation.nodes();

    if(nodes.length>1){
      var extX = d3.extent(nodes, function(d){ return d.x; }),
          extY = d3.extent(nodes, function(d){ return d.y; });
      var size = d3.max([extX[1],extX[0],extY[1],extY[0]].map(function(d){ return Math.abs(d); }));
      size = size*2 + axisExtension;
    }else{
      var size = Math.min(width,height)-axisExtension;
    }

    d3.selectAll(".net .axis")
        .attr("x1",function(d){ return -(d[0]*size/2); })
        .attr("y1",function(d){ return -(d[1]*size/2); })
        .attr("x2",function(d){ return (d[0]*size/2); })
        .attr("y2",function(d){ return (d[1]*size/2); })
        .style("opacity",+options.showAxes)

    d3.selectAll(".net .axisLabel")
      .style("opacity",+options.showAxes)
      .attr("x",function(d,i){
        switch(i){
          case 1:
            return 0;
          case 2:
            return (-size-4)/2;
          case 3:
            return 0;
          default:
            return size/2;
        }
      })
      .attr("y",function(d,i){
        switch(i){
          case 1:
            return (-size-4)/2;
          case 2:
            return 4*options.cex;
          case 3:
            return size/2 + 8*options.cex;
          default:
            return 4*options.cex;
        }
      })
}

function setSomeSale(callback){
  var config = {
    scale: false,
    data: [],
    item: "",
    itemAttr: "",
    exports: callback
  }

  config.exports.getScale = function(){
    return config.scale;
  }

  config.exports.data = function(x) {
      if (!arguments.length) return config.data;
      config.data = x;
      return config.exports;
  };

  config.exports.item = function(x) {
      if (!arguments.length) return config.item;
      config.item = x;
      return config.exports;
  };

  config.exports.itemAttr = function(x) {
      if (!arguments.length) return config.itemAttr;
      config.itemAttr = x;
      return config.exports;
  };

  config.exports.domain = function(x) {
      if (!arguments.length){
        return config.scale ? config.scale.domain() : false;
      }
      if(config.scale){
        config.scale.domain(x);
      }
      return config.exports;
  };

  config.exports.range = function(x) {
      if (!arguments.length){
        return config.scale ? config.scale.range() : false;
      }
      if(config.scale){
        config.scale.range(x);
      }
      return config.exports;
  };

  return config;
}

function setShapeScale(){
  var config = setSomeSale(function(obj){
    var shape = defaultShape;
    if(config.scale){
      shape = config.scale(obj[options[config.itemAttr]]);
    }
    return d3["symbol"+shape];
  });

  config.exports.computeScale = function(){
    if(options[config.itemAttr]){
      var domain = d3.map(config.data, function(d) { return d[options[config.itemAttr]]; }).keys(),
          range = [];
      domain.forEach(function(d,i){
        range[i] = symbolTypes[i%symbolTypes.length];
      })
      config.scale = d3.scaleOrdinal()
         .range(range)
         .domain(domain);
    }
    return config.exports;
  }

  return config.exports;
}

function setColorScale(){
  var config = setSomeSale(function(obj){
    if(config.scale){
      return (obj[options[config.itemAttr]] === null)? (config.item == "node"? "#ffffff" : "#000000") : config.scale(obj[options[config.itemAttr]]);
    }else{
      return config.item == "link" && !options.heatmap ? defaultLinkColor : defaultColor;
    }
  });

  config.datatype = "string";

  config.exports.computeScale = function(){
    if(options[config.itemAttr]){
      config.datatype = dataType(config.data,options[config.itemAttr]);
      var domain, range;
      if(config.datatype == "number"){
        domain = d3.extent(config.data.filter(function(d){ return d !== null; }), function(d) { return d[options[config.itemAttr]]; });
        if(options[config.item+"Bipolar"]){
          var absmax = Math.max(Math.abs(domain[0]),Math.abs(domain[1]));
          domain = [-absmax,+absmax];
        }
        range = colorScales[options["colorScale"+config.itemAttr]];
        if(range.length==3){
          domain = [domain[0],d3.mean(domain),domain[1]];
        }
        config.scale = d3.scaleLinear()
          .range(range)
          .domain(domain);
      }else{
        domain = d3.map(config.data.filter(function(d){ return d[options[config.itemAttr]] !== null; }), function(d){ return d[options[config.itemAttr]]; }).keys();
        range = [];
        domain.forEach(function(d,i){
          range[i] = categoryColors[i%categoryColors.length];
        })
        config.scale = d3.scaleOrdinal()
          .range(range)
          .domain(domain);
      }
    }
    return config.exports;
  }

  config.exports.displayScale = function(){
    if(config.scale && config.datatype == "number"){
      var div = legendPanel.append("div")
      .attr("class","scale")

      div.append("img")
        .attr("width","24")
        .attr("height","24")
        .attr("src",b64Icons.edit)
        .on("click",function(){
          displayPicker(options,config.itemAttr,function(){
            delete VisualHandlers[config.itemAttr];
            drawNet();
          });
        })

      div = div.append("div");

      div.append("div")
      .attr("class","title")
      .text("Color / "+options[config.itemAttr])
      .on("click",function(){
          displayVisualPicker("Color");
      });

      var scaleWidth = div.node().offsetWidth - parseInt(div.style("padding-right"));

      div.append("svg")
      .attr("width", scaleWidth)
      .attr("height",10)
      .append("rect")
        .attr("x",0)
        .attr("y",0)
        .attr("height",10)
        .attr("width",scaleWidth)
        .attr("rx",2)
        .attr("fill", "url(#"+options["colorScale"+config.itemAttr]+")");

      var domain = config.scale.domain();

      div.append("span")
      .attr("class","domain1")
      .text(formatter(domain[0]));

      div.append("span")
      .attr("class","domain2")
      .text(formatter(domain[domain.length-1]));
    }
  }

  return config.exports;
}

function getNumAttr(data,itemAttr,range,def){
    if(options[itemAttr]){
      if(data.length){
        if(dataType(data,options[itemAttr]) == "number"){
          var item = itemAttr.slice(0,4),
              attrDomain;
          if(options[item+"Bipolar"])
            attrDomain = [0,d3.max(data, function(d) { return Math.abs(d[options[itemAttr]]); })];
          else
            attrDomain = d3.extent(data, function(d) { return +d[options[itemAttr]]; });
          if(attrDomain[0]!=attrDomain[1]){
            var scaleAttr = d3.scaleLinear()
              .range(range)
              .domain(attrDomain);

            return function(d){
              if(d[options[itemAttr]] === null && (itemAttr == 'linkWidth' || itemAttr == 'linkIntensity'))
                return 0;
              if(options[item+"Bipolar"]){
                return scaleAttr(Math.abs(d[options[itemAttr]]));
              }else{
                if(d[options[itemAttr]] === null && attrDomain[0]<0)
                  return range[0];
                return scaleAttr(+d[options[itemAttr]]);
              }
            }
          }
        }
      }
    }
    return function(){ return def; }
}

function addGradient(defs,id, stops){
  var offset = 100/(stops.length-1);
  var gradient = defs.append("linearGradient")
    .attr("id",id)
    .attr("x1","0%")
    .attr("y1","0%")
    .attr("x2","100%")
    .attr("y2","0%");

  stops.forEach(function(d, i){
    gradient
    .append("stop")
    .attr("offset",(offset*i)+"%")
    .style("stop-color",d);
  });
}

function displayVisualPicker(type){
  var win = displayWindow(400),
      attrData = Graph.nodenames.filter(function(d){ return hiddenFields.indexOf(d)==-1; });
  attrData.unshift("-"+texts.none+"-");
  win.append("h2")
    .text(texts.selectattribute+texts[type])
  var ul = win.append("ul")
    .attr("class","visual-selector")
  ul.selectAll("li")
      .data(attrData)
    .enter().append("li")
      .text(String)
      .property("val",String)
      .classed("active",function(d){
        return d==options["node"+type];
      })
      .on("click",function(attr){
        ul.selectAll("li").classed("active",false);
        d3.select(this).classed("active",true);
        applyAuto("node"+type,attr);
        displaySidebar();
        d3.select("div.window-background").remove();
      })
}

function displayInfoPanel(info){

  var div = body.select("div.infopanel"),
      prevPanel = !div.empty();

  if(info){
    div.remove();
    if(!infoLeft){
      infoLeft = docSize.width * 2/3;
    }
    div = body.append("div")
          .attr("class","infopanel");
    var infoHeight = (options.showTables ? 10 + height : docSize.height - 10)
      - parseInt(div.style("top"))
      - parseInt(div.style("padding-top"))
      - parseInt(div.style("padding-bottom"));
    div.style("height",infoHeight+"px");
    div.style("left",docSize.width+"px").transition().duration(prevPanel?0:500)
      .style("left",infoLeft+"px")
    div.append("div")
      .attr("class","drag")
      .call(d3.drag()
        .on("start", function() {
          contentDiv.style("display","none");
        })
        .on("drag", function() {
          var left = d3.mouse(body.node())[0]-parseInt(div.style("border-left-width"));
          if(left>(docSize.width*2/4) && left<(docSize.width*3/4)){
            infoLeft = left;
            div.style("left",infoLeft+"px");
          }
        })
        .on("end", function() {
          contentDiv.style("display",null);
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
    var contentDiv = div.append("div").append("div").html(info);
  }else{
    div.select("div.infopanel > div.close-button").dispatch("click");
  }
}

function selectAllNodes(){
  Graph.nodes.forEach(function(d){
    if(checkSelectable(d)){
      d.selected = true;
    }
  });
  showTables();
}

function filterSelection(){
    Graph.nodes.forEach(function(d){
      if(!d.selected)
        d._hidden = true;
    });
    drawNet();
}

function showHidden(){
  egoNet = false;
  Graph.nodes.forEach(function(d){
    delete d._hidden;
    delete d._neighbor;
  });
  Graph.links.forEach(function(d){
    delete d._hidden;
  });
  drawNet();
}

function addNeighbors(){
    Graph.links.forEach(function(d){
      if(checkSelectableLink(d))
        if(d.source.selected || d.target.selected)
          d.source.__neighbor = d.target.__neighbor = true;
    });
    Graph.nodes.forEach(function(d){
      d.selected = checkSelectable(d) && d.__neighbor;
      delete d.__neighbor;
    });
    showTables();
}

function switchEgoNet(){
    egoNet = true;
    Graph.nodes.forEach(function(d){
      if(d.selected){
        d._neighbor = true;
      }else{
        delete d._neighbor;
      }
    });
    Graph.links.forEach(function(d){
      if(!d._hidden && !d._hideFrame)
        if(d.source.selected || d.target.selected)
          d.target._neighbor = d.source._neighbor = true;
    });
    drawNet();
}

function checkSelectable(node){
  var selectable = !node._hidden && !node._hideFrame;
  if(egoNet)
    selectable = selectable && node._neighbor;
  return selectable;
}

function checkSelectableLink(link){
  var selectable = !link._hidden && !link.target._hidden && !link.source._hidden && !link._hideFrame;
  if(egoNet)
    selectable = selectable && ((link.source.select || link.source._neighbor) && (link.target.select || link.target._neighbor));
  return selectable;
}

function treeAction(){
  if(!selectedNodesLength()){
      Graph.nodes.forEach(function(d){
        if(checkSelectable(d))
          d.selected = true;
      });
  }

  Graph.nodes.filter(function(d){
      return d.selected;
  }).forEach(function(d){
    if(d.childNodes.length){
        d.childNodes.forEach(function(c){
          c.selected = true;
          delete c._hidden;
        });
        d._hidden = true;
        delete d.selected;
    }else{
        return2roots(d);
    }
  });

  if(egoNet){
      switchEgoNet();
  }else{
      drawNet();
  }
}

function treeActionExpand(){
  Graph.nodes.filter(function(d){
      return d.selected;
  }).forEach(function(d){
        d.childNodes.forEach(function(c){
          c.selected = true;
          delete c._hidden;
        });
        d._hidden = true;
        delete d.selected;
  });

  if(egoNet){
      switchEgoNet();
  }else{
      drawNet();
  }
}

function treeActionCollapse(){
  Graph.nodes.filter(function(d){
      return d.selected;
  }).forEach(return2roots);

  if(egoNet){
      switchEgoNet();
  }else{
      drawNet();
  }
}

function return2roots(d){
    if(d.parentNode){
      delete d.selected;
      return2roots(d.parentNode);
    }else{
      d.selected = true;
      delete d._hidden;
    }
}

function stopResumeNet(){
  if(options.dynamicNodes){
    Graph.nodes.forEach(function(node){
        delete node.fx;
        delete node.fy;
    });
    if(backupNodes){
      backupNodes.forEach(function(node){
        delete node.fx;
        delete node.fy;
      });
    }
    update_forces();
  }else{
    Graph.nodes.forEach(function(node){
        node.fx = node.x ? node.x : 0;
        node.fy = node.y ? node.y : 0;
    });
    simulation.stop();
  }
  displaySidebar();
}

function clickHide(items, show, callback) {
    items.transition()
      .duration(500)
      .style("opacity", +show)
      .on("end",callback ? callback : null)
}

function showAxesFunction(){
  if(!options.showCoordinates){
    clickHide(d3.selectAll(".net .axis, .net .axisLabel"), options.showAxes);
  }else{
    clickHide(d3.selectAll(".plot > svg > .axis, .plot > svg > .axisLabel"), options.showAxes);
  }
}


function showLegendFunction(){
  panel.select(".legend-panel > .legends").style("display",options.showLegend ? null : "none");
  panel.select(".legend-panel > .show-panel-button").style("display",!options.showLegend ? null : "none");
}

function displayLegend(){
  var parent,
      legend,
      type,
      key,
      title,
      text = stripTags,
      color = "#000000",
      shape = defaultShape,
      data = [];

  function exports(parent){

    if(!data.length)
      return 0;

    legend = parent.append("div")
    .attr("class","legend")
    .property("key",key)

    legend.append("div")
        .attr("class","title")
        .text(texts[type] + " / " + (typeof title == "undefined" ? key : title))
        .on("click",function(){
          displayVisualPicker(type);
        })

    legend.append("hr")
    .attr("class","legend-separator")

    var row = legend.selectAll("div.legend-item")
      .data(data)
    .enter().append("div")
      .attr("class","legend-item")

    displaycheck(row,function(self){
      var compare = function(value){
        value = String(value);
        Graph.nodes.forEach(function(d){
          if(d3.event.ctrlKey && !d3.event.shiftKey){
            delete d.selected;
          }
          if(checkLegendKeyValue(d,key,value)){
            if(self.selected && checkSelectable(d)){
              d.selected = true;
            }else{
              delete d.selected;
            }
          }
        });
      }
      if(d3.event.shiftKey && row.filter(function(d){ return this.selected; }).size()>1){
        var first = false,
            last = false;
        row.each(function(d,i){
          if(this.selected){
            if(first===false){
              first = i;
            }
            last = i;
          }
        });
        row.filter(function(d,i){
          return i>=first && i<=last;
        }).each(compare);
      }else{
        compare(d3.select(self).datum());
      }
    },true);

    if(type == "Image"){
      row.append("img")
        .attr("src", String)
        .attr("width",16)
        .attr("height",16)
    }else{
      row.append("svg")
        .attr("width",16)
        .attr("height",16)
      .append("path")
      .attr("transform","translate(8,8)")
      .attr("d", d3.symbol().type(typeof shape=="function" ? function(d){ return d3["symbol"+shape(d)]; } : d3["symbol"+shape]))
      .style("fill", color)

      if(typeof color == "function"){
        row.each(function(d,i){
          d3.select(this).select("svg").on("click",function(){
            displayPicker2(d,color(d),function(val){
              var range = color.range(),
                  domain = color.domain();
              range[domain.indexOf(d)] = val;
              color.range(range)
              drawNet();
            });
            d3.event.stopPropagation();
          })
        })
      }
      if(typeof shape == "function"){
        row.each(function(d,i){
          d3.select(this).select("svg").on("click",function(){
            displayPickerShape(d,shape(d),symbolTypes,function(val){
              var range = shape.range(),
                  domain = shape.domain();
              range[domain.indexOf(d)] = val;
              shape.range(range)
              drawNet();
            });
            d3.event.stopPropagation();
          })
        })
      }
    }

    row.append("span")
      .text(text)
  }

  exports.type = function(x) {
      if (!arguments.length) return type;
      type = x;
      return exports;
  };

  exports.key = function(x) {
      if (!arguments.length) return key;
      key = x;
      return exports;
  };

  exports.data = function(x) {
      if (!arguments.length) return data;
      data = x;
      return exports;
  };

  exports.title = function(x) {
      if (!arguments.length) return title;
      title = x;
      return exports;
  };

  exports.text = function(x) {
      if (!arguments.length) return text;
      text = x;
      return exports;
  };

  exports.color = function(x) {
      if (!arguments.length) return color;
      color = x;
      return exports;
  };

  exports.shape = function(x) {
      if (!arguments.length) return shape;
      shape = x;
      return exports;
  };

  return exports;
}

// render checkbox
function displaycheck(sel,callback,item){

    if(item){
      sel.property("item",true);
    }

    sel.append("div")
    .attr("class","legend-check-box")

    sel.style("cursor","pointer")
    .on("click",function(){
      this.selected = !this.selected;
      callback(this);
      showTables();
    })
}

function checkLegendKeyValue(d,key,value){
  return String(d[key])==value || (d[key] && (typeof d[key] == "object" && (d[key].indexOf(value)!=-1 || d[key].join(",")==value)));
}

function displayBottomButton(sel,text,tooltip,callback){
      sel.append("button")
        .attr("class","legend-bottom-button primary disabled")
        .text(texts[text])
        .on("click",function(){
          var selected = legendPanel.selectAll("div.legend-item").filter(function(){ return this.selected; });
          Graph.nodes.forEach(function(d){
            delete d.selected;
            if(checkSelectable(d)){
              selected.each(function(value){
                if(!d.selected){
                  var key = this.parentNode.key;
                  if(checkLegendKeyValue(d,key,value)){
                    d.selected = true;
                  }
                }
              })
            }
          });
          showTables();
          callback();
        })
        .attr("title",tooltip)
}

function getImageName(path){
  var name = path.split("/");
  name = name.pop().split(".");
  name.pop();
  return name.join(".");
}

function stripTags(text){
  text = String(text);
  if(text=="null"){
    return "NA";
  }
  return text.replace(/(<([^>]+)>)/ig,"");
}

function showTables() {
  var hidden = hiddenFields.slice((options.showCoordinates && !options.heatmap) ? 4 : 2);

  var totalItems = {};
  ["nodes","links"].forEach(function(name){
    totalItems[name] = (frameControls ? Graph[name].filter(function(d){ return !d._hideFrame; }) : Graph[name]).filter(name=="nodes" ? checkSelectable : checkSelectableLink).length;
  });

  var tableWrapper = function(dat, name, columns){
    var currentData,
        columnAlign = columns.map(function(col){
          if(dataType(dat,col) == 'number'){
            return "right";
          }
          return null;
        });
    if(name=="nodes")
      currentData = Graph.nodes.filter(checkSelectable);
    else
      currentData = Graph.links.filter(checkSelectableLink);
    var table = d3.select("div.tables > div."+name),
        last = -1,
    drawTable = function(d){
      var tr = table.append("tr")
        .datum(d.index)
        .classed("selected",function(dd){
          return currentData[dd]._selected;
        });
      columns.forEach(function(col,i){
          var txt = d[col];
          if(txt == null)
            txt = "";
          if(typeof txt == 'object'){
            if(frameControls)
              txt = txt[frameControls.frame];
            else
              txt = txt.join("; ");
          }
          if(typeof txt == 'number'){
            txt = formatter(txt);
          }
          tr.append("td").html(txt)
              .style("text-align",columnAlign[i])
              .on("mousedown",function(){ d3.event.preventDefault(); });
      });
      tr.on("click",function(origin,j){
          if(d3.event.shiftKey && last!=-1)
            var selecteds = d3.range(Math.min(last,this.rowIndex),Math.max(last,this.rowIndex)+1);
          table.selectAll("tr").classed("selected", function(d,i){
            var selected = d3.select(this).classed("selected");
            if(selecteds){
              if(d3.event.ctrlKey || d3.event.metaKey)
                selected = selected || selecteds.indexOf(i)!=-1;
              else
                selected = selecteds.indexOf(i)!=-1;
            }else{
              if(d3.event.ctrlKey || d3.event.metaKey){
                selected = selected ^ d == origin;
              }else{
                selected = d == origin;
                if(options.nodeText){
                  plot.selectAll("div.tooltip").remove();
                  if(name=="nodes"){
                    showTooltip(currentData[origin],true);
                  }else{
                    showTooltip(currentData[origin].source,true);
                    showTooltip(currentData[origin].target,true);
                  }
                }
              }
            }
            if(!options.heatmap){
              currentData[d]._selected = selected;                
            }
            return selected;
          })
          if(!options.heatmap)
            simulation.restart();

          d3.select("button.primary.tableselection").classed("disabled",table.selectAll("tr.selected").empty());

          if(d3.select(this).classed("selected"))
            last = this.rowIndex;
          else
            last = -1;
        });
    },

    drawHeader = function() {
        var thead = table.append("thead"),
            tbody = table.append("tbody"),
            desc = columns.map(function(){ return false; });
        columns.forEach(function(d,i){
          var sort1 = function(a,b){
                var rv = [1,-1];
                if(a[d]==null) return rv[0];
                if(b[d]==null) return rv[1];
                a = a[d][options.nodeName]?a[d][options.nodeName]:a[d];
                b = b[d][options.nodeName]?b[d][options.nodeName]:b[d];
                if(desc[i]){
                  rv = rv.reverse();
                }
                if (a > b) {
                  return rv[0];
                }
                if (a < b) {
                  return rv[1];
                }
                return 0;
              };
          thead.append("th")
            .attr("class","sorting")
            .text(d)
            .style("text-align",columnAlign[i])
            .on("click",function(){
              tbody.html("");
              dat.sort(sort1);
              var desci = desc[i];
              desc = columns.map(function(){ return false; });
              thead.selectAll("th").attr("class","sorting");
              desc[i] = !desci;
              d3.select(this).attr("class",desci ? "sorting_desc" : "sorting_asc");
              dat.forEach(drawTable);
            });
        });
        return tbody;
    }

    d3.select("div.tables > div.table-header > div.table-title."+name)
      .html("<span>"+texts[name+"attributes"] + "</span> ("+dat.length+" "+texts.outof+" "+totalItems[name]+")")
    table.html("");
    table = table.append("div");
    if(dat.length==0){
      table.style("cursor",null);
      table.on('mousedown.drag', null);
      table.text(texts.noitemsselected);
    }else{
      table = table.append("table");
      table.on("mousedown", function(){ d3.event.stopPropagation(); })
      table = drawHeader();
      dat.forEach(drawTable);
      table.each(function(){
        var twidth = this.parentNode.offsetWidth,
            itemDiv = d3.select(this.parentNode.parentNode.parentNode),
            thidden = itemDiv.style("display") == "none";
        if(thidden){
          itemDiv.style("display",null);
          twidth = this.parentNode.offsetWidth;
          itemDiv.style("display","none");
        }
        d3.select(this.parentNode.parentNode)
            .style("width",(twidth+8)+"px")
            .style("cursor","col-resize")
            .call(d3.drag()
              .on("drag",function(){
                var coorx = d3.mouse(this)[0],
                    self = d3.select(this),
                    selfTable = self.select("table");
                selfTable.style("width",(coorx-8)+"px");
                if(selfTable.node().offsetWidth > (coorx-8))
                  selfTable.style("width",selfTable.node().offsetWidth+"px");
                else
                  self.style("width",coorx+"px");
              })
            )
      })
    }
  },

  cleanData = function(d){
    var dReturn = {}, key;
    for(key in d)
      if(hidden.indexOf(key)==-1)
        dReturn[key] = d[key];
    return dReturn;
  },

  filterHidden = function(d){
    return hidden.indexOf(d)==-1;
  };

  var nodesData = Graph.nodes.filter(function(d){
        delete d._selected;
        return checkSelectable(d) && d.selected;
      }).map(cleanData),
      linksData = Graph.links.filter(function(d){
        delete d._selected;
        return checkSelectableLink(d) && (d.source.selected && d.target.selected);
      }).map(cleanData),
      nodeColumns = Graph.nodenames.filter(filterHidden),
      linkColumns = Graph.linknames.filter(filterHidden);

  if(options.showCoordinates && !options.heatmap){
    nodeColumns = d3.merge([nodeColumns,["x","y"]]);

    nodesData.forEach(function(d){
      d["x"] = parseFloat(scaleCoorX.invert(d["x"]).toFixed(2));
      d["y"] = parseFloat(scaleCoorY.invert(d["y"]).toFixed(2));
    });
  }

  tableWrapper(nodesData,"nodes",nodeColumns);
  tableWrapper(linksData,"links",linkColumns);

  // hide infopanel
  if(!body.select("div.infopanel").empty() && nodesData.length==0){
    body.select("div.infopanel > div.close-button").dispatch("click");
  }

  // update frequency bars
  if(!body.select("div.frequency-barplots").empty()){
    displayFreqBars();
  }

  // highlight egonet of selection
  if(!options.heatmap){
    var names = nodesData.map(function(node){ return node[options.nodeName]; });
    if(nodesData.length && nodesData.length!=totalItems["nodes"]){
      Graph.nodes.forEach(function(node){
        delete node._back;
        if(checkSelectable(node) && !node.selected){
          node._back = true;
        }
      })
      Graph.links.forEach(function(link){
        delete link._back;
        if(checkSelectableLink(link)){
          if(names.indexOf(link.Source)!=-1 || names.indexOf(link.Target)!=-1){
            delete link.source._back;
            delete link.target._back;
          }else{
            link._back = true;
          }
        }
      })
    }else{
      Graph.links.forEach(function(link){
        delete link._back;
      })
      Graph.nodes.forEach(function(node){
        delete node._back;
      })
    }
    simulation.restart();
  }

  // update sidebar filter selected
  updateSidebarFilters();

  // check legend items checked
  checkLegendItemsChecked();

  // enable/disable selection buttons
  if(nodesData.length){
    d3.selectAll("button.primary.selectneighbors, button.primary.isolate, button.primary.filter").classed("disabled",!(nodesData.length<totalItems["nodes"]));
    if(Graph.tree){
      d3.selectAll("button.primary.expand, button.primary.collapse").classed("disabled",true);
      Graph.nodes.filter(checkSelectable).forEach(function(node){
          if(node.childNodes.length){
            d3.selectAll("button.primary.expand").classed("disabled",false);
          }
          if(node.parentNode){
            d3.selectAll("button.primary.collapse").classed("disabled",false);
          }
      });
    }
  }else{
    d3.selectAll("button.primary.tableselection, button.primary.selectneighbors, button.primary.isolate, button.primary.filter, button.primary.expand, button.primary.collapse").classed("disabled",true);
  }
}

// check checkboxes after node selections
function checkLegendItemsChecked() {
    var parent = legendPanel.select(".legends > div.legends-content"),
        legendSelectAll = legendPanel.select(".legend-selectall");
    if(!legendSelectAll.empty()){
      var items = parent.selectAll(".legend-item");
      if(!items.empty()){
        var unselectedNodes = Graph.nodes.filter(checkSelectable).filter(function(d){ return !d.selected; });

        items.each(function(value){
          checkInBox(this,true);
          var key = this.parentNode.key;
          for(var i = 0; i<unselectedNodes.length; i++){
            var d = unselectedNodes[i];
            if(checkLegendKeyValue(d,key,value)){
              checkInBox(this,false);
              break;
            }
          }
        })

        var size = items.filter(function(){ return this.selected; }).size();
        checkInBox(legendSelectAll.node(), size ? true : false);
        legendPanel.selectAll("button.legend-bottom-button").classed("disabled",!size || size==items.size());
      }
    }

    // visually mark/unmark checkbox
    function checkInBox(thiz,select){
        var checkBox = d3.select(thiz).select(".legend-check-box");
        thiz.selected = select;
        checkBox.classed("checked",select)
    }
}

function tables2xlsx(){
      var nodes = [],
          links = [],
          tableNodes = d3.select(".tables .nodes table"),
          tableLinks = d3.select(".tables .links table"),
          loadData = function(table){
            var items = [];
            items.push([]);
            table.selectAll("th").each(function(){
              items[0].push(d3.select(this).text());
            })
            table.selectAll("tr").each(function(){
              var row = [];
              d3.select(this).selectAll("td").each(function(){
                var dat = d3.select(this).text();
                if(d3.select(this).style("text-align")=="right") dat = +dat;
                row.push(dat);
              })
              items.push(row);
            })
            return items;
          }
      if(!tableNodes.empty()){
        nodes = loadData(tableNodes);
      }
      if(!tableLinks.empty()){
        links = loadData(tableLinks);
      }
      if(nodes.length == 0 && links.length == 0)
        displayWindow()
            .append("p")
              .attr("class","window-message")
              .text(texts.noitemsselected);
      else
        downloadExcel({nodes: nodes, links: links}, d3.select("head>title").text());
}

function selectNodesFromTable(){
        var names = [],
            index = 0,
            trSelected;
        if(d3.select("div.tables > div.nodes").style("display")=="block"){
          trSelected = d3.selectAll("div.tables > div.nodes table tr.selected");
          if(!trSelected.empty()){
            d3.selectAll("div.tables > div.nodes table th").each(function(d,i){
              if(this.textContent == options.nodeName)
                index = i+1;
            })
            trSelected
              .each(function(){
                names.push(d3.select(this).select("td:nth-child("+index+")").text());
              })
              .classed("selected",false);
          }
        }else{
          trSelected = d3.selectAll("div.tables > div.links table tr.selected");
          if(!trSelected.empty()){
            trSelected
              .each(function(){
                for(var i=1; i<=2; i++){
                  index = d3.select(this).select("td:nth-child("+i+")").text();
                  if(names.indexOf(index)==-1)
                    names.push(index);
                }
              })
              .classed("selected",false);
          }
        }
        if(!trSelected.empty()){
          Graph.nodes.forEach(function(d){
            d.selected = names.indexOf(d[options.nodeName]) != -1;
          });
          showTables();
        }
}

function getLayoutRange(){
  var xrange, yrange;
  if(options.showCoordinates){
      var offsetTop = 50,
          offsetRight = sidebarWidth + 40,
          offsetBottom = 50*Math.max(options.cex,1),
          offsetLeft = sidebarWidth + 40;

      if(options.note){
        offsetBottom = offsetBottom + divNote.node().clientHeight;
      }

      xrange = [offsetLeft,width-offsetRight],
      yrange = [offsetTop,height-offsetBottom];
  }else{
      var size = Math.min(width,height) / 1.2;

      xrange = [0,size].map(function(d){ return ((width-size)/2)+d; });
      yrange = [0,size].map(function(d){ return ((height-size)/2)+d; });
  }
  return { x: xrange, y: yrange };
}

function selectLayout(key){
  if(Graph.layouts){
    if(!key){
      key = d3.keys(Graph.layouts)[0];
    }
    Graph.nodes.forEach(function(node,i){
      var coor = Graph.layouts[key][i];
      node.fx = coor[0];
      node.fy = coor[1];
    })
  }
}

function adaptLayout(){
  plot.style("width",width+"px");
  plot.style("height",height+"px");

  var initialize = false;
  if(typeof options.dynamicNodes == "undefined"){
    initialize = true;
    options.dynamicNodes = true;
  }

  var anyFixed = false,
      nodes = backupNodes ? backupNodes : Graph.nodes;

  if(options.dynamicNodes){
    for(var i=0; i<nodes.length; i++){
      if(nodes[i].hasOwnProperty("fx") || nodes[i].hasOwnProperty("fy")){
        anyFixed = true;
        break;
      }
   }
  }else{
    anyFixed = true;
  }

  if(anyFixed){
    if(initialize){
      var xdim, ydim,
          centerDim = function(dim){
            if(dim[0]==dim[1]){
              dim[0] = dim[0] - 1;
              dim[1] = dim[1] + 1;
            }
            return dim;
          }

      if(options.hasOwnProperty("limits") && options.limits.length==4){
        xdim = [options.limits[0],options.limits[2]];
        ydim = [options.limits[1],options.limits[3]];
      }else{
        if(backupNodes){
          xdim = centerDim(d3.extent(d3.merge(nodes.map(function(d){ return d.fx }))));
          ydim = centerDim(d3.extent(d3.merge(nodes.map(function(d){ return d.fy }))));
        }else{
          xdim = centerDim(d3.extent(nodes,function(d){ return d.fx }));
          ydim = centerDim(d3.extent(nodes,function(d){ return d.fy }));
        }
        var dx = xdim[1] - xdim[0],
            dy = ydim[1] - ydim[0];
        xdim[0] = xdim[0] - dx*0.04;
        xdim[1] = xdim[1] + dx*0.04;
        ydim[0] = ydim[0] - dy*0.04;
        ydim[1] = ydim[1] + dy*0.04;
      }

      scaleCoorX = d3.scaleLinear().domain(xdim);
      scaleCoorY = d3.scaleLinear().domain(ydim);
    }else{
      if(backupNodes){
        backupNodes.forEach(function(d){
          if(d.hasOwnProperty("fx")){
            d.fx = d.fx.map(function(e){ return(scaleCoorX.invert(e)); });
          }
          if(d.hasOwnProperty("fy")){
            d.fy = d.fy.map(function(e){ return(scaleCoorY.invert(e)); });
          }
        });
      }else{
        Graph.nodes.forEach(function(d){
          if(typeof d.fx == 'number'){
            d.fx = scaleCoorX.invert(d.fx);
          }
          if(typeof d.fy == 'number'){
            d.fy = scaleCoorY.invert(d.fy);
          }
        });
      }
    }

    var range = getLayoutRange(),
        dx = range.x[1]-range.x[0],
        dy = range.y[1]-range.y[0];

    range.x = range.x.map(function(d){ return d-(width/2); });
    range.y = range.y.map(function(d){ return d-(height/2); });

    range.y.reverse();

    scaleCoorX.range(range.x);
    scaleCoorY.range(range.y);

    options.dynamicNodes = false;
    if(backupNodes){
      backupNodes.forEach(function(d){
        if(d.hasOwnProperty("fx")){
          d.fx = d.fx.map(function(e){ return(scaleCoorX(e)); });
        }else{
          options.dynamicNodes = true;
        }
        if(d.hasOwnProperty("fy")){
          d.fy = d.fy.map(function(e){ return(scaleCoorY(e)); });
        }else{
          options.dynamicNodes = true;
        }
      });
    }else{
      Graph.nodes.forEach(function(d){
        if(typeof d.fx == 'number'){
          d.fx = scaleCoorX(d.fx);
        }else{
          options.dynamicNodes = true;
        }
        if(typeof d.fy == 'number'){
          d.fy = scaleCoorY(d.fy);
        }else{
          options.dynamicNodes = true;
        }
      });
    }
  }else{
    if(initialize){
      var size = Math.min(width,height);

      scaleCoorX = d3.scaleLinear()
        .domain([0,2*width/size])

      scaleCoorY = d3.scaleLinear()
        .domain([0,-2*height/size])
    }

    scaleCoorX.range([0,width]);
    scaleCoorY.range([0,height]);
  }
}

function displayFreqBars(){
  if(!options.frequencies){
    return;
  }else if(options.frequencies!="absolute"){
    options.frequencies = "relative";
  }

  var div = body.select(".frequency-barplots");

  if(div.empty()){
    displayInfoPanel("<div class=\"frequency-barplots\"><div>");
    div = body.select(".frequency-barplots");
    div.append("div")
    .attr("class","select-wrapper")
    .append("select")
    .on("change",function(){
      options.frequencies = this.value;
      displayFreqBars();
    })
    .selectAll("option")
      .data(["absolute","relative"])
    .enter().append("option")
      .property("selected",function(d){ return options.frequencies==d; })
      .property("value",String)
      .text(String)
  }

  var renderPercentage = options.frequencies=="relative" ? "%" : "";

  Graph.nodenames.filter(function(d){ return hiddenFields.indexOf(d)==-1; }).forEach(function(name){
    var type = dataType(Graph.nodes,name);
    if(type=="string" || type=="object"){
      var values = {},
          selectedValues = {};
      Graph.nodes.forEach(function(node){
        var loadValue = function(val){
            val = String(val);
            if(!values.hasOwnProperty(val)){
              values[val] = 1;
            }else{
              values[val] += 1;
            }
            if(node.selected){
              if(!selectedValues.hasOwnProperty(val)){
                selectedValues[val] = 1;
              }else{
                selectedValues[val] += 1;
              }
            }
        }
        if(type=="object" && typeof node[name] == "object"){
          node[name].forEach(loadValue);
        }else{
          loadValue(node[name]);
        }
      });

      var maxvalue = d3.max(d3.values(values)),
          keyvalues = d3.keys(values).sort(function(a,b){
            a = values[a];
            b = values[b];
            return a > b ? -1 : a < b ? 1 : a <= b ? 0 : NaN;
          });
          selectedlength = Graph.nodes.filter(function(n){ return n.selected; }).length;

      if(options.frequencies=="relative"){
        for(v in values){
          values[v] = values[v]/GraphNodesLength*100;
        }
        for(v in selectedValues){
          selectedValues[v] = selectedValues[v]/selectedlength*100;
        }

        maxvalue = d3.max([d3.max(d3.values(values)),d3.max(d3.values(selectedValues))]);
      }

      if(keyvalues.length!=GraphNodesLength){
        var barplot = getBarPlot(name,true);

        keyvalues.forEach(function(v){
          var percentage = values[v]/maxvalue*100,
              percentage2 =  0;

          if(selectedValues[v]){
            percentage2 = selectedValues[v]/maxvalue*100;
          }

          var getValue = function(values,value){
            return options.frequencies=="relative" ? formatter(values[value])+"%" : values[value];
          }

          var row = barplot.append("div")
            .attr("class","freq-bar")
            .attr("title",v+": "+getValue(values,v) + (selectedValues[v] ? "\nSelection: "+getValue(selectedValues,v) : ""))
            .on("click",function(){
              Graph.nodes.filter(checkSelectable).forEach(function(node){
                delete node.selected;
                if(type=="object" && typeof node[name] == "object"){
                  if(node[name].indexOf(v)!=-1){
                    node.selected = true;
                  }
                }else{
                  if(node[name]==v){
                    node.selected = true;
                  }
                }
              })
              showTables();
            })
          row.append("div")
            .attr("class","freq1")
            .style("width",percentage+"%")
            .style("background-color",options.nodeColor==name ? VisualHandlers.nodeColor.getScale()(v) : null)
            .html("&nbsp;");
          row.append("div")
            .attr("class","freq2")
            .style("width",percentage2+"%")
            .html("&nbsp;");
          row.append("span")
            .text(v)
        })

        var axis = barplot.append("div")
          .attr("class","freq-axis")

        var x = d3.scaleLinear()
          .domain([0,maxvalue])

        x.ticks(5).forEach(function(t){
          axis.append("span").style("left",(t/maxvalue*100)+"%").text(t+renderPercentage);
        })
      }
    }else if(type=="number"){
      var values = Graph.nodes.map(function(node){ return +node[name]; }),
          selectedValues = Graph.nodes.filter(function(n){ return n.selected; }).map(function(node){ return +node[name]; });

      var barplot = getBarPlot(name);

      // set the dimensions and margins of the graph
      var margin = {top: 10, right: 10, bottom: 30, left: 40},
          w = ((infoLeft ? docSize.width - infoLeft : docSize.width * 1/3) - 72) - margin.left - margin.right,
          h = 200 - margin.top - margin.bottom;

      // append the svg object
      var svg = barplot.append("svg")
          .attr("width", w + margin.left + margin.right)
          .attr("height", h + margin.top + margin.bottom)
        .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      // X axis: scale and draw
      var x = d3.scaleLinear()
        .domain(d3.extent(values,function(d) { return d; }))
        .range([0, w]);

      svg.append("g")
      .attr("transform", "translate(0," + h + ")")
      .call(d3.axisBottom(x));

      // set the parameters for the histogram
      var histogram = d3.histogram()
        .value(function(d) { return d; })
        .domain(x.domain())
        .thresholds(x.ticks(10));

      // And apply this function to data to get the bins
      var bins = histogram(values),
          bins2 = selectedValues.length ? histogram(selectedValues) : [];

      for(var i = 0; i<bins.length; i++){
          bins[i].y = options.frequencies=="relative" ? bins[i].length/GraphNodesLength*100 : bins[i].length;
          if(selectedValues.length){
            bins[i].y2 = options.frequencies=="relative" ? bins2[i].length/selectedValues.length*100 : bins2[i].length;
          }
      }

      // Y axis: scale and draw
      var y = d3.scaleLinear()
        .range([h, 0])
        .domain([0, d3.max(bins, function(d) { return d.y; })]);

      svg.append("g")
      .call(d3.axisLeft(y)
        .tickFormat(function(d){
          return d + renderPercentage;
        }));

      // append the bar rectangles to the svg element
      var columns = svg.selectAll("g.freq-bar")
        .data(bins)
        .enter()
        .append("g")
          .attr("class","freq-bar")
          .attr("transform", function(d) { return "translate(" + x(d.x0) + ",0)"; })
          .style("cursor","pointer")
          .on("click",function(d,i){
              Graph.nodes.filter(checkSelectable).forEach(function(node){
                delete node.selected;
                if(node[name]>=d.x0 && ((i<bins.length-1 && node[name]<d.x1) || (i==bins.length-1 && node[name]<=d.x1))){
                  node.selected = true;
                }
              })
              showTables();
          })

      var colorScale = options.nodeColor==name ? VisualHandlers.nodeColor.getScale() : false;

      columns.append("rect")
          .attr("class","freq1")
          .attr("x", 1)
          .attr("y", function(d) { return y(d.y); })
          .attr("width", function(d) { return x(d.x1) - x(d.x0) -1 ; })
          .attr("height", function(d) { return h - y(d.y); })
          .style("fill", colorScale ? function(d){
            return colorScale((d.x0+d.x1)/2);
          } : "#cbdefb")

      if(selectedValues.length){
        columns.append("rect")
          .attr("class","freq2")
          .attr("x", 1 + 4)
          .attr("y", function(d) { return y(d.y2); })
          .attr("width", function(d) { return x(d.x1) - x(d.x0) -1 -8 ; })
          .attr("height", function(d) { return h - y(d.y2); })
          .style("fill", "#c6c6c6")
      }
    }
  })

  function getBarPlot(name,shape){
      var barplot = div.selectAll("div.bar-plot").filter(function(){ return this.variable==name; });
      if(barplot.empty()){
        barplot = div.append("div")
          .attr("class","bar-plot")
          .property("variable",name);
        var h2 = barplot.append("h2").text(name);
        if(shape){
          h2.append("img")
          .attr("title",texts.Shape)
          .attr("src",b64Icons.shapes)
          .on("click",function(){
            applyAuto("nodeShape",name);
          })
        }
        h2.append("img")
          .attr("title",texts.Color)
          .attr("src",b64Icons.drop)
          .on("click",function(){
            applyAuto("nodeColor",name);
          })
      }else{
        barplot.selectAll("*:not(h2)").remove();
      }
    return barplot;
  }
}

function embedImages(callback){

  var docSize = viewport(),
      loading = body.append("div")
      .attr("class","loading")
      .style("width",docSize.width+"px")
      .style("height",docSize.height+"px");

  loading.append("p")
    .text(texts.loading)

  if(options.imageItem){
    if(options.imageItems && !images64){

      images64 = {};

      var imgLinks = d3.set(d3.merge(options.imageItems.map(function(d){ return Graph.nodes.map(function(dd){ return dd[d]; }); }))).values();

      var loadImage = function(i){
        var imgSrc = imgLinks[i++];
        var img = images[imgSrc];
        var canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);
        try{
            images64[imgSrc] = canvas.toDataURL();
        }catch(e){
            console.log(e);
        }finally{
            if(i<imgLinks.length){
              loadImage(i);
            }else{
              callback();
              loading.remove();
            }
        }
      }

      loadImage(0);
      return 0;
    }
  }
  callback();
  loading.remove();
}

function svg2png(callback){

  var svg = d3.select(".panel > .plot > svg");

  var canvas = document.createElement("canvas");
  canvas.width = svg.attr("width");
  canvas.height = svg.attr("height");
  var ctx = canvas.getContext("2d");
  ctx.fillStyle = "#ffffff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  svg.selectAll(".zoombutton").style("display","none");
  if(options.main){
    svg.append("text")
      .attr("class","main")
      .attr({"x":+svg.attr("width")/2, "y":30})
      .style("text-anchor","middle")
      .style("font-size",d3.select("div.main span.title").style("font-size"))
      .text(options.main);
  }
  if(options.note){
    svg.append("text")
      .attr("class","note")
      .attr({"x":10, "y":+svg.attr("height")-10})
      .style("font-size",d3.select("div.note").style("font-size"))
      .text(options.note);
  }
  var svgString = new XMLSerializer().serializeToString(svg.node());
  var svgBlob = new Blob([svgString], {type: 'image/svg+xml;charset=utf-8'});
  var DOMURL = self.URL || self.webkitURL || self;
  var img = new Image();
  var url = DOMURL.createObjectURL(svgBlob);
  img.onload = function() {
    ctx.drawImage(img, 0, 0);
    canvas.toBlob(callback);
  };
  img.src = url;

  svg.select("svg>text.main").remove()
  svg.select("svg>text.note").remove()
  svg.selectAll(".zoombutton").style("display",null);
}

function svg2pdf(){
    displayWindow()
      .append("p")
        .attr("class","window-message")
        .text("The network is not loaded yet!");
}

function moveShift(key){
  if(frameControls){
    switch(key){
      case "ArrowLeft":
      case "ArrowRight":
        if(key=="ArrowLeft"){
          var val = frameControls.frame-1;
          if(val < 0){
            val = frameControls.frames.length+val;
          }
        }else{
          var val = frameControls.frame+1;
        }
        frameControls.play = false;
        handleFrames(val);
        clickFrameCtrlBtn();
      break;
    }
  }
}

function movePan(dir){
  switch(dir){
    case "ArrowUp":
      transform.y = transform.y - 10;
      break;
    case "ArrowDown":
      transform.y = transform.y + 10;
      break;
    case "ArrowLeft":
      transform.x = transform.x - 10;
      break;
    case "ArrowRight":
      transform.x = transform.x + 10;
      break;
  }
  Sliders.zoom.update(options.zoomScale).brushedValue(false);
}

function resetPan(){
  var w = width,
      h = height,
      infopanel = body.select(".infopanel");
  if(!infopanel.empty()){
    w = w-infopanel.node().offsetWidth;
  }
  transform.x = w/2;
  transform.y = h/2;
  Sliders.zoom.update(options.zoomScale).brushedValue(false);
}

function resetZoom(){
  transform.k = options.zoomScale = options.zoom;
  transform.x = width/2;
  transform.y = height/2;
  Sliders.zoom.update(options.zoomScale).brushedValue(false);
}

function computeWidth(){
  var w = docSize.width - 20;
  return w;
}

function computeHeight(){
    var h = docSize.height - 2;
    if(main){
      h = h-main.node().offsetHeight;
    }
    if(options.showTables){
      h = h - 165;
    }
    return h;
}

window.onresize = function(){
  docSize = viewport();
  width = computeWidth();
  height = computeHeight();
  displayPanelButtons();
  drawSVG();
}

} // network function end

if(typeof multiGraph == 'undefined'){
  window.onload = function(){
    network(JSON.parse(d3.select("#data").text()));
  };
}
