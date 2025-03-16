#!/usr/bin/env bqn
⟨
  Get,Post,
  OpenSession,ResetSession,CloseSession,
  SetURL,SetHeaders,SetVerbose,SetTimeout,SetTimeoutms,SetData,
  Perform,
⟩←•Import"curl.bqn"

httpbinURL←"http://localhost:8080"

RunTest←{•term.OutRaw (4⥊' ')∾"Test "∾𝕨 ⋄ 𝕏 @ ⋄ •Out ((69-≠𝕨)⥊'.')∾"OK"}
RunSuite←{•Out 𝕨∾':' ⋄ RunTest´¨𝕩 ⋄ •Out "    All "∾(•Fmt ≠𝕩)∾" tests passed."}
RunAll←{RunSuite´¨𝕩 ⋄ •Out "All "∾(•Fmt +´≠¨⊢´¨𝕩)∾" tests passed."}

simpleAPI_testsuite←⟨
  "simple GET"‿{𝕊𝕩:
    r←Get httpbinURL∾"/get"
    ! 200=r.code
    ! 0=r.redirectCount
    ! 1=⊑"HTTP/"⍷r.headers
    ! 1=+´"Content-Type: "⍷r.headers
    ! 1=+´"Content-Length: "⍷r.headers
    ! 1=+´"""Host"": ""localhost:8080"""⍷r.content
    ! 1=+´"""User-Agent"": ""curl/bqn"""⍷r.content
    ! 0=+´"""Hello"": ""World"""⍷r.content
  },
  "simple GET with headers"‿{𝕊𝕩:
    headers←⟨"User-Agent: toto","Content-Type: application/json","Hello: World"⟩
    r←headers Get httpbinURL∾"/get"
    ! 200=r.code
    ! 0=r.redirectCount
    ! 1=+´"""Host"": ""localhost:8080"""⍷r.content
    ! 1=+´"""User-Agent"": ""toto"""⍷r.content
    ! 1=+´"""Content-Type"": ""application/json"""⍷r.content
    ! 1=+´"""Hello"": ""World"""⍷r.content
  },
  "simple POST with headers"‿{𝕊𝕩:
    headers←⟨"Content-Type: application/json"⟩
    r←headers Post ⟨httpbinURL∾"/post",¯1000 + 1000 + "{""key"": 1}"⟩
    ! 200=r.code
    ! 0=r.redirectCount
    ! 1=⊑"HTTP/"⍷r.headers
    ! 1=+´"Content-Type: "⍷r.headers
    ! 1=+´"Content-Length: "⍷r.headers
    ! 1=+´"""Content-Type"": ""application/json"""⍷r.content
    ! 1=+´"""data"": ""{\""key\"": \""value\""}"""⍷r.content
  }
⟩

advancedAPI_testsuite←⟨
  "open session"‿{𝕊𝕩:
    session←OpenSession @
    ! 8=≠session.sessionPtr
    ! (8↑0)≢session.headersSlist
    CloseSession session
  },
  "GET"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform (httpbinURL∾"/get") SetURL session
    ! 200=r.code
    ! 0=r.redirectCount
    ! 10≤≠r.content
    CloseSession session
  },
  "POST"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform "toto"SetData (httpbinURL∾"/post") SetURL session
    ! 200=r.code
    ! 0=r.redirectCount
    ! 1=+´"toto"⍷r.content
    CloseSession session
  },
  "basic auth fail"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/basic-auth/username/s3cr3tpa55word") SetURL session
    r←Perform session
    ! 401=r.code
    CloseSession session
  },
  "basic auth with header"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/basic-auth/username/s3cr3tpa55word") SetURL session
    r←Perform ⟨"Authorization: Basic dXNlcm5hbWU6czNjcjN0cGE1NXdvcmQ="⟩ SetHeaders session
    ! 200=r.code
    CloseSession session
  },
  "basic auth with URL"‿{𝕊𝕩:
    session←OpenSession @
    session↩("http://username:s3cr3tpa55word@localhost:8080/basic-auth/username/s3cr3tpa55word") SetURL session
    r←Perform session
    ! 200=r.code
    CloseSession session
  },
  "bearer auth fail"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/bearer") SetURL session
    r←Perform session
    ! 401=r.code
    CloseSession session
  },
  "bearer auth"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/bearer") SetURL session
    r←Perform ⟨"Authorization: Bearer hey!"⟩ SetHeaders session
    ! 200=r.code
    CloseSession session
  },
  "status GET"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform (httpbinURL∾"/status/418") SetURL session
    ! 418=r.code
    CloseSession session
  },
  "status POST"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform ""SetData (httpbinURL∾"/status/418") SetURL session
    ! 418=r.code
    CloseSession session
  },
  "set headers"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/headers") SetURL session
    r←Perform ⟨"Hello: World"⟩ SetHeaders session
    ! 1=+´"""Hello"": ""World"""⍷r.content
    CloseSession session
  },
  "default user-agent"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/user-agent") SetURL session
    r←Perform session
    ! 1=+´"curl/bqn"⍷r.content
    CloseSession session
  },
  "custom user-agent"‿{𝕊𝕩:
    session←OpenSession @
    session↩(httpbinURL∾"/user-agent") SetURL session
    r←Perform ⟨"User-Agent: hello/world"⟩ SetHeaders session
    ! 0=+´"curl/bqn"⍷r.content
    ! 1=+´"hello/world"⍷r.content
    CloseSession session
  },
  "timeout with fast request"‿{𝕊𝕩:
    session←OpenSession @
    session↩1010 SetTimeoutms (httpbinURL∾"/delay/1") SetURL session
    r←Perform session
    ! 200=r.code
    CloseSession session
  },
  "request timeout"‿{𝕊𝕩:
    session←OpenSession @
    session↩100 SetTimeoutms (httpbinURL∾"/delay/1") SetURL session
    ! Perform⎊1 session
    CloseSession session
  },
  "follow redirects"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform (httpbinURL∾"/redirect/5") SetURL session
    ! 200=r.code
    ! 5=r.redirectCount
    CloseSession session
  },
  "follow absolute redirects"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform (httpbinURL∾"/absolute-redirect/5") SetURL session
    ! 200=r.code
    ! 5=r.redirectCount
    CloseSession session
  },
  "follow relative redirects"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform (httpbinURL∾"/relative-redirect/5") SetURL session
    ! 200=r.code
    ! 5=r.redirectCount
    CloseSession session
  },
  "parameters"‿{𝕊𝕩:
    session←OpenSession @
    r←Perform (httpbinURL∾"/anything?hello=world&zig=zag") SetURL session
    ! 1=+´"""hello"": ""world"""⍷r.content
    ! 1=+´"""zig"": ""zag"""⍷r.content
    CloseSession session
  },
⟩

RunAll⟨
  "Simple API"‿simpleAPI_testsuite,
  "Advanced API"‿advancedAPI_testsuite,
⟩
