############ Cannon impact messages #####################

var last_impact = 0;

var hit_count = 0;

var impact_listener = func {
  
  if (radar.myRadar3.Target_Index != nil and (getprop("sim/time/elapsed-sec")-last_impact) > 1) {
    var target = radar.myRadar3.tgts_list[radar.myRadar3.Target_Index];
    var ballistic_name = getprop("/ai/models/model-impact");
    var ballistic = props.globals.getNode(ballistic_name, 0);
    if (ballistic != nil) {
      var typeNode = ballistic.getNode("impact/type");
      if (typeNode != nil and typeNode.getValue() != "terrain") {
        var lat = ballistic.getNode("impact/latitude-deg").getValue();
        var lon = ballistic.getNode("impact/longitude-deg").getValue();
        var impactPos = geo.Coord.new().set_latlon(lat, lon);

        var selectionPos = target.get_Coord();

        var distance = impactPos.distance_to(selectionPos);
        if (distance < 125) {
          last_impact = getprop("sim/time/elapsed-sec");
          var phrase =  ballistic.getNode("name").getValue() ~ " hit: " ~ target.get_Callsign();
          if (getprop("payload/armament/msg")) {
            defeatSpamFilter(phrase);
			      #hit_count = hit_count + 1;
          } else {
            setprop("/sim/messages/atc", phrase);
          }
        }
      }
    }
  }
}

setlistener("/ai/models/model-impact", impact_listener, 0, 0);

var spams = 0;
var spamList = [];

var defeatSpamFilter = func (str) {
  spams += 1;
  if (spams == 15) {
    spams = 1;
  }
  str = str~":";
  for (var i = 1; i <= spams; i+=1) {
    str = str~".";
  }
  var newList = [str];
  for (var i = 0; i < size(spamList); i += 1) {
    append(newList, spamList[i]);
  }
  spamList = newList;  
}

var spamLoop = func {
  var spam = pop(spamList);
  if (spam != nil) {
    setprop("/sim/multiplay/chat", spam);
  }
  settimer(spamLoop, 1.20);
}

spamLoop();

setprop("payload/armament/msg", 1);