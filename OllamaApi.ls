
  do ->

    { create-url: url } = dependency 'web.URL'
    { http } = dependency 'web.Client'
    { mime-types: { json } } = dependency 'web.MimeTypes'
    { serialize } = dependency 'os.win32.com.JSON'

    default-ollama-port = 11434

    ollama-url = url 'localhost', default-ollama-port |> -> "#it/api"

    parse = -> eval "(#it)"

    is-ollama-server-available = (port = default-ollama-port) ->

    ollama-api = (method, endpoint, options) -> http method, "#ollama-url#endpoint", options

    get-models = -> ollama-api 'get', '/tags' |> (.content) |> parse |> (.models)

    generate = (model, prompt) ->

      { content: json } = ollama-api 'post', '/generate', content-type: json, accept: json, content: serialize { model, prompt, stream: no }

      deserialize json .response

    {
      is-ollama-server-available,
      get-models,
      generate
    }

