# Les trois appels de l'API Bot Telegram dont Fideback a besoin, par le bot qu'un manager a créé avec BotFather.
# Fideback ne fait qu'envoyer : ni webhook, ni interrogation automatique des messages.
#
# Le token fait partie de l'URL de l'API : il n'apparaît jamais dans une erreur ni dans le journal.
require "net/http"

module Telegram
  class BotClient
    TIMEOUT = 5

    # Un refus de Telegram (status = code HTTP) ou une panne réseau (status = nil).
    class Error < StandardError
      attr_reader :api_method, :status, :description, :retry_after

      def initialize(api_method:, status:, description:, retry_after: nil)
        @api_method = api_method
        @status = status
        @description = description
        @retry_after = retry_after
        super("Telegram #{api_method} : #{status || 'réseau'} #{description}".strip)
      end

      # Panne réseau, erreur serveur ou débit limité : une nouvelle tentative a ses chances.
      def temporary?
        status.nil? || status >= 500 || status == 429
      end

      def unauthorized? = status == 401
      def webhook_conflict? = status == 409
    end

    # Envoie une requête JSON et rend [code HTTP, corps]. Remplacé dans les tests.
    class NetHttpTransport
      NETWORK_ERRORS = [ Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError, Net::HTTPBadResponse, IOError ].freeze

      def post(uri, json)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                   open_timeout: TIMEOUT, read_timeout: TIMEOUT, write_timeout: TIMEOUT) do |http|
          http.post(uri.path, json, "Content-Type" => "application/json")
        end
        [ response.code.to_i, response.body.to_s ]
      end
    end

    class_attribute :transport, default: NetHttpTransport.new

    # La conversation privée la plus récente parmi les messages rendus par getUpdates, ou nil. Les groupes et les
    # canaux sont ignorés : les notifications vont dans la conversation du manager avec son bot.
    def self.latest_private_chat(updates)
      message = Array(updates)
        .filter_map { |update| update["message"] }
        .select { |candidate| candidate.dig("chat", "type") == "private" }
        .max_by { |candidate| [ candidate["date"].to_i, candidate["message_id"].to_i ] }
      message&.fetch("chat")
    end

    def initialize(token)
      @token = token
    end

    # Le bot lui-même ; sert à vérifier le token et à connaître le nom d'utilisateur du bot.
    def get_me
      call("getMe")
    end

    # Les messages reçus ces dernières 24 h. Sans offset : rien n'est acquitté, un autre consommateur des messages du
    # bot les voit toujours. Sans allowed_updates : ce réglage persisterait pour ce consommateur.
    def get_updates
      call("getUpdates")
    end

    def send_message(chat_id, text)
      call("sendMessage", chat_id: chat_id, text: text, parse_mode: "HTML", link_preview_options: { is_disabled: true })
    end

    # Sans le token.
    def inspect
      "#<#{self.class.name}>"
    end

    private

    def call(api_method, params = {})
      uri = URI("https://api.telegram.org/bot#{@token}/#{api_method}")
      status, body = transport.post(uri, params.to_json)
      payload = parse(body)
      return payload["result"] if status == 200 && payload["ok"]

      raise Error.new(api_method: api_method, status: status, description: payload["description"],
                      retry_after: payload.dig("parameters", "retry_after"))
    rescue *NetHttpTransport::NETWORK_ERRORS => error
      raise Error.new(api_method: api_method, status: nil, description: error.class.name)
    end

    def parse(body)
      parsed = JSON.parse(body)
      parsed.is_a?(Hash) ? parsed : {}
    rescue JSON::ParserError
      {}
    end
  end
end
