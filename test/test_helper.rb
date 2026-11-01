ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Renseigne toutes les notes attendues d'un sondé, pour que sa soumission soit acceptée.
    def answer_fully(respondent)
      rated = respondent.campaign.questions.select(&:rating?)
      respondent.subjects_to_rate.each do |subject|
        rated.each { |question| respondent.answers.create!(subject: subject, question: question, rating: 4) }
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
