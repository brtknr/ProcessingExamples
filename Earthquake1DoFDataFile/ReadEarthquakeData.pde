int EndOfFile;
void ReadEarthquakeData()
{
  FileReader Maud;
  float AccelerationFactor=gravity/1000.0;
  try
  {
    InputFile = selectInput("Open file - any or no extension, plain text expected.");
    Maud=new FileReader(InputFile);
    EndOfFile=0;
    LastRecord=-1;
    for(;;)
    { 
      float timeOfRecord_temp=ReadFloat(Maud);
      if(EndOfFile==1)break;
      LastRecord++;
      float xAcceleration_temp=AccelerationFactor*ReadFloat(Maud);
      float yAcceleration_temp=AccelerationFactor*ReadFloat(Maud);
      float zAcceleration_temp=AccelerationFactor*ReadFloat(Maud);
      //println(timeOfRecord_temp + "\t" + xAcceleration_temp + "\t" + yAcceleration_temp + "\t" + zAcceleration_temp);
    }
    Maud.close();
    println("Finished Reading file first time throught. Last record (starting from 0) = " + LastRecord);
  }
  catch(Exception e)
  {
    println("Error: Problem Reading data file.");
    exit();
  }
  timeOfRecord = new float[LastRecord+1];
  xAcceleration = new float[LastRecord+1];
  yAcceleration = new float[LastRecord+1];
  zAcceleration = new float[LastRecord+1];
  GroundAccelerationToSave = new float[LastRecord+1];
  GroundMovementToSave = new float[LastRecord+1];
  ThetaToSave = new float[LastRecord+1];
  bendingMomentOverRotationalStiffnessToSave = new float[LastRecord+1];
  try
  {
    Maud=new FileReader(InputFile);
    EndOfFile=0;
    float this_delta_time = 0.0;
    for(int Record=0;Record<=LastRecord;Record++)
    { 
      timeOfRecord[Record]=ReadFloat(Maud);
      if(Record>0)this_delta_time=timeOfRecord[Record]-timeOfRecord[Record-1];
      if(Record==1)delta_time=this_delta_time;
      if(Record>1&&abs(delta_time-this_delta_time)/delta_time>0.01){
        println("Time step is " + this_delta_time + " at time = " + timeOfRecord[Record]);
        exit();
      }
      xAcceleration[Record]=AccelerationFactor*ReadFloat(Maud);
      yAcceleration[Record]=AccelerationFactor*ReadFloat(Maud);
      zAcceleration[Record]=AccelerationFactor*ReadFloat(Maud);
      //println(timeOfRecord[Record] + "\t" + xAcceleration[Record] + "\t" + yAcceleration[Record] + "\t" + zAcceleration[Record]);
    }
    Maud.close();
    println("Finished Reading earthquake record");
  }
  catch(Exception e)
  {
    println("Error: Problem Reading data file.");
    exit();
  }
}
String ReadWord(FileReader Maud)
{
  String no,myword="null";
  String space=" ",tab="\t",blank="",newline="\n",carriagereturn="\r";
  char[] s = new char[1];
  try
  {
    int CommentLine=0;
    for(;;)
    {
      myword=blank;
      for(;;)
      {
        if(Maud.read(s)==-1)
        {
          //println("Found end of file");
          EndOfFile=1;
          myword+="000";
        }
        if(EndOfFile==1)break;
        no=String.valueOf(s);
        if(no.equals("#"))
        {
          CommentLine=1;
          //println("Found comment line.");
        }
        if(CommentLine==1&&(no.equals(newline)||no.equals(carriagereturn)))CommentLine=0;
        int EndOfNumber=0;
        if(CommentLine==0)
        {
          if(no.equals(space)||no.equals(tab)||no.equals(newline)||no.equals(carriagereturn))EndOfNumber=1;
          else myword+=no;
        }
        if(EndOfNumber==1)break;
      }
      if(EndOfFile==1)break;
      if(myword.equals(blank));
      else break;
    }
  }
  catch(Exception e)
  {
    println("Error: Can't Read word");
  }
  return myword;
}

int ReadInt(FileReader Maud)
{
  return Integer.parseInt(String.valueOf(ReadWord(Maud)));
}

float ReadFloat(FileReader Maud)
{
  return Float.parseFloat(String.valueOf(ReadWord(Maud)));
}


