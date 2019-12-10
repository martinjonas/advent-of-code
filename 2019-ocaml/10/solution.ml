open Batteries
open Printf

let rec gcd a b = if b = 0 then a else gcd b (a mod b)

let get_pos array x y = Array.get (Array.get array y) x

let evaporated = ref 0
let evaporate array x y = Array.set (Array.get array y) x '.'; evaporated := !evaporated + 1

let get_angles arr =
  let possibilities = List.of_enum (-(Array.length arr - 1)--(Array.length arr - 1)) in
  List.map (fun dx -> List.map (fun dy -> (dx, dy)) possibilities) possibilities
  |> List.concat
  |> List.filter (fun (dx, dy) -> (gcd (abs dx) (abs dy) == 1))

let rec apply_to_nearest_with_angle
          arr ((x,y) : int*int) ((dx,dy) : int*int) oob visible =
  if (x + dx >= Array.length arr || y + dy >= Array.length arr ||
     x + dx < 0 || y + dy < 0)
  then oob
  else
    if get_pos arr (x + dx) (y+dy) == '#'
    then visible (x+dx) (y+dy)
    else apply_to_nearest_with_angle arr (x+dx, y+dy) (dx, dy) oob visible

let count_visible_with_angle arr (pos : int*int) (angle : int*int) =
  apply_to_nearest_with_angle arr pos angle 0 (fun _ _ -> 1)

let count_visible arr (pos : int*int) : int =
  get_angles arr
  |> List.map (count_visible_with_angle arr pos)
  |> List.sum

let evaporate_visible_with_angle arr (pos : int*int) (angle : int*int) =
  apply_to_nearest_with_angle arr pos angle ()
    (fun x y -> evaporate arr x y; printf "  %d. (%d, %d)\n" (!evaporated) x y)

let get_angle ((x,y) : int*int) : float = atan2 (float_of_int x) (float_of_int y)

let evaporate_visible arr (pos : int*int) : unit =
  get_angles arr
  |> List.sort (fun pos1 pos2 -> compare (get_angle pos2) (get_angle pos1))
  |> List.iter (evaporate_visible_with_angle arr pos)

let get_best_pos array =
  let pos_arr =
  Array.mapi (fun y ->
      Array.mapi (fun x ch ->
          match ch with
          | '#' -> count_visible array (x,y)
          | _   -> 0
    )) array in
  let best_num = Array.max (Array.map (Array.max) pos_arr) in
  let y = Array.findi (Array.mem best_num) pos_arr in
  let x = Array.findi ((==) best_num) (Array.get pos_arr y) in
  (x, y, best_num)

let solve array =
  let (x,y,best_num) = get_best_pos array in
  printf "Best: (%d,%d)\n" x y;
  printf "Evaporating:\n";
  evaporate_visible array (x, y)

let () = let filelines = File.lines_of "input" in
         filelines
         |> Enum.map (fun line -> Array.of_list (String.to_list line))
         |> Array.of_enum
         |> solve
