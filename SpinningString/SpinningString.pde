float angle,r[],z[];
int Step=500,Lasti,LastPicture=200;
void setup() 
{
  Lasti=50*Step;
  size(1200,750,P2D);
  smooth();
  float OmegaSquaredOverg=20.0/width;
  r=new float[Lasti+1];
  z=new float[Lasti+1];
  float ds=1.0*width/float(Lasti+1);
  r[0]=0.15*width;
  z[0]=0.95*width;
  float drbyds=-1.0/sqrt(1.0+1.0/(r[0]*r[0]*OmegaSquaredOverg*OmegaSquaredOverg));
  float d2rbyds2=-(OmegaSquaredOverg/2.0)*drbyds*pow(1.0-drbyds*drbyds,1.5);
  drbyds+=d2rbyds2*ds;
  for(int i=0;i<=Lasti-1;i++)
  {
    float temp=1.0-drbyds*drbyds;
    float dzbyds=sqrt(temp);
    r[i+1]=r[i]+drbyds*ds;
    z[i+1]=z[i]-dzbyds*ds;
    d2rbyds2=(-r[i+1]*OmegaSquaredOverg*temp-drbyds)*dzbyds/(ds*float(i+1));
    drbyds+=d2rbyds2*ds; 
  }
  angle=0.0;
}
void draw() 
{   
  background(255,255,255);
  translate(0.0,height/2);
  noFill();
  for(int Picture=0;Picture<=LastPicture;Picture++)
  {
    if(Picture==0)
    {
      stroke(230,255,40,200);
      strokeWeight(2);
    }
    else
    {
      stroke(0,0,0,20);
      strokeWeight(1);
    }
    float mycosine=cos(angle+TWO_PI*float(Picture)/float(LastPicture));
    beginShape();
    for(int i=0;i<=Lasti;i+=Step)vertex(z[i],r[i]*mycosine);
    endShape();
  }
  angle+=0.03;
  if(angle>TWO_PI)angle-=TWO_PI;
}














