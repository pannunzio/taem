/****
SAVE THIS SOMEWHERE!!
 mdls -name kMDItemDisplayName -name kMDItemFinderComment -name kMDItemUserTags *.mp4 >> tags.txt
***/


import java.util.Map;

Table tagsTable;
HashMap<String,Integer> feels = new HashMap<String,Integer>();
HashMap<String,Integer> needs = new HashMap<String,Integer>();
HashMap<String,Integer> cats = new HashMap<String,Integer>();
HashMap<String,Integer> labs = new HashMap<String,Integer>();
HashMap<String,Integer> sLabs = new HashMap<String,Integer>();

String[] feelingsInventory = {"affectionate", "engaged", "hopeful", "confident", "excited", "grateful", "inspired", "joyful", "exhilarated", "peaceful", "refreshed", "afraid", "annoyed", "angry", "aversion", "confused", "disconnected", "disquiet", "embarassed", "fatigue", "pain", "sad", "tense", "vulnerable", "yearning"};
String[] needsInventory = {"connection", "physicalWellbeing", "honesty", "play", "peace", "autonomy", "meaning"};
String[] categories = {"ALONE", "LISTENING", "SPEAKING"};
String[] labels = {"PROMPT", "WAITING", "REACTION"};
String[] subLabels = {"DISMISSAL", "AGREE", "DISAGREE", "QUESTION", "STATEMENT", "GREETING"};

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
  for(int i = 0; i < labels.length; i++){
    labs.put(labels[i], i);
  }
  for(int i = 0; i < subLabels.length; i++){
    sLabs.put(subLabels[i], i);
  }
  
  parseTags();
  printTable();
}

void parseTags(){
  String[] lines = loadStrings("tags.txt");
  
  tagsTable = new Table();
  
  tagsTable.addColumn("id");
  tagsTable.addColumn("Clip Name");
  tagsTable.addColumn("Needs");
  tagsTable.addColumn("Feelings");
  tagsTable.addColumn("Category");
  tagsTable.addColumn("Label");
  tagsTable.addColumn("SubLabel");
  tagsTable.addColumn("Dialog");
  
  
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
        String l = "";
        String sl = "";
        
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
          } else if(labs.get(s) != null){
            l += s + ",";
          } else if(sLabs.get(s) != null){
            sl += s + ",";
          }
          i++;
         }
         
        newRow = tagsTable.getRow(tagsTable.getRowCount()-1);
        newRow.setString("Category", c.substring(0, c.length() - 1));
        newRow.setString("Needs", n);
        newRow.setString("Feelings", f);
        if(l.length() > 1)
          newRow.setString("Label", l.substring(0, l.length() - 1));
        else 
          newRow.setString("Label", l);
        if(sl.length() > 1)
          newRow.setString("SubLabel", sl.substring(0, sl.length() - 1));
        else 
          newRow.setString("SubLabel", sl);
      } else {
        i++;
      }
    } else if(parsed[0].equals("kMDItemFinderComment")){
      if(!parsed[parsed.length-1].equals("(null)")){
        String s = lines[i].substring(24, lines[i].length() - 1);
        i++;
        newRow = tagsTable.getRow(tagsTable.getRowCount()-1);
        newRow.setString("Dialog", s);
      } else {
        i++;
      }
    }else {
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
   println("|CLIP NAME\t|CATEGORY\t|NEEDS\t\t|FEELINGS\t\t|SUBLABEL\t|DIALOG");
  for (TableRow row : table.rows()) {

    String name = row.getString("Clip Name");
    String cat = row.getString("Category");
    String need = row.getString("Needs");
    String feel = row.getString("Feelings");
    String label = row.getString("Label");
    String sublabel = row.getString("SubLabel");
    String dialog = row.getString("Dialog");

    println(name + "|" + cat + "|" + need + "|" + feel + "|" + label+ "|" + sublabel+ "|" + dialog);
  }

}
