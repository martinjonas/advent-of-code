open Batteries
open Printf

module StringMap = Map.Make(String)

let rec count_subtree map node =
  StringMap.find_default [] node map
  |> List.map (count_subtree map)
  |> List.fold_left (+) 0
  |> (+) 1

let print_orbits map =
  StringMap.keys map
  |> Enum.map (fun node -> count_subtree map node - 1)
  |> Enum.fold (+) 0
  |> printf "%d"

let rec santa_you_steps map node =
  let children = StringMap.find_default [] node map in
  match children with
  | xs when List.mem "SAN" xs -> (0, 999999999999999)
  | xs when List.mem "YOU" xs -> (999999999999999, 0)
  | xs ->
     List.map (santa_you_steps map) xs
     |> List.fold_left (fun (x,y) (z,v) -> (min x z, min y v)) (999999999999999,999999999999999)
     |> fun (s, y) -> (if s < 999999999999999 && y < 999999999999999 then (s,y) else (s+1, y+1))

let solve orbit_pairs =
  let adjacency_map =
    Enum.fold (fun m (l,r) -> StringMap.modify_def [] l (fun list -> r :: list) m)
      StringMap.empty orbit_pairs in
  let (s, y) = santa_you_steps adjacency_map "COM"
  in printf "%d\n" ((s+1)+(y+1))

let () = let filelines = File.lines_of "input" in
         filelines
         |> Enum.map (fun s -> (String.sub s 0 3, String.sub s 4 3))
         |> solve
