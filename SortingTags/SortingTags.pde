import java.util.Map;

Table tagsTable;
HashMap<String,Integer> feels = new HashMap<String,Integer>();
HashMap<String,Integer> needs = new HashMap<String,Integer>();
HashMap<String,Integer> cats = new HashMap<String,Integer>();

String[] feelingsInventory = {"affectionate", "engaged", "hopeful", "confident", "excited", "grateful", "inspired", "joyful", "exhilarated", "peaceful", "refreshed", "afraid", "annoyed", "angry", "aversion", "confused", "disconnected", "disquiet", "embarassed", "fatigue", "pain", "sad", "tense", "vulnerable", "yearning"};
String[] needsInventory = {"connection", "physicalWellbeing", "honesty", "play", "peace", "autonomy", "meaning"};
String[] categories = {"action", "reaction", "dialog"};

String fileDirectory = "../tags.csv";

void setup() {
  for(int i = 0; i < needsInventory.length; i++){
    needs.put(needsInventory[i], i);
  }
  
  for(int i = 0; i < feelingsInventory.length; i++){
    feels.put(feelingsInventory[i], i);
  }
  
  for(int i = 0; i < categories.length; i++){
    cats.put(categories[i], i);
  }
  
  parseTags();
  printTable();
}

void parseTags(){
  String[] lines = loadStrings("tags.txt");
  
  tagsTable = new Table();
  
  tagsTable.addColumn("id");
  tagsTable.addColumn("Clip Name");
  tagsTable.addColumn("Category");
  tagsTable.addColumn("Needs");
  tagsTable.addColumn("Feelings");
  tagsTable.addColumn("Label");
  
  
  int i = 0;
  while (i < lines.length) {
    String line = lines[i];
    String[] parsed = splitTokens(line, " ");
    TableRow newRow;
    if(parsed[0].equals("kMDItemDisplayName")){
      
      newRow = tagsTable.addRow();
      newRow.setInt("id", tagsTable.getRowCount() - 1);
      String s = parsed[parsed.length-1]; 
      newRow.setString("Clip Name", s.substring(1, 9));
      i++;
      
    } else if(parsed[0].equals("kMDItemUserTags")){
      if(!parsed[parsed.length-1].equals("(null)")){
        i++;
        String n = ""; //needs, feelings, categories, actions just bc im lazy
        String f = "";
        String c = "";
        String a = "";
        
        while (lines[i].charAt(0) != ')'){
          String s = trim(lines[i]);
          
          if(s.charAt(s.length()-1) == ',')
            s = s.substring(0, s.length() -1);
            
          if(needs.get(s) != null){
            n += s + ",";
          }
          else if(feels.get(s) != null){
            f += s + ",";
          }
          else if(cats.get(s) != null){
            c += s + ",";
          } else {
            a += s + ",";
          }
          i++;
         }
         
        newRow = tagsTable.getRow(tagsTable.getRowCount()-1);
        newRow.setString("Category", c);
        newRow.setString("Needs", n);
        newRow.setString("Feelings", f);
        newRow.setString("Label", a);
      } else {
        i++;
      }
    } else {
      i++;
    }
  }  
  
  saveTable(tagsTable, fileDirectory);
  println("close");
}

void printTable(){
  Table table;

  table = loadTable(fileDirectory, "header");

  println(table.getRowCount() + " total rows in table");

  for (TableRow row : table.rows()) {

    String name = row.getString("Clip Name");
    String cat = row.getString("Category");
    String need = row.getString("Needs");
    String feel = row.getString("Feelings");
    String act = row.getString("Label");

    println(name + " -> (" + cat + ") | Needs: " + need + " || Feelings: " + feel + " || Label: " + act);
  }

}
