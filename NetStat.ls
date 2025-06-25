
  do ->

    { exec-tool } = dependency 'os.shell.Tool'
    { keep-array-items, map-array-items } = dependency 'unsafe.Array'
    { string-contains, last-index-of, string-interval, string-as-words } = dependency 'unsafe.String'
    { lower-case } = dependency 'unsafe.StringCase'
    { type } = dependency 'reflection.Type'
    { value-as-string } = dependency 'reflection.Value'

    is-connection-line = -> it `string-contains` ':'

    endpoint-from-string = (string) ->

      [ address, port ] = if string `string-contains` ':'

        colon-index = string `last-index-of` ':'

        * string `string-interval` [ 0, colon-index ]
          string `string-interval` [ colon-index + 1 ]

      else

        [ string, '' ]

      { address, port }

    array-as-connection = ([ protocol, local, remote, status = '' ]) ->

      local-endpoint = endpoint-from-string local
      remote-endpoint = endpoint-from-string remote

      [ protocol-name, state ] = [ (lower-case string) for string in [ protocol, status ] ]

      { protocol-name, local-endpoint, remote-endpoint, state }

    connection-from-line = (line) -> line |> string-as-words |> array-as-connection

    lines-as-connections = (lines) ->

      lines

        |> keep-array-items _, is-connection-line
        |> map-array-items _ , connection-from-line

    netstat = (options) -> exec-tool 'netstat', options |> (.output-lines)

    get-active-connections = -> netstat <[ -an ]> |> lines-as-connections

    query-connections = (query) -> type '< Function >' query ; keep-array-items get-active-connections!, query

    {
      netstat,
      get-active-connections,
      query-connections
    }