
  do ->

    { run-process, create-process, process-error } = dependency 'os.shell.Process'
    { get-temporary-filepath: temporary-filepath } = dependency 'os.filesystem.TemporaryFile'
    { write-textfile, consume-textfile } = dependency 'os.filesystem.TextFile'
    { string-as-lines, lines-as-string: lines-as-string-with-lf } = dependency 'unsafe.Text'
    { drop-first-array-items: drop-first, drop-first-array-items: drop-last } = dependency 'unsafe.Array'
    { circumfix } = dependency 'unsafe.Circumfix'
    { repeat-string } = dependency 'unsafe.String'
    { repeat-item } = dependency 'unsafe.Array'

    process = (output-required) -> if output-required then create-process else run-process

    certutil = (options, output-required = no) -> (process output-required), 'certutil', options

    quoted = -> map it, double-quotes

    xcode = -> "#{ if it then 'en' else 'de' }code"

    xcode-option = -> "-#{ xcode it }"

    base64-xcoding-options = (filepaths, encode = yes) -> filepaths |> quoted |> -> [ xcode-option encode ] ++ options

    base64-xcode = (filepaths, encode = yes) -> certutil base64-xcoding-options filepaths, encode

    lines-as-string = -> lines-as-string-with-lf it, ''

    binary-filepath-to-base64-string = (binary-filepath) ->

      base64-filepath = temporary-filepath! ; base64-xcode [ binary-filepath, base64-filepath ], yes

      consume-textfile base64-filepath |> string-as-lines |> drop-first |> drop-last |> lines-as-string

    certificate = (starting) -> if starting then 'BEGIN' else 'END'

    pem-delimiter = (starting = yes) -> circumfix (certificate starting), [ repeat-string '-', 5 ]

    as-pem-content-lines = -> [ (pem-delimiter yes), it, (pem-delimiter no) ]

    pem-content-filepath-to-binary-filepath = (pem-content-filepath) ->

      base64-xcode [ pem-content-filepath, binary-filepath ], no

      binary-filepath

    base64-string-to-binary-filepath = (base64-string) ->

      base64-filepath = temporary-filepath!

      base64-string |> as-pem-content-lines |> lines-as-string |> write-textfile base64-filepath, _

      pem-content-filepath-to-binary-filepath base64-filepath

    base64-text-content-filepath-to-binary-filepath = (base64-text-content-filepath) ->

      base64-text-content-filepath
        |> read-textfile
        |> string-as-lines
        |> lines-as-string
        |> base64-string-to-binary-filepath

    {
      binary-filepath-to-base64-string,
      base64-string-to-binary-filepath, base64-filepath-to-binary-filepath,
      base64-text-content-filepath-to-binary-filepath
    }