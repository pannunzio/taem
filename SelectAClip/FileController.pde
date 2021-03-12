void initDBConnection(){
  try{
    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/clip_management?" + "user=processing&password=root123!!");
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
  String clipName = "0002.mp4";
  ArrayList<String> l = new ArrayList<String>();
  String need = machine.getPrimaryNeed();
  
  ResultSet rs = null;
  Statement stmt = null;
  String q = "select CLIP_ID from " + need.toUpperCase();
  //printFlags();
  
  q += " WHERE LABEL IS NOT NULL ";//AND CATEGORY IS NOT NULL ";
  if (actionFlag){
    q+= "AND CATEGORY LIKE %action% ";
  }
  if (cancelDialog)
    q+= "AND CATEGORY NOT LIKE '%dialog%' ";
  else if(dialogFlag)
    q+= "AND CATEGORY LIKE '%dialog%' ";
  if (movementFlag)
    q+= "AND LABEL LIKE '%movement%' ";
  if (greetingFlag)
    q+= "AND LABEL LIKE '%greeting%' ";
  if (reactionFlag)
    q+= "AND CATEGORY LIKE '%reaction%' ";
  if (questionFlag)
    q+= "AND LABEL LIKE '%question%' ";
 
  println("query: " + q );
  try{
    stmt = conn.createStatement();
    rs = stmt.executeQuery(q);
    while(rs.next()){
      l.add(rs.getString("CLIP_ID"));
    }
    resetFlags();
  
  }catch (SQLException e){
    println(e.getMessage());
  }
  
  //just choosing a random clip here
  if(l.size() > 0){
    int n = (int) random(1, l.size()) - 1;
    clipName = (String) l.get(n);
  }
  return clipName;
}
