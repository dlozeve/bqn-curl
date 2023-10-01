⟨Get,Post⟩←•Import"curl.bqn"

r←⟨"Content-Type: application/json"⟩Post"http://localhost:8080/post"‿"{""key"": ""value""}"
r.code
r.headers
r.content
