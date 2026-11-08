# Remplace l'API Bot Telegram dans les tests : enregistre les requêtes et rend des réponses préparées. Installée pour
# chaque test (voir test_helper), si bien qu'aucun test n'appelle le vrai service.
class FakeTelegram
  Request = Struct.new(:token, :api_method, :params, keyword_init: true)

  BOT = { "id" => 123456789, "is_bot" => true, "first_name" => "Fideback", "username" => "fideback_test_bot" }.freeze

  attr_reader :requests

  def initialize
    @requests = []
    @responses = Hash.new { |hash, key| hash[key] = [] }
  end

  # Prépare la prochaine réponse à api_method : un résultat, un refus (status, description) ou une panne (raise).
  def respond(api_method, result: nil, status: 200, description: nil, retry_after: nil, raise: nil)
    @responses[api_method] << { result: result, status: status, description: description, retry_after: retry_after, raise: raise }
    self
  end

  def post(uri, json)
    token, api_method = uri.path.match(%r{\A/bot([^/]+)/(\w+)\z}).captures
    requests << Request.new(token: token, api_method: api_method, params: JSON.parse(json))

    response = @responses[api_method].shift || { result: default_result(api_method), status: 200 }
    raise response[:raise] if response[:raise]

    if response[:status] == 200
      [ 200, { ok: true, result: response[:result] }.to_json ]
    else
      body = { ok: false, error_code: response[:status], description: response[:description] }
      body[:parameters] = { retry_after: response[:retry_after] } if response[:retry_after]
      [ response[:status], body.to_json ]
    end
  end

  def requests_to(api_method)
    requests.select { |request| request.api_method == api_method }
  end

  def sent_messages
    requests_to("sendMessage").map(&:params)
  end

  # Un message privé tel que getUpdates le rend.
  def self.private_update(update_id:, chat_id:, first_name:, username: nil, date: Time.current.to_i)
    chat = { "id" => chat_id, "type" => "private", "first_name" => first_name, "username" => username }.compact
    { "update_id" => update_id, "message" => { "message_id" => update_id, "date" => date, "chat" => chat, "text" => "/start" } }
  end

  def self.group_update(update_id:, chat_id:, title:, date: Time.current.to_i)
    { "update_id" => update_id, "message" => { "message_id" => update_id, "date" => date,
                                               "chat" => { "id" => chat_id, "type" => "group", "title" => title }, "text" => "salut" } }
  end

  private

  def default_result(api_method)
    case api_method
    when "getMe" then BOT
    when "getUpdates" then []
    when "sendMessage" then { "message_id" => 1 }
    else true
    end
  end
end
