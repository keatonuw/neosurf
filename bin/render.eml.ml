let widget name next prev =
  <html>
  <body>
    <div>
      <h1><%s name%></h1>
      <a href="<%s next%>">next</a>
      <a href="<%s prev%>">prev</a>
    </div>
  </body>
  </html>

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

let edit request id (wr : Webring.webring) =
  <html>
  <body>
    <h1><%s wr.name%></h1>
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
    <div>
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
