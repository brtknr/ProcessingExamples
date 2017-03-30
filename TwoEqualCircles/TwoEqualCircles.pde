float x[][],xCircle[][],a,c,aSq,cSq;
int LastPoint;
void setup() 
{
  size(1200,700);
  smooth();
  LastPoint=1000;
  x=new float[LastPoint+1][2];
  xCircle=new float[LastPoint+1][2];
  a=250.0;
  aSq=a*a;
  c=200.0;
  cSq=c*c;
  for(int Point=0;Point<=LastPoint;Point++)
  {
    float theta=TWO_PI*float(Point)/float(LastPoint);
    xCircle[Point][0]=a*cos(theta);
    xCircle[Point][1]=a*sin(theta);
  }
}
void draw() 
{   
  background(255,255,255);
  translate(width/2,height/2);
  stroke(0,0,0,64);
  strokeWeight(2);
  for(int Point=0;Point<=LastPoint-1;Point++)
  {
    line(xCircle[Point][0]-c,xCircle[Point][1],xCircle[Point+1][0]-c,xCircle[Point+1][1]);
    line(xCircle[Point][0]+c,xCircle[Point][1],xCircle[Point+1][0]+c,xCircle[Point+1][1]);
  }
  float myMousex=mouseX-width/2-5;
  float myMousey=mouseY-height/2-5;
  float radius2=myMousex*myMousex+myMousey*myMousey;
  float cos2theta=(myMousex*myMousex-myMousey*myMousey)/radius2;
  float h4=((myMousex-c)*(myMousex-c)+myMousey*myMousey-aSq)*((myMousex+c)*(myMousex+c)+myMousey*myMousey-aSq);
  for(int plusorminus=-1;plusorminus<=1;plusorminus+=2)
  {
    stroke(0,127*(1+plusorminus),0,255);
    float hSq,eta;
    if(h4>=0.0)eta=1.0;
    else eta=-1.0;
    hSq=float(plusorminus)*sqrt(eta*h4);
    float v=0.0;
    float ySq;
    if(eta==-1||aSq-cSq-hSq>0.0)
    {
      float x=0.0,y=0.0,previousx=0.0,previousy=0.0;
      int start=1;
      int MaxNo=0;
      do
      {
        MaxNo++;
        float e=exp(v);
        float co=(e+eta/e)/2.0;
        float si=(e-eta/e)/2.0;
        x=hSq*si/(2.0*c);
        ySq=aSq-cSq-x*x-hSq*co;
        float dsbydv=0.0;
        if(ySq>=0.0)
        {
          y=sqrt(ySq);
          if(start==0)
          {
            for(int mirrorx=-1;mirrorx<=1;mirrorx+=2)
            {
              for(int mirrory=-1;mirrory<=1;mirrory+=2)
                line(float(mirrorx)*previousx,float(mirrory)*previousy,float(mirrorx)*x,float(mirrory)*y);
            }
          }
          if(eta==-1&&start==1&&plusorminus==-1&&v!=0.0)
          {
            for(int mirrorx=-1;mirrorx<=1;mirrorx+=2)
            {
              for(int mirrory=-1;mirrory<=1;mirrory+=2)
                line(float(mirrorx)*x,float(mirrory)*y,float(mirrorx)*x,0.0);
            }
          }
          start=0;
          previousx=x;
          previousy=y;
          float dxbydv=hSq*co/(2.0*c);
          float dybydv=(-2.0*x*dxbydv-hSq*si)/(2.0*y);
          dsbydv=sqrt(dxbydv*dxbydv+dybydv*dybydv);
        }
        if(dsbydv==0.0)v+=0.005;
        else v+=2.0/dsbydv;
      }
      while((ySq>=0.0||(eta==-1&&start==1&&plusorminus==-1))&&MaxNo<10000);
      if(start==0)
      {
        for(int mirrorx=-1;mirrorx<=1;mirrorx+=2)
        {
          for(int mirrory=-1;mirrory<=1;mirrory+=2)
            line(float(mirrorx)*x,float(mirrory)*y,float(mirrorx)*x,0.0);
        }
      }
    }
  }
  fill(0,0,255,255);
  noStroke();
  ellipse(myMousex,myMousey,10,10);
}
