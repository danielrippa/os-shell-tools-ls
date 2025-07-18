
  do ->

    { create-process } = dependency 'os.shell.Process'
    { stderr } = dependency 'os.shell.IO'
    { type } = dependency 'reflection.Type'
    { value-as-string } = dependency 'reflection.Value'
    { lf } = dependency 'unsafe.Constants'

    yq = (options) -> create-process 'yq', options

    yaml-filepath-as-json = (filepath) ->

      { errorlevel, stdout: json, stderr: error } = yq <[ --exit-status --no-colors --input-format yaml --output-format json ]> ++ type '< String >' filepath

      stderr lf, error if error isnt void

      if errorlevel is 0 then json else null

    {
      yaml-filepath-as-json
    }