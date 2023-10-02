#!/usr/bin/env bqn
⟨
  Get,Post,
  OpenSession,ResetSession,CloseSession,
  SetURL,SetHeaders,SetVerbose,SetTimeout,SetTimeoutms,SetData,
  Perform,
⟩←•Import"curl.bqn"

httpbinURL←"http://localhost:8080"
r←0

## Simple API

•Out "    Test GET"
r↩Get httpbinURL∾"/get"
! 200=r.code
! 0=r.redirectCount
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
! 0=r.redirectCount
! 1=+´"""Host"": ""localhost:8080"""⍷r.content
! 1=+´"""User-Agent"": ""toto"""⍷r.content
! 1=+´"""Content-Type"": ""application/json"""⍷r.content
! 1=+´"""Hello"": ""World"""⍷r.content
•Out "OK"

•Out "    Test POST with headers"
r↩⟨"Content-Type: application/json"⟩Post⟨httpbinURL∾"/post","{""key"": ""value""}"⟩
! 200=r.code
! 0=r.redirectCount
! 1=⊑"HTTP/"⍷r.headers
! 1=+´"Content-Type: "⍷r.headers
! 1=+´"Content-Length: "⍷r.headers
! 1=+´"""Content-Type"": ""application/json"""⍷r.content
! 1=+´"""data"": ""{\""key\"": \""value\""}"""⍷r.content
•Out "OK"

## Advanced API

•Out "    Test open session"
session←OpenSession @
! 8=≠session.sessionPtr
! (8↑0)≢session.headersSlist
•Out "OK"

•Out "    Test GET"
session↩ResetSession session
r↩Perform (httpbinURL∾"/get") SetURL session
! 200=r.code
! 0=r.redirectCount
! 10≤≠r.content
•Out "OK"

•Out "    Test POST"
session↩ResetSession session
r↩Perform "toto"SetData (httpbinURL∾"/post") SetURL session
! 200=r.code
! 0=r.redirectCount
! 1=+´"toto"⍷r.content
•Out "OK"

•Out "    Test basic auth fail"
session↩ResetSession session
session↩(httpbinURL∾"/basic-auth/username/s3cr3tpa55word") SetURL session
r↩Perform session
! 401=r.code
•Out "OK"

•Out "    Test basic auth with header"
session↩ResetSession session
session↩(httpbinURL∾"/basic-auth/username/s3cr3tpa55word") SetURL session
r↩Perform ⟨"Authorization: Basic dXNlcm5hbWU6czNjcjN0cGE1NXdvcmQ="⟩ SetHeaders session
! 200=r.code
•Out "OK"

•Out "    Test basic auth with URL"
session↩ResetSession session
session↩("http://username:s3cr3tpa55word@localhost:8080/basic-auth/username/s3cr3tpa55word") SetURL session
r↩Perform session
! 200=r.code
•Out "OK"

•Out "    Test bearer auth fail"
session↩ResetSession session
session↩(httpbinURL∾"/bearer") SetURL session
r↩Perform session
! 401=r.code
•Out "OK"

•Out "    Test bearer auth"
session↩ResetSession session
session↩(httpbinURL∾"/bearer") SetURL session
r↩Perform ⟨"Authorization: Bearer hey!"⟩ SetHeaders session
! 200=r.code
•Out "OK"

•Out "    Test status GET"
session↩ResetSession session
r↩Perform (httpbinURL∾"/status/418") SetURL session
! 418=r.code
•Out "OK"

•Out "    Test status POST"
session↩ResetSession session
r↩Perform ""SetData (httpbinURL∾"/status/418") SetURL session
! 418=r.code
•Out "OK"

•Out "    Test set headers"
session↩ResetSession session
session↩(httpbinURL∾"/headers") SetURL session
r↩Perform ⟨"Hello: World"⟩ SetHeaders session
! 1=+´"""Hello"": ""World"""⍷r.content
•Out "OK"

•Out "    Test default user-agent"
session↩ResetSession session
session↩(httpbinURL∾"/user-agent") SetURL session
r↩Perform session
! 1=+´"curl/bqn"⍷r.content
•Out "OK"

•Out "    Test custom user-agent"
session↩ResetSession session
session↩(httpbinURL∾"/user-agent") SetURL session
r↩Perform ⟨"User-Agent: hello/world"⟩ SetHeaders session
! 0=+´"curl/bqn"⍷r.content
! 1=+´"hello/world"⍷r.content
•Out "OK"

•Out "    Test timeout with fast request"
session↩ResetSession session
session↩1010 SetTimeoutms (httpbinURL∾"/delay/1") SetURL session
r↩Perform session
! 200=r.code
•Out "OK"

•Out "    Test request timeout"
session↩ResetSession session
session↩100 SetTimeoutms (httpbinURL∾"/delay/1") SetURL session
! Perform⎊1 session
•Out "OK"

•Out "    Test follow redirects"
session↩ResetSession session
r↩Perform (httpbinURL∾"/redirect/5") SetURL session
! 200=r.code
! 5=r.redirectCount
•Out "OK"

•Out "    Test follow absolute redirects"
session↩ResetSession session
r↩Perform (httpbinURL∾"/absolute-redirect/5") SetURL session
! 200=r.code
! 5=r.redirectCount
•Out "OK"

•Out "    Test follow relative redirects"
session↩ResetSession session
r↩Perform (httpbinURL∾"/relative-redirect/5") SetURL session
! 200=r.code
! 5=r.redirectCount
•Out "OK"

•Out "    Test parameters"
session↩ResetSession session
r↩Perform (httpbinURL∾"/anything?hello=world&zig=zag") SetURL session
! 1=+´"""hello"": ""world"""⍷r.content
! 1=+´"""zig"": ""zag"""⍷r.content
•Out "OK"

•Out "    Test close session"
CloseSession session
•Out "OK"

•Out "All tests passed."
