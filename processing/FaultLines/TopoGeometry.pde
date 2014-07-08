class TopoGeometry {

  String id;
  int[][] arcIDs;
  String idList = "|";
  ArrayList<String> allIds = new ArrayList();
  PVector origin;
  int income;

  ArrayList<TopoGeometry> neighbours = new ArrayList();
  HashMap<TopoGeometry, ArrayList<String>> neighbourArcMap = new HashMap();

  boolean checkNeighbour(TopoGeometry tg) {
    boolean chk = false;
    for (int i = 0; i < arcIDs.length; i++) {
      for (int j = 0; j < arcIDs[i].length; j++) {
        if (tg.idList.indexOf("|" + arcIDs[i][j] + "|") != -1) {
          chk = true;
          if (!neighbourArcMap.containsKey(tg)) neighbourArcMap.put(tg, new ArrayList());
          neighbourArcMap.get(tg).add(str(arcIDs[i][j]));
        }
      }
    }

    return(chk);
  }

  void drawSharedArcs(TopoGeometry t) {
    for (String as: neighbourArcMap.get(t)) {
      int aid = int(as);
      int cid = (aid >= 0) ? aid:~aid;
      TopoArc arc = map.arcs[cid];
      float diff = abs(income - t.income);
      stroke((diff > thresh && income > 1000 && t.income > 1000) ? 255: 45);
      arc.render(aid < 0);
    }
  }

  void update() {
  }

  void render() {

    if (activeTracts.contains(this)) {
      //stroke(255, map(income, 10000, 150000, 0, 255), 0, 50);
    } 
    else {
      //stroke(255, 10);
    }

    for (TopoGeometry n:neighbours) {
      drawSharedArcs(n);
    }


    int c = 0;
    for (int i = 0; i < arcIDs.length; i++) {
      for (int j = 0; j < arcIDs[i].length; j++) {
        int aid = arcIDs[i][j];
        try {
          int cid = (aid >= 0) ? aid:~aid;
          TopoArc arc = map.arcs[cid];
          if (c == 0) {
            pushMatrix();
            translate(arc.origin.x, arc.origin.y);
            //ellipse(0, 0, 5, 5);
            fill(0);

            textSize(8);
            //text(id, 8, 5);
            popMatrix();
          }



          //arc.render(aid < 0);
          c++;
        } 
        catch(Exception e) {
          //FIX THIS
          println(e);
        }
      }
    }
  }
}

