class Part {

  int id;
  PVector loc;
  PVector vel;
  PVector acc;
  float mass;
  float G;

  int idA;
  int idC;


  boolean rotation = false;

  boolean motion = true;
  boolean limitv = false;
  boolean ground = false;
  boolean last = false;


  Part(int id, PVector l, PVector u, float m) {
    this.id = id;
    acc = new PVector(0, 0, 0);
    vel = u.get();
    loc = l.get();
    this.mass = m;
    G = 8;
  }

  void run (ArrayList parts) {

    form(parts);
    bouncy(parts);
    contact(parts);
    if (contacted > 1) {
      findC(parts);
    }
    update(parts);
    render(parts);
  }


  ////    acceleration due to attraction force    ////
  void form(ArrayList parts) {
    PVector att = attraction(parts);    //attraction to all particles
    PVector last = lastpart(parts);     //attraction to last particle
    PVector boun = bouncy(parts);       //repulsion from particles in motion
    PVector grou = plane(parts);        //repulsion from ground plane

    ////    Converting and weighting of forces    ////
    att.div(mass);
    last.div(mass);    
    boun.div(mass);

    if (lastatt) {
      att.mult(0);
    }
    else {
      att.mult(10);
    }
    last.mult(10);
    boun.mult(10);

    ////    Add force vectors to acceleration    ////
    acc.add(att);
    acc.add(last);
    acc.add(boun);


    if (ground && groundtog) {
      acc.set(acc.x, acc.y, 0);
      acc.add(grou);
    }
  }

  PVector plane(ArrayList parts) {

    PVector gforce = new PVector(0, 0, 0);
    float sep6 = mass*3;
    float gV = 0;
    float gL = 0;
    float gA;

    if (motion) {

      if (loc.z < sep6 && ground != true) {
        ground = true;
        gV = vel.mag();
        gL = loc.z;
      }

      gA = gV*gV/(gL);      
      PVector z = new PVector(0, 0, gA);
      gforce.set(z);
    }

    if (motion && loc.z > gL) {
      ground = false;
    }
    return gforce;
  }

  ////    Motion particle collision    ////
  PVector bouncy(ArrayList parts) {

    PVector rforce = new PVector(0, 0, 0);
    float sep4;
    float d4 = 0;

    if (motion && id > n-1) {
      for (int i = 0; i < parts.size(); i++) {
        Part other = (Part) parts.get(i);

        if (id != other.id) {

          if (motion && other.motion) {

            d4 = PVector.dist(loc, other.loc);

            sep4 = 1.1*(mass + other.mass);

            if (d4 < sep4) {
              PVector diff4 = PVector.sub(loc, other.loc);
              diff4.normalize();
              float force = 4*(other.mass * other.mass) / (d4 * d4);
              diff4.mult(force);
              rforce.add(diff4);
            }
          }
        }
      }
    }
    return rforce;
  }

  ////    Update location    ////
  void update(ArrayList parts) {

    vel.add(acc);

    if (limitv) {
      vel.limit(1);
      limitv = false;
    }
    vel.limit(25);

    loc.add(vel);
    acc.mult(0);

    if (!motion) {
      vel.set(0, 0, 0);
    }

    if (contacted == 2 && id > n-1 && !motion && rotation) {
      PVector Bmove = contact2(parts);      

      loc.x = Bmove.x;
      loc.y = Bmove.y;              
      loc.z = Bmove.z;
      ////    removing allows particles to be effected by in the momentum of the in coming particle    ////

      if (!impact) {
        rotation = false;
      }
    }
  }

  ////    Render/colour    ////
  void render(ArrayList parts) {

    if (vel.mag() == 0) {
      float f = id;

      ////    red increase green    ////
      if (f < 25) {
        fill(255, 10*f, 0);
      }

      ////    green decrease red    ////
      if (25 < f && f < 50) {
        fill(500 - 10*f, 255, 0);
      }

      ////    green increase blue    ////
      if (50 < f && f < 75) {
        fill(0, 255, -500 + 10*f);
      }

      ////    blue decrease green    ////
      if (75 < f && f < 100) {
        fill(0, 1000 - 10*f, 255);
      }

      ////     blue increase red    ////
      if (100 < f && f < 125) {
        fill(-1000 + 10*f, 0, 255);
      }

      ////    red drecase blue    ////
      if (125 < f && f < 150) {
        fill(255, 0, 1500 - 10*f);
      }
      colour = false;
    }
    else {
      fill(255);
    }

    if (look == 3) {
      PVector dir5 = new PVector(0, 0, 0);
      float d5;
      for (int i = 0; i < parts.size(); i++) {
        Part other = (Part) parts.get(i);

        if (id !=other.id) {
          d5 = PVector.dist(loc, other.loc);

          if (d5 < 2*mass + sep5) {
            stroke(0);
            line(loc.x, loc.y, loc.z, other.loc.x, other.loc.y, other.loc.z);
          }
        }
      }
    }

    strokeWeight(1);
    stroke(0);
    pushMatrix();
    translate(loc.x, loc.y, loc.z);

    if (look == 2) {
      noStroke();
      sphere(mass);
    }
    if (look == 1) {
      box(mass*sqrt(2));
    }
    popMatrix();
  }

