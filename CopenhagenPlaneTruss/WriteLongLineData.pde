void WriteLongLineData(){
  FileWriter Madeleine=null;
  try{
    Madeleine=new FileWriter(FileLocation+"WrittenLongLineData.txt");
    Madeleine.write(a + "\t" + b + "\n\n");
    Madeleine.write(LastDataPoint + "\n\n");
    for(int DataPoint=0;DataPoint<=LastDataPoint;DataPoint++)
      Madeleine.write(DataPoint + "\t" + xDataPoint[DataPoint] + "\t" + yDataPoint[DataPoint] + "\n");
    Madeleine.write("\n" + LastLongLine + "\n\n");
    for(int LongLine=0;LongLine<=LastLongLine;LongLine++)
      Madeleine.write(LongLine + "\t" + LongLineEnd[0][LongLine] + "\t" + LongLineEnd[1][LongLine] + "\n");
    Madeleine.close();
  }
  catch(Exception e){
    println("Error: Problem writing file");
  }
  println("Input data written to file");
}
