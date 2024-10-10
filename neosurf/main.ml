let () = Dream.run
@@ Dream.logger
@@ Dream.memory_sessions
@@ Dream.sql_pool "sqlite3:db.sqlite3"
@@ Dream.router [
  Dream.get "" 
    (fun r -> Dream.redirect r "/webring");

  Dream.scope "/webring" [] [

    (* Get all webrings, HTML *)
    Dream.get "/" (fun request ->
      let%lwt rings = Dream.sql request Db.get_webrings in
      Render.webrings request rings
      |> Dream.html);

    (* Get all webrings, JSON *)
    Dream.get "/api" (fun request ->
      let%lwt rings = Dream.sql request Db.get_webrings in
      rings
      |> Webring.yojson_of_webring_list
      |> Yojson.Safe.to_string
      |> Dream.json);

    (* Get a webring, JSON *)
    Dream.get "/api/:id" (fun request ->
      let id = int_of_string @@ Dream.param request "id" in
      let%lwt ring = Dream.sql request (Db.get_webring id) in
      ring
      |> Webring.yojson_of_webring
      |> Yojson.Safe.to_string
      |> Dream.json);
       
    (* Create a webring (via form) *)
    Dream.post "/create" (fun request ->
      match%lwt Dream.form request with
      | `Ok ["name", name; "owner", owner; "url", url] ->
        let wr = Webring.create name owner url in
        let%lwt () = Dream.sql request (Db.create_webring wr) in
        Dream.redirect request "/webring/"
      | _ -> Dream.empty `Bad_Request);

    (* Get form to create webring *)
    Dream.get "/create" (fun request ->
      Render.create request 
      |> Dream.html);

    (* Get form to edit webring *)
    Dream.get "/:id/edit" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      let%lwt webring = Dream.sql request (Db.get_webring id) in
      Render.edit request id webring
      |> Dream.html);

    Dream.post "/:id/delete" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      let%lwt () = Dream.sql request (Db.delete_webring id) in
      match%lwt Dream.form request with
      | `Ok _ -> 
          Dream.redirect request "/webring/"
      | _ -> 
          Dream.empty `Bad_Request);

    (* Add a member to webring [id] *)
    Dream.post "/:id/add" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      match%lwt Dream.form request with 
      | `Ok ["add", _; "name", name; "url", url] -> 
        let%lwt webring = Dream.sql request (Db.get_webring id) in
        let wr = Webring.add_member { name = name; url = url } webring in 
        let%lwt () = Dream.sql request (Db.update_webring id wr) in
        let rd = "/webring/" ^ string_of_int id ^ "/edit" in
        Dream.redirect request rd
      | _ -> Dream.empty `Bad_Request);

    Dream.post "/:id/theme" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      match%lwt Dream.form request with
      | `Ok ["color", color; "font", font; "size", size] ->
        let%lwt webring = Dream.sql request (Db.get_webring id) in
          let size = int_of_string size in
          let wr = Webring.theme { color = color; font = Webring.font_of_string font; font_size = size; } webring in
        let%lwt () = Dream.sql request (Db.update_webring id wr) in
        let rd = "/webring/" ^ string_of_int id ^ "/edit" in
        Dream.redirect request rd
      | _ -> Dream.empty `Bad_Request);

    (* Remove [name] from webring [id] *)
    Dream.post "/:id/:name/remove" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      let name = Dream.param request "name" in
      match%lwt Dream.form request with
      | `Ok _ ->
        let%lwt webring = Dream.sql request (Db.get_webring id) in
        let wr = Webring.remove_member name webring in
        let%lwt () = Dream.sql request (Db.update_webring id wr) in
        let rd = "/webring/" ^ string_of_int id ^ "/edit" in
        Dream.redirect request rd
      | _ -> Dream.empty `Bad_Request);

    (* Get HTML widget for a webring member *)
    Dream.get "/:id/:name" (fun request ->
      let id = int_of_string @@ Dream.param request "id" in
      let name = Dream.param request "name" in
      let%lwt ring = Dream.sql request (Db.get_webring id) in
      let info = Webring.widget_data name ring in
      match info with 
      | Some (name, next, prev) ->
        Render.widget name next prev ring.theme
        |> Dream.html
      | None -> Dream.empty `Bad_Request);

  ];

  Dream.get "/static/**" @@ Dream.static "./static"; 
]
