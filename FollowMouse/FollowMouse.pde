float x,y,xdot,ydot,margin,diameter;
void setup() 
{
  size(screen.width - 10,screen.height - 50);
  smooth();
  x = width / 2; y = height / 2;
  xdot = 0.0; ydot = 0.0;
  margin = 15.0;
  diameter = 10.0;
  stroke(0,0,0,100);
}
void draw() 
{   
  background(255,255,255);
  strokeWeight(1.5);

  float constant1 = 0.995;
  float constant2 = 200.0;

  xdot = constant1 * xdot - (x - mouseX)/constant2; ydot = constant1 * ydot - (y - mouseY)/constant2;

  x+=xdot; y+=ydot;

  if((x < margin + diameter / 2.0 && xdot < 0.0) || (x > width  - margin - diameter / 2.0 && xdot > 0.0))xdot = - xdot;
  if((y < margin + diameter / 2.0 && ydot < 0.0) || (y > height - margin - diameter / 2.0 && ydot > 0.0))ydot = - ydot;

  line(x,y,mouseX,mouseY);
  fill(255,0,0,255); ellipse(x,y,diameter,diameter);
  fill(0,0,255,255); ellipse(mouseX,mouseY,diameter / 2.0,diameter / 2.0);

  noFill();
  beginShape();
  vertex(margin, margin); vertex(margin, height - margin); vertex(width - margin, height - margin); vertex(width - margin, margin);
  endShape(CLOSE);
}




