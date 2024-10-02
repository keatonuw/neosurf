module type DB = Caqti_lwt.CONNECTION

module Q = struct
  open Caqti_request.Infix
  open Caqti_type

  (** create a webring with a given name *)
  let create_webring = 
    (string ->. unit) @@
    "INSERT INTO webring(name) VALUES ($1)"

  (** get name of a webring by id *)
  let get_webring =
    (int ->! string) @@
    "SELECT name FROM webring WHERE id = $1"

  (** get all webrings *)
  let get_webrings =
    (unit ->* t2 int string) @@
    "SELECT id, name FROM webring"

  (** rename webring by ID *)
  let rename_webring =
    (t2 int string ->. unit) @@
    "UPDATE webring SET name = $2 WHERE id = $1"

  (** delete webring by ID *)
  let delete_webring = 
    (int ->. unit) @@
    "DELETE FROM webring WHERE id = $1"

  (** [add_member (webring_id, name, url)] adds a member [name] to [webring_id], linking to [url] *)
  let add_member = 
    (t3 int string string ->. unit) @@
    "INSERT INTO webring_members(webring_id, name, url) VALUES ($1, $2, $3)"

  (** remove a member by webring and member ID *)
  let delete_member =
    (t2 int int ->. unit) @@
    "DELETE FROM webring_members WHERE webring_id = $1, member_id = $2"

  (** [get_members_of webring_id] gets all member [(id, name, url)] records for [webring_id] *)
  let get_members_of =
    (int ->* t3 int string string)
    "SELECT wm.member_id, wm.name, wm.url FROM webring_members wm, webring w WHERE w.id = w.webring_id AND w.id = $1"
end

let create_webring =
  fun name (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.create_webring name in
    Caqti_lwt.or_fail unit_or_error

let get_webring =
  fun id (module Db : DB) ->
    let%lwt name_or_error = Db.find Q.get_webring id in
    Caqti_lwt.or_fail name_or_error

let get_webrings =
  fun (module Db : DB) ->
    let%lwt webrings_or_error = Db.collect_list Q.get_webrings () in
    Caqti_lwt.or_fail webrings_or_error 

let rename_webring = 
  fun id name (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.rename_webring (id, name) in
    Caqti_lwt.or_fail unit_or_error

let delete_webring =
  fun id (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.delete_webring id in
    Caqti_lwt.or_fail unit_or_error

let add_member =
  fun id name url (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.add_member (id, name, url) in
    Caqti_lwt.or_fail unit_or_error

let delete_member =
  fun wr_id m_id (module Db : DB) ->
    let%lwt unit_or_error = Db.exec Q.delete_member (wr_id, m_id) in
    Caqti_lwt.or_fail unit_or_error

let get_members_of = 
  fun id (module Db : DB) ->
    let%lwt members_or_error = Db.collect_list id in
    Caqti_lwt.or_fail members_or_error
