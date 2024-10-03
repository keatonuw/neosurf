open Ppx_yojson_conv_lib.Yojson_conv.Primitives

(** a member of a webring is called [name] and has a site at [url] *)
type webring_member = {
  name : string;
  url : string;
} [@@deriving yojson]

(** a webring has a [name] and a list of [members] *)
type webring = {
  name : string;
  members : webring_member list;
} [@@deriving yojson]

(* creating type for serialization purposes *)
type webring_list = (int * webring) list [@@deriving yojson]

(** [create name owner url] creates a [webring] called [name] with a member [owner] at URL [url] *)
let create name owner url = {
  name = name;
  members = [{ name = owner; url = url; }];
}

(** [add_member member webring] is a webring identical to [webring] but with  [member] added *)
let add_member (m : webring_member) = function
  | { name = n; members = ms; } ->
    { name = n; members = m :: ms }

(** [remove_member name webring] is a webring identical to [webring] but without the member [name] *)
let remove_member (member : string) = function
  | { name; members; } ->
    { name = name; members = (List.filter (fun (m : webring_member) -> m.name <> member) members) }

(** helper to navigate member lists *)
let adv_member adv_fn (current : webring_member) = function
  | { name = _; members = ms } ->
    let idx = match (List.find_index (fun m -> m = current) ms) with Some i -> i | None -> 0 in
    List.nth ms ((adv_fn idx) mod (List.length ms))

(** [next_member member webring] is the next [webring_member] in [webring.members] *)
let next_member = adv_member ((+) 1)

(** [prev_member member webring] is the previous [webring_member] in [webring.members] *)
let prev_member = adv_member ((-) 1)

(** [rand_member member webring] is a random [webring_member] in [webring.members] *)
let rand_member = adv_member ((+) (Random.int 100))

  (** [widget_date name webring] is some [(name, next, prev)] tuple, where [name] is a webring member name, [next] links to the next member, and [prev] the previous. *)
let widget_data name (wr : webring) =
  let member = List.find_opt (fun (m : webring_member) -> m.name = name) wr.members in
  match member with
  | Some member -> Some (member.name, (next_member member wr).url, (prev_member member wr).url)
  | None -> None
