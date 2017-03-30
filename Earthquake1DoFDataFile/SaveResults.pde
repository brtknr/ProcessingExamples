void SaveResults(int startRecord,int lastRecordToSave)
{
  FileWriter Madeleine=null;
  try
  {
    String OutputFile = selectOutput("Save results as plain text. Windows would like a .txt.");
    Madeleine=new FileWriter(OutputFile);
    for(int Record=startRecord;Record<=lastRecordToSave;Record++)
    {
      Madeleine.write(timeOfRecord[Record] + "\t" + GroundAccelerationToSave[Record] + "\t" + GroundMovementToSave[Record]);
      Madeleine.write("\t" + ThetaToSave[Record] + "\t" + bendingMomentOverRotationalStiffnessToSave[Record] + "\n");
    }
    Madeleine.close();
    println("Data saved");
  }
  catch(Exception e)
  {
    println("Error: Problem writing file");
    exit();
  }
}




