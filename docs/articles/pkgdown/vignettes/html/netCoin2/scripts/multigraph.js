function MultiGraph(input){
  this.json = JSON.parse(d3.select("#data").text());
  this.items = this.json.items;
  this.types = this.json.types;
  this.current = 0;
  if(input!=""){
    this.current = parseInt(input.substring(1));
    if(isNaN(this.current) || this.current>=this.items.length)
      this.current = 0;
  }
  this.json = this.json.data[this.current];
}

MultiGraph.prototype = {
  graphSelect: function(sel){
    var current = this.current,
        items = this.items;
    sel = sel.append("div").attr("class","multi-select")
    var select = sel.append("select")
    select.selectAll("option")
      .data(items)
      .enter().append("option")
        .property("value",function(d,i){ return i; })
        .text(function(d){ return d; })
        .each(function(d,i){
          if(i==current)
            this.selected = true; 
        })
    select.on("change",function(){ window.location.href = "?"+this.value; })
    sel.append("img")
        .attr("src",b64Icons.menu)
    sel.append("span")
      .html(items[current])

    d3.select("body").on("keydown.multishortcut",function(){
      if(d3.event.ctrlKey){ 
        var key = getKey(d3.event);
        switch(key){
          case "ArrowUp":
          case "ArrowDown":
            if(d3.event.shiftKey){
              var multiSelect = select.node(),
                  idx = multiSelect.selectedIndex;
              idx = (key=="ArrowUp"?idx-1:idx+1);
              if(idx<0){
                idx = items.length-1;
              }
              if(idx>=items.length){
                idx = 0;
              }
              window.location.href = "?"+idx;
            }
            return;
        }
      }
    });
  },
  getJSON: function(){
    return this.json;
  },
  getType: function(){
    return this.types[this.current];
  },
  getItem: function(){
    return this.items[this.current];
  }
}

var multiGraph = true;

window.onload = function(){
  multiGraph = new MultiGraph(window.location.search);
  var json = multiGraph.getJSON();
  switch(multiGraph.getType()){
    case 'network':
      network(json);
      break;
    case 'barplot':
      barplot(json);
      break;
    case 'timeline':
      timeline(json);
      break;
    case 'gallery':
      gallery(json);
      break;
    case 'iFrame':
      displayIframe(json);
      break;
  }
}

function displayIframe(url){

  d3.select("html").style("height","100%")
  var body = d3.select('body')
    .style("display","flex")
    .style("flex-direction","column")
    .style("width","100%")
    .style("height","100%")

  var topBar = displayTopBar();
  body.call(topBar);

  body.append("iframe")
    .style("flex-grow",1)
    .style("width","100%")
    .style("height","100%")
    .attr("src",url+"/index.html")
    .attr("frameborder",0)
    .attr("marginwidth",0)
    .attr("marginheight",0)
}

