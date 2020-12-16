import java.util.Map;

public class Machine{
  private HashMap<String, Float> needs;
  private State currentState;
  
  private String  primaryNeed;
  private Float   primaryScore; 
  
  public Machine(){
    this.needs = new HashMap<String, Float>();
    this.currentState = State.WAITING;
    this.primaryNeed = "connection";
    this.primaryScore = 0.0;
    
    //all needs begin with a score of 80% met -- contentness 
    for (int i = 0; i < needsInventory.length; i++){
      needs.put(needsInventory[i].toLowerCase(), random(8, 10));
    }
    
    //since the initial state is waiting, the needs that need to be met are meaning and connection
    needs.put("connection", needs.get("connection") - random(1.5, 2));
    needs.put("meaning", needs.get("meaning") - random(1.5, 2));
    
    updatePrimaryNeed();
  }
  
  void updateNeed(String need, Boolean isMet){
    float increment = random(0,10);
    if(!isMet)
      increment *= -1;
      
    needs.put(need, needs.get(need) + increment);
  }
  
  void updatePrimaryNeed(){
    for (Map.Entry n : needs.entrySet()) {
      if((float) n.getValue() < this.primaryScore){
        this.primaryNeed = (String) n.getKey();
        this.primaryScore = (float) n.getValue();
      }
    }
  }
  
  void updateState(ArrayList<Pair> needUpdate){
    for(Pair p : needUpdate){
      String needName;
      Boolean isMet;
      Float increment = random(0, 2);
      
      needName = (String) p.getA();
      isMet = (Boolean) p.getB();
      
      if(!isMet) increment *= -1;
      
      needs.put(needName, needs.get(needName) + increment);
    }
   
    updatePrimaryNeed();
    
    //it's after the updated primary need
    String tieBreaker = "connection";
    Float minScore = 10.0;
    for (Map.Entry n : needs.entrySet()) {
      if((float) n.getValue() <= minScore
          && !this.primaryNeed.equals((String) n.getKey())){
        tieBreaker = (String) n.getKey();
        minScore = (float) n.getValue();
      }
    }
    
    //so we got the top 2 needs now
    switch(this.primaryNeed){
      case "connection":
        if(tieBreaker.equals("meaning"))
          setState(State.WAITING);
        else if(tieBreaker.equals("physicalwellbeing") || tieBreaker.equals("play"))
          setState(State.ACTION);
        else if(tieBreaker.equals("honesty"))
          setState(State.QUESTION);
        else
          setState(State.REACTION);
        break;
      case "physicalwellbeing":
        setState(State.ACTION);
        break;
      case "play":
        //50-50 chance of being either or
        if(random(100) <50)
          setState(State.ACTION);
        else
          setState(State.QUESTION);
        break;
      case "meaning":
        setState(State.QUESTION);
        break;
      case "honesty":
        if(random(100) <50)
          setState(State.QUESTION);
        else
          setState(State.REACTION);
        break;
      case "peace":
        setState(State.REACTION);
        break;
      case "autonomy":
        if(tieBreaker.equals("physicalwellbeing") || tieBreaker.equals("play")) 
          setState(State.ACTION);
        else if(tieBreaker.equals("connection") || tieBreaker.equals("meaning") || tieBreaker.equals("peace"))
          setState(State.QUESTION);
        break;
      default:
        setState(State.WAITING);
        break;
    }
  }
  
  State getCurrentState (){
    return this.currentState;
  }
  
  void setState(State state){
    this.currentState = state;
  }
}
