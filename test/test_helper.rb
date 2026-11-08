ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "support/fake_telegram"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # L'API Telegram de chaque test : aucune requête ne part vers le vrai service.
    attr_reader :fake_telegram

    setup do
      @fake_telegram = FakeTelegram.new
      Telegram::BotClient.transport = @fake_telegram
    end

    # Un token au format de ceux que donne BotFather, qui se termine par « 1234 ».
    TELEGRAM_TOKEN = "123456789:AAHfakeTokenForTestsOnly_abcdefgh1234".freeze

    def configure_telegram(manager, enabled: true, chat_id: "42")
      manager.update!(telegram_bot_token: TELEGRAM_TOKEN, telegram_chat_id: chat_id, telegram_enabled: enabled)
      manager
    end

    # Renseigne toutes les notes et tous les commentaires attendus d'un sondé, pour que sa soumission soit acceptée.
    def answer_fully(respondent)
      respondent.subjects_to_rate.each do |subject|
        respondent.campaign.questions.each do |question|
          respondent.answers.create!(subject: subject, question: question,
                                     rating: (4 if question.rating?), body: ("Un commentaire" if question.comment?))
        end
      end
      respondent
    end

    # Fait soumettre un sondé par le chemin réel, ce qui peut clôturer sa campagne.
    def submit_fully(respondent)
      assert answer_fully(respondent).submit!, "la soumission de #{respondent.name} a été refusée"
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
