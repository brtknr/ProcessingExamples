float xPan=0.0,yPan=0.0;
float NextxPan=0.0,NextyPan=0.0;
float LX=0.0,LXpressed=0.0,LY=0.0,LYpressed=0.0;
float RX=0.0,RXpressed=0.0,RY=0.0,RYpressed=0.0;
float UnPressedPanXmag=0.0,UnPressedPanYmag=0.0,PressedPanXmag=0.0,PressedPanYmag=0.0;
void draw(){
  Calculation();
  background(0,0,0);
  if(keyPressed) {
    if (keyCode == UP) MomentScale=1.1*MomentScale;
    if (keyCode == DOWN) MomentScale=MomentScale/1.1;
    if (key == 'b' || key == 'B'){
      if(DrawBendingMoments==0)DrawBendingMoments=1;
      else DrawBendingMoments=0;
    } 
    if (key == 'r' || key == 'R'){
      LoadFactor=1.0;
      PrepareData();
      SetVelocityAndScale();
    }
  }
  if(mousePressed && mouseButton == RIGHT){
    RXpressed = mouseX;
    RYpressed = mouseY;
    NextScale=myScale*(1.0+((RXpressed-RX)-(RYpressed-RY))/width);
  }
  else{ 
    RX = mouseX;
    RY = mouseY;
    myScale=NextScale;
  }
  if(mousePressed && mouseButton == LEFT){
    LXpressed = mouseX;
    LYpressed = mouseY;
    NextxPan=xPan+(LXpressed-LX)/NextScale;
    NextyPan=yPan+(LYpressed-LY)/NextScale;
  }
  else{
    LX = mouseX;
    LY = mouseY;
    xPan=NextxPan;
    yPan=NextyPan;
  }
  translate(float(width)/2.0,float(height)/2.0);
  //xShift[0]=-NextxPan/NextScale;xShift[1]=NextyPan/NextScale;
  xShift[0]=-NextxPan;
  xShift[1]=NextyPan;
  for(int Member=0;Member<=LastMember;Member++){
    DrawMember(Member);
    /*noStroke();
     for(int MemberEnd=0;MemberEnd<=1;MemberEnd++){
     if(MemberEndType[MemberEnd][Member]==0)fill(0,255,0);
     else fill(255,0,0);
     float alpha=0.25;
     if(MemberEnd==0)alpha=1.0-alpha;
     ellipse(alpha*xPlot(0,End[0][Member])+(1.0-alpha)*xPlot(0,End[1][Member]),-(alpha*xPlot(1,End[0][Member])+(1.0-alpha)*xPlot(1,End[1][Member])),4,4);
     }*/
  }
  strokeWeight(1);
  for(int Node=0;Node<=LastNode;Node++){
    if(NodeType[Node]==0){
      //noStroke();
      stroke(255,0,0);
      fill(255,0,0);
      ellipse(xPlot(0,Node),-xPlot(1,Node),2,2);
    }
    else{
      stroke(255,255,255);
      fill(0,0,0);
      ellipse(xPlot(0,Node),-xPlot(1,Node),8,8);
    }
    /*float ThetaLength=10.0;
     for(int whichTheta=0;whichTheta<=1;whichTheta++){
     if(whichTheta==0)stroke(0,255,0);
     else stroke(255,0,0);
     line(xPlot(0,Node)+ThetaLength*cos(Theta[whichTheta][Node]),-(xPlot(1,Node)+ThetaLength*sin(Theta[whichTheta][Node])),
     xPlot(0,Node)-ThetaLength*cos(Theta[whichTheta][Node]),-(xPlot(1,Node)-ThetaLength*sin(Theta[whichTheta][Node])));
     }*/
  }
}
float xPlot(int xy,int Node){
  return (x[xy][Node]-xShift[xy])*NextScale;
}
void DrawMember(int Member){
  float[] t0,t1;
  float[][] r,ru;
  int Lastiu;
  //Lastiu=int(CurrentL[Member]*NextScale/2);if(Lastiu==0)Lastiu=1;
  Lastiu=20;
  t0=new float[2];
  t1=new float[2];
  r=new float[2][Lastiu+1];
  ru=new float[2][Lastiu+1];
  t0[0]=cos(Theta[MemberEndType[0][Member]][End[0][Member]]);
  t0[1]=sin(Theta[MemberEndType[0][Member]][End[0][Member]]);
  t1[0]=cos(Theta[MemberEndType[1][Member]][End[1][Member]]);
  t1[1]=sin(Theta[MemberEndType[1][Member]][End[1][Member]]);
  if(t0[0]*(x[0][End[1][Member]]-x[0][End[0][Member]])+t0[1]*(x[1][End[1][Member]]-x[1][End[0][Member]])<0.0){
    t0[0]=-t0[0];
    t0[1]=-t0[1];
  }
  if(t1[0]*(x[0][End[1][Member]]-x[0][End[0][Member]])+t1[1]*(x[1][End[1][Member]]-x[1][End[0][Member]])<0.0){
    t1[0]=-t1[0];
    t1[1]=-t1[1];
  }
  for(int iu=0;iu<=Lastiu;iu++){
    float u=float(iu)/float(Lastiu);
    for(int xy=0;xy<=1;xy++){
      r[xy][iu]=x[xy][End[0][Member]]+(x[xy][End[1][Member]]-x[xy][End[0][Member]])*u
        +(CurrentL[Member]*t0[xy]-(x[xy][End[1][Member]]-x[xy][End[0][Member]]))*u*(1.0-u)*(1.0-u)
        -(CurrentL[Member]*t1[xy]-(x[xy][End[1][Member]]-x[xy][End[0][Member]]))*u*u*(1.0-u);
      ru[xy][iu]=(x[xy][End[1][Member]]-x[xy][End[0][Member]])
        +(CurrentL[Member]*t0[xy]-(x[xy][End[1][Member]]-x[xy][End[0][Member]]))*((1.0-u)*(1.0-u)-2.0*u*(1.0-u))
          -(CurrentL[Member]*t1[xy]-(x[xy][End[1][Member]]-x[xy][End[0][Member]]))*(2.0*u*(1.0-u)-u*u);
    }
  }
  stroke(255,255,255);
  float LineWidth=3.0*sqrt(EAminusT0[Member]/BasicEA);
  if(LineWidth<1.0)LineWidth=1.0;
  strokeWeight(LineWidth);
  for(int iu=0;iu<=Lastiu-1;iu++)line((r[0][iu]-xShift[0])*NextScale,-(r[1][iu]-xShift[1])*NextScale,
  (r[0][iu+1]-xShift[0])*NextScale,-(r[1][iu+1]-xShift[1])*NextScale);
  if(DrawBendingMoments==1){
    stroke(127,127,255);
    strokeWeight(1);
    for(int iu=0;iu<=Lastiu;iu+=1){
      float u=float(iu)/float(Lastiu);
      line((r[0][iu]-xShift[0])*NextScale,-(r[1][iu]-xShift[1])*NextScale,
      +(+(-BendingMoment[0][Member]*(1.0-u)+BendingMoment[1][Member]*u)*MomentScale*ru[1][iu]/CurrentL[Member]+r[0][iu]-xShift[0])*NextScale,
      -(-(-BendingMoment[0][Member]*(1.0-u)+BendingMoment[1][Member]*u)*MomentScale*ru[0][iu]/CurrentL[Member]+r[1][iu]-xShift[1])*NextScale);
    }
    for(int iu=0;iu<=Lastiu-1;iu++){
      float u0=float(iu)/float(Lastiu);
      float u1=float(iu+1)/float(Lastiu);
      line(
      +(+(-BendingMoment[0][Member]*(1.0-u0)+BendingMoment[1][Member]*u0)*MomentScale*ru[1][iu+0]/CurrentL[Member]+r[0][iu+0]-xShift[0])*NextScale,
      -(-(-BendingMoment[0][Member]*(1.0-u0)+BendingMoment[1][Member]*u0)*MomentScale*ru[0][iu+0]/CurrentL[Member]+r[1][iu+0]-xShift[1])*NextScale,
      +(+(-BendingMoment[0][Member]*(1.0-u1)+BendingMoment[1][Member]*u1)*MomentScale*ru[1][iu+1]/CurrentL[Member]+r[0][iu+1]-xShift[0])*NextScale,
      -(-(-BendingMoment[0][Member]*(1.0-u1)+BendingMoment[1][Member]*u1)*MomentScale*ru[0][iu+1]/CurrentL[Member]+r[1][iu+1]-xShift[1])*NextScale);
    }
  }
}
