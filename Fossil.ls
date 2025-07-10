
  do ->

    { crate-process } = dependency 'os.shell.Process'
    { get-temporary-filepath } = dependency 'os.filesysten.TemporaryFile'
    { filepath-as-base64-string } = dependency 'os.filesystem.BinaryFile'

    delta-error = (filepath) -> new Error "Unable to create delta. Input file '#filepath' not found."

    file-found = (filepath) -> throw delta-error filepath unless file-exists filepath

    files-exist = -> each-array-item it, file-found

    fossil = (options) -> get-temporary-filepath! => run-process "fossil", options ++ [ .. ] ; return ..

    as-base64 = (filepath) -> base64 = filepath-as-base64-string ; delete-file filepath ; base64

    create-delta = -> fossil <[ delta create ]> ++ it

    base64-delta = (filepath1, filepath2) -> [ filepath1, filepath2 ] |> files-exist |> create-delta |> as-base64

    {
      base64-delta
    }