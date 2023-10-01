⟨Get⟩⇐

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
  options,
  info
⟩←•Import"ffi.bqn"
⟨RandID⟩←•Import"utils.bqn"

Get←{
𝕊 url: ⟨⟩ 𝕊 url ;
headers 𝕊 url:
  id←RandID 32
  filename←"/tmp/bqncurl."∾id
  filePtr←Fopen⟨filename∾@,"w+"⟩
  headerFilename←"/tmp/bqncurl.header."∾id
  headerFilePtr←Fopen⟨headerFilename∾@,"w+"⟩

  session←EasyInit⟨⟩

  ruseragent←EasySetoptStr⟨session,options.useragent,"curl/bqn"∾@⟩
  ("Error setting user agent: "∾•Fmt ruseragent)!ruseragent=0
  rurl←EasySetoptStr⟨session,options.url,url∾@⟩
  ("Error setting URL: "∾•Fmt rurl)!rurl=0
  rfile←EasySetoptPtr⟨session,options.writedata,filePtr⟩
  ("Error setting file target: "∾•Fmt rfile)!rfile=0
  rheaderfile←EasySetoptPtr⟨session,options.headerdata,headerFilePtr⟩
  ("Error setting header file target: "∾•Fmt rheaderfile)!rheaderfile=0
  rredirect←EasySetoptLong⟨session,options.followlocation,1⟩
  ("Error setting redirect option: "∾•Fmt rredirect)!rredirect=0
  # EasySetoptLong⟨session,options.header,1⟩
  # EasySetoptLong⟨session,options.verbose,1⟩

  slist←(8↑0){SlistAppend⟨𝕩,𝕨∾@⟩}´headers
  rheaders←EasySetoptPtr⟨session,options.httpHeader,slist⟩
  ("Error setting headers: "∾•Fmt rheaders)!rheaders=0

  rperform←EasyPerform⟨session⟩
  ("Error performing request: "∾•Fmt rperform)!rperform=0

  SlistFreeAll slist

  rcode‿⟨code⟩←EasyGetinfoLong⟨session,info.responseCode,⟨0⟩⟩
  ("Error retrieving response code: "∾•Fmt rcode)!rcode=0
  # ("Request failed with status code "∾•Fmt code)!2=⌊code÷100
  rtime‿⟨time⟩←EasyGetinfoDouble⟨session,info.totalTime,⟨0.0⟩⟩
  ("Error retrieving request time: "∾•Fmt rtime)!rtime=0

  Fclose filePtr
  Fclose headerFilePtr
  content←•file.Bytes filename
  responseHeaders←•file.Chars headerFilename

  •file.Remove filename
  EasyCleanup session
  {
    code⇐code,
    time⇐time,
    headers⇐responseHeaders,
    content⇐content,
  }
}