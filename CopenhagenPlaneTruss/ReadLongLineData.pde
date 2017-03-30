void ReadLongLineData(){
  FileReader Maud;
  try{
    Maud=new FileReader(FileLocation+"LongLineData.txt");
    a=ReadFloat(Maud);
    b=ReadFloat(Maud);
    LastDataPoint=ReadInt(Maud);
    println("Last data point = " + LastDataPoint);
    xDataPoint=new float[LastDataPoint+1];
    yDataPoint=new float[LastDataPoint+1];
    for(int DataPoint=0;DataPoint<=LastDataPoint;DataPoint++){
      ReadInt(Maud);
      xDataPoint[DataPoint]=ReadFloat(Maud);
      yDataPoint[DataPoint]=ReadFloat(Maud);
    }
    LastLongLine=ReadInt(Maud);
    println("Last long line = " + LastLongLine);
    LongLineEnd=new int[2][LastLongLine+1];
    for(int LongLine=0;LongLine<=LastLongLine;LongLine++){
      ReadInt(Maud);
      LongLineEnd[0][LongLine]=ReadInt(Maud);
      LongLineEnd[1][LongLine]=ReadInt(Maud);
    }
    Maud.close();
    println("Finished reading file");
  }
  catch(Exception e){
    println("Error: Problem reading data file.");
  }
  println("Input data read from file");
}
String ReadWord(FileReader Maud){
  String no,myword="null";
  String space=" ",tab="\t",blank="",newline="\n",carriagereturn="\r";
  char[] s = new char[1];
  try{
    for(;;){
      myword=blank;
      for(;;){
        Maud.read(s);
        no=String.valueOf(s);
        if(no.equals(space)||no.equals(tab)||no.equals(newline)||no.equals(carriagereturn))break;
        myword+=no;
      }
      if(myword.equals(blank));
      else break;
    }
  }
  catch(Exception e){
    println("Error: Can't read word");
  }
  return myword;
}
int ReadInt(FileReader Maud){

  return Integer.parseInt(String.valueOf(ReadWord(Maud)));
}
float ReadFloat(FileReader Maud){

  return Float.parseFloat(String.valueOf(ReadWord(Maud)));
}
