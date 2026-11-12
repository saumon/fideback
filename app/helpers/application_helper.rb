module ApplicationHelper
  VOICE_COUNT = 6

  # Couleur stable d'une personne dans sa campagne : son rang parmi les personnes du même type,
  # pour qu'un sondé garde la même couleur sur le suivi et sur chaque synthèse.
  def voice_class(person)
    @voice_ranks ||= {}
    ranks = @voice_ranks[[ person.class, person.campaign_id ]] ||= person.class.where(campaign_id: person.campaign_id).order(:id).ids
    "voice-#{ranks.index(person.id).to_i % VOICE_COUNT}"
  end

  def initials(name)
    name.to_s.split.first(2).map { |part| part[0] }.join.upcase
  end

  # Pastille d'initiales, décorative : le nom est toujours écrit à côté.
  def avatar(person, css_class: nil, **options)
    tag.span(initials(person.name), class: [ "avatar", voice_class(person), css_class ], aria: { hidden: true }, **options)
  end

  # Section de la navigation principale à laquelle appartient l'écran ouvert, d'après son contrôleur
  # plutôt que son adresse : le détail, l'édition et les synthèses d'une campagne sont dans « Mes campagnes ».
  # Les écrans sans entrée de menu (accueil, page introuvable, espace d'un sondé) n'en ont pas.
  def current_nav_section
    case controller_path
    when "campaigns", "summaries", "respondents" then :campaigns
    when "teams" then :team
    when "question_templates" then :templates
    when %r{\Aadmin/} then :admin
    when "managers/registrations" then :account
    when "managers/sessions" then :sign_in
    end
  end

  # Lien de la navigation principale ; l'entrée de la section courante est signalée comme page courante.
  def nav_link(label, path, section)
    link_to label, path, data: { label: label }, aria: { current: ("page" if section == current_nav_section) }
  end
end
