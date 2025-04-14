⟨
  # Simple API
  Get,Post,
  # Advanced API
  OpenSession,ResetSession,CloseSession,  # session management
  SetURL,SetHeaders,SetVerbose,SetTimeout,SetTimeoutms,SetData,  # request parameters
  Perform,  # perform request
⟩⇐

⟨
  easyInit,
  easyCleanup,
  easyReset,
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

# Simple GET request, with optional headers as left argument
Get←{
𝕊 url: ⟨⟩ 𝕊 url ;
headers 𝕊 url:
  session←OpenSession @
  r←Perform headers SetHeaders url SetURL session
  CloseSession session
  r
}

# Simple POST request, with optional headers as left argument
Post←{
𝕊 url‿data: ⟨⟩ 𝕊 url‿data ;
headers 𝕊 url‿data:
  session←OpenSession @
  r←Perform data SetData headers SetHeaders url SetURL session
  CloseSession session
  r
}

# Raise an error if the return code 𝕩 is not 0, with custom message 𝕨
Check←{
  msg←"Curl: "∾𝕨∾" ("∾(•Fmt 𝕩)∾")"
  msg ! 𝕩=0
}

# Create a libcurl session, with default values for user-agent and redirects
OpenSession←{𝕊𝕩:
  sessionPtr←EasyInit⟨⟩
  "setting user agent"Check EasySetoptStr⟨sessionPtr,curlOptions.useragent,"curl/bqn"∾@⟩
  "setting redirect option"Check EasySetoptLong⟨sessionPtr,curlOptions.followlocation,1⟩
  slist←SlistAppend⟨8↑0,""⟩
  "creating slist" ! slist≢8↑0
  {sessionPtr⇐sessionPtr,headersSlist⇐slist}
}

# Reset a libcurl session to default parameters, as if just created by
# OpenSession, but preserving open connections and caches
ResetSession←{𝕊 session:
  SlistFreeAll session.headersSlist
  EasyReset session.sessionPtr
  "setting user agent"Check EasySetoptStr⟨session.sessionPtr,curlOptions.useragent,"curl/bqn"∾@⟩
  "setting redirect option"Check EasySetoptLong⟨session.sessionPtr,curlOptions.followlocation,1⟩
  slist←SlistAppend⟨8↑0,""⟩
  "creating slist" ! slist≢8↑0
  {sessionPtr⇐session.sessionPtr,headersSlist⇐slist}
}

# Close a libcurl session, freeing memory
CloseSession←{𝕊 session:
  SlistFreeAll session.headersSlist
  EasyCleanup session.sessionPtr
  @
}

# Set URL for the next request
SetURL←{url 𝕊 session:
  "setting URL"Check EasySetoptStr⟨session.sessionPtr,curlOptions.url,url∾@⟩
  session
}

# Set headers for the next request, as a list of strings
SetHeaders←{headers 𝕊 session:
  slist←session.headersSlist{SlistAppend⟨𝕩,𝕨∾@⟩}´headers
  "setting headers"Check rheaders←EasySetoptPtr⟨session.sessionPtr,curlOptions.httpHeader,slist⟩
  session
}

# Set the next request as verbose (logging to standard output)
SetVerbose←{𝕊 session:
  "setting verbose option"Check EasySetoptLong⟨session.sessionPtr,curlOptions.verbose,1⟩
  session
}

# Set timeout in seconds for the next request
SetTimeout←{timeout 𝕊 session:
  "setting timeout"Check EasySetoptLong⟨session.sessionPtr,curlOptions.timeout,timeout⟩
  session
}

# Set timeout in milliseconds for the next request
SetTimeoutms←{timeoutms 𝕊 session:
  "setting timeout (ms)"Check EasySetoptLong⟨session.sessionPtr,curlOptions.timeoutms,timeoutms⟩
  session
}

# Use a POST method and set data to post
SetData←{data 𝕊 session:
  "setting up POST request"Check EasySetoptLong⟨session.sessionPtr,curlOptions.post,1⟩
  "setting POST data size"Check EasySetoptLong⟨session.sessionPtr,curlOptions.postfieldsize,≠data⟩
  "copying POST data"Check EasySetoptStr⟨session.sessionPtr,curlOptions.copypostfields,data⟩
  session
}

# Perform a request and get response in a namespace
Perform←{𝕊 session:
  id←RandID 32
  filename←"/tmp/bqncurl."∾id
  filePtr←Fopen⟨filename∾@,"w+"⟩
  headerFilename←"/tmp/bqncurl.header."∾id
  headerFilePtr←Fopen⟨headerFilename∾@,"w+"⟩
  "setting response file target"Check EasySetoptPtr⟨session.sessionPtr,curlOptions.writedata,filePtr⟩
  "setting header file target"Check EasySetoptPtr⟨session.sessionPtr,curlOptions.headerdata,headerFilePtr⟩

  "performing request"Check EasyPerform⟨session.sessionPtr⟩

  rcode‿⟨code⟩←EasyGetinfoLong⟨session.sessionPtr,curlInfo.responseCode,⟨0⟩⟩
  "retrieving response code"Check rcode
  rredirectcount‿⟨redirectCount⟩←EasyGetinfoLong⟨session.sessionPtr,curlInfo.redirectCount,⟨0⟩⟩
  "retrieving redirect count"Check rredirectcount
  rtime‿⟨time⟩←EasyGetinfoDouble⟨session.sessionPtr,curlInfo.totalTime,⟨0.0⟩⟩
  "retrieving request time"Check rtime

  Fclose filePtr
  Fclose headerFilePtr

  content←•file.Bytes filename
  responseHeaders←•file.Chars headerFilename

  •file.Remove filename
  •file.Remove headerFilename

  {
    code⇐code,
    headers⇐responseHeaders,
    content⇐content,
    time⇐time,
    redirectCount⇐redirectCount,
  }
}
