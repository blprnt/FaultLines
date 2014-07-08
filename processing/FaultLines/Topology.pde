class Topology {

  TopoArc[] arcs;
  ArrayList<TopoGeometry> geometries = new ArrayList();
  PVector scaleVector;
  PVector translateVector;

  Topology() {
  }

  Topology(String url, String objLabel) {
    loadTopoJSON(url, objLabel);
  }

  //Rendering

  void st() {
    pushMatrix();
    scale(scaleVector.x, scaleVector.y);
    translate(-translateVector.x, -translateVector.y);
  }

  void renderAll() {
    /*
    for(TopoGeometry tg:geometries) {
     tg.render(); 
     }
     */

    for (TopoArc a:arcs) {
      a.render(true);
    }
  }

  void et() {
    popMatrix();
  }

  //Loading

  Topology loadTopoJSON(String url, String objectLabel) {
    JSONObject doc = loadJSONObject(url);
    JSONObject objects = doc.getJSONObject("objects");
    JSONArray jarcs = doc.getJSONArray("arcs");
    JSONObject trans = doc.getJSONObject("transform");
    JSONArray tscale = trans.getJSONArray("scale");
    JSONArray ttranslate = trans.getJSONArray("translate");

    scaleVector = new PVector(tscale.getFloat(0), tscale.getFloat(1));
    translateVector = new PVector(ttranslate.getFloat(0), ttranslate.getFloat(1));
    processArcs(jarcs);
    processObjects(objects, objectLabel);
    println(arcs.length);
    println(geometries.size());
    return(this);
  }

  void processObjects(JSONObject objects, String objectLabel) {
    JSONObject target = objects.getJSONObject(objectLabel);
    if (target.getString("type").equals("GeometryCollection")) {
      println("processing geometry");
      JSONArray geometryList = target.getJSONArray("geometries");
      for (int i = 0; i < geometryList.size(); i++) {
        JSONObject g = geometryList.getJSONObject(i);
        TopoGeometry tg = new TopoGeometry();
        println(g);
        tg.id = g.getString("id");
        if (!tractMap.containsKey(tg.id)) {
          tractMap.put(tg.id, new ArrayList());
        }
        tractMap.get(tg.id).add(tg);
        geometries.add(tg);
        JSONArray arcList = g.getJSONArray("arcs");
        tg.arcIDs = new int[arcList.size()][];
        for (int j = 0; j < arcList.size(); j++) {
          JSONArray alist = arcList.getJSONArray(j);
          tg.arcIDs[j] = new int[alist.size()];
          for (int k = 0; k < alist.size(); k++) {
            try {
              int ai = alist.getInt(k);
              if (ai > 0 && tg.origin == null) tg.origin = arcs[ai].origin;
              tg.arcIDs[j][k] = ai;
              int aai = (ai < 0) ? ~ai:ai;
              tg.allIds.add(str(ai));
              tg.idList = tg.idList + aai + "|";
            } 
            catch(Exception e) {
              //<---------------------- FIX THIS.
              println("ERROR" + e);
              //println(alist);
            }
          }
        }
      }
    }
  }


  void processArcs(JSONArray arcArray) {
    arcs = new TopoArc[arcArray.size()];
    for (int i = 0; i < arcs.length; i++) {
      TopoArc a = new TopoArc();
      JSONArray arc = arcArray.getJSONArray(i);
      a.points = new PVector[arc.size()];

      for (int j = 0; j < arc.size(); j++) {
        JSONArray point = arc.getJSONArray(j); 

        if (j == 0) {
          a.origin = new PVector(point.getInt(0), point.getInt(1));
          a.points[j] = new PVector(0, 0);
        } 
        else {
          a.points[j] = new PVector(point.getInt(0), point.getInt(1));
        }
      }
      arcs[i] = a;
    }
  }
}

