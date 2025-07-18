
  do ->

    { create-process } = dependency 'os.shell.Process'
    { string-as-lines } = dependency 'unsafe.Text'
    { keep-array-items } = dependency 'unsafe.Array'
    { trimmed-string } = dependency 'unsafe.Whitespace'

    gnu-file = (options) -> create-process 'file', options

    just-first-line = (lines) -> lines.0

    just-mime-type = (line) -> line |> (/ ';') |> (.1) |> trimmed-string

    major-and-minor-type = (mime-type) -> [ major, minor ] = mime-type / '/' ; { major, minor }

    is-textfile = (filepath) ->

      { success, error, stdout } = gnu-file <[ --mime-type ]> ++ filepath ; throw error unless success

      stdout |> string-as-lines |> just-first-line |> just-mime-type |> major-and-minor-type |> (.major) |> (is 'text')

    {
      gnu-file,
      is-textfile
    }