
  do ->

    { exec-tool } = dependency 'os.shell.Tool'
    { keep-array-items, map-array-items } = dependency 'unsafe.Array'
    { string-contains, last-index-of, string-interval, string-as-words } = dependency 'unsafe.String'
    { lower-case } = dependency 'unsafe.StringCase'
    { type } = dependency 'reflection.Type'
    { value-as-string } = dependency 'reflection.Value'
    { system-directory } = dependency 'os.win32.wmi.OS'
    { build-path } = dependency 'os.filesystem.Path'
    { string-as-lines } = dependency 'unsafe.Text'
    { create-process } = dependency 'os.shell.Process'

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

    netstat-executable = -> build-path [ system-directory!, 'netstat' ]

    netstat = (options, working-folder) ->

      create-process netstat-executable!, options, working-folder |> (.stdout) |> string-as-lines

    get-active-connections = (working-folder) -> netstat <[ -an ]>, working-folder |> lines-as-connections

    query-connections = (query, working-folder) -> type '< Function >' query ; keep-array-items (get-active-connections working-folder), query

    {
      netstat,
      get-active-connections,
      query-connections
    }