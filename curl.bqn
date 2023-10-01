⟨Get,Post⟩⇐

⟨
  easyInit,
  easyCleanup,
  easySetoptStr,
  easySetoptPtr,
  easySetoptLong,
  easyPerform,
  easyGetinfoStr,
  easyGetinfoLong,
  easyGetinfoDouble,
  slistAppend,
  slistFreeAll,
  fopen,
  fclose,
  curlOptions,
  curlInfo
⟩←•Import"ffi.bqn"
⟨RandID⟩←•Import"utils.bqn"

Check←{
  msg←"Curl: "∾𝕨∾" ("∾(•Fmt 𝕩)∾")"
  msg ! 𝕩=0
}

PrepareRequest←{session 𝕊 url‿headers:
  id←RandID 32
  filename←"/tmp/bqncurl."∾id
  filePtr←Fopen⟨filename∾@,"w+"⟩
  headerFilename←"/tmp/bqncurl.header."∾id
  headerFilePtr←Fopen⟨headerFilename∾@,"w+"⟩

  "setting user agent"Check EasySetoptStr⟨session,curlOptions.useragent,"curl/bqn"∾@⟩
  "setting URL"Check EasySetoptStr⟨session,curlOptions.url,url∾@⟩
  "setting file target"Check EasySetoptPtr⟨session,curlOptions.writedata,filePtr⟩
  "setting header file target"Check EasySetoptPtr⟨session,curlOptions.headerdata,headerFilePtr⟩
  "setting redirect option"Check EasySetoptLong⟨session,curlOptions.followlocation,1⟩
  # "setting verbosity"Check EasySetoptLong⟨session,curlOptions.verbose,1⟩
  slist←(8↑0){SlistAppend⟨𝕩,𝕨∾@⟩}´headers
  "setting headers"Check rheaders←EasySetoptPtr⟨session,curlOptions.httpHeader,slist⟩

  slist‿filename‿filePtr‿headerFilename‿headerFilePtr
}

ReadResponse←{session 𝕊 slist‿filename‿filePtr‿headerFilename‿headerFilePtr:
  SlistFreeAll slist

  rcode‿⟨code⟩←EasyGetinfoLong⟨session,curlInfo.responseCode,⟨0⟩⟩
  "retrieving response code"Check rcode
  rtime‿⟨time⟩←EasyGetinfoDouble⟨session,curlInfo.totalTime,⟨0.0⟩⟩
  "retrieving request time"Check rtime

  Fclose filePtr
  Fclose headerFilePtr

  content←•file.Bytes filename
  responseHeaders←•file.Chars headerFilename

  •file.Remove filename
  •file.Remove headerFilename

  {
    code⇐code,
    time⇐time,
    headers⇐responseHeaders,
    content⇐content,
  }
}

Get←{
𝕊 url: ⟨⟩ 𝕊 url ;
headers 𝕊 url:
  session←EasyInit⟨⟩
  d←session PrepareRequest url‿headers

  "performing request"Check EasyPerform⟨session⟩

  response←session ReadResponse d
  EasyCleanup session
  response
}

Post←{
𝕊 url‿data: ⟨⟩ 𝕊 url‿data ;
headers 𝕊 url‿data:
  session←EasyInit⟨⟩
  d←session PrepareRequest url‿headers
  "setting up POST request"Check EasySetoptLong⟨session,curlOptions.post,1⟩
  "setting POST data"Check EasySetoptStr⟨session,curlOptions.postfields,data⟩
  "setting POST data size"Check EasySetoptLong⟨session,curlOptions.postfieldsize,≠data⟩

  "performing request"Check EasyPerform⟨session⟩

  response←session ReadResponse d
  EasyCleanup session
  response
}
