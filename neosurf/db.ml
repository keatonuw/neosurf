module type DB = Caqti_lwt.CONNECTION

module Q = struct
  open Caqti_request.Infix
  open Caqti_type

  (** create a webring with a given JSON blob *)
  let create_webring = 
    (string ->. unit) @@
    "INSERT INTO webring(blob) VALUES ($1)"

  (** overwrite a webring's JSON blob *)
  let update_webring =
    (t2 int string ->. unit) @@
    "UPDATE webring SET blob = $2 WHERE id = $1"

  (** get a webring blob by id *)
  let get_webring =
    (int ->! string) @@
    "SELECT blob FROM webring WHERE id = $1"

  (** get all webrings *)
  let get_webrings =
    (unit ->* t2 int string) @@
    "SELECT id, blob FROM webring"

  (** delete webring by ID *)
  let delete_webring = 
    (int ->. unit) @@
    "DELETE FROM webring WHERE id = $1"
end

let create_webring =
  fun wr (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.create_webring (Yojson.Safe.to_string @@ Webring.yojson_of_webring wr) in
    Caqti_lwt.or_fail unit_or_error

let update_webring =
  fun id wr (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.update_webring (id, Yojson.Safe.to_string @@ Webring.yojson_of_webring wr) in
    Caqti_lwt.or_fail unit_or_error

let get_webring =
  fun id (module Db : DB) ->
    let%lwt blob_or_error = Db.find Q.get_webring id in
    Caqti_lwt.or_fail blob_or_error
    |> fun w ->
      match%lwt w with
      | blob -> Lwt.return (
          Yojson.Safe.from_string blob
          |> Webring.webring_of_yojson
        )

let get_webrings =
  fun (module Db : DB) ->
    let%lwt webrings_or_error = Db.collect_list Q.get_webrings () in
    Caqti_lwt.or_fail webrings_or_error 
    |> fun ws ->
      match%lwt ws with
      | list -> Lwt.return (
          List.map (fun (id, blob) -> (id, Webring.webring_of_yojson @@ Yojson.Safe.from_string blob)) list
        )

let delete_webring =
  fun id (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.delete_webring id in
    Caqti_lwt.or_fail unit_or_error
