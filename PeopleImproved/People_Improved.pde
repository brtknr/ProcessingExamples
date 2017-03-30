import processing.opengl.*;
float x[][][],xDot[][],xDoubleDot[][],deltax[];
float a,b,WalkingSpeed,radius,SocialDistanceSquared,walkControl;
int LastPerson,LastPrevious;
void setup() 
{
  size(500, 500);
  smooth();
  a = float( width) / 2.0 - 5.0;
  b = float(height) / 2.0 - 5.0;
  float SocialDistance = a / 10.0;
  SocialDistanceSquared = SocialDistance * SocialDistance;
  LastPerson = 400;
  LastPrevious = 50;
  radius = 5.0;
  WalkingSpeed = 2.0;
  walkControl = 0.1;
  deltax = new float[2];
  x = new float[2][LastPerson + 1][LastPrevious + 1];
  xDot=new float[2][LastPerson + 1];
  xDoubleDot=new float[2][LastPerson + 1];
  for(int Person = 0; Person <= LastPerson; Person ++)
  {
    x[0][Person][0] = random( - a, a);
    x[1][Person][0] = random( - b, b);

    float theta = random( 0, TWO_PI);
    xDot[0][Person] = 0.1*WalkingSpeed * cos(theta);
    xDot[1][Person] = 0.1*WalkingSpeed * sin(theta);

    for(int Previous = 1; Previous <= LastPrevious; Previous ++)
    {
      for(int xy = 0;xy <= 1; xy ++)x[xy][Person][Previous] = x[xy][Person][0];
    }
  }
  strokeWeight(1);
}
void draw() 
{   
  background(255,255,255);
  translate(width/2,height/2);

  for(int Person = 0; Person <= LastPerson; Person ++)
  {
    if(x[0][Person][0] > + a && xDot[0][Person] > 0.0)xDot[0][Person] = - xDot[0][Person];
    if(x[0][Person][0] < - a && xDot[0][Person] < 0.0)xDot[0][Person] = - xDot[0][Person];
    if(x[1][Person][0] > + b && xDot[1][Person] > 0.0)xDot[1][Person] = - xDot[1][Person];
    if(x[1][Person][0] < - b && xDot[1][Person] < 0.0)xDot[1][Person] = - xDot[1][Person];

    float CurrentSpeed = sqrt(xDot[0][Person] * xDot[0][Person] + xDot[1][Person] * xDot[1][Person]);
    float error = (CurrentSpeed - WalkingSpeed) / CurrentSpeed;
    error = error + 0.9 * (sqrt(error * error + walkControl * walkControl) - walkControl);
    for(int xy = 0;xy <= 1; xy ++)xDoubleDot[xy][Person] = - 0.02 * xDot[xy][Person] * error;
    float distanceSq = 
      (mouseX - (x[0][Person][0] + width/2 )) * (mouseX - (x[0][Person][0] + width/2 )) + 
      (mouseY - (x[1][Person][0] + height/2)) * (mouseY - (x[1][Person][0] + height/2));
    double factor = 0.01 * exp(- distanceSq / 100000.0);
    xDoubleDot[0][Person] += factor * (mouseX - (x[0][Person][0] + width/2 ));
    xDoubleDot[1][Person] += factor * (mouseY - (x[1][Person][0] + height/2));
  }

  for(int Person = 0; Person <= LastPerson - 1; Person ++)
  {
    for(int otherPerson = Person + 1; otherPerson <= LastPerson; otherPerson ++)
    {
      for(int xy = 0;xy <= 1; xy ++)deltax[xy] = x[xy][otherPerson][0] - x[xy][Person][0];
      float separationSq = deltax[0] * deltax[0] + deltax[1] * deltax[1];

      float socialforce = 0.1 * exp(- separationSq / SocialDistanceSquared) / sqrt(separationSq);
      for(int xy = 0;xy <= 1; xy ++)
      {
        xDoubleDot[xy][     Person] -= socialforce * deltax[xy];
        xDoubleDot[xy][otherPerson] += socialforce * deltax[xy];
      }
    }
  }

  for(int Person = 0; Person <= LastPerson; Person ++)
  {
    for(int Previous = LastPrevious;Previous >= 1; Previous --)
    {
      for(int xy = 0;xy <= 1; xy ++)x[xy][Person][Previous] = x[xy][Person][Previous - 1];
    }

    for(int xy = 0;xy <= 1; xy ++)xDot[xy][Person] += xDoubleDot[xy][Person];
    for(int xy = 0;xy <= 1; xy ++)x[xy][Person][0] += xDot[xy][Person];
  }

  for(int Person = 0; Person <= LastPerson; Person ++)
  {
    noFill();
    beginShape();
    for(int Previous = 0; Previous <= LastPrevious; Previous ++)
    {
      float factor = 1.0 - float(Previous)/float(LastPrevious);
      factor = factor * factor * 255;
      stroke(0,0,factor,factor);
      vertex(x[0][Person][Previous],x[1][Person][Previous]);
    }
    endShape();
    noStroke();
    fill(0,100,100,255);
    ellipse(x[0][Person][0],x[1][Person][0],radius,radius);
  }

  noFill();
  stroke(255,0,0,150);
  beginShape();
  vertex(- a, - b);
  vertex(+ a, - b);
  vertex(+ a, + b);
  vertex(- a, + b);
  endShape(CLOSE);
}