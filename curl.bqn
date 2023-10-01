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

PrepareRequest←{session 𝕊 url‿headers:
  id←RandID 32
  filename←"/tmp/bqncurl."∾id
  filePtr←Fopen⟨filename∾@,"w+"⟩
  headerFilename←"/tmp/bqncurl.header."∾id
  headerFilePtr←Fopen⟨headerFilename∾@,"w+"⟩

  ruseragent←EasySetoptStr⟨session,curlOptions.useragent,"curl/bqn"∾@⟩
  ("Error setting user agent: "∾•Fmt ruseragent)!ruseragent=0
  rurl←EasySetoptStr⟨session,curlOptions.url,url∾@⟩
  ("Error setting URL: "∾•Fmt rurl)!rurl=0
  rfile←EasySetoptPtr⟨session,curlOptions.writedata,filePtr⟩
  ("Error setting file target: "∾•Fmt rfile)!rfile=0
  rheaderfile←EasySetoptPtr⟨session,curlOptions.headerdata,headerFilePtr⟩
  ("Error setting header file target: "∾•Fmt rheaderfile)!rheaderfile=0
  rredirect←EasySetoptLong⟨session,curlOptions.followlocation,1⟩
  ("Error setting redirect option: "∾•Fmt rredirect)!rredirect=0
  # EasySetoptLong⟨session,curlOptions.header,1⟩
  # EasySetoptLong⟨session,curlOptions.verbose,1⟩

  slist←(8↑0){SlistAppend⟨𝕩,𝕨∾@⟩}´headers
  rheaders←EasySetoptPtr⟨session,curlOptions.httpHeader,slist⟩
  ("Error setting headers: "∾•Fmt rheaders)!rheaders=0

  slist‿filename‿filePtr‿headerFilename‿headerFilePtr
}

ReadResponse←{session 𝕊 slist‿filename‿filePtr‿headerFilename‿headerFilePtr:
  SlistFreeAll slist

  rcode‿⟨code⟩←EasyGetinfoLong⟨session,curlInfo.responseCode,⟨0⟩⟩
  ("Error retrieving response code: "∾•Fmt rcode)!rcode=0
  rtime‿⟨time⟩←EasyGetinfoDouble⟨session,curlInfo.totalTime,⟨0.0⟩⟩
  ("Error retrieving request time: "∾•Fmt rtime)!rtime=0

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

  rperform←EasyPerform⟨session⟩
  ("Error performing request: "∾•Fmt rperform)!rperform=0

  response←session ReadResponse d
  EasyCleanup session
  response
}

Post←{
𝕊 url‿data: ⟨⟩ 𝕊 url‿data ;
headers 𝕊 url‿data:
  session←EasyInit⟨⟩
  d←session PrepareRequest url‿headers
  rpost←EasySetoptLong⟨session,curlOptions.post,1⟩
  ("Error setting up POST request: "∾•Fmt rpost)!rpost=0
  rpostfields←EasySetoptStr⟨session,curlOptions.postfields,data⟩
  ("Error setting POST data: "∾•Fmt rpostfields)!rpostfields=0
  rpostfieldsize←EasySetoptLong⟨session,curlOptions.postfieldsize,≠data⟩
  ("Error setting POST data size: "∾•Fmt rpostfieldsize)!rpostfieldsize=0

  rperform←EasyPerform⟨session⟩
  ("Error performing request: "∾•Fmt rperform)!rperform=0

  response←session ReadResponse d
  EasyCleanup session
  response
}
