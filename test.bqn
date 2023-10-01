⟨Get⟩←•Import"curl.bqn"

r←⟨"Hello: World","Blabla: Blublu"⟩Get"http://httpbin.org/get?key=value"
r.code
r.headers
r.content
r.time
