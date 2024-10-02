let () = Dream.run
@@ Dream.logger
@@ Dream.router [
  Dream.get "" (fun _ ->
    "hello"
    |> Dream.html);
]
