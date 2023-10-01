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
⟩⇐

⟨Hex2Num⟩←•Import"utils.bqn"

⟨libcurlPath⟩←•Import"config.bqn"

CurlFFI←libcurlPath⊸•FFI

curlPtr←"*:i8"
curlOption←"i32"
curlCode←"i32"

easyInit←CurlFFI curlPtr‿"curl_easy_init"
easyCleanup←CurlFFI ""‿"curl_easy_cleanup"‿(">"∾curlPtr)

easySetoptStr←CurlFFI curlCode‿"curl_easy_setopt"‿curlPtr‿curlOption‿"*u8:c8"
easySetoptPtr←CurlFFI curlCode‿"curl_easy_setopt"‿curlPtr‿curlOption‿"*:i8"
easySetoptLong←CurlFFI curlCode‿"curl_easy_setopt"‿curlPtr‿curlOption‿"i32"

easyPerform←CurlFFI curlCode‿"curl_easy_perform"‿curlPtr

easyGetinfoStr←CurlFFI curlCode‿"curl_easy_getinfo"‿curlPtr‿curlOption‿"&u8:c8"
easyGetinfoLong←CurlFFI curlCode‿"curl_easy_getinfo"‿curlPtr‿curlOption‿"&i32"
easyGetinfoDouble←CurlFFI curlCode‿"curl_easy_getinfo"‿curlPtr‿curlOption‿"&f64"

slistAppend←CurlFFI "*:i8"‿"curl_slist_append"‿"*:i8"‿"*u8:c8"
slistFreeAll←CurlFFI ""‿"curl_slist_free_all"‿">*:i8"

fopen←@•FFI "*:i8"‿"fopen"‿"*u8:c8"‿"*u8:c8"
fclose←@•FFI ""‿"fclose"‿">*:i8"

options←{
  strOffset←10000
  slistOffset←10000
  ptrOffset←10000

  # boolean options
  verbose⇐41
  header⇐42
  noprogress⇐43
  post⇐47
  followlocation⇐52
  httpget⇐80

  # long integer options
  timeout⇐78  # timeout in seconds
  timeoutms⇐155  # timeout in milliseconds

  # string options, null-terminated
  url⇐strOffset+2
  userpwd⇐strOffset+5  # user:password
  useragent⇐strOffset+18

  # pointer options
  writedata⇐ptrOffset+1
  headerdata⇐ptrOffset+29

  # linked list options
  httpHeader⇐slistOffset+23
}


info←{
  strOffset←Hex2Num"100000"
  longOffset←Hex2Num"200000"
  doubleOffset←Hex2Num"300000"
  slistOffset←Hex2Num"400000"
  ptrOffset←Hex2Num"400000"

  # long integer info
  responseCode⇐longOffset+2
  headerSize⇐longOffset+11  # in bytes
  requestSize⇐longOffset+12  # in bytes
  redirectCount⇐longOffset+20
  httpVersion⇐longOffset+46

  # double info
  totalTime⇐doubleOffset+3  # in seconds
  nameLookupTime⇐doubleOffset+4  # in seconds
  connectTime⇐doubleOffset+5  # in seconds

  # string info
  effectiveUrl⇐strOffset+1
  contentType⇐strOffset+18
  primaryIP⇐strOffset+32
  httpScheme⇐strOffset+49
  effectiveMethod⇐strOffset+58
}
