/*

 FaultLines: an attempt to visualize borders between census tracts with drastically different income levels.
 blprnt@blprnt.com
 
 - This requires a hacky implementation of TopoJSON (Sorry, Mike)
 - Currently works for NY State, but will be looking to iplement for other states/regions/countries
 - Yeah, I know I should be doing this in D3.js
 
 */

Topology map;
HashMap<String, ArrayList<TopoGeometry>> tractMap = new HashMap();

PVector focus = new PVector();
PVector tfocus = new PVector(-719, 1972);
float s = 1;
float ts = 10.89;

float thresh = 10000;
PFont labelSerif;
PFont labelSans;

ArrayList<TopoGeometry> activeTracts = new ArrayList();

void setup() {
  size(displayWidth, displayHeight, P3D);
  background(0);
  smooth(8);

  labelSerif = createFont("ChunkFive",72);
  labelSans = createFont("Helvetica",72);

  map = new Topology("ny.json", "tracts");

  processIncomeData("../../data/queens/ACS_12_5YR_B19013_with_ann.csv");
  processIncomeData("../../data/kings/ACS_12_5YR_B19013_with_ann.csv");
  processIncomeData("../../data/nyc/ACS_12_5YR_B19013_with_ann.csv");

  findNeighbours();
}

void draw() {
  randomSeed(floor(mouseX/100));
  background(0);
  fill(255, 150);


  if (mousePressed) {
    tfocus.x -= mouseX - pmouseX; 
    tfocus.y -= mouseY - pmouseY;
  }

  focus.lerp(tfocus, 0.1);
  s = lerp(s, ts, 0.1);

  strokeWeight(0.3);
  stroke(0, 100); 

  thresh = map(mouseX, 0, width, 0, 100000);
  fill(255);
  
  //Label text
  textFont(labelSerif);
  textSize(48);
  text("$" + floor(thresh), 350, 60);
  
  textFont(labelSans);
  textSize(18);
  text("Census tract boundaries with an income difference greater than",50,25);

  translate(width/2, height/2);
  translate(-focus.x, -focus.y, -focus.z);
  scale(s);
  translate(-width/2, -height/2);
  map.st();
  //map.renderAll();
  for (TopoGeometry tg:map.geometries) {
    tg.render();
  }
  map.et();
}

void processIncomeData(String url) {
  Table t = loadTable(url, "header");
  for (TableRow r:t.rows()) {
    //GEO.id,GEO.id2,GEO.display-label,HD01_VD01,HD02_VD01
    String id = r.getString("GEO.id");
    String tid = id.substring(14, id.length());
    int inc = r.getInt("HD01_VD01");
    println(inc);
    try {
      ArrayList<TopoGeometry> tgList = tractMap.get(tid);
      if (tgList != null) {
        for (TopoGeometry tg:tgList) {
          tg.income = inc;
          activeTracts.add(tg);
        }
      }
    } 
    catch(Exception e) {
    }
  }
}

void findNeighbours() {
  for (TopoGeometry tg1:activeTracts) {
    println(tg1.idList);
    for (TopoGeometry tg2:activeTracts) {
      if (tg1 != tg2) {
        if (tg1.checkNeighbour(tg2)) tg1.neighbours.add(tg2);
      }
    }
  }
}


void keyPressed() {
  if (key == '=') ts += 0.1;
  if (key == '-') ts -= 0.1;
  if (key == 's') save("../../ProgressImages/FaultLines_" + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + ".png");
}

