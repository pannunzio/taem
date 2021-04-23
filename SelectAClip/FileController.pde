void initDBConnection(){
  try{
    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/clip_management2?" + "user=processing&password=root123!!");
  } catch (SQLException e) {
    println(e.getMessage());
  } catch (Exception e){
    println(e.getMessage());
  }
}

void selectAClip(){
  this.selectedClip = getVid();
  println("selected clip: " + this.selectedClip);
  isPlaying = true;
  try{
    clip = new Movie(this, FILEPATH + this.selectedClip);
  } catch(Exception e){
    print(e.getMessage());
  }

}

String getVid(){
  String clipName = null;
  ArrayList<Pair> l = new ArrayList<Pair>();
  String need = machine.getPrimaryNeed();
  String q = "select CLIP_ID, DIALOG from " ;
  
  ResultSet rs = null;
  
  if(machine.getState() == State.ALONE){
     q+= "speaking where Label like '%PROMPT%' AND SubLabel like '%GREETING%'";
  } else {
   q += machine.getStateString();
  
    if(machine.getState() == State.SPEAKING){
      q += " WHERE Label like '%" + machine.getBehavior() +"%'";
      q += " AND SubLabel like '%" + machine.getEngagement() + "%'";
      
      if(machine.getBehavior() == Behavior.REACTION){
        q += " AND NEEDS LIKE '%" + need + "%' OR NEEDS IS NULL";
      }
    }
  }
  //printFlags();
  try{
    rs = tryQuery(q);
    println("query: " + q );
    while(rs == null){
      q =  "select CLIP_ID, DIALOG from " + machine.getStateString();
      rs = tryQuery(q);
    } 
    while(rs.next()){
      l.add(new Pair(rs.getString("CLIP_ID"), rs.getString("DIALOG")));
    }
  } catch (SQLException e){
    println(e.getMessage());
  }
 
  if(!l.isEmpty()){
//  int n = (int) random(1, l.size()) - 1;
    Random rnd = new Random();
    Pair p = l.get(rnd.nextInt(l.size()));
    clipName = (String) p.getA();
//  clipName = (String) ((Pair) l.get(n)).getA(); //this is the single ugliest piece of syntax i've ever seen and i can't believe it actually worked
    String sub = (String) p.getB();
    if(!sub.isEmpty())
      machine.setSubtitle(sub);
  } 
    
  return clipName;
}

ResultSet tryQuery(String query){
  ResultSet rs = null;
  Statement stmt = null;
  try{
    stmt = conn.createStatement();
    rs = stmt.executeQuery(query);
    
    if(!rs.next()){
      return null;
    }
    
  }catch (SQLException e){
    println(e.getMessage());
  }
  return rs;
}
