float p[],phase[],x[],y[],z[],A[],B[],factor,T,t,rms,rootm,
omega_n,c,move,rootpower,delta_t,mass,lambda,stiffness,
velocity,acceleration,velocityVerlet,accelerationVerlet;
int m=100,n=1000;

void setup()
{
  size(1200,800);
  smooth();
  strokeWeight(1.5);
  factor=0.1*float(height);
  move=0.2*float(height);
  T=10000.0;
  delta_t=0.001*T;
  omega_n=0.4*float(m)*TWO_PI/T;
  stiffness=10.0;
  mass=stiffness/(omega_n*omega_n);
  c=0.01;
  lambda=2.0*c*sqrt(stiffness*mass);
  p = new float[n+1];
  x = new float[n+1];
  y = new float[n+1];
  z = new float[n+1];
  A = new float[m+1];
  B = new float[m+1];
  phase = new float[m+1];
  for(int j=0;j<=n;j++)
  {
    p[j]=0.0;
    x[j]=0.0;
    y[j]=0.0;
    z[j]=0.0;
  } 
  rms=1.0;
  rootm=sqrt(float(m));
  float power=0.0;
  for(int i=1;i<=m;i++)
  {
    phase[i]=random(0.0,TWO_PI);
    float omega=TWO_PI*float(i)/T;
    float u=omega/omega_n;
    A[i]=(rms/rootm)*(1.0-u*u)/(((1.0-u*u)*(1.0-u*u)+(2.0*c*u)*(2.0*c*u))*stiffness);
    B[i]=(rms/rootm)*(2.0*c*u)/(((1.0-u*u)*(1.0-u*u)+(2.0*c*u)*(2.0*c*u))*stiffness);
    power+=A[i]*A[i]+B[i]*B[i];
  }
  rootpower=sqrt(power);

  t=0.0;
  acceleration=0.0;
  velocity=0.0;
  accelerationVerlet=0.0;
  velocityVerlet=0.0;
}

void draw() 
{
  t+=delta_t;
  if(t>T)t-=T;
  background(255,255,255);
  translate(0,height/2);

  p[0]=0.0;
  x[0]=0.0;

  z[0]+=velocityVerlet*delta_t+accelerationVerlet*delta_t*delta_t/2.0;
  velocityVerlet+=accelerationVerlet*delta_t/2.0;

  for(int i=1;i<=m;i++)
  {
    float omega=TWO_PI*float(i)/T;
    float u=omega/omega_n;
    p[0]+=(rms/rootm)*cos(omega*t+phase[i]);
    x[0]+=A[i]*cos(omega*t+phase[i])+B[i]*sin(omega*t+phase[i]);
  }

  accelerationVerlet=(p[0]-lambda*velocityVerlet-stiffness*z[0])/mass;
  velocityVerlet+=accelerationVerlet*delta_t/2.0;

  acceleration=(p[0]-lambda*velocity-stiffness*y[0])/mass;
  velocity+=acceleration*delta_t;
  y[0]+=velocity*delta_t;

  for(int j=n;j>=1;j--)
  {
    p[j]=p[j-1];
    x[j]=x[j-1];
    y[j]=y[j-1];
    z[j]=z[j-1];
  }
  noFill();
  stroke(0,0,0);
  beginShape();
  for(int j=0;j<=n;j++)
    vertex(float(j*width)/float(n),p[j]*factor/rms-move);
  endShape();
  beginShape();
  for(int j=0;j<=n;j++)
    vertex(float(j*width)/float(n),x[j]*factor/rootpower+move);   
  endShape();
  stroke(0,0,255);
  beginShape();
  for(int j=0;j<=n;j++)
    vertex(float(j*width)/float(n),y[j]*factor/rootpower+move);   
  endShape();
  stroke(255,0,0);
  beginShape();
  for(int j=0;j<=n;j++)
    vertex(float(j*width)/float(n),z[j]*factor/rootpower+move);   
  endShape();
}





