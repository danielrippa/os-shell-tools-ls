
  do ->

    { create-process } = dependency 'os.shell.Process'
    { string-as-lines } = dependency 'unsafe.Text'
    { trimmed-string } = dependency 'unsafe.Whitespace'

    certutil = (options) -> create-process 'certutil', options

    sha256-options = (filepath) -> "-hashfile #filepath SHA256" |> (/ ' ')

    just-second-line = (lines) -> lines.1

    sha256-from-filepath = (filepath) ->

      { stdout: output, success, error, errorlevel } = certutil sha256-options filepath ; throw error if (errorlevel isnt 0) or not success

      output |> string-as-lines |> just-second-line |> trimmed-string

    {
      sha256-from-filepath
    }