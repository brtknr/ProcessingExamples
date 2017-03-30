void Calculation(){
  float[][] Force,Moment,MomentStiffness;
  float[] Stiffness,deltax,Rotation;
  deltax=new float[2];
  Rotation=new float[2];
  Force=new float[2][LastNode+1];
  Stiffness=new float[LastNode+1];
  Moment=new float[2][LastNode+1];
  MomentStiffness=new float[2][LastNode+1];
  for(int Node=0;Node<=LastNode;Node++){
    for(int xy=0;xy<=1;xy++)Force[xy][Node]=LoadFactor*Load[xy][Node];
    Stiffness[Node]=0.0;
    for(int EndType=0;EndType<=1;EndType++){
      Moment[EndType][Node]=0.0;
      MomentStiffness[EndType][Node]=0.0;
    }
  }
  for(int Member=0;Member<=LastMember;Member++){
    float LSq=0,ToverL,ThisStiffness;
    for(int xy=0;xy<=1;xy++){
      deltax[xy]=x[xy][End[1][Member]]-x[xy][End[0][Member]];
      LSq+=deltax[xy]*deltax[xy];
    }
    if(LSq>1.0e-12){
      CurrentL[Member]=sqrt(LSq);
      ToverL=EAoverL0[Member];
      if(EAminusT0[Member]!=0.0)ToverL-=EAminusT0[Member]/CurrentL[Member];
      if(EAminusT0[Member]>0.0)ThisStiffness=EAoverL0[Member];
      else ThisStiffness=ToverL;
      for(int xy=0;xy<=1;xy++){
        Force[xy][End[0][Member]]+=ToverL*deltax[xy];
        Force[xy][End[1][Member]]-=ToverL*deltax[xy];
        Stiffness[End[0][Member]]+=ThisStiffness;
        Stiffness[End[1][Member]]+=ThisStiffness;
      }
      float MemberTheta=atan2(deltax[1],deltax[0]);
      for(int MemberEnd=0;MemberEnd<=1;MemberEnd++){
        Rotation[MemberEnd]=Theta[MemberEndType[MemberEnd][Member]][End[MemberEnd][Member]]-MemberTheta;
        for(;;){
          if(Rotation[MemberEnd]>HALF_PI)Rotation[MemberEnd]-=PI;
          else break;
        }
        for(;;){
          if(Rotation[MemberEnd]<-HALF_PI)Rotation[MemberEnd]+=PI;
          else break;
        }
      }
      float ThisMomentStiffness;
      if(CurrentL[Member]>MinimumLength)ThisMomentStiffness=4.0*EI[Member]/CurrentL[Member];
      else ThisMomentStiffness=4.0*EI[Member]/MinimumLength;
      BendingMoment[0][Member]=(Rotation[0]+Rotation[1]/2.0)*ThisMomentStiffness;
      BendingMoment[1][Member]=(Rotation[1]+Rotation[0]/2.0)*ThisMomentStiffness;
      Moment[MemberEndType[0][Member]][End[0][Member]]-=BendingMoment[0][Member];
      Moment[MemberEndType[1][Member]][End[1][Member]]-=BendingMoment[1][Member];
      MomentStiffness[MemberEndType[0][Member]][End[0][Member]]+=ThisMomentStiffness;
      MomentStiffness[MemberEndType[1][Member]][End[1][Member]]+=ThisMomentStiffness;
      float ShearForceOverL=(3.0/2.0)*(Rotation[0]+Rotation[1])*ThisMomentStiffness/LSq;
      Force[0][End[0][Member]]+=ShearForceOverL*deltax[1];
      Force[0][End[1][Member]]-=ShearForceOverL*deltax[1];
      Force[1][End[0][Member]]-=ShearForceOverL*deltax[0];
      Force[1][End[1][Member]]+=ShearForceOverL*deltax[0];
      Stiffness[End[0][Member]]+=2.0*ThisMomentStiffness/LSq;
      Stiffness[End[1][Member]]+=2.0*ThisMomentStiffness/LSq;
    }
  }
  float CarryOver=1.0-0.005;
  for(int Node=0;Node<=LastNode;Node++){
    for(int xy=0;xy<=1;xy++)
      Velocity[xy][Node]=CarryOver*Velocity[xy][Node]+0.5*Force[xy][Node]/Stiffness[Node];
    x[0][Node]+=Velocity[0][Node];
    if(NodeType[Node]==0)x[1][Node]+=Velocity[1][Node];
    for(int EndType=0;EndType<=1;EndType++){
      AngularVelocity[EndType][Node]=CarryOver*AngularVelocity[EndType][Node]+0.5*Moment[EndType][Node]/MomentStiffness[EndType][Node];
      Theta[EndType][Node]+=AngularVelocity[EndType][Node];
    }
  }
}
