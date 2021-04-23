import java.util.Map;

String[] questionWords = {"who", "what", "where", "why", "when", "how", "is", "are"};
String[] identifierWords = {"me", "my", "mine", "your", "yours", "she", "her", "hers", "they", "them", "theirs", "he", "his", "him"}; 

public class Machine{
  private HashMap<String, Float> needs;
  private HashMap<String, Float> feelings;
 
  private State state;
  private State previousState;
  private Engagement engagement;
  private Behavior behavior;
  
  private String  primaryNeed;
  private Float   primaryScore;
  
  private Boolean resetTimer;
  private String subtitle;
  
  public Machine(){
    this.needs = new HashMap<String, Float>();
    this.feelings = new HashMap<String, Float>();
    this.state = State.ALONE;
    this.previousState = State.ALONE;
    this.engagement = Engagement.GREETING;
    this.behavior = Behavior.PROMPT;
    this.primaryNeed = "connection";
    this.primaryScore = 0.0;
    
    //all needs begin with a score of 80% met -- contentness 
    for (int i = 0; i < needsInventory.length; i++){
      needs.put(needsInventory[i].toLowerCase(), 0.0f);
    }
    for (int i = 0; i < feelingsInventory.length; i++){
      needs.put(feelingsInventory[i].toLowerCase(), 0.0f);
    }
     
    updatePrimaryNeed();
    this.resetTimer = false;
    this.subtitle = null;
  }
  
  void updateNeed(String need, int score){  
    println("need updated: " + need);
    needs.put(need, needs.get(need) + score);
    updatePrimaryNeed();
  }
  
  void updatePrimaryNeed(){
    for (Map.Entry n : needs.entrySet()) {
      if((float) n.getValue() > this.primaryScore){
        this.primaryNeed = (String) n.getKey();
        this.primaryScore = (float) n.getValue();
      }
    }
    println("primary Need: " + primaryNeed);
  }
  
  void resetInventory(){
     for (int i = 0; i < needsInventory.length; i++){
      needs.remove(needsInventory[i].toLowerCase());
    }
    for (int i = 0; i < needsInventory.length; i++){
      needs.put(needsInventory[i].toLowerCase(), 0.0f);
    }
    for (int i = 0; i < feelingsInventory.length; i++){
      needs.remove(feelingsInventory[i].toLowerCase());
    }
    for (int i = 0; i < feelingsInventory.length; i++){
      needs.put(feelingsInventory[i].toLowerCase(), 0.0f);
    }
  }
   
  void setEngagement(String firstWord){
    Boolean flag = false;
    for(String s: questionWords){
      if(firstWord.equals(s)){
        flag = true;
        break;
      }      
    }
    if(!flag){
      setEngagement(Engagement.QUESTION);
    } else {
      for(String s: identifierWords){
        if(firstWord.equals(s)){
          flag = true;
          break;
        }      
      }
      if(flag)
        setEngagement(Engagement.STATEMENT);
      else{
        float f = random(0, 100);
        if(f < 25)
          setEngagement(Engagement.AGREE);
        else if(f < 50)
          setEngagement(Engagement.DISAGREE);
        else if (f < 75)
          setEngagement(Engagement.STATEMENT);
        else
          setEngagement(Engagement.QUESTION);
      }
    }
  }
  
  void updateState(){
   
    if(this.resetTimer){
      this.resetTimer = false;     
      if(getState() == State.LISTENING 
        && getBehavior() == Behavior.WAITING){
        setState(State.ALONE);
      }
      println("new state: " + this.state);
    }
  }
  
  Engagement getEngagement(){
    return this.engagement;
  }
  
  String getEngagementString(){
    switch(this.engagement){
      case DISMISSAL:
       return "DISMISSAL";
      case GREETING:
       return "GREETING";
      case AGREE:
        return "AGREE";
      case DISAGREE:
        return "DISAGREE";
      case STATEMENT:
        return "STATEMENT";
      case QUESTION:
        return "QUESTION";
      default:
        return null;
    }
  }
  
  void setEngagement(Engagement e){
    this.engagement = e;
  }
  
  State getState (){
    return this.state;
  }

  String getStateString (){
    switch(this.state){
      case ALONE:
       return "ALONE";
      case LISTENING:
       return "LISTENING";
      case SPEAKING:
        return "SPEAKING";
      default:
        return null;
    }
  }  
  
  
  Behavior getBehavior (){
    return this.behavior;
  }

  String getBehaviorString (){
    switch(this.behavior){
      case PROMPT:
       return "PROMPT";
      case WAITING:
       return "WAITING";
      case REACTION:
        return "REACTION";
      default:
        return null;
    }
  }  
  
  void setState(State state){
    this.previousState = this.state;
    this.state = state;
  }
  
  State getPreviousState(){
    return this.previousState;
  }
  
  void setBehavior(Behavior b){
    this.behavior = b;
  }
  
  String getPrimaryNeed(){
    return this.primaryNeed;
  }
  
  void resetTimer(){
    this.resetTimer = true;
  }
  
  //FOR TESTING ONLY!!!!
  void setPrimaryNeed(String need){
    this.primaryNeed = need;
  }
  
  void setSubtitle(String s){
    if(s != null)
      this.subtitle = s;
  }
  
  String getSubtitle(){
    return this.subtitle;
  }
  
  void resetSubtitle(){
    this.subtitle = null;
  }
}
