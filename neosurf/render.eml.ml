(** render a user's widget *)
let widget name next prev =
  <html>
  <body>
    <div id="widget">
      <h1 id="name"><%s name%></h1>
      <a href="<%s next%>" id="next">next</a>
      <a href="<%s prev%>" id="prev">prev</a>
    </div>
  </body>
  </html>

(** render all webrings *)
let webrings request wrs =
  <html>
  <body>
    <div>
      <a href="/webring/create">Create Webring</a>
    </div>
    <div>
% wrs |> List.iter begin fun ((id, { name; members; }) : int * Webring.webring) -> 
      <div>
        <p><%s name%></p>
        <a href="/webring/<%d id%>/edit">Edit</a>
        <form action="/webring/<%d id%>/delete" method="post">
          <%s! Dream.csrf_tag request%>
          <input type="submit" value="Delete"/>
        </form>
      </div>
      <div>
% members |> List.iter begin fun ({ name; url; } : Webring.webring_member) ->
        <div>
          <a href=<%s url%>><%s name%></a>
          <a href="/webring/<%d id%>/<%s name%>">Widget</a>
        </div>
% end;
% end;
      </div>
    </div>
  </body>
  </html>

(** form to create a webring *)
let create request = 
  <html>
  <body>
    <form action="/webring/create" method="post">
      <%s! Dream.csrf_tag request%>
      <label for="name">Webring Name</label>
      <input type="text" name="name">
      <label for="owner">Admin Name</label>
      <input type="text" name="owner">
      <label for="url">Admin URL</label>
      <input type="text" name="url">
      <input type="submit" value="Create">
    </form>
  </body>
  </html>

(** form to edit a webring *)
let edit request id (wr : Webring.webring) =
  <html>
  <body>
    <h1><%s wr.name%></h1>
    
    <div>
      <h3>Widget</h3>
      <form action="/webring/<%d id%>/theme" method="post" id="theme">
        <%s! Dream.csrf_tag request%>
        <select name="font">
          <option style="font-family:sans-serif" value="sans-serif">Sans-Serif</option>
          <option style="font-family:serif" value="serif">Serif</option>
        </select>
        <input type="color" name="color"/>
      </form>
      <h3>Widget Preview</h3>
      <%s! widget "Name" "/" "/"%>
    </div>
    <div>
      <h3>Members</h3>
      <ul>
% wr.members |> List.iteri begin fun i ({name; url;} : Webring.webring_member) ->
        <li>
          <a href=<%s url%>><%s name%></a>
          <form action="/webring/<%d id%>/<%s name%>/remove" method="post" id="remove<%d i%>">
            <%s! Dream.csrf_tag request%>
            <input type="submit" value="Remove" name="remove<%d i%>">
          </form>
        </li>
% end;
      </ul>
    </div>
    <div>
      <h3>Add Member</h3>
      <form action="/webring/<%d id%>/add" method="post" id="add">
        <%s! Dream.csrf_tag request%>

        <label for="name">Member Name</label>
        <input type="text" name="name">

        <label for="url">Member URL</label>
        <input type="text" name="url">

        <input type="submit" value="Add" name="add">
      </form>
    </div>
  </body>
  </html>
