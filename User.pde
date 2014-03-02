//Programme object, used to store information for each user
public class User {

  //declare variable for values
  private int user_id;
  private String user_name;
  private String password;
  private int therapist_id;
  private String first_name;
  private String last_name;
  private String dob;
  private String height;
  private String weight;
  private String sex;
  private String injury_type;
  private String error = null;

  public User () {
    this.user_id = -1;
  }

  //constructor that takes all values and sets them        
  public User (int id, String un, String pw, int tid, String fn, String ln, String db, String uh, String wt, String sx, String it, String er) {
    this.user_id = id;
    this.user_name = un;
    this.password = pw;
    this.therapist_id = tid;
    this.first_name = fn;
    this.last_name = ln;
    this.dob = db;
    this.height = uh; 
    this.weight = wt;
    this.sex = sx;
    this.injury_type = it;
    this.error = er;
  }

  //getters and setters for the user values
  public int getUser_id() {
    return user_id;
  }

  public String getDob() {
    return dob;
  }

  public void setDob(String dob) {
    this.dob = dob;
  }

  public String getHeight() {
    return height;
  }

  public void setHeight(String height) {
    this.height = height;
  }

  public String getWeight() {
    return weight;
  }

  public void setWeight(String weight) {
    this.weight = weight;
  }

  public String getSex() {
    return sex;
  }

  public void setSex(String sex) {
    this.sex = sex;
  }

  public String getInjury_type() {
    return injury_type;
  }

  public void setInjury_type(String injury_type) {
    this.injury_type = injury_type;
  }

  public void setUser_id(int user_id) {
    this.user_id = user_id;
  }

  public String getUser_name() {
    return user_name;
  }

  public void setUser_name(String user_name) {
    this.user_name = user_name;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public int getTherapist_id() {
    return therapist_id;
  }

  public void setTherapist_id(int therapist_id) {
    this.therapist_id = therapist_id;
  }

  public String getFirst_name() {
    return first_name;
  }

  public void setFirst_name(String first_name) {
    this.first_name = first_name;
  }

  public String getLast_name() {
    return last_name;
  }

  public void setLast_name(String last_name) {
    this.last_name = last_name;
  }

  public String getError() {
    return this.error;
  }

  public void setError(String err) {
    this.error = err;
  }
}

