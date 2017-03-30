import processing.opengl.*;
int m = 2000, lastTerm = 10;
float t,T,xdot,x,mass,damping,stiffness,delta_t,omega_n,c;
void setup()
{
  size(1200,720);
  //smooth();
  t = 0.0;
  delta_t = 2.0;
  mass = 900.0;
  stiffness = 1.0;
  damping = 0.05 * 2.0 * sqrt(stiffness * mass);
  omega_n = sqrt(stiffness / mass);
  c = damping / (2.0 * sqrt(stiffness * mass));
  T = float(width) / 2.0;
  xdot = 0.0;
  x = float(height) / 2.0;
}

void draw()
{
  background(255,255,255);
  float lasttime = 0.0;
  float lasty = 0.0;
  float lastx = 0.0;
  for(int i = 0;i <= m; i++)
  {
    float time = float(width) * float(i) / float(m);
    float y = calculate_y(time + t);
    strokeWeight(1.5);
    stroke(0, 0, 0, 50);
    if(i != 0)line(time,y,lasttime,lasty);
    lasttime = time;
    lasty = y;
    float calculated_x = calculate_x(time + t);
    strokeWeight(1.2);
    stroke(0, 0, 255, 100);
    if(i != 0)line(time,calculated_x,lasttime,lastx);
    lastx = calculated_x;
  }
  float time = float(width) / 2.0;
  float y = calculate_y(time + t);  
  float ydot = calculate_ydot(time + t);
  if(t == 0.0)
  {
    x = y;
    xdot = ydot;
  }
  float force = - stiffness * (x - y) - damping * (xdot - ydot);
  xdot += (force / mass) * delta_t;
  x += xdot * delta_t;
  strokeWeight(1.5);
  stroke(0, 0, 200, 200);
  line(time,  x,time, y);
  fill(255, 255, 255, 255);
  strokeWeight(1.0);
  stroke(0, 0, 0, 200);
  ellipse(time, y, 6, 6);
  ellipse(time, x, 8, 8);
  fill(255, 0, 0, 255); 
  ellipse(time, calculate_x(time + t), 6, 6);
  t += delta_t;
}

float calculate_y(float t)
{
  float y = float(height) / 2.0;

  int plusorminus = -1;
  for(int j = 1; j <= lastTerm; j++)
  {
    int n = 2 * j - 1;
    plusorminus = - plusorminus;
    y += float(plusorminus) * (4.0 * T / (TWO_PI * PI * float (n * n))) * sin(TWO_PI * float(n) * t/T);
  }
  return y;
}

float calculate_ydot(float t)
{
  float ydot = 0.0;

  int plusorminus = -1;
  for(int j = 1; j <= lastTerm; j++)
  {
    int n = 2 * j - 1;
    plusorminus = - plusorminus;
    ydot += float(plusorminus) * (4.0 / (PI * float (n))) * cos(TWO_PI * float(n) * t/T);
  }
  return ydot;
}

float calculate_x(float t)
{
  float x = float(height) / 2.0;

  int plusorminus = -1;
  for(int j = 1; j <= lastTerm; j++)
  {
    int n = 2 * j - 1;
    plusorminus = - plusorminus;
    float omega_over_omega_n = (TWO_PI * float(n) / T) / omega_n;
    float one_minus_thingy = 1.0 - omega_over_omega_n * omega_over_omega_n;
    float two_c_thingy = 2.0 * c * omega_over_omega_n;
    float bottom = one_minus_thingy * one_minus_thingy + two_c_thingy * two_c_thingy;
    x += float(plusorminus) * (4.0 * T / (TWO_PI * PI * float (n * n))) * 
      ((one_minus_thingy + two_c_thingy * two_c_thingy) * sin(TWO_PI * float(n) * t/T)
      - omega_over_omega_n * omega_over_omega_n * two_c_thingy * cos(TWO_PI * float(n) * t/T)) / bottom;
  }
  return x;
}








