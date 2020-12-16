String getRandomVid(){
  Table t = loadTable(fileDirectory, "header");
  int count = t.getRowCount();
  float r = random(2, count-1);
  TableRow row = t.getRow((int) r);
  return row.getString("Clip Name");
}

String getVid(){
  Table t = loadTable(fileDirectory, "header");
  int count = t.getRowCount();
  float r = random(2, count-1);
  
  String label;
  String category;
  
  //switch(
  
 // t.matchRows(, "Label");
  
  TableRow row = t.getRow((int) r);
  return row.getString("Clip Name");
}

void printTable(){
  Table table;

  table = loadTable(fileDirectory, "header");

  for (TableRow row : table.rows()) {

    String name = row.getString("Clip Name");
    String cat = row.getString("Category");
    String need = row.getString("Needs");
    String feel = row.getString("Feelings");
    String act = row.getString("Label");

    println(name + " -> (" + cat + ") | Needs: " + need + " || Feelings: " + feel + " || Label: " + act);
  }
}
