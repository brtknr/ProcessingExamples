
void SetVelocityAndScale(){
  Velocity=new float[2][LastNode+1];
  AngularVelocity=new float[2][LastNode+1];
  for(int Node=0;Node<=LastNode;Node++){
    for(int xy=0;xy<=1;xy++)Velocity[xy][Node]=0.0;
    for(int EndType=0;EndType<=1;EndType++)AngularVelocity[EndType][Node]=0.0;
  }
  xMax=new float[2];
  xMin=new float[2];
  xShift=new float[2];
  xAv=new float[2];
  for(int Node=0;Node<=LastNode;Node++){
    for(int xy=0;xy<=1;xy++)
    {
      if(Node==0){
        xMax[xy]=x[xy][Node];
        xMin[xy]=x[xy][Node];
      }
      else{
        if(xMax[xy]<x[xy][Node])xMax[xy]=x[xy][Node];
        if(xMin[xy]>x[xy][Node])xMin[xy]=x[xy][Node];
      }
    }
  }
  for(int xy=0;xy<=1;xy++){
    xAv[xy]=(xMax[xy]+xMin[xy])/2.0;
    xShift[xy]=xAv[xy];
  }
  myScale=(xMax[0]-xMin[0])/float(width);
  if(myScale<(xMax[1]-xMin[1])/float(height))myScale=(xMax[1]-xMin[1])/float(height);
  myScale=0.75/myScale;
  NextScale=myScale;
}

