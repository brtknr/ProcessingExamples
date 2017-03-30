float x[],y[],R;
int LastPoint = 400,position,increment;
void setup() 
{
  size(1200,700);
  smooth();
  strokeWeight(2);
  x = new float[LastPoint + 1];
  y = new float[LastPoint + 1];
  R = 0.4 * height / 2.0;
  for(int Point = 0;Point <= LastPoint;Point++)
  {
    float theta = TWO_PI * (float) Point / (float) LastPoint;
    x[Point] = R * (theta - sin(theta) - PI);
    y[Point] = - R * cos(theta);
  }
  position = 0;
  increment = 1;
}
void draw() 
{   
  background(255,255,255);
  translate(width / 2,height / 2);

  stroke(0,0,255,150);
  fill(255,255,255,0);
  beginShape();
  for(int Point = 0;Point <= LastPoint;Point++)vertex(x[Point],y[Point]);
  endShape(CLOSE);

  float theta = TWO_PI * (float) position / (float) LastPoint;
  stroke(0,0,0,100);
  ellipse(R * (theta - PI),0.0,2.0 * R,2.0 * R);
  stroke(255,0,0,255);
  fill(255,0,0);
  ellipse(R * (theta - sin(theta) - PI),- R * cos(theta),10,10);
  position += increment;
  if(position == LastPoint || position == 0)increment =- increment;
}