  ////    Resultant attraction force    ////
  PVector attraction (ArrayList parts) {
    float sep1;
    PVector dir1 = new PVector(0, 0, 0);
    float size = parts.size();
    float d1;

    if (motion) {

      //Check promxity of every part
      for (int i = 0; i < parts.size(); i++) {
        Part A = (Part) parts.get(i);

        if (id != A.id) {


          if (A.motion != true) {
            d1 = PVector.dist(A.loc, loc);

            sep1 = mass + A.mass;

            if (d1 > sep1) {

              PVector diff1 = PVector.sub(A.loc, loc);
              diff1.normalize();
              float force = (G * A.mass * A.mass) / (d1 * d1);
              diff1.mult(force);
              ////    Average force    ////
              if (lastatt) {
                diff1.div(parts.size());
                diff1.mult(3);
              }

              dir1.add(diff1);
            }
          }
        }
      }
    }
    return dir1;
  }

  ////    Attraction to recent stationary particle    ////
  PVector lastpart (ArrayList parts) {

    float sep2;
    int idL= n-1;
    PVector dirlast = new PVector(0, 0, 0);

    if (motion && lastatt) {

      for (int i = parts.size(); i < 0; i--) {
        Part L = (Part) parts.get(i);

        if (last != true) {
          if (L.motion != true) {
            idL = i;
            break;
          }
        }
      }

      Part L = (Part) parts.get(idL);      

      float d2 = PVector.dist(loc, L.loc);

      sep2 = mass + L.mass;

      if (d2 > sep2) {

        PVector diff2 = PVector.sub(L.loc, loc);
        diff2.normalize();
        float force = (G * L.mass * L.mass) / (d2 * d2);
        diff2.mult(force);
        dirlast.add(diff2);
      }
    }
    return dirlast;
  }

  ////    Contact between motion and stationary particle    ////
  void contact(ArrayList parts) {

    float sep3;
    float d3 = 0;
    if (motion) {

      for (int i = 0; i < parts.size(); i++) {
        Part other = (Part) parts.get(i);

        if (id != other.id) {

          if (other.vel.mag() == 0) {

            d3 = PVector.dist(loc, other.loc);

            sep3 = mass + other.mass;

            if (d3 < sep3) {

              colour = true;
              motion = false;
              idA = i;
              rotation = true;
            }
            if (d3 < sep3*2) {
              limitv = true;
            }
          }
        }
      }
    }
  }

  ////    Pre function for contact2    ////
  void findC(ArrayList parts) {

    if (!motion && id > n-1) {

      float mindC = 4*mass;
      for (int i = 0; i < parts.size(); i++) {
        Part C = (Part) parts.get(i);    

        if (C.id != id && C.id != idA) {     
          float cdist = PVector.dist(loc, C.loc);
          cdist -= C.mass;
          if (mindC > cdist) {
            mindC = cdist;
            idC = i;
          }
        }
      }
    }
  }

  ////    Relocation of particle to gain two points of contact    ////
  PVector contact2 (ArrayList parts) {

    PVector AB;

    float dC;
    float rB;
    float rC;
    float BCmass;

    float thetaBC;

    PVector AC;

    float BCang;

    PVector Z = new PVector(0, 0, 1);

    PVector BCP;
    PVector ACP;
    PVector Bmove = new PVector (0, 0, 0);

    float Cfact;
    float CNfact;

    ////Access found particles////
    Part A = (Part) parts.get(idA);
    Part C = (Part) parts.get(idC);

    ////Particle vectors from A////
    AB = PVector.sub(loc, A.loc);
    AC = PVector.sub(C.loc, A.loc);

    ////Cross Products////
    BCP = AB.cross(AC);
    ACP = AC.cross(BCP);

    ////Vector magnitudes////
    rC = AC.mag();
    rB = mass + A.mass;
    BCmass = mass + C.mass;

    ////Require angle for particle B////
    thetaBC = acos((sq(rB) + sq(rC) - sq(BCmass))/(2*rB*rC));

    ////Axes unit vectors////
    AC.normalize();
    ACP.normalize();

    ////New vector local position of B////
    Cfact = rB*cos(thetaBC);
    AC.mult(Cfact);
    CNfact = rB*sin(thetaBC);
    ACP.mult(CNfact);

    ////Compile components of relocation vector////
    Bmove.add(ACP);
    Bmove.add(AC);
    Bmove.add(A.loc);

    return Bmove;
  }
}

