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
end
