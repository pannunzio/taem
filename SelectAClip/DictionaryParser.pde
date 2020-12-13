
void beginPhraseAnalysis(String[] message){
  printParsedMsg(message);
  
  for(int i = 0; i < message.length; i++){
    println("\t- " + message[i]);
  }    
}
void printParsedMsg(String[] message){
  println("message: ");
  for(int i = 0; i < message.length; i++){
    println("\t- " + message[i]);
  }    
}
