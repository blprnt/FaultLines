class TopoArc {

  PVector[] points;
  PVector origin;

  void update() {
  }

  void render(boolean flip) {
    pushMatrix();
    translate(origin.x, origin.y);
    beginShape(LINES);
    PVector o = new PVector();
    vertex(0,0);
    for (int i = 1; i < points.length; i++) {
      if (!flip) {
        o.add(new PVector(points[i].x,points[i].y));
      } else {
        o.add(new PVector(points[i].x,points[i].y));
        //o.add(new PVector(points[points.length -1].x,points[points.length - 1].y));
      }
      vertex(o.x,o.y);
    }
    endShape(CLOSE);
    popMatrix();
  }
}

