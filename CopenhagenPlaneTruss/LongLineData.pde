void LongLineData(){
  a=200.0;
  b=50.0;
  LastLongLine=40;
  LastDataPoint=5+2*(LastLongLine-4);
  xDataPoint=new float[LastDataPoint+1];
  yDataPoint=new float[LastDataPoint+1];
  LongLineEnd=new int[2][LastLongLine+1];
  xDataPoint[0]=-a;
  yDataPoint[0]=-b;
  xDataPoint[1]=+a;
  yDataPoint[1]=-b;
  xDataPoint[2]=+a;
  yDataPoint[2]=+b;
  xDataPoint[3]=-a;
  yDataPoint[3]=+b;
  LongLineEnd[0][0]=0;
  LongLineEnd[1][0]=1;
  LongLineEnd[0][1]=1;
  LongLineEnd[1][1]=2;
  LongLineEnd[0][2]=2;
  LongLineEnd[1][2]=3;
  LongLineEnd[0][3]=3;
  LongLineEnd[1][3]=0;
  for(int LongLine=4;LongLine<=LastLongLine;LongLine++)
  {
    int DataPoint=4+2*(LongLine-4);
    LongLineEnd[0][LongLine]=DataPoint;
    xDataPoint[DataPoint]=random(-a+error,a-error);
    yDataPoint[DataPoint]=random(-b+error,b-error);
    DataPoint=5+2*(LongLine-4);
    float angle=random(TWO_PI);
    xDataPoint[DataPoint]=xDataPoint[DataPoint-1]+a*cos(angle);
    yDataPoint[DataPoint]=yDataPoint[DataPoint-1]+a*sin(angle);
    LongLineEnd[1][LongLine]=DataPoint;
  }
}
