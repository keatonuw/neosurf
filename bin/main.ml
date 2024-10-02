let () = Dream.run
@@ Dream.logger
@@ Dream.memory_sessions
@@ Dream.sql_pool "sqlite3:db.sqlite3"
@@ Dream.router [
  Dream.get "" (fun _ ->
    "hello"
    |> Dream.html);

  Dream.scope "/webring" [] [

    (* Get all webrings *)
    Dream.get "" (fun request ->
      let%lwt rings = Dream.sql request Db.get_webrings in
      rings
      |> Webring.yojson_of_webring_list
      |> Yojson.Safe.to_string
      |> Dream.json);

       
    (* Create a webring (via form) *)
    Dream.post "/create" (fun request ->
      match%lwt Dream.form request with
      | `Ok ["name", name; "owner", owner; "url", url] ->
        let wr = Webring.create name owner url in
        let%lwt () = Dream.sql request (Db.create_webring wr) in
        Dream.empty `OK
      | _ -> Dream.empty `Bad_Request);

    (* Get form to create webring *)
    Dream.get "/create" (fun request ->
      Render.create request 
      |> Dream.html);

    (* Get a webring *)
    Dream.get "/:id" (fun request ->
      let id = int_of_string @@ Dream.param request "id" in
      let%lwt ring = Dream.sql request (Db.get_webring id) in
      ring
      |> Webring.yojson_of_webring
      |> Yojson.Safe.to_string
      |> Dream.json);

    (* Get form to edit webring *)
    Dream.get "/:id/edit" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      let%lwt webring = Dream.sql request (Db.get_webring id) in
      Render.edit request id webring
      |> Dream.html);

    Dream.post "/:id/add" (fun request ->
      let id = int_of_string (Dream.param request "id") in
      match%lwt Dream.form request with 
      | `Ok ["name", name; "url", url] -> 
        let%lwt webring = Dream.sql request (Db.get_webring id) in
        let wr = Webring.add_member { name = name; url = url } webring in 
        let%lwt () = Dream.sql request (Db.update_webring id wr) in
        Dream.empty `OK
      | _ -> Dream.empty `Bad_Request);

    (* Get HTML widget for a webring member *)
    Dream.get "/:id/:name" (fun request ->
      let id = int_of_string @@ Dream.param request "id" in
      let name = Dream.param request "name" in
      let%lwt ring = Dream.sql request (Db.get_webring id) in
      let info = Webring.widget_data name ring in
      match info with 
      | Some (name, next, prev) ->
        Render.widget name next prev
        |> Dream.html
      | None -> Dream.empty `Bad_Request);

  ];
]
