⟨Get,Post⟩←•Import"curl.bqn"

httpbinURL←"http://localhost:8080"

•Out "    Test GET"
r←Get httpbinURL∾"/get"
! 200=r.code
! 1=⊑"HTTP/"⍷r.headers
! 1=+´"Content-Type: "⍷r.headers
! 1=+´"Content-Length: "⍷r.headers
! 1=+´"""Host"": ""localhost:8080"""⍷r.content
! 1=+´"""User-Agent"": ""curl/bqn"""⍷r.content
! 0=+´"""Hello"": ""World"""⍷r.content
•Out "OK"

•Out "    Test GET with headers"
r↩⟨"User-Agent: toto","Content-Type: application/json","Hello: World"⟩Get httpbinURL∾"/get"
! 200=r.code
! 1=+´"""Host"": ""localhost:8080"""⍷r.content
! 1=+´"""User-Agent"": ""toto"""⍷r.content
! 1=+´"""Content-Type"": ""application/json"""⍷r.content
! 1=+´"""Hello"": ""World"""⍷r.content
•Out "OK"

•Out "    Test POST with headers"
r↩⟨"Content-Type: application/json"⟩Post⟨httpbinURL∾"/post","{""key"": ""value""}"⟩
! 200=r.code
! 1=⊑"HTTP/"⍷r.headers
! 1=+´"Content-Type: "⍷r.headers
! 1=+´"Content-Length: "⍷r.headers
! 1=+´"""Content-Type"": ""application/json"""⍷r.content
! 1=+´"""data"": ""{\""key\"": \""value\""}"""⍷r.content
•Out "OK"

•Out "All tests passed."
