# « Détecter » : retrouve, à la demande du manager, la conversation privée qu'il a ouverte avec son bot. Un seul
# getUpdates, sans acquitter les messages ; rien n'est enregistré, et le webhook éventuel du bot n'est jamais touché.
module Telegram
  class ChatDetection
    Result = Struct.new(:chat_id, :message, keyword_init: true) do
      def found? = chat_id.present?
    end

    def self.call(token) = new(token).call

    def initialize(token)
      @token = token
    end

    def call
      return Result.new(message: "Saisissez d'abord le token de votre bot.") if @token.blank?

      client = Telegram::BotClient.new(@token)
      bot = client.get_me
      chat = Telegram::BotClient.latest_private_chat(client.get_updates)
      return Result.new(message: no_message_text(bot)) unless chat

      Result.new(chat_id: chat["id"].to_s,
                 message: "Conversation trouvée : #{person(chat)}. Vérifiez que c'est bien vous, puis enregistrez.")
    rescue Telegram::BotClient::Error => error
      Result.new(message: self.class.error_message(error))
    end

    # Le message en français d'un refus de Telegram, pour la détection comme pour le message de test.
    def self.error_message(error)
      if error.temporary?
        "Telegram est injoignable pour le moment, réessayez dans un instant."
      elsif error.unauthorized? || error.status == 404
        "Token refusé par Telegram : vérifiez-le auprès de BotFather."
      elsif error.webhook_conflict?
        "Ce bot reçoit déjà ses messages par un webhook (n8n, par exemple) : Fideback ne peut pas les lire. " \
          "Saisissez l'identifiant de conversation à la main, @userinfobot vous le donne."
      elsif error.status == 403
        "Telegram refuse l'envoi : vous avez bloqué ce bot ou ne lui avez jamais écrit. Envoyez-lui /start, puis réessayez."
      elsif error.description.to_s.include?("chat not found")
        "Conversation introuvable : vérifiez l'identifiant et envoyez /start à votre bot."
      else
        "Telegram a refusé la demande (#{error.description.presence || error.status})."
      end
    end

    private

    def no_message_text(bot)
      name = bot["username"].present? ? "@#{bot['username']}" : "votre bot"
      "Aucun message récent : écrivez /start à #{name} dans Telegram, puis cliquez de nouveau sur « Détecter »."
    end

    def person(chat)
      name = [ chat["first_name"], chat["last_name"] ].compact_blank.join(" ")
      chat["username"].present? ? "#{name} (@#{chat['username']})" : name
    end
  end
end
