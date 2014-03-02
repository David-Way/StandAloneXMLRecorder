//This class is used to access user data
public class UserDAO {

  private final String USER_AGENT = "Mozilla/5.0";

  //Constructor
  public UserDAO () {
  }

  //This function returns a user object for the passed in user name and password
  public User logIn(String un, String pw) {

    //URL to make SLiM API request
    String url = "http://davidway.me/kinect/api/user.php/user_table/"+ un+"/" + pw;
    User user = new User();
    HttpClient client = new DefaultHttpClient();
    HttpGet request = new HttpGet(url);

    // add request header
    request.addHeader("User-Agent", USER_AGENT);//Set user agent
    HttpResponse response = null;
    try {   
      //execute the request using the client, store the response
      response = client.execute(request);

      System.out.println("\nSending 'GET' request to URL : " + url);
      System.out.println("Response Code : " + 
        response.getStatusLine().getStatusCode());

      //Create a buffered reader for the content of the HTTP request
      BufferedReader rd = new BufferedReader(
      new InputStreamReader(response.getEntity().getContent()));

      //Create a string buffer
      StringBuffer result = new StringBuffer();
      String line = "";
      //Loop through append the values of lines into the string buffer
      while ( (line = rd.readLine ()) != null) {
        result.append(line);
      }

      //Creates a Gson object, from the google json parsing library
      Gson gson = new Gson();
      //Set the user object equal to the result string parsed into a record object
      user = gson.fromJson(result.toString(), User.class);                        


      System.out.println("old " + result.toString());
      System.out.println("new" + user.getFirst_name());
    } 
    catch (Exception e) {
      System.out.println(e.getMessage());
    }

    //Return the user object
    return user;
  }
}

