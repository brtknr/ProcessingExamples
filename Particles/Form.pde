class Form {
  ArrayList parts;

  Form() {
    parts = new ArrayList();
  }

  void run() {
    for (int i = 0; i < parts.size(); i++) {
      Part p = (Part) parts.get(i);
      p.run(parts);
    }
  }

  void reset() {
    parts.clear();
  }

  void addPart(Part p) {
    parts.add(p);
  }
}

