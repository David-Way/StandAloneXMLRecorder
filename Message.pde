//Messsage object. Used to display information messages on screen
class Message {

  //Create a CP5 group
  private Group messageGroup;
  //Create array to store the textlabels
  private Textlabel [] textlabels;

  //Set background
  color bgCol = color(68, 142, 174);
  //Message variables
  int m_height, m_width;
  PVector position;
  String m_string;
  String groupName = "messageGroup";
  int m_fontSize = 24;

  //Constructor that takes all values and sets them   
  public Message(int _w, int _h, PVector _pos, String _s) {
    //bgCol = bgCol;
    m_height = _h;
    m_width = _w;
    position = _pos;
    m_string = _s;
  }

  //Second constructor to take the fontsize   
  public Message(int _w, int _h, PVector _pos, String _s, int _fs) {
    m_fontSize = _fs;
    m_height = _h;
    m_width = _w;
    position = _pos;
    m_string = _s;
  }

  //Create function creates the message UI
  public void create(String gname, String lname) {
    cp5.setAutoDraw(false);
    groupName = gname;

    messageGroup = cp5.addGroup(gname)
      .setPosition(position)
        .setSize(m_width, m_height)
          .setBackgroundColor(color(bgCol))
            .hideBar()
              ;

    textlabels = new Textlabel[1];


    textlabels[0] = cp5.addTextlabel(lname)
      .setText(m_string)
        .setPosition(10, 10)
          .setWidth(m_width - 10)
            .setHeight(m_height - 10)
              .setColorValue(0xffffffff)
                .setFont(createFont("Arial", m_fontSize))
                  .setGroup(messageGroup)
                    .setMultiline(true)
                      ;
  }

  //this function draws the cp5 object UI elements
  void drawUI() {
    cp5.draw();
  }

  //this function is called to remove the textlabels and group UI elements
  void destroy() {
    for ( int i = 0 ; i < textlabels.length ; i++ ) {
      textlabels[i].remove();
      textlabels[i] = null;
    }
    cp5.getGroup(groupName).remove();
  }

  boolean check() {
    boolean result = false;
    if (textlabels.length > 0) {
      result = true;
    }
    return result;
  }
}

