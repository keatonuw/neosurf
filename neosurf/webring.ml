open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type theme_color = string [@@deriving yojson]

type theme_font = Serif | SanSerif [@@deriving yojson]

let string_of_font (font : theme_font) =
  match font with
  | Serif -> "serif"
  | SanSerif -> "sans-serif"
let font_of_string s =
  if s = "serif" then Serif 
  else SanSerif

(** a member of a webring is called [name] and has a site at [url] *)
type webring_member = {
  name : string;
  url : string;
} [@@deriving yojson]

type webring_theme = {
  color : theme_color;
  font : theme_font;
  font_size : int;
} [@@deriving yojson]

(** a webring has a [name] and a list of [members] *)
type webring = {
  name : string;
  members : webring_member list;
  theme : webring_theme;
} [@@deriving yojson]

(* creating type for serialization purposes *)
type webring_list = (int * webring) list [@@deriving yojson]

let default_theme = {
  color = "#000000";
  font = Serif;
  font_size = 12;
}

(** [create name owner url] creates a [webring] called [name] with a member [owner] at URL [url] *)
let create name owner url = {
  name = name;
  members = [{ name = owner; url = url; }];
  theme = default_theme;
}

(** [add_member member webring] is a webring identical to [webring] but with  [member] added *)
let add_member (m : webring_member) = function
  | { name = n; members = ms; theme = t; } ->
    { name = n; members = m :: ms; theme = t; }

let theme t = function
  | { name; members; _; } ->
    { name = name; members = members; theme = t; }

(** [remove_member name webring] is a webring identical to [webring] but without the member [name] *)
let remove_member (member : string) = function
  | { name; members; theme = t; } ->
    { name = name; members = (List.filter (fun (m : webring_member) -> m.name <> member) members); theme = t; }

(** helper to navigate member lists *)
let adv_member adv_fn (current : webring_member) = function
  | { name = _; members = ms; theme = _ } ->
    let idx = match (List.find_index (fun m -> m = current) ms) with Some i -> i | None -> 0 in
    List.nth ms ((abs (adv_fn idx)) mod (List.length ms))

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
