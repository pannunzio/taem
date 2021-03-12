

void beginPhraseAnalysis(String[] message){
  XML[] words = dictionary.getChildren("word");
 
  for(int i = 0; i < message.length; i++){
    //fun fact: did you know that filling your code with breaks is poor practice and has a large potential for bugs
    //this is related to how the assembler handles the breaks in code. I can talk about this at length if you want.
    //always use flags and returns if possible;
    String word = message[i];
    println("WORD OF THE DAY: " + word + "\n****************");
    Boolean flag = false;
    for (int j = 0; j < words.length && !flag; j++){
      if(word.equals(words[j].getString("name"))){
        flag = true;
       // extractEntry(words[j]);
      }
    }
    addEntry(message[i]);
  }    
}
void printParsedMsg(String[] message){
  println("message: ");
  for(int i = 0; i < message.length; i++){
    println("\t- " + message[i]);
  }    
}

void extractEntry(XML entry){
  
}

void addEntry(String newWord){
  XML newEntry = dictionary.addChild("word");
  newEntry.setContent(newWord);
  JSONArray json = loadJSONArray(getRequestUrl() + newWord + getToken());
  String[] syn = getRelated(json);
  println(syn);
  //println(json);
}

String[] getRelated(JSONArray apiReq) {
  JSONArray synonyms = apiReq.getJSONObject(0).getJSONArray("def").getJSONObject(0).getJSONArray("sseq").getJSONArray(0).getJSONArray(0).getJSONObject(1).getJSONArray("syn_list").getJSONArray(0);
  String[] syns = new String[synonyms.size()];
  for(int i = 0; i < synonyms.size(); i++){
    JSONObject syn = synonyms.getJSONObject(i); 
    syns[i] = syn.getString("wd");
  }
  return syns;
}
