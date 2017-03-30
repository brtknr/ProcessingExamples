float x[],y[],r0,r,rdot,theta,thetadot,StiffnessOverMass,gravity,deltat;
int LastPrevious;
void setup() 
{
  size(800,800,P2D);
  smooth();
  theta = 0.0;
  deltat = 0.00002;
  r0 = 0.3 * height;
  StiffnessOverMass = 10.0;
  gravity = 50.0;
  r = 1.4 * r0;
  theta = PI;
  rdot = 0.0;
  thetadot = 0.01;
  LastPrevious = 2000;
  x = new float[LastPrevious+1];
  y = new float[LastPrevious+1];
  for(int Previous = 0;Previous <= LastPrevious; Previous++)
  {
    x[Previous] = r * sin(theta);
    y[Previous] = - r * cos(theta);
  }
  strokeWeight(1.2);
}
void draw() 
{   
  background(255,255,255);
  translate(0.5 * width, 0.45 * height);

  for(int innerloop = 0; innerloop <= 2000; innerloop ++)
  {
    float rdoubledot     = gravity * cos(theta) + r * thetadot * thetadot - (r - r0) * StiffnessOverMass;
    float thetadoubledot = - (gravity * sin(theta) + 2.0 * rdot * thetadot) / r;

    rdot     += rdoubledot     * deltat;
    thetadot += thetadoubledot * deltat;

    r     += rdot     * deltat;
    theta += thetadot * deltat;
  }

  for(int Previous = 0; Previous <= LastPrevious-1; Previous++)
  {
    x[Previous] = x[Previous + 1];
    y[Previous] = y[Previous + 1];
  }

  x[LastPrevious] = r * sin(theta);
  y[LastPrevious] = -r * cos(theta);

  noFill();
  beginShape();
  for(int Previous = 0; Previous <= LastPrevious; Previous ++)
  {
    float factor = float(Previous)/float(LastPrevious);
    factor = factor * factor * 255;
    stroke(255 - factor,0,factor,factor);
    vertex(x[Previous], - y[Previous]);
  }
  endShape();

  stroke(0,0,0,150);
  line(0.0,0.0,x[LastPrevious], - y[LastPrevious]);
  noStroke();
  fill(255,0,0,255);
  ellipse(x[LastPrevious], - y[LastPrevious],8,8);
  fill(0,0,255,255);
  ellipse(0.0,0.0,4,4);
}


