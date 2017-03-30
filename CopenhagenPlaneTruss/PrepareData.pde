void PrepareData(){
  LongLineData();
  //ReadLongLineData();
  //WriteLongLineData();
  error=a/10000.0;
  NodeKey=new int[LastLongLine+1][LastLongLine+1];
  Vector=new float[2][LastLongLine+1];
  for(int go=0;go<=1;go++){
    if(go==1){
      x=new float[2][LastNode+1];
      Load=new float[2][LastNode+1];
      NodeType=new int[LastNode+1];
      Theta=new float[2][LastNode+1];
    }
    LastNode=-1;
    for(int LongLine=0;LongLine<=LastLongLine;LongLine++){
      Vector[0][LongLine]=xDataPoint[LongLineEnd[0][LongLine]]-xDataPoint[LongLineEnd[1][LongLine]];
      Vector[1][LongLine]=yDataPoint[LongLineEnd[0][LongLine]]-yDataPoint[LongLineEnd[1][LongLine]];
      NodeKey[LongLine][LongLine]=-1;
    }
    for(int LL0=0;LL0<=LastLongLine-1;LL0++){
      for(int LL1=LL0+1;LL1<=LastLongLine;LL1++){
        NodeKey[LL0][LL1]=-1;
        NodeKey[LL1][LL0]=-1;
        float Bottom=Vector[1][LL0]*Vector[0][LL1]-Vector[0][LL0]*Vector[1][LL1];
        if(Bottom!=0){
          float xintersect=(
          (xDataPoint[LongLineEnd[0][LL0]]*yDataPoint[LongLineEnd[1][LL0]]-yDataPoint[LongLineEnd[0][LL0]]*xDataPoint[LongLineEnd[1][LL0]])*Vector[0][LL1]
            -(xDataPoint[LongLineEnd[0][LL1]]*yDataPoint[LongLineEnd[1][LL1]]-yDataPoint[LongLineEnd[0][LL1]]*xDataPoint[LongLineEnd[1][LL1]])*Vector[0][LL0])/Bottom;

          float yintersect=(
          (xDataPoint[LongLineEnd[0][LL0]]*yDataPoint[LongLineEnd[1][LL0]]-yDataPoint[LongLineEnd[0][LL0]]*xDataPoint[LongLineEnd[1][LL0]])*Vector[1][LL1]
            -(xDataPoint[LongLineEnd[0][LL1]]*yDataPoint[LongLineEnd[1][LL1]]-yDataPoint[LongLineEnd[0][LL1]]*xDataPoint[LongLineEnd[1][LL1]])*Vector[1][LL0])/Bottom;

          if(xintersect>=-a-error&&xintersect<=+a+error&&yintersect>=-b-error&&yintersect<=+b+error){
            LastNode++;
            if(go==1){
              NodeKey[LL0][LL1]=LastNode;
              NodeKey[LL1][LL0]=LastNode;
              x[0][LastNode]=xintersect;
              x[1][LastNode]=yintersect;
              if(LL0<LL1){
                Theta[0][LastNode]=atan2(Vector[1][LL0],Vector[0][LL0]);
                Theta[1][LastNode]=atan2(Vector[1][LL1],Vector[0][LL1]);
              }
              else{
                Theta[1][LastNode]=atan2(Vector[1][LL0],Vector[0][LL0]);
                Theta[0][LastNode]=atan2(Vector[1][LL1],Vector[0][LL1]);
              }
              Load[0][LastNode]=0.0;
              Load[1][LastNode]=-100.0;
              if(x[1][LastNode]==-b&&(x[0][LastNode]==-a||x[0][LastNode]==+a))NodeType[LastNode]=1;
              else NodeType[LastNode]=0;
            }
          }
        }
      }
    }
  }
  println("Last node = " + LastNode);
  for(int Node=0;Node<=LastNode-1;Node++){
    for(int otherNode=Node+1;otherNode<=LastNode;otherNode++){
      if(x[0][Node]==x[0][otherNode]&&x[1][Node]==x[1][otherNode])println("Repeated node " + Node + " " + otherNode);
    }
  }
  for(int go=0;go<=1;go++){
    if(go==1){
      End=new int[2][LastMember+1];
      MemberEndType=new int[2][LastMember+1];
      BendingMoment=new float[2][LastMember+1];
      EAoverL0=new float[LastMember+1];
      EAminusT0=new float[LastMember+1];
      EI=new float[LastMember+1];
      CurrentL=new float[LastMember+1];
    }
    LastMember=-1;
    for(int LongLine=0;LongLine<=LastLongLine;LongLine++)
    {
      for(int CrossingLongLine=0;CrossingLongLine<=LastLongLine;CrossingLongLine++)
      { 
        if(LongLine!=CrossingLongLine&&NodeKey[LongLine][CrossingLongLine]>=0){
          int BestOtherCrossingLL=-1; 
          float MinScalarProduct=-1.0;
          for(int otherCrossingLongLine=0;otherCrossingLongLine<=LastLongLine;otherCrossingLongLine++)
          {
            if(otherCrossingLongLine!=CrossingLongLine&&NodeKey[LongLine][otherCrossingLongLine]>=0){
              float ScalarProduct=0.0;
              for(int xy=0;xy<=1;xy++)ScalarProduct+=Vector[xy][LongLine]*(x[xy][NodeKey[LongLine][CrossingLongLine]]-x[xy][NodeKey[LongLine][otherCrossingLongLine]]);
              if(ScalarProduct==0.0)println("Zero scalar product " + NodeKey[LongLine][CrossingLongLine] + " " + NodeKey[LongLine][otherCrossingLongLine]);
              if(ScalarProduct>=0.0&&(ScalarProduct<MinScalarProduct||MinScalarProduct<0.0)){
                MinScalarProduct=ScalarProduct;
                BestOtherCrossingLL=otherCrossingLongLine;
              }
            }
          }
          if(BestOtherCrossingLL!=-1){
            LastMember++;
            if(go==1){
              int EndType;
              End[0][LastMember]=NodeKey[LongLine][CrossingLongLine];
              if(LongLine<CrossingLongLine)EndType=0;
              else EndType=1;
              MemberEndType[0][LastMember]=EndType;
              End[1][LastMember]=NodeKey[LongLine][BestOtherCrossingLL];
              if(LongLine<BestOtherCrossingLL)EndType=0;
              else EndType=1;
              MemberEndType[1][LastMember]=EndType;
              float BasicEI=100000.0;
              BasicEA=BasicEI*pow((a/20.0),2);
              BendingMoment[0][LastMember]=0.0;
              BendingMoment[1][LastMember]=0.0;
              if(LongLine<=3){
                EAminusT0[LastMember]=BasicEA;
                EI[LastMember]=BasicEI;
              }
              else{
                EAminusT0[LastMember]=BasicEA/3.0;
                EI[LastMember]=BasicEI/9.0;
              }
              float LSq=0.0;
              for(int xy=0;xy<=1;xy++)LSq+=(x[xy][End[0][LastMember]]-x[xy][End[1][LastMember]])*(x[xy][End[0][LastMember]]-x[xy][End[1][LastMember]]);
              float L0=sqrt(LSq);      
              EAoverL0[LastMember]=EAminusT0[LastMember]/L0;   
            }
          }
        }
      }
    }
  }
  println("Last member = " + LastMember);
}
